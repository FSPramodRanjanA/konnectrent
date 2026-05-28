import 'package:equatable/equatable.dart';
import 'package:konnectrent/domain/entities/amortization_row.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';

enum Verdict { rentWins, buyWins, breakEven }

/// Immutable output produced by [RentCalcEngine].
class RentCalcResult extends Equatable {
  const RentCalcResult({
    required this.input,
    required this.monthlyEmi,
    required this.tenYearRentTotal,
    required this.tenYearBuyTotal,
    required this.breakEvenYear,
    required this.verdict,
    required this.rentAdvantage,
    required this.schedule,
    required this.cumulativeRent,
    required this.cumulativeBuy,
    // New feature fields
    this.affordabilityRatio,
    this.taxBenefitTotal,
    this.effectiveBuyTotal,
    this.sipCorpus,
    this.prepaymentTenureYears,
    this.prepaymentInterestSaved,
  });

  final RentCalcInput input;
  final double monthlyEmi;
  final double tenYearRentTotal;
  final double tenYearBuyTotal;
  final int? breakEvenYear;
  final Verdict verdict;

  /// Positive = renting cheaper; negative = buying cheaper (over 10 years).
  final double rentAdvantage;
  final List<AmortizationRow> schedule;
  final List<double> cumulativeRent;  // 20 years
  final List<double> cumulativeBuy;   // 20 years

  // ── EMI Affordability ─────────────────────────────────────────────────────
  /// EMI as a % of monthly income. Null if income not provided.
  final double? affordabilityRatio;

  // ── Tax Benefit ───────────────────────────────────────────────────────────
  /// Total tax savings over loan tenure. Null if not opted in.
  final double? taxBenefitTotal;

  /// Buy total after applying tax savings (more accurate when benefit enabled).
  final double? effectiveBuyTotal;

  // ── SIP vs Property ───────────────────────────────────────────────────────
  /// Corpus if rent-saving + down payment invested in SIP over 20 years.
  final double? sipCorpus;

  // ── Pre-payment ───────────────────────────────────────────────────────────
  /// Reduced tenure (years) when extra yearly payment applied.
  final int? prepaymentTenureYears;

  /// Total interest saved due to extra yearly payment.
  final double? prepaymentInterestSaved;

  // ── Convenience accessors ─────────────────────────────────────────────────
  double get fiveYearRentTotal =>
      cumulativeRent.length >= 5 ? cumulativeRent[4] : 0;
  double get fiveYearBuyTotal =>
      cumulativeBuy.length >= 5 ? cumulativeBuy[4] : 0;
  double get twentyYearRentTotal =>
      cumulativeRent.length >= 20 ? cumulativeRent[19] : 0;
  double get twentyYearBuyTotal =>
      cumulativeBuy.length >= 20 ? cumulativeBuy[19] : 0;

  @override
  List<Object?> get props => [
        input, monthlyEmi, tenYearRentTotal, tenYearBuyTotal,
        breakEvenYear, verdict, rentAdvantage, schedule,
        cumulativeRent, cumulativeBuy, affordabilityRatio,
        taxBenefitTotal, effectiveBuyTotal, sipCorpus,
        prepaymentTenureYears, prepaymentInterestSaved,
      ];
}
