class Booking {
  final DateTime startDate;
  final DateTime endDate;
  final int maxBookings; // عدد الحجوزات المسموح

  Booking({
    required this.startDate,
    required this.endDate,
    required this.maxBookings,
  });
}
