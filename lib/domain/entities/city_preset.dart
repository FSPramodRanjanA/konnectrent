import 'package:konnectrent/domain/entities/rent_calc_input.dart';

/// Static city-level defaults for Indian metros and Tier-2 cities.
/// Figures are 2024–25 market averages — pre-fills the input form.
class CityPreset {
  const CityPreset({
    required this.name,
    required this.input,
  });

  final String name;
  final RentCalcInput input;

  static const all = [
    CityPreset(
      name: 'Mumbai',
      input: RentCalcInput(
        monthlyRent: 45000,
        annualRentIncrease: 5,
        propertyPrice: 12500000,
        downPayment: 2500000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 7,
        annualMaintenance: 20000,
        opportunityCostRate: 12,
        stampDutyRate: 5.0,
        registrationRate: 1.0,
      ),
    ),
    CityPreset(
      name: 'Delhi / NCR',
      input: RentCalcInput(
        monthlyRent: 30000,
        annualRentIncrease: 5,
        propertyPrice: 9000000,
        downPayment: 1800000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 6,
        annualMaintenance: 15000,
        opportunityCostRate: 12,
        stampDutyRate: 4.0,
        registrationRate: 1.0,
      ),
    ),
    CityPreset(
      name: 'Bengaluru',
      input: RentCalcInput(
        monthlyRent: 28000,
        annualRentIncrease: 6,
        propertyPrice: 8500000,
        downPayment: 1700000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 8,
        annualMaintenance: 15000,
        opportunityCostRate: 12,
        stampDutyRate: 5.6,
        registrationRate: 1.0,
      ),
    ),
    CityPreset(
      name: 'Hyderabad',
      input: RentCalcInput(
        monthlyRent: 22000,
        annualRentIncrease: 5,
        propertyPrice: 7000000,
        downPayment: 1400000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 7,
        annualMaintenance: 12000,
        opportunityCostRate: 12,
        stampDutyRate: 4.0,
        registrationRate: 0.5,
      ),
    ),
    CityPreset(
      name: 'Pune',
      input: RentCalcInput(
        monthlyRent: 20000,
        annualRentIncrease: 5,
        propertyPrice: 7500000,
        downPayment: 1500000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 6,
        annualMaintenance: 12000,
        opportunityCostRate: 12,
        stampDutyRate: 5.0,
        registrationRate: 1.0,
      ),
    ),
    CityPreset(
      name: 'Chennai',
      input: RentCalcInput(
        monthlyRent: 18000,
        annualRentIncrease: 5,
        propertyPrice: 7000000,
        downPayment: 1400000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 6,
        annualMaintenance: 12000,
        opportunityCostRate: 12,
        stampDutyRate: 7.0,
        registrationRate: 1.0,
      ),
    ),
    CityPreset(
      name: 'Ahmedabad',
      input: RentCalcInput(
        monthlyRent: 15000,
        annualRentIncrease: 4,
        propertyPrice: 5500000,
        downPayment: 1100000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 5,
        annualMaintenance: 10000,
        opportunityCostRate: 12,
        stampDutyRate: 4.9,
        registrationRate: 1.0,
      ),
    ),
    CityPreset(
      name: 'Jaipur',
      input: RentCalcInput(
        monthlyRent: 12000,
        annualRentIncrease: 4,
        propertyPrice: 4500000,
        downPayment: 900000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 5,
        annualMaintenance: 8000,
        opportunityCostRate: 12,
        stampDutyRate: 5.0,
        registrationRate: 1.0,
      ),
    ),
    CityPreset(
      name: 'Kolkata',
      input: RentCalcInput(
        monthlyRent: 15000,
        annualRentIncrease: 4,
        propertyPrice: 5500000,
        downPayment: 1100000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 5,
        annualMaintenance: 10000,
        opportunityCostRate: 12,
        stampDutyRate: 6.0,
        registrationRate: 1.0,
      ),
    ),
  ];

  /// Stamp duty rates by state for the state picker.
  static const Map<String, double> stampDutyByState = {
    'Maharashtra': 5.0,
    'Karnataka': 5.6,
    'Tamil Nadu': 7.0,
    'Delhi': 4.0,
    'Uttar Pradesh': 7.0,
    'West Bengal': 6.0,
    'Rajasthan': 5.0,
    'Gujarat': 4.9,
    'Telangana': 4.0,
    'Andhra Pradesh': 5.0,
    'Kerala': 8.0,
    'Madhya Pradesh': 7.5,
    'Haryana': 5.0,
    'Punjab': 5.0,
    'Bihar': 5.7,
  };
}
