import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';

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

  /// Sort bookings with most recent activity first, then by workflow priority.
  static List<Booking> sortBookings(List<Booking> bookings) {
    final sorted = List<Booking>.from(bookings);
    sorted.sort((a, b) {
      final ta =
          a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb =
          b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final byRecent = tb.compareTo(ta);
      if (byRecent != 0) return byRecent;

      final priorityA = getBookingPriority(a.status);
      final priorityB = getBookingPriority(b.status);
      return priorityA.compareTo(priorityB);
    });
    return sorted;
  }

  /// Filter valid bookings (exclude temp/corrupt records)
  static List<Booking> filterValidBookings(List<Booking> bookings) {
    return bookings.toList();
  }

  /// Collect images from chalet data Map (same rules as admin/detail screens).
  static List<String> collectChaletImages(Map<String, dynamic> data) {
    final urls = collectChaletImageUrls(data);
    if (urls.isEmpty) {
      return const [''];
    }
    return urls.length > 5 ? urls.sublist(0, 5) : urls;
  }

  /// Calculate discounted price string
  static double calculateFinalPrice(Map<String, dynamic> data) {
    return calculateFinalPriceFromBase(data, _parseStoredPrice(data['price']));
  }

  /// Day-use price with the same admin discount rules as overnight price.
  static double calculateDayUseFinalPrice(Map<String, dynamic> data) {
    final dayUseBase = _parseStoredPrice(data['dayUsePrice']);
    final base = dayUseBase > 0 ? dayUseBase : _parseStoredPrice(data['price']);
    return calculateFinalPriceFromBase(data, base);
  }

  /// Price shown on cards / detail for users (day-use listings use [dayUsePrice]).
  static double listingDisplayPrice(
    Map<String, dynamic> data, {
    bool preferDayUse = false,
  }) {
    if (preferDayUse || data['dayUseOnly'] == true) {
      final dayUse = calculateDayUseFinalPrice(data);
      if (dayUse > 0) return dayUse;
    }
    return calculateFinalPrice(data);
  }

  static bool shouldLabelPricePerDay(
    Map<String, dynamic> data, {
    bool preferDayUse = false,
  }) {
    if (data['dayUseOnly'] == true) return true;
    if (!preferDayUse) return false;
    return _parseStoredPrice(data['dayUsePrice']) > 0;
  }

  static double _parseStoredPrice(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(
          (raw ?? '').toString().replaceAll(RegExp('[^0-9.]'), ''),
        ) ??
        0.0;
  }

  static double calculateFinalPriceFromBase(
    Map<String, dynamic> data,
    double basePrice,
  ) {
    if (data['discountEnabled'] != true) return basePrice;

    final discountType = data['discountType'];
    final discountValue =
        double.tryParse(data['discountValue']?.toString() ?? '0') ?? 0.0;
    if (discountValue <= 0) return basePrice;

    double finalPrice = basePrice;
    if (discountType == 'percentage') {
      finalPrice = basePrice * (1 - discountValue / 100);
    } else if (discountType == 'fixed') {
      finalPrice = basePrice - discountValue;
      if (finalPrice < 0) finalPrice = 0;
    }
    return finalPrice;
  }

  static bool getGeneralAmenityFlag(ChaletDraft draft, String key) {
    switch (key) {
      case 'hasWifi':
        return draft.hasWifi;
      case 'hasPool':
        return draft.hasPool;
      case 'hasAirConditioning':
        return draft.hasAirConditioning;
      case 'hasParking':
        return draft.hasParking;
      case 'hasGarden':
        return draft.hasGarden;
      case 'hasBBQ':
        return draft.hasBBQ;
      case 'hasBeachView':
        return draft.hasBeachView;
      case 'hasHousekeeping':
        return draft.hasHousekeeping;
      case 'hasPetsAllowed':
        return draft.hasPetsAllowed;
      case 'hasGym':
        return draft.hasGym;
      case 'hasKitchen':
        return draft.hasKitchen;
      case 'hasTV':
        return draft.hasTV;
      default:
        return false;
    }
  }

  static ChaletDraft setGeneralAmenityFlag(
    ChaletDraft draft,
    String key,
    bool value,
  ) {
    switch (key) {
      case 'hasWifi':
        return draft.copyWith(hasWifi: value);
      case 'hasPool':
        return draft.copyWith(hasPool: value);
      case 'hasAirConditioning':
        return draft.copyWith(hasAirConditioning: value);
      case 'hasParking':
        return draft.copyWith(hasParking: value);
      case 'hasGarden':
        return draft.copyWith(hasGarden: value);
      case 'hasBBQ':
        return draft.copyWith(hasBBQ: value);
      case 'hasBeachView':
        return draft.copyWith(hasBeachView: value);
      case 'hasHousekeeping':
        return draft.copyWith(hasHousekeeping: value);
      case 'hasPetsAllowed':
        return draft.copyWith(hasPetsAllowed: value);
      case 'hasGym':
        return draft.copyWith(hasGym: value);
      case 'hasKitchen':
        return draft.copyWith(hasKitchen: value);
      case 'hasTV':
        return draft.copyWith(hasTV: value);
      default:
        return draft;
    }
  }

  static ChaletDraft setDayUseAmenity(ChaletDraft draft, String key, bool value) {
    final updated = List<String>.from(draft.dayUseAmenities);
    if (value) {
      if (!updated.contains(key)) updated.add(key);
    } else {
      updated.remove(key);
    }
    return draft.copyWith(dayUseAmenities: updated);
  }

  static bool isAmenitySelectedForDisplay(ChaletDraft draft, String key) {
    if (draft.dayUseOnly) return draft.dayUseAmenities.contains(key);
    if (!draft.dayUseEnabled) return getGeneralAmenityFlag(draft, key);
    return getGeneralAmenityFlag(draft, key);
  }

  static Map<String, bool> amenitiesDisplayMap(ChaletDraft draft) {
    return {
      for (final amenity in allAmenities)
        amenity['key'] as String: isAmenitySelectedForDisplay(
          draft,
          amenity['key'] as String,
        ),
    };
  }

  static ChaletDraft applyAmenityUpdate(
    ChaletDraft draft,
    String amenityKey,
    bool value,
  ) {
    if (draft.dayUseOnly) {
      return setDayUseAmenity(draft, amenityKey, value);
    }
    if (!draft.dayUseEnabled) {
      return setGeneralAmenityFlag(draft, amenityKey, value);
    }
    return setDayUseAmenity(
      setGeneralAmenityFlag(draft, amenityKey, value),
      amenityKey,
      value,
    );
  }

  static bool requiresDayUsePrice(ChaletDraft draft) =>
      draft.dayUseEnabled || draft.dayUseOnly;

  /// Chalet appears in the day-use section (either listing mode).
  static bool isListedInDayUseSection(Map<String, dynamic> data) =>
      data['dayUseEnabled'] == true || data['dayUseOnly'] == true;

  static bool supportsDayUseBooking(Map<String, dynamic> data) =>
      isListedInDayUseSection(data);

  static List<String> buildGeneralAmenitiesList(ChaletDraft draft) {
    final list = <String>[];
    for (final amenity in allAmenities) {
      final key = amenity['key'] as String;
      if (getGeneralAmenityFlag(draft, key)) list.add(key);
    }
    return list;
  }

  static List<String> buildDayUseAmenitiesList(ChaletDraft draft) {
    return List<String>.from(draft.dayUseAmenities);
  }

  static Map<String, bool> dayUseAmenityFlags(ChaletDraft draft) {
    return {
      for (final amenity in allAmenities)
        amenity['key'] as String: draft.dayUseAmenities.contains(
          amenity['key'] as String,
        ),
    };
  }

  static const List<Map<String, dynamic>> allAmenities = [
    {
      'key': 'hasWifi',
      'label': 'واي فاي',
      'icon': Icons.wifi,
      'color': ColorsManager.chaletActionBlue,
    },
    {
      'key': 'hasPool',
      'label': 'مسبح',
      'icon': Icons.pool,
      'color': ColorsManager.cyan06B6D4,
    },
    {
      'key': 'hasAirConditioning',
      'label': 'تكييف',
      'icon': Icons.ac_unit,
      'color': ColorsManager.bookingsWarningOrange,
    },
    {
      'key': 'hasParking',
      'label': 'موقف سيارات',
      'icon': Icons.local_parking,
      'color': ColorsManager.purple8B5CF6,
    },
    {
      'key': 'hasGarden',
      'label': 'حديقة',
      'icon': Icons.local_florist,
      'color': ColorsManager.chaletActionGreen,
    },
    {
      'key': 'hasBBQ',
      'label': 'منطقة شواء',
      'icon': Icons.outdoor_grill,
      'color': ColorsManager.chaletUnavailableRed,
    },
    {
      'key': 'hasBeachView',
      'label': 'إطلالة على البحر',
      'icon': Icons.beach_access,
      'color': ColorsManager.skyBlue0EA5E9,
    },
    {
      'key': 'hasHousekeeping',
      'label': 'خدمة تنظيف',
      'icon': Icons.cleaning_services,
      'color': ColorsManager.indigo6366F1,
    },
    {
      'key': 'hasPetsAllowed',
      'label': 'حيوانات أليفة',
      'icon': Icons.pets,
      'color': ColorsManager.chaletGalleryPink,
    },
    {
      'key': 'hasGym',
      'label': 'صالة رياضة',
      'icon': Icons.fitness_center,
      'color': ColorsManager.teal,
    },
    {
      'key': 'hasKitchen',
      'label': 'مطبخ',
      'icon': Icons.kitchen,
      'color': ColorsManager.orange,
    },
    {
      'key': 'hasTV',
      'label': 'تلفاز',
      'icon': Icons.tv,
      'color': ColorsManager.indigo6366F1,
    },
  ];
}
