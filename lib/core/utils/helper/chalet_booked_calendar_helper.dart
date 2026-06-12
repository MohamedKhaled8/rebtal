import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart' as di;
import 'package:rebtal/feature/chalet/domain/usecases/get_chalet_booked_dates_usecase.dart';

DateTime chaletDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Calendar day buckets for booking UI.
class ChaletCalendarOccupancy {
  final Set<DateTime> confirmedBooked;
  final Set<DateTime> pendingReview;

  const ChaletCalendarOccupancy({
    required this.confirmedBooked,
    required this.pendingReview,
  });

  static const empty = ChaletCalendarOccupancy(
    confirmedBooked: {},
    pendingReview: {},
  );
}

const _pendingBookingStatuses = [
  'pending',
  'approved',
  'awaitingPayment',
  'paymentUnderReview',
  'pendingOwnerApproval',
  'reOffered',
];

/// Days unavailable — [confirmed] / [completed] only.
Future<Set<DateTime>> loadChaletBookedDaySet(String chaletId) async {
  if (chaletId.isEmpty) return {};
  final result = await di.getIt<GetChaletBookedDatesUseCase>()(chaletId);
  return result.fold(
    (_) => <DateTime>{},
    (dates) => {for (final d in dates) chaletDateOnly(d)},
  );
}

/// Confirmed + pending-review days for calendar coloring.
Future<ChaletCalendarOccupancy> loadChaletCalendarOccupancy(
  String chaletId,
) async {
  if (chaletId.isEmpty) return ChaletCalendarOccupancy.empty;

  final confirmed = await loadChaletBookedDaySet(chaletId);
  final pending = await _loadPendingReviewDaySet(chaletId);

  pending.removeAll(confirmed);
  return ChaletCalendarOccupancy(
    confirmedBooked: confirmed,
    pendingReview: pending,
  );
}

Future<Set<DateTime>> _loadPendingReviewDaySet(String chaletId) async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection('bookings')
        .where('chaletId', isEqualTo: chaletId)
        .where('status', whereIn: _pendingBookingStatuses)
        .get();

    final days = <DateTime>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      final from = _parseBookingDate(data['from']);
      final to = _parseBookingDate(data['to']);
      if (from == null || to == null) continue;

      var cursor = chaletDateOnly(from);
      final endDay = chaletDateOnly(to);
      while (cursor.isBefore(endDay)) {
        days.add(cursor);
        cursor = cursor.add(const Duration(days: 1));
      }
    }
    return days;
  } catch (_) {
    return {};
  }
}

DateTime? _parseBookingDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

bool isChaletDayBooked(Set<DateTime> bookedDays, DateTime day) {
  return bookedDays.contains(chaletDateOnly(day));
}
