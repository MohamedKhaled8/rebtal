import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A date range with a fixed nightly price for owner availability tiers.
class PricingPeriod extends Equatable {
  final String id;
  final DateTime from;
  final DateTime to;
  final double price;

  const PricingPeriod({
    required this.id,
    required this.from,
    required this.to,
    required this.price,
  });

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  PricingPeriod normalized() => PricingPeriod(
    id: id,
    from: dateOnly(from),
    to: dateOnly(to),
    price: price,
  );

  bool contains(DateTime day) {
    final d = dateOnly(day);
    final f = dateOnly(from);
    final t = dateOnly(to);
    return !d.isBefore(f) && !d.isAfter(t);
  }

  int get nightCount {
    final diff = dateOnly(to).difference(dateOnly(from)).inDays;
    return diff < 0 ? 0 : diff;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'from': dateOnly(from).toIso8601String(),
    'to': dateOnly(to).toIso8601String(),
    'price': price,
  };

  factory PricingPeriod.fromMap(Map<String, dynamic> map) {
    return PricingPeriod(
      id: map['id']?.toString() ?? '',
      from: _parseDate(map['from']) ?? DateTime.now(),
      to: _parseDate(map['to']) ?? DateTime.now(),
      price: _parsePrice(map['price']),
    );
  }

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return dateOnly(value.toDate());
    if (value is DateTime) return dateOnly(value);
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed == null ? null : dateOnly(parsed);
    }
    return null;
  }

  static List<PricingPeriod> listFromFirestore(dynamic raw) {
    if (raw is! List) return const [];
    final periods = <PricingPeriod>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map) continue;
      final p = PricingPeriod.fromMap(Map<String, dynamic>.from(item)).normalized();
      if (p.price <= 0) continue;
      final id = p.id.isNotEmpty
          ? p.id
          : 'period_${i}_${p.from.millisecondsSinceEpoch}_${p.price.toInt()}';
      periods.add(
        PricingPeriod(id: id, from: p.from, to: p.to, price: p.price),
      );
    }
    periods.sort((a, b) => a.from.compareTo(b.from));
    return periods;
  }

  @override
  List<Object?> get props => [id, from, to, price];
}
