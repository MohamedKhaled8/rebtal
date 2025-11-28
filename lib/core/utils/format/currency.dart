import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  // Format number only using English locale, no decimals
  static final NumberFormat _number = NumberFormat('#,##0', 'en_EG');

  // Returns: "{number} EG" or "{number} EG / night"
  static String egp(num? amount, {bool withSuffixPerNight = false}) {
    final value = (amount ?? 0).toDouble();
    final numStr = _number.format(value);
    final base = '$numStr EG';
    if (withSuffixPerNight) return '$base / night';
    return base;
  }
}
