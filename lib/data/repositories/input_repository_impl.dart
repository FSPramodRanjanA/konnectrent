import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/repositories/input_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-backed implementation of [InputRepository].
class InputRepositoryImpl implements InputRepository {
  static const _kMonthlyRent = 'monthly_rent';
  static const _kAnnualRentIncrease = 'annual_rent_increase';
  static const _kPropertyPrice = 'property_price';
  static const _kDownPayment = 'down_payment';
  static const _kAnnualInterestRate = 'annual_interest_rate';
  static const _kLoanTenureYears = 'loan_tenure_years';
  static const _kAnnualAppreciation = 'annual_appreciation';
  static const _kAnnualMaintenance = 'annual_maintenance';
  static const _kOpportunityCostRate = 'opportunity_cost_rate';
  static const _kStampDutyRate = 'stamp_duty_rate';
  static const _kRegistrationRate = 'registration_rate';
  static const _kMonthlyIncome = 'monthly_income';
  static const _kTaxSlab = 'tax_slab';
  static const _kIncludeTaxBenefit = 'include_tax_benefit';
  static const _kExtraYearlyPayment = 'extra_yearly_payment';

  @override
  Future<void> saveInputs(RentCalcInput input) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setDouble(_kMonthlyRent, input.monthlyRent),
      prefs.setDouble(_kAnnualRentIncrease, input.annualRentIncrease),
      prefs.setDouble(_kPropertyPrice, input.propertyPrice),
      prefs.setDouble(_kDownPayment, input.downPayment),
      prefs.setDouble(_kAnnualInterestRate, input.annualInterestRate),
      prefs.setInt(_kLoanTenureYears, input.loanTenureYears),
      prefs.setDouble(_kAnnualAppreciation, input.annualAppreciation),
      prefs.setDouble(_kAnnualMaintenance, input.annualMaintenance),
      prefs.setDouble(_kOpportunityCostRate, input.opportunityCostRate),
      prefs.setDouble(_kStampDutyRate, input.stampDutyRate),
      prefs.setDouble(_kRegistrationRate, input.registrationRate),
      prefs.setDouble(_kMonthlyIncome, input.monthlyIncome),
      prefs.setInt(_kTaxSlab, input.taxSlab),
      prefs.setBool(_kIncludeTaxBenefit, input.includeTaxBenefit),
      prefs.setDouble(_kExtraYearlyPayment, input.extraYearlyPayment),
    ]);
  }

  @override
  Future<RentCalcInput?> loadInputs() async {
    final prefs = await SharedPreferences.getInstance();

    final monthlyRent = prefs.getDouble(_kMonthlyRent);
    if (monthlyRent == null) return null;

    return RentCalcInput(
      monthlyRent: monthlyRent,
      annualRentIncrease: prefs.getDouble(_kAnnualRentIncrease) ?? 5,
      propertyPrice: prefs.getDouble(_kPropertyPrice) ?? 6000000,
      downPayment: prefs.getDouble(_kDownPayment) ?? 1200000,
      annualInterestRate: prefs.getDouble(_kAnnualInterestRate) ?? 8.5,
      loanTenureYears: prefs.getInt(_kLoanTenureYears) ?? 20,
      annualAppreciation: prefs.getDouble(_kAnnualAppreciation) ?? 6,
      annualMaintenance: prefs.getDouble(_kAnnualMaintenance) ?? 10000,
      opportunityCostRate: prefs.getDouble(_kOpportunityCostRate) ?? 12,
      stampDutyRate: prefs.getDouble(_kStampDutyRate) ?? 5.0,
      registrationRate: prefs.getDouble(_kRegistrationRate) ?? 1.0,
      monthlyIncome: prefs.getDouble(_kMonthlyIncome) ?? 0.0,
      taxSlab: prefs.getInt(_kTaxSlab) ?? 0,
      includeTaxBenefit: prefs.getBool(_kIncludeTaxBenefit) ?? false,
      extraYearlyPayment: prefs.getDouble(_kExtraYearlyPayment) ?? 0.0,
    );
  }
}
