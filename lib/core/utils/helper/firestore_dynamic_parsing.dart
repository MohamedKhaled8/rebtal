import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore fields may be [Timestamp], ISO [String], [DateTime], or millis [int].
/// Never use `as Timestamp?` on raw map values — user docs use string dates from [UserModel].
Timestamp firestoreDynamicToTimestamp(
  dynamic value, {
  Timestamp? fallback,
}) {
  final fb = fallback ?? Timestamp.now();
  if (value == null) return fb;
  if (value is Timestamp) return value;
  if (value is DateTime) return Timestamp.fromDate(value);
  if (value is String && value.isNotEmpty) {
    try {
      return Timestamp.fromDate(DateTime.parse(value));
    } catch (_) {
      return fb;
    }
  }
  if (value is int) {
    return Timestamp.fromMillisecondsSinceEpoch(value);
  }
  return fb;
}
