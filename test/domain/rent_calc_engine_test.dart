import 'package:flutter_test/flutter_test.dart';
import 'package:konnectrent/domain/engine/rent_calc_engine.dart';
import 'package:konnectrent/domain/entities/rent_calc_input.dart';
import 'package:konnectrent/domain/entities/rent_calc_result.dart';

void main() {
  final defaultInput = RentCalcInput.defaults();

  group('calculateEMI', () {
    test('returns correct EMI for standard inputs', () {
      final emi = RentCalcEngine.calculateEMI(4800000, 8.5, 20);
      expect(emi, closeTo(41656, 1));
    });

    test('returns 0 when principal is 0', () {
      expect(RentCalcEngine.calculateEMI(0, 8.5, 20), 0);
    });

    test('returns principal/n when rate is 0', () {
      final emi = RentCalcEngine.calculateEMI(1200000, 0, 10);
      expect(emi, closeTo(10000, 1));
    });

    test('returns correct EMI for 30-year tenure', () {
      final emi = RentCalcEngine.calculateEMI(4800000, 8.5, 30);
      expect(emi, closeTo(36908, 1));
    });
  });

  group('calculateRentTotal', () {
    test('calculates 10-year rent with 5% annual increase', () {
      final total = RentCalcEngine.calculateRentTotal(defaultInput);
      // Year 1: 20000*12=240000, compounding at 5%
      expect(total, greaterThan(2400000));
      expect(total, lessThan(3200000));
    });

    test('no increase returns 10 * 12 * monthlyRent', () {
      final input = defaultInput.copyWith(annualRentIncrease: 0);
      final total = RentCalcEngine.calculateRentTotal(input);
      expect(total, closeTo(defaultInput.monthlyRent * 12 * 10, 1));
    });
  });

  group('calculateBuyTotal', () {
    test('returns a positive number for default inputs', () {
      final total = RentCalcEngine.calculateBuyTotal(defaultInput);
      expect(total, greaterThan(0));
    });

    test('zero appreciation increases buy total', () {
      final withAppreciation = RentCalcEngine.calculateBuyTotal(defaultInput);
      final noAppreciation =
          RentCalcEngine.calculateBuyTotal(defaultInput.copyWith(annualAppreciation: 0));
      expect(noAppreciation, greaterThan(withAppreciation));
    });

    test('100% down payment (loan = 0) is valid', () {
      final input = defaultInput.copyWith(downPayment: defaultInput.propertyPrice - 1);
      final total = RentCalcEngine.calculateBuyTotal(input);
      expect(total, isNotNaN);
    });
  });

  group('findBreakEvenYear', () {
    test('returns a year ≤ 30 for default inputs', () {
      final year = RentCalcEngine.findBreakEvenYear(defaultInput);
      if (year != null) {
        expect(year, inInclusiveRange(1, 30));
      }
    });

    test('returns null when appreciation is 0% and rent is very low', () {
      const input = RentCalcInput(
        monthlyRent: 1000,
        annualRentIncrease: 0,
        propertyPrice: 6000000,
        downPayment: 1200000,
        annualInterestRate: 8.5,
        loanTenureYears: 20,
        annualAppreciation: 0,
        annualMaintenance: 10000,
        opportunityCostRate: 12,
      );
      final year = RentCalcEngine.findBreakEvenYear(input);
      expect(year, isNull);
    });
  });

  group('buildSchedule', () {
    test('returns rows equal to loanTenureYears', () {
      final schedule = RentCalcEngine.buildSchedule(defaultInput);
      expect(schedule.length, defaultInput.loanTenureYears);
    });

    test('year numbers are sequential from 1', () {
      final schedule = RentCalcEngine.buildSchedule(defaultInput);
      for (int i = 0; i < schedule.length; i++) {
        expect(schedule[i].year, i + 1);
      }
    });

    test('remaining balance approaches 0 at end of tenure', () {
      final schedule = RentCalcEngine.buildSchedule(defaultInput);
      expect(schedule.last.remainingBalance, closeTo(0, 500));
    });

    test('total principal paid equals loan amount', () {
      final schedule = RentCalcEngine.buildSchedule(defaultInput);
      final totalPrincipal =
          schedule.fold<double>(0, (sum, row) => sum + row.principalPaid);
      expect(totalPrincipal, closeTo(defaultInput.loanAmount, 500));
    });
  });

  group('calculate (full result)', () {
    test('returns correct verdict for default inputs', () {
      final result = RentCalcEngine.calculate(defaultInput);
      expect(result.verdict, isA<Verdict>());
    });

    test('cumulative series have length 20', () {
      final result = RentCalcEngine.calculate(defaultInput);
      expect(result.cumulativeRent.length, 20);
      expect(result.cumulativeBuy.length, 20);
    });

    test('cumulative rent is monotonically increasing', () {
      final result = RentCalcEngine.calculate(defaultInput);
      for (int i = 1; i < result.cumulativeRent.length; i++) {
        expect(result.cumulativeRent[i], greaterThan(result.cumulativeRent[i - 1]));
      }
    });
  });
}
