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

  static ({double refundAmount, double refundPercentage, String message})
  calculateRefund(DateTime checkInDate, double totalAmount) {
    final now = DateTime.now();

    // Normalize to midnight to ignore hours/minutes
    final dateCheckIn = DateTime(
      checkInDate.year,
      checkInDate.month,
      checkInDate.day,
    );
    final dateToday = DateTime(now.year, now.month, now.day);

    final difference = dateCheckIn.difference(dateToday).inDays;

    // Policy:
    // >= 7 days: 100%
    // 3 - 6 days: 50%
    // < 3 days: 0%

    if (difference >= 7) {
      return (
        refundAmount: totalAmount,
        refundPercentage: 100.0,
        message: 'استرداد كامل (100%) - الإلغاء قبل الموعد بـ 7 أيام أو أكثر.',
      );
    } else if (difference >= 3) {
      final amount = totalAmount * 0.5;
      return (
        refundAmount: amount,
        refundPercentage: 50.0,
        message: 'استرداد جزئي (50%) - الإلغاء قبل الموعد بـ 3 إلى 7 أيام.',
      );
    } else {
      return (
        refundAmount: 0.0,
        refundPercentage: 0.0,
        message: 'غير مسترد (0%) - الإلغاء قبل الموعد بأقل من 3 أيام.',
      );
    }
  }
}
