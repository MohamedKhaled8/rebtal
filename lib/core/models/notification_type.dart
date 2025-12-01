enum NotificationType {
  bookingRequest('booking_request'),
  bookingApproved('booking_approved'),
  bookingRejected('booking_rejected'),
  chaletApproved('chalet_approved'),
  chaletRejected('chalet_rejected'),
  general('general');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationType.bookingRequest:
        return 'طلب حجز جديد';
      case NotificationType.bookingApproved:
        return 'تم قبول الحجز';
      case NotificationType.bookingRejected:
        return 'تم رفض الحجز';
      case NotificationType.chaletApproved:
        return 'تم قبول الشاليه';
      case NotificationType.chaletRejected:
        return 'تم رفض الشاليه';
      case NotificationType.general:
        return 'إشعار عام';
    }
  }
}
