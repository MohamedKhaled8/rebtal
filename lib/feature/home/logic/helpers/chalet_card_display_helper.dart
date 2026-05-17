import 'package:cloud_firestore/cloud_firestore.dart';

class ChaletCardDisplayHelper {
  static bool isDayUseUnavailableToday(Map<String, dynamic> data) {
    final dayUseEnabled = data['dayUseEnabled'] == true;
    if (!dayUseEnabled) return false;
    final status = data['dayUseBookingAvailability']?.toString();
    final bookedAt = data['dayUseBookedAt']?.toString();
    if (status != 'unavailable' || bookedAt == null || bookedAt.isEmpty) {
      return false;
    }
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return bookedAt == todayKey;
  }

  static bool isNewChalet(Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    if (createdAt == null) return false;

    DateTime? date;
    if (createdAt is Timestamp) {
      date = createdAt.toDate();
    } else if (createdAt is String) {
      date = DateTime.tryParse(createdAt);
    }

    if (date == null) return false;
    return DateTime.now().difference(date).inHours <= 48;
  }

  static bool hasDiscount(Map<String, dynamic> data) {
    final discountEnabled = data['discountEnabled'] ?? false;
    final discountValue = data['discountValue'];
    return discountEnabled == true &&
        discountValue != null &&
        discountValue.toString().isNotEmpty;
  }

  static String calculateDiscountedPrice(Map<String, dynamic> data) {
    final price = data['price'];
    final discountType = data['discountType'];
    final discountValue = data['discountValue'];

    if (!hasDiscount(data) || price == null) return price?.toString() ?? '0';

    final originalPrice = (price is num)
        ? price.toDouble()
        : double.tryParse(price.toString().replaceAll(RegExp('[^0-9.]'), '')) ??
              0.0;

    final value = (discountValue is num)
        ? discountValue.toDouble()
        : double.tryParse(
                discountValue.toString().replaceAll(RegExp('[^0-9.]'), ''),
              ) ??
              0.0;

    var discountedPrice = originalPrice;
    if (discountType == 'percentage') {
      discountedPrice = originalPrice - (originalPrice * (value / 100));
    } else {
      discountedPrice = originalPrice - value;
    }

    if (discountedPrice < 0) discountedPrice = 0;
    return discountedPrice.toStringAsFixed(0);
  }
}
