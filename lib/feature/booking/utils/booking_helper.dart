class BookingHelper {
  static String getShortId(String value) {
    if (value.isEmpty) return value;
    if (value.length <= 10) return value;
    return '${value.substring(0, 6)}…${value.substring(value.length - 4)}';
  }

  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime dt) {
    final local = dt.toLocal();

    // أسماء الأيام بالعربي
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final dayName = days[(local.weekday - 1) % 7];

    // التاريخ
    final date =
        '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';

    // الوقت بنظام 12 ساعة
    int hour = local.hour;
    String period = 'ص'; // صباحاً

    if (hour >= 12) {
      period = 'م'; // مساءً
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;

    final time =
        '${hour.toString()}:${local.minute.toString().padLeft(2, '0')} $period';

    return '$dayName، $date - $time';
  }
}
