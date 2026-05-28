import 'dart:convert';

import 'package:konnectrent/domain/entities/amortization_row.dart';
import 'package:konnectrent/domain/entities/calculation_snapshot.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';
import 'package:konnectrent/domain/repositories/history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists up to 10 calculation snapshots in SharedPreferences as JSON.
class HistoryRepositoryImpl implements HistoryRepository {
  static const _key = 'calc_history';
  static const _maxItems = 10;

  @override
  Future<void> save(RentCalcResult result, String label) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final json = jsonEncode(_resultToMap(result, id, label));
    raw.insert(0, json);
    if (raw.length > _maxItems) raw.removeLast();
    await prefs.setStringList(_key, raw);
  }

  @override
  Future<List<CalculationSnapshot>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final snapshots = <CalculationSnapshot>[];
    for (final item in raw) {
      try {
        snapshots.add(_mapToSnapshot(jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {
        // Skip malformed entries silently
      }
    }
    return snapshots;
  }

  @override
  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((item) {
      try {
        return (jsonDecode(item) as Map<String, dynamic>)['id'] == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_key, raw);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ── Serialisation helpers ─────────────────────────────────────────────────

  static Map<String, dynamic> _resultToMap(
    RentCalcResult r,
    String id,
    String label,
  ) =>
      {
        'id': id,
        'label': label,
        'savedAt': DateTime.now().toIso8601String(),
        'monthlyEmi': r.monthlyEmi,
        'tenYearRentTotal': r.tenYearRentTotal,
        'tenYearBuyTotal': r.tenYearBuyTotal,
        'breakEvenYear': r.breakEvenYear,
        'verdict': r.verdict.name,
        'rentAdvantage': r.rentAdvantage,
        'affordabilityRatio': r.affordabilityRatio,
        'taxBenefitTotal': r.taxBenefitTotal,
        'effectiveBuyTotal': r.effectiveBuyTotal,
        'sipCorpus': r.sipCorpus,
        'prepaymentTenureYears': r.prepaymentTenureYears,
        'prepaymentInterestSaved': r.prepaymentInterestSaved,
        'cumulativeRent': r.cumulativeRent,
        'cumulativeBuy': r.cumulativeBuy,
        'input': _inputToMap(r.input),
        'schedule': r.schedule
            .map((row) => {
                  'year': row.year,
                  'principalPaid': row.principalPaid,
                  'interestPaid': row.interestPaid,
                  'remainingBalance': row.remainingBalance,
                },)
            .toList(),
      };

  static Map<String, dynamic> _inputToMap(RentCalcInput i) => {
        'monthlyRent': i.monthlyRent,
        'annualRentIncrease': i.annualRentIncrease,
        'propertyPrice': i.propertyPrice,
        'downPayment': i.downPayment,
        'annualInterestRate': i.annualInterestRate,
        'loanTenureYears': i.loanTenureYears,
        'annualAppreciation': i.annualAppreciation,
        'annualMaintenance': i.annualMaintenance,
        'opportunityCostRate': i.opportunityCostRate,
        'stampDutyRate': i.stampDutyRate,
        'registrationRate': i.registrationRate,
        'monthlyIncome': i.monthlyIncome,
        'taxSlab': i.taxSlab,
        'includeTaxBenefit': i.includeTaxBenefit,
        'extraYearlyPayment': i.extraYearlyPayment,
      };

  static CalculationSnapshot _mapToSnapshot(Map<String, dynamic> m) {
    final inputMap = m['input'] as Map<String, dynamic>;
    final input = RentCalcInput(
      monthlyRent: (inputMap['monthlyRent'] as num).toDouble(),
      annualRentIncrease: (inputMap['annualRentIncrease'] as num).toDouble(),
      propertyPrice: (inputMap['propertyPrice'] as num).toDouble(),
      downPayment: (inputMap['downPayment'] as num).toDouble(),
      annualInterestRate: (inputMap['annualInterestRate'] as num).toDouble(),
      loanTenureYears: inputMap['loanTenureYears'] as int,
      annualAppreciation: (inputMap['annualAppreciation'] as num).toDouble(),
      annualMaintenance: (inputMap['annualMaintenance'] as num).toDouble(),
      opportunityCostRate: (inputMap['opportunityCostRate'] as num).toDouble(),
      stampDutyRate: (inputMap['stampDutyRate'] as num?)?.toDouble() ?? 5.0,
      registrationRate: (inputMap['registrationRate'] as num?)?.toDouble() ?? 1.0,
      monthlyIncome: (inputMap['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      taxSlab: inputMap['taxSlab'] as int? ?? 0,
      includeTaxBenefit: inputMap['includeTaxBenefit'] as bool? ?? false,
      extraYearlyPayment:
          (inputMap['extraYearlyPayment'] as num?)?.toDouble() ?? 0.0,
    );

    final scheduleList = (m['schedule'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .map(
          (e) => AmortizationRow(
            year: e['year'] as int,
            principalPaid: (e['principalPaid'] as num).toDouble(),
            interestPaid: (e['interestPaid'] as num).toDouble(),
            remainingBalance: (e['remainingBalance'] as num).toDouble(),
          ),
        )
        .toList();

    final verdict = Verdict.values.firstWhere(
      (v) => v.name == m['verdict'],
      orElse: () => Verdict.rentWins,
    );

    final result = RentCalcResult(
      input: input,
      monthlyEmi: (m['monthlyEmi'] as num).toDouble(),
      tenYearRentTotal: (m['tenYearRentTotal'] as num).toDouble(),
      tenYearBuyTotal: (m['tenYearBuyTotal'] as num).toDouble(),
      breakEvenYear: m['breakEvenYear'] as int?,
      verdict: verdict,
      rentAdvantage: (m['rentAdvantage'] as num).toDouble(),
      schedule: scheduleList,
      cumulativeRent: (m['cumulativeRent'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      cumulativeBuy: (m['cumulativeBuy'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      affordabilityRatio: (m['affordabilityRatio'] as num?)?.toDouble(),
      taxBenefitTotal: (m['taxBenefitTotal'] as num?)?.toDouble(),
      effectiveBuyTotal: (m['effectiveBuyTotal'] as num?)?.toDouble(),
      sipCorpus: (m['sipCorpus'] as num?)?.toDouble(),
      prepaymentTenureYears: m['prepaymentTenureYears'] as int?,
      prepaymentInterestSaved:
          (m['prepaymentInterestSaved'] as num?)?.toDouble(),
    );

    return CalculationSnapshot(
      id: m['id'] as String,
      label: m['label'] as String,
      result: result,
      savedAt: DateTime.parse(m['savedAt'] as String),
    );
  }
}
