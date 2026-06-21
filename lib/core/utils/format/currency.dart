import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  // Format number only using English locale, no decimals
  static final NumberFormat _number = NumberFormat('#,##0', 'en_EG');

  // Returns localized currency string
  static String egp(
    BuildContext context,
    num? amount, {
    bool withSuffixPerNight = false,
    bool withSuffixPerDay = false,
  }) {
    final value = (amount ?? 0).toDouble();
    final numStr = _number.format(value);
    final base = '$numStr ${context.tr('booking_egp_currency')}';
    if (withSuffixPerDay) return '$base / ${context.tr('common_day')}';
    if (withSuffixPerNight) return '$base / ${context.tr('common_night')}';
    return base;
  }
}
