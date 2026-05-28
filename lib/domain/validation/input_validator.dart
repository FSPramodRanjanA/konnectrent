import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/validation/validation_result.dart';

/// Validates a [RentCalcInput] and returns [Valid] or [Invalid].
/// Pure — no Flutter imports, no side effects.
class InputValidator {
  const InputValidator._();

  static ValidationResult validate(RentCalcInput input) {
    final errors = <String, String>{};

    if (input.monthlyRent <= 0) {
      errors['monthlyRent'] = 'Monthly rent must be greater than 0';
    }

    if (input.annualRentIncrease < 0 || input.annualRentIncrease > 20) {
      errors['annualRentIncrease'] = 'Annual increase must be between 0% and 20%';
    }

    if (input.propertyPrice <= 0) {
      errors['propertyPrice'] = 'Property price must be greater than 0';
    }

    if (input.downPayment < 0) {
      errors['downPayment'] = 'Down payment cannot be negative';
    }

    if (input.downPayment >= input.propertyPrice) {
      errors['downPayment'] = 'Down payment must be less than property price';
    }

    if (input.annualInterestRate < 5 || input.annualInterestRate > 20) {
      errors['annualInterestRate'] = 'Interest rate must be between 5% and 20%';
    }

    if (input.loanTenureYears < 5 || input.loanTenureYears > 30) {
      errors['loanTenureYears'] = 'Loan tenure must be between 5 and 30 years';
    }

    if (input.annualAppreciation < 0 || input.annualAppreciation > 15) {
      errors['annualAppreciation'] = 'Appreciation must be between 0% and 15%';
    }

    if (input.annualMaintenance < 0) {
      errors['annualMaintenance'] = 'Maintenance cost cannot be negative';
    }

    if (input.opportunityCostRate < 0 || input.opportunityCostRate > 30) {
      errors['opportunityCostRate'] = 'Opportunity cost rate must be between 0% and 30%';
    }

    if (input.stampDutyRate < 0 || input.stampDutyRate > 15) {
      errors['stampDutyRate'] = 'Stamp duty must be between 0% and 15%';
    }

    if (input.registrationRate < 0 || input.registrationRate > 5) {
      errors['registrationRate'] = 'Registration charges must be between 0% and 5%';
    }

    if (input.monthlyIncome < 0) {
      errors['monthlyIncome'] = 'Monthly income cannot be negative';
    }

    return errors.isEmpty ? const Valid() : Invalid(errors);
  }

  /// Validates a single raw string field value and returns an error message or null.
  static String? validateField(String fieldName, String value) {
    final trimmed = value.trim();

    // Optional fields — blank is allowed
    const optionalFields = {'monthlyIncome', 'extraYearlyPayment'};
    if (trimmed.isEmpty) {
      return optionalFields.contains(fieldName) ? null : 'This field is required';
    }

    final num = double.tryParse(trimmed);
    if (num == null) return 'Please enter a valid number';

    switch (fieldName) {
      case 'monthlyRent':
        if (num <= 0) return 'Must be greater than 0';
      case 'annualRentIncrease':
        if (num < 0 || num > 20) return 'Must be between 0 and 20';
      case 'propertyPrice':
        if (num <= 0) return 'Must be greater than 0';
      case 'downPayment':
        if (num < 0) return 'Cannot be negative';
      case 'annualInterestRate':
        if (num < 5 || num > 20) return 'Must be between 5 and 20';
      case 'annualAppreciation':
        if (num < 0 || num > 15) return 'Must be between 0 and 15';
      case 'annualMaintenance':
        if (num < 0) return 'Cannot be negative';
      case 'opportunityCostRate':
        if (num < 0 || num > 30) return 'Must be between 0 and 30';
      case 'stampDutyRate':
        if (num < 0 || num > 15) return 'Must be between 0% and 15%';
      case 'registrationRate':
        if (num < 0 || num > 5) return 'Must be between 0% and 5%';
      case 'monthlyIncome':
        if (num < 0) return 'Cannot be negative';
      case 'extraYearlyPayment':
        if (num < 0) return 'Cannot be negative';
    }
    return null;
  }
}
