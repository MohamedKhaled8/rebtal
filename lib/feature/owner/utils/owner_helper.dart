import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';

/// Helper class for booking-related utilities
class OwnerHelper {
  /// Get priority for sorting bookings
  /// Lower number = higher priority
  static int getBookingPriority(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 0; // Highest priority - requires approval
      case BookingStatus.paymentUnderReview:
        return 1; // Requires verification
      case BookingStatus.awaitingPayment:
        return 2; // Waiting for payment
      case BookingStatus.approved:
        return 3; // Active bookings
      default:
        return 4; // Completed, Cancelled, Rejected
    }
  }

  /// Sort bookings by priority and date
  static List<Booking> sortBookings(List<Booking> bookings) {
    final sorted = List<Booking>.from(bookings);
    sorted.sort((a, b) {
      final priorityA = getBookingPriority(a.status);
      final priorityB = getBookingPriority(b.status);

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      // If same priority, sort by createdAt (newest first)
      final dateA = a.createdAt ?? DateTime(2000);
      final dateB = b.createdAt ?? DateTime(2000);
      return dateB.compareTo(dateA); // Descending order
    });
    return sorted;
  }

  /// Filter valid bookings (exclude temp/corrupt records)
  static List<Booking> filterValidBookings(List<Booking> bookings) {
    return bookings.toList();
  }

  /// Collect images from chalet data Map
  static List<String> collectChaletImages(Map<String, dynamic> data) {
    final List<dynamic>? imgs = data['images'] as List<dynamic>?;
    final List<String> result = [];

    final String? profile = data['profileImage']?.toString();
    if (profile != null && profile.isNotEmpty) {
      result.add(profile);
    }

    if (imgs != null) {
      for (final e in imgs) {
        if (e == null) continue;
        final s = e.toString();
        if (s.isNotEmpty && s != profile) {
          result.add(s);
        }
        if (result.length >= 5) break;
      }
    }

    if (result.isEmpty) {
      result.add('https://via.placeholder.com/400x300?text=No+Image');
    }

    return result;
  }

  /// Calculate discounted price string
  static double calculateFinalPrice(Map<String, dynamic> data) {
    final basePrice = (data['price'] is num)
        ? data['price'].toDouble()
        : double.tryParse(
                (data['price'] ?? '').toString().replaceAll(
                  RegExp('[^0-9.]'),
                  '',
                ),
              ) ??
              0.0;
    final discountType = data['discountType'];
    final discountValue = double.tryParse(data['discountValue'] ?? '0') ?? 0.0;

    double finalPrice = basePrice;
    if (discountType == 'percentage' && discountValue > 0) {
      finalPrice = basePrice * (1 - discountValue / 100);
    } else if (discountType == 'fixed' && discountValue > 0) {
      finalPrice = basePrice - discountValue;
      if (finalPrice < 0) finalPrice = 0;
    }
    return finalPrice;
  }

  static const List<Map<String, dynamic>> allAmenities = [
    {
      'key': 'hasWifi',
      'label': 'واي فاي',
      'icon': Icons.wifi,
      'color': ColorManager.chaletActionBlue,
    },
    {
      'key': 'hasPool',
      'label': 'مسبح',
      'icon': Icons.pool,
      'color': ColorManager.cyan06B6D4,
    },
    {
      'key': 'hasAirConditioning',
      'label': 'تكييف',
      'icon': Icons.ac_unit,
      'color': ColorManager.bookingsWarningOrange,
    },
    {
      'key': 'hasParking',
      'label': 'موقف سيارات',
      'icon': Icons.local_parking,
      'color': ColorManager.purple8B5CF6,
    },
    {
      'key': 'hasGarden',
      'label': 'حديقة',
      'icon': Icons.local_florist,
      'color': ColorManager.chaletActionGreen,
    },
    {
      'key': 'hasBBQ',
      'label': 'منطقة شواء',
      'icon': Icons.outdoor_grill,
      'color': ColorManager.chaletUnavailableRed,
    },
    {
      'key': 'hasBeachView',
      'label': 'إطلالة على البحر',
      'icon': Icons.beach_access,
      'color': ColorManager.skyBlue0EA5E9,
    },
    {
      'key': 'hasHousekeeping',
      'label': 'خدمة تنظيف',
      'icon': Icons.cleaning_services,
      'color': ColorManager.indigo6366F1,
    },
    {
      'key': 'hasPetsAllowed',
      'label': 'حيوانات أليفة',
      'icon': Icons.pets,
      'color': ColorManager.chaletGalleryPink,
    },
    {
      'key': 'hasGym',
      'label': 'صالة رياضة',
      'icon': Icons.fitness_center,
      'color': ColorManager.teal,
    },
    {
      'key': 'hasKitchen',
      'label': 'مطبخ',
      'icon': Icons.kitchen,
      'color': ColorManager.orange,
    },
    {
      'key': 'hasTV',
      'label': 'تلفاز',
      'icon': Icons.tv,
      'color': ColorManager.indigo6366F1,
    },
  ];
}
