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

  /// Returns refund amount, percentage, message, and tier index for UI.
  /// Tier: 0 = 7+ nights (100%), 1 = 3–6 nights (up to 50%), 2 = <3 nights (50% deduction), 3 = day of check-in (0%).
  static ({
    double refundAmount,
    double refundPercentage,
    String message,
    int tier,
  }) calculateRefund(DateTime checkInDate, double totalAmount) {
    final now = DateTime.now();
    final dateCheckIn = DateTime(
      checkInDate.year,
      checkInDate.month,
      checkInDate.day,
    );
    final dateToday = DateTime(now.year, now.month, now.day);
    final nightsBeforeCheckIn = dateCheckIn.difference(dateToday).inDays;

    // Policy: 7+ nights → 100%; 3–6 → up to 50%; <3 → 50% deduction; day-of → 0%
    if (nightsBeforeCheckIn >= 7) {
      return (
        refundAmount: totalAmount,
        refundPercentage: 100.0,
        message: 'استرداد كامل (100%) - الإلغاء قبل 7 ليالٍ أو أكثر من الوصول.',
        tier: 0,
      );
    }
    if (nightsBeforeCheckIn >= 3) {
      final amount = totalAmount * 0.5;
      return (
        refundAmount: amount,
        refundPercentage: 50.0,
        message: 'استرداد جزئي (50%) - الإلغاء قبل 3–6 ليالٍ من الوصول.',
        tier: 1,
      );
    }
    if (nightsBeforeCheckIn >= 1) {
      final amount = totalAmount * 0.5;
      return (
        refundAmount: amount,
        refundPercentage: 50.0,
        message: 'خصم 50% - الإلغاء قبل أقل من 3 ليالٍ من الوصول.',
        tier: 2,
      );
    }
    return (
      refundAmount: 0.0,
      refundPercentage: 0.0,
      message: 'لا استرداد (0%) - الإلغاء في يوم الوصول.',
      tier: 3,
    );
  }
}
