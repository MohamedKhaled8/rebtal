import 'package:rebtal/core/utils/model/pricing_period.dart';

/// Resolves nightly prices from chalet data (flat price or tiered periods).
class ChaletPricingService {
  const ChaletPricingService._();

  static List<PricingPeriod> periodsFromChalet(Map<String, dynamic> data) {
    final fromFirestore = PricingPeriod.listFromFirestore(
      data['pricingPeriods'],
    );
    if (fromFirestore.isNotEmpty) return fromFirestore;

    final from = _parseEnvelopeDate(data['availableFrom']);
    final to = _parseEnvelopeDate(data['availableTo']);
    final base = _parseBasePrice(data['price']);
    if (from != null && to != null && base > 0) {
      return [PricingPeriod(id: 'legacy', from: from, to: to, price: base)];
    }
    return const [];
  }

  static bool hasTieredPricing(Map<String, dynamic> data) =>
      PricingPeriod.listFromFirestore(data['pricingPeriods']).isNotEmpty;

  static double basePrice(Map<String, dynamic> data) {
    final periods = periodsFromChalet(data);
    if (periods.isEmpty)
      return _applyDiscount(data, _parseBasePrice(data['price']));
    final min = periods.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    return _applyDiscount(data, min);
  }

  static double priceForNight(Map<String, dynamic> data, DateTime night) {
    final periods = periodsFromChalet(data);
    final d = PricingPeriod.dateOnly(night);

    for (final period in periods) {
      if (period.contains(d)) {
        return _applyDiscount(data, period.price);
      }
    }

    return _applyDiscount(data, _parseBasePrice(data['price']));
  }

  static PricingPeriod? periodForNight(
    Map<String, dynamic> data,
    DateTime night,
  ) {
    final d = PricingPeriod.dateOnly(night);
    for (final period in periodsFromChalet(data)) {
      if (period.contains(d)) return period;
    }
    return null;
  }

  /// Stay nights: [start, end) — checkout day excluded.
  static List<DailyPriceEntry> nightlyBreakdown(
    Map<String, dynamic> data,
    DateTime start,
    DateTime end,
  ) {
    final entries = <DailyPriceEntry>[];
    var cursor = PricingPeriod.dateOnly(start);
    final checkout = PricingPeriod.dateOnly(end);
    while (cursor.isBefore(checkout)) {
      final period = periodForNight(data, cursor);
      entries.add(
        DailyPriceEntry(
          date: cursor,
          price: priceForNight(data, cursor),
          period: period,
        ),
      );
      cursor = cursor.add(const Duration(days: 1));
    }
    return entries;
  }

  static double totalForRange(
    Map<String, dynamic> data,
    DateTime start,
    DateTime end, {
    bool isDayUse = false,
  }) {
    final spanDays = PricingPeriod.dateOnly(
      end,
    ).difference(PricingPeriod.dateOnly(start)).inDays.clamp(0, 365);

    if (isDayUse) {
      final days = spanDays == 0 ? 1 : spanDays;
      return priceForNight(data, start) * days;
    }

    final breakdown = nightlyBreakdown(data, start, end);
    if (breakdown.isEmpty) return 0;
    return breakdown.fold<double>(0, (sum, e) => sum + e.price);
  }

  static double averageNightly(
    Map<String, dynamic> data,
    DateTime start,
    DateTime end,
  ) {
    final breakdown = nightlyBreakdown(data, start, end);
    if (breakdown.isEmpty) return basePrice(data);
    final total = breakdown.fold<double>(0, (s, e) => s + e.price);
    return total / breakdown.length;
  }

  static DateTime? envelopeFrom(Map<String, dynamic> data) {
    final periods = periodsFromChalet(data);
    if (periods.isEmpty) return _parseEnvelopeDate(data['availableFrom']);
    return periods.map((p) => p.from).reduce((a, b) => a.isBefore(b) ? a : b);
  }

  static DateTime? envelopeTo(Map<String, dynamic> data) {
    final periods = periodsFromChalet(data);
    if (periods.isEmpty) return _parseEnvelopeDate(data['availableTo']);
    return periods.map((p) => p.to).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  static double _parseBasePrice(dynamic price) {
    if (price is num) return price.toDouble();
    return double.tryParse(
          (price ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0;
  }

  static DateTime? _parseEnvelopeDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return PricingPeriod.dateOnly(value);
    if (value is String) {
      final d = DateTime.tryParse(value);
      return d == null ? null : PricingPeriod.dateOnly(d);
    }
    return null;
  }

  static double _applyDiscount(Map<String, dynamic> data, double basePrice) {
    final discountEnabled = data['discountEnabled'] == true;
    if (!discountEnabled || basePrice <= 0) return basePrice;

    final discountValue =
        double.tryParse(data['discountValue']?.toString() ?? '0') ?? 0;
    if (discountValue <= 0) return basePrice;

    final discountType = data['discountType'];
    var result = basePrice;
    if (discountType == 'percentage') {
      result = basePrice * (1 - discountValue / 100);
    } else if (discountType == 'fixed') {
      result = basePrice - discountValue;
    }
    return result < 0 ? 0 : result;
  }

  /// Returns true if [a] and [b] overlap (inclusive date ranges).
  static bool periodsOverlap(PricingPeriod a, PricingPeriod b) {
    final aFrom = PricingPeriod.dateOnly(a.from);
    final aTo = PricingPeriod.dateOnly(a.to);
    final bFrom = PricingPeriod.dateOnly(b.from);
    final bTo = PricingPeriod.dateOnly(b.to);
    return !aTo.isBefore(bFrom) && !bTo.isBefore(aFrom);
  }

  static List<PricingPeriod> withDiscountedDisplay(
    Map<String, dynamic> data,
    List<PricingPeriod> periods,
  ) {
    return periods
        .map(
          (p) => PricingPeriod(
            id: p.id,
            from: p.from,
            to: p.to,
            price: _applyDiscount(data, p.price),
          ),
        )
        .toList();
  }
}

class DailyPriceEntry {
  final DateTime date;
  final double price;
  final PricingPeriod? period;

  const DailyPriceEntry({required this.date, required this.price, this.period});
}
