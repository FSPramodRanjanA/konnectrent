import 'package:equatable/equatable.dart';

/// Immutable value object representing all user inputs for the calculation.
class RentCalcInput extends Equatable {
  const RentCalcInput({
    required this.monthlyRent,
    required this.annualRentIncrease,
    required this.propertyPrice,
    required this.downPayment,
    required this.annualInterestRate,
    required this.loanTenureYears,
    required this.annualAppreciation,
    required this.annualMaintenance,
    required this.opportunityCostRate,
    this.stampDutyRate = 5.0,
    this.registrationRate = 1.0,
    this.monthlyIncome = 0.0,
    this.taxSlab = 0,
    this.includeTaxBenefit = false,
    this.extraYearlyPayment = 0.0,
  });

  // ── Core rent inputs ───────────────────────────────────────────────────────
  final double monthlyRent;
  final double annualRentIncrease;

  // ── Core buy inputs ────────────────────────────────────────────────────────
  final double propertyPrice;
  final double downPayment;
  final double annualInterestRate;
  final int loanTenureYears;
  final double annualAppreciation;
  final double annualMaintenance;
  final double opportunityCostRate;

  // ── Stamp duty & registration (upfront one-time costs) ────────────────────
  final double stampDutyRate;     // % of property price (state-specific)
  final double registrationRate;  // % of property price (typically 1%)

  // ── EMI affordability ─────────────────────────────────────────────────────
  final double monthlyIncome;     // 0 = not provided → affordability hidden

  // ── Tax benefit ───────────────────────────────────────────────────────────
  final int taxSlab;              // 0, 5, 20, or 30 (%)
  final bool includeTaxBenefit;

  // ── Pre-payment simulator ─────────────────────────────────────────────────
  final double extraYearlyPayment; // Extra principal paid each year (₹)

  // ── Derived ───────────────────────────────────────────────────────────────
  double get loanAmount => propertyPrice - downPayment;
  double get stampDutyAmount => propertyPrice * stampDutyRate / 100;
  double get registrationAmount => propertyPrice * registrationRate / 100;
  double get totalUpfrontCost => downPayment + stampDutyAmount + registrationAmount;

  /// Default values matching Indian market context.
  factory RentCalcInput.defaults() => const RentCalcInput(
        monthlyRent: 20000,
        annualRentIncrease: 5,
        propertyPrice: 6000000,
        downPayment: 1200000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 6,
        annualMaintenance: 10000,
        opportunityCostRate: 12,
        stampDutyRate: 5.0,
        registrationRate: 1.0,
        monthlyIncome: 0.0,
        taxSlab: 0,
        includeTaxBenefit: false,
        extraYearlyPayment: 0.0,
      );

  RentCalcInput copyWith({
    double? monthlyRent,
    double? annualRentIncrease,
    double? propertyPrice,
    double? downPayment,
    double? annualInterestRate,
    int? loanTenureYears,
    double? annualAppreciation,
    double? annualMaintenance,
    double? opportunityCostRate,
    double? stampDutyRate,
    double? registrationRate,
    double? monthlyIncome,
    int? taxSlab,
    bool? includeTaxBenefit,
    double? extraYearlyPayment,
  }) =>
      RentCalcInput(
        monthlyRent: monthlyRent ?? this.monthlyRent,
        annualRentIncrease: annualRentIncrease ?? this.annualRentIncrease,
        propertyPrice: propertyPrice ?? this.propertyPrice,
        downPayment: downPayment ?? this.downPayment,
        annualInterestRate: annualInterestRate ?? this.annualInterestRate,
        loanTenureYears: loanTenureYears ?? this.loanTenureYears,
        annualAppreciation: annualAppreciation ?? this.annualAppreciation,
        annualMaintenance: annualMaintenance ?? this.annualMaintenance,
        opportunityCostRate: opportunityCostRate ?? this.opportunityCostRate,
        stampDutyRate: stampDutyRate ?? this.stampDutyRate,
        registrationRate: registrationRate ?? this.registrationRate,
        monthlyIncome: monthlyIncome ?? this.monthlyIncome,
        taxSlab: taxSlab ?? this.taxSlab,
        includeTaxBenefit: includeTaxBenefit ?? this.includeTaxBenefit,
        extraYearlyPayment: extraYearlyPayment ?? this.extraYearlyPayment,
      );

  @override
  List<Object?> get props => [
        monthlyRent, annualRentIncrease, propertyPrice, downPayment,
        annualInterestRate, loanTenureYears, annualAppreciation,
        annualMaintenance, opportunityCostRate, stampDutyRate,
        registrationRate, monthlyIncome, taxSlab, includeTaxBenefit,
        extraYearlyPayment,
      ];
}
