import 'dart:math';

import 'package:konnectrent/domain/entities/amortization_row.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';

/// Pure calculation engine. All methods are static and side-effect free.
/// No Flutter imports — testable with plain `dart test`.
class RentCalcEngine {
  const RentCalcEngine._();

  // ── Core formulas ──────────────────────────────────────────────────────────

  /// Standard reducing-balance EMI.
  static double calculateEMI(
    double principal,
    double annualRate,
    int tenureYears,
  ) {
    if (principal <= 0) return 0;
    final r = annualRate / 12 / 100;
    final n = tenureYears * 12;
    if (r == 0) return principal / n;
    return principal * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
  }

  /// Cumulative rent paid over [years] with annual escalation.
  static double cumulativeRent(RentCalcInput input, int years) {
    double total = 0;
    for (int y = 1; y <= years; y++) {
      total +=
          input.monthlyRent * 12 * pow(1 + input.annualRentIncrease / 100, y - 1);
    }
    return total;
  }

  /// True cumulative cost of buying over [years] (EMI + maintenance +
  /// opportunity cost − appreciation). Includes upfront stamp duty in year 1.
  static double cumulativeBuy(RentCalcInput input, int years) {
    final emi = calculateEMI(
      input.loanAmount,
      input.annualInterestRate,
      input.loanTenureYears,
    );
    final totalEmi = emi * 12 * years;
    final maintenance = input.annualMaintenance * years;
    final oppCost = input.downPayment *
        (pow(1 + input.opportunityCostRate / 100, years) - 1);
    final appreciation =
        input.propertyPrice * (pow(1 + input.annualAppreciation / 100, years) - 1);
    // Stamp duty + registration are upfront one-time costs included from year 1
    final upfront = input.stampDutyAmount + input.registrationAmount;
    return totalEmi + maintenance + oppCost - appreciation + upfront;
  }

  static double calculateRentTotal(RentCalcInput input) =>
      cumulativeRent(input, 10);

  static double calculateBuyTotal(RentCalcInput input) =>
      cumulativeBuy(input, 10);

  /// First year (1–30) where cumulative buy cost < cumulative rent cost.
  static int? findBreakEvenYear(RentCalcInput input) {
    for (int y = 1; y <= 30; y++) {
      if (cumulativeBuy(input, y) < cumulativeRent(input, y)) return y;
    }
    return null;
  }

  // ── Amortization ──────────────────────────────────────────────────────────

  /// Annual amortization schedule for the full loan tenure.
  static List<AmortizationRow> buildSchedule(RentCalcInput input) {
    final emi = calculateEMI(
      input.loanAmount,
      input.annualInterestRate,
      input.loanTenureYears,
    );
    final r = input.annualInterestRate / 12 / 100;
    double balance = input.loanAmount;
    final rows = <AmortizationRow>[];

    for (int year = 1; year <= input.loanTenureYears; year++) {
      double yearPrincipal = 0;
      double yearInterest = 0;

      for (int m = 0; m < 12; m++) {
        final interest = balance * r;
        final principal = emi - interest;
        yearInterest += interest;
        yearPrincipal += principal;
        balance -= principal;
        if (balance < 0) balance = 0;
      }

      rows.add(AmortizationRow(
        year: year,
        principalPaid: yearPrincipal,
        interestPaid: yearInterest,
        remainingBalance: balance,
      ),);
    }
    return rows;
  }

  // ── EMI Affordability ──────────────────────────────────────────────────────

  /// Returns EMI as % of monthly income. Null if income ≤ 0.
  static double? calculateAffordabilityRatio(RentCalcInput input) {
    if (input.monthlyIncome <= 0) return null;
    final emi = calculateEMI(
      input.loanAmount,
      input.annualInterestRate,
      input.loanTenureYears,
    );
    return (emi / input.monthlyIncome) * 100;
  }

  // ── Tax Benefit ───────────────────────────────────────────────────────────

  /// Annual tax saving = min(actualInterest, ₹2L) × taxRate (Sec 24b)
  ///                   + min(actualPrincipal, ₹1.5L) × taxRate (Sec 80C).
  static double calculateAnnualTaxBenefit(
    double principalPaid,
    double interestPaid,
    int taxSlab,
  ) {
    if (taxSlab == 0) return 0;
    const maxInterestDeduction = 200000.0; // ₹2L — Section 24(b)
    const maxPrincipalDeduction = 150000.0; // ₹1.5L — Section 80C
    final rate = taxSlab / 100;
    final interestSaving = min(interestPaid, maxInterestDeduction) * rate;
    final principalSaving = min(principalPaid, maxPrincipalDeduction) * rate;
    return interestSaving + principalSaving;
  }

  /// Total tax benefit over entire loan tenure.
  static double calculateTotalTaxBenefit(RentCalcInput input) {
    if (!input.includeTaxBenefit || input.taxSlab == 0) return 0;
    final schedule = buildSchedule(input);
    return schedule.fold<double>(
      0,
      (sum, row) => sum +
          calculateAnnualTaxBenefit(
            row.principalPaid,
            row.interestPaid,
            input.taxSlab,
          ),
    );
  }

  // ── SIP vs Property ───────────────────────────────────────────────────────

  /// Corpus if (down payment lump sum + monthly SIP of [monthlyContribution])
  /// is invested at [annualRate]% CAGR for [years] years.
  static double calculateSipCorpus({
    required double lumpSum,
    required double monthlyContribution,
    required double annualRate,
    required int years,
  }) {
    final r = annualRate / 12 / 100;
    final n = years * 12;
    // Lump-sum future value
    final lumpFV = lumpSum * pow(1 + annualRate / 100, years);
    // SIP future value
    final sipFV = r > 0
        ? monthlyContribution * ((pow(1 + r, n) - 1) / r) * (1 + r)
        : monthlyContribution * n;
    return lumpFV + sipFV;
  }

  // ── Pre-payment Simulator ─────────────────────────────────────────────────

  /// Simulates prepayment: returns [reducedYears, interestSaved].
  static (int years, double interestSaved) simulatePrepayment(
    RentCalcInput input,
  ) {
    if (input.extraYearlyPayment <= 0) {
      return (input.loanTenureYears, 0);
    }

    final emi = calculateEMI(
      input.loanAmount,
      input.annualInterestRate,
      input.loanTenureYears,
    );
    final r = input.annualInterestRate / 12 / 100;
    double balance = input.loanAmount;
    double totalInterest = 0;
    int month = 0;

    while (balance > 0 && month < input.loanTenureYears * 12) {
      final interest = balance * r;
      final principal = emi - interest;
      totalInterest += interest;
      balance -= principal;
      month++;
      // Apply extra yearly payment at end of each year
      if (month % 12 == 0 && balance > 0) {
        balance -= input.extraYearlyPayment;
        if (balance < 0) balance = 0;
      }
    }

    // Original total interest (no prepayment)
    final originalInterest = buildSchedule(input).fold<double>(
      0,
      (s, row) => s + row.interestPaid,
    );

    final reducedYears = (month / 12).ceil();
    return (reducedYears, originalInterest - totalInterest);
  }

  // ── Full result ───────────────────────────────────────────────────────────

  /// Builds the complete [RentCalcResult] combining all calculations.
  static RentCalcResult calculate(RentCalcInput input) {
    final emi = calculateEMI(
      input.loanAmount,
      input.annualInterestRate,
      input.loanTenureYears,
    );
    final rentTotal = calculateRentTotal(input);
    final buyTotal = calculateBuyTotal(input);
    final breakEven = findBreakEvenYear(input);
    final schedule = buildSchedule(input);
    final rentAdv = buyTotal - rentTotal;
    final verdict = rentAdv > 0
        ? Verdict.rentWins
        : rentAdv < 0
            ? Verdict.buyWins
            : Verdict.breakEven;

    // 20-year cumulative series for chart
    final cumRent = List.generate(20, (i) => cumulativeRent(input, i + 1));
    final cumBuy = List.generate(20, (i) => cumulativeBuy(input, i + 1));

    // Affordability
    final affordability = calculateAffordabilityRatio(input);

    // Tax benefit
    final taxBenefit = input.includeTaxBenefit && input.taxSlab > 0
        ? calculateTotalTaxBenefit(input)
        : null;
    final effectiveBuy =
        taxBenefit != null ? buyTotal - taxBenefit : null;

    // SIP corpus — only meaningful when renting wins
    double? sipCorpus;
    if (verdict == Verdict.rentWins) {
      final monthlyEmiSaving = emi - input.monthlyRent;
      final monthlySip = monthlyEmiSaving > 0 ? monthlyEmiSaving : 0.0;
      sipCorpus = calculateSipCorpus(
        lumpSum: input.downPayment + input.stampDutyAmount + input.registrationAmount,
        monthlyContribution: monthlySip,
        annualRate: input.opportunityCostRate,
        years: 20,
      );
    }

    // Pre-payment
    int? prepayYears;
    double? prepayInterestSaved;
    if (input.extraYearlyPayment > 0) {
      final (y, saved) = simulatePrepayment(input);
      prepayYears = y;
      prepayInterestSaved = saved;
    }

    return RentCalcResult(
      input: input,
      monthlyEmi: emi,
      tenYearRentTotal: rentTotal,
      tenYearBuyTotal: buyTotal,
      breakEvenYear: breakEven,
      verdict: verdict,
      rentAdvantage: rentAdv,
      schedule: schedule,
      cumulativeRent: cumRent,
      cumulativeBuy: cumBuy,
      affordabilityRatio: affordability,
      taxBenefitTotal: taxBenefit,
      effectiveBuyTotal: effectiveBuy,
      sipCorpus: sipCorpus,
      prepaymentTenureYears: prepayYears,
      prepaymentInterestSaved: prepayInterestSaved,
    );
  }
}
