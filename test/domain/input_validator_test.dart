import 'package:flutter_test/flutter_test.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/validation/input_validator.dart';
import 'package:konnectrent/domain/validation/validation_result.dart';

void main() {
  final validInput = RentCalcInput.defaults();

  group('validate — full input object', () {
    test('returns Valid for default inputs', () {
      expect(InputValidator.validate(validInput), isA<Valid>());
    });

    test('returns Invalid when monthlyRent is 0', () {
      final result = InputValidator.validate(validInput.copyWith(monthlyRent: 0));
      expect(result, isA<Invalid>());
      expect((result as Invalid).fieldErrors.containsKey('monthlyRent'), isTrue);
    });

    test('returns Invalid when monthlyRent is negative', () {
      final result = InputValidator.validate(validInput.copyWith(monthlyRent: -1));
      expect(result, isA<Invalid>());
    });

    test('returns Invalid when annualRentIncrease > 20', () {
      final result =
          InputValidator.validate(validInput.copyWith(annualRentIncrease: 21));
      expect(result, isA<Invalid>());
    });

    test('returns Invalid when annualRentIncrease < 0', () {
      final result =
          InputValidator.validate(validInput.copyWith(annualRentIncrease: -1));
      expect(result, isA<Invalid>());
    });

    test('returns Invalid when propertyPrice is 0', () {
      final result = InputValidator.validate(validInput.copyWith(propertyPrice: 0));
      expect(result, isA<Invalid>());
    });

    test('returns Invalid when downPayment equals propertyPrice', () {
      final result = InputValidator.validate(
        validInput.copyWith(downPayment: validInput.propertyPrice),
      );
      expect(result, isA<Invalid>());
    });

    test('returns Invalid when downPayment is negative', () {
      final result = InputValidator.validate(validInput.copyWith(downPayment: -100));
      expect(result, isA<Invalid>());
    });

    test('returns Invalid when interest rate < 5', () {
      final result =
          InputValidator.validate(validInput.copyWith(annualInterestRate: 4));
      expect(result, isA<Invalid>());
    });

    test('returns Invalid when interest rate > 20', () {
      final result =
          InputValidator.validate(validInput.copyWith(annualInterestRate: 21));
      expect(result, isA<Invalid>());
    });

    test('returns Invalid when appreciation > 15', () {
      final result =
          InputValidator.validate(validInput.copyWith(annualAppreciation: 16));
      expect(result, isA<Invalid>());
    });

    test('returns Invalid when appreciation < 0', () {
      final result =
          InputValidator.validate(validInput.copyWith(annualAppreciation: -1));
      expect(result, isA<Invalid>());
    });

    test('returns multiple errors at once', () {
      final result = InputValidator.validate(
        validInput.copyWith(monthlyRent: 0, propertyPrice: 0),
      );
      final errors = (result as Invalid).fieldErrors;
      expect(errors.containsKey('monthlyRent'), isTrue);
      expect(errors.containsKey('propertyPrice'), isTrue);
    });
  });

  group('validateField — single field', () {
    test('returns null for valid monthlyRent', () {
      expect(InputValidator.validateField('monthlyRent', '20000'), isNull);
    });

    test('returns error for empty value', () {
      expect(InputValidator.validateField('monthlyRent', ''), isNotNull);
    });

    test('returns error for non-numeric value', () {
      expect(InputValidator.validateField('monthlyRent', 'abc'), isNotNull);
    });

    test('returns error for out-of-range annualRentIncrease', () {
      expect(InputValidator.validateField('annualRentIncrease', '25'), isNotNull);
    });

    test('returns null for valid annualRentIncrease', () {
      expect(InputValidator.validateField('annualRentIncrease', '5'), isNull);
    });

    test('returns null for zero annualRentIncrease', () {
      expect(InputValidator.validateField('annualRentIncrease', '0'), isNull);
    });
  });
}
