import 'package:rebtal/core/utils/dependency/get_it.dart' as di;
import 'package:rebtal/feature/chalet/domain/usecases/get_chalet_booked_dates_usecase.dart';

DateTime chaletDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Days (date-only) unavailable for new bookings — only [confirmed] / [completed]
/// in Firestore (after admin confirms payment). See [ChaletRemoteDataSource.getChaletBookings].
Future<Set<DateTime>> loadChaletBookedDaySet(String chaletId) async {
  if (chaletId.isEmpty) return {};
  final result = await di.getIt<GetChaletBookedDatesUseCase>()(chaletId);
  return result.fold(
    (_) => <DateTime>{},
    (dates) => {for (final d in dates) chaletDateOnly(d)},
  );
}

bool isChaletDayBooked(Set<DateTime> bookedDays, DateTime day) {
  return bookedDays.contains(chaletDateOnly(day));
}
