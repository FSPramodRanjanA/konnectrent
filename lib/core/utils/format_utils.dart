import 'package:intl/intl.dart';

/// Centralized Indian number formatting. Use everywhere — never format inline in widgets.
class FormatUtils {
  const FormatUtils._();

  static String toIndianCurrency(double amount) {
    if (amount.isNaN || amount.isInfinite) return '₹0';
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    }
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
        .format(amount);
  }

  static String toIndianCurrencyFull(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
        .format(amount);
  }

  static String toPercent(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  static String toEmi(double emi) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
        .format(emi);
  }
}
