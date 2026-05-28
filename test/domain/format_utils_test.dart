import 'package:flutter_test/flutter_test.dart';
import 'package:konnectrent/core/utils/format_utils.dart';

void main() {
  group('toIndianCurrency', () {
    test('formats thousands correctly', () {
      expect(FormatUtils.toIndianCurrency(50000), contains('50'));
    });

    test('formats lakh boundary (exactly 1L)', () {
      expect(FormatUtils.toIndianCurrency(100000), '₹1.0L');
    });

    test('formats crore boundary (exactly 1Cr)', () {
      expect(FormatUtils.toIndianCurrency(10000000), '₹1.0Cr');
    });

    test('formats values above 1 crore', () {
      expect(FormatUtils.toIndianCurrency(60000000), '₹6.0Cr');
    });

    test('formats values between 1L and 1Cr', () {
      expect(FormatUtils.toIndianCurrency(4800000), '₹48.0L');
    });

    test('handles zero', () {
      expect(FormatUtils.toIndianCurrency(0), isNotEmpty);
    });

    test('handles NaN gracefully', () {
      expect(FormatUtils.toIndianCurrency(double.nan), '₹0');
    });

    test('handles Infinity gracefully', () {
      expect(FormatUtils.toIndianCurrency(double.infinity), '₹0');
    });
  });

  group('toPercent', () {
    test('formats 8.5 as 8.5%', () {
      expect(FormatUtils.toPercent(8.5), '8.5%');
    });

    test('respects decimal places parameter', () {
      expect(FormatUtils.toPercent(8.5678, decimals: 2), '8.57%');
    });
  });
}
