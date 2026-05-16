import 'dart:io';

class ChaletDraftSnapshot {
  final List<File> uploadedImages;
  final String selectedLocation;
  final bool isAvailable;
  final bool hasWifi;
  final bool hasPool;
  final bool hasAirConditioning;
  final bool hasParking;
  final bool hasGarden;
  final bool hasBBQ;
  final bool hasBeachView;
  final bool hasHousekeeping;
  final bool hasPetsAllowed;
  final bool hasGym;
  final bool hasKitchen;
  final bool hasTV;
  final String status;
  final String? phoneNumber;
  final String? email;
  final String? chaletName;
  final String? description;
  final String? merchantName;
  final String price;
  final String? chaletArea;
  final int? bedrooms;
  final int? bathrooms;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final int? childrenCount;
  final bool discountEnabled;
  final String? discountType;
  final String? discountValue;
  final List<String> features;

  const ChaletDraftSnapshot({
    required this.uploadedImages,
    required this.selectedLocation,
    required this.isAvailable,
    required this.hasWifi,
    required this.hasPool,
    required this.hasAirConditioning,
    required this.hasParking,
    required this.hasGarden,
    required this.hasBBQ,
    required this.hasBeachView,
    required this.hasHousekeeping,
    required this.hasPetsAllowed,
    required this.hasGym,
    required this.hasKitchen,
    required this.hasTV,
    required this.status,
    required this.phoneNumber,
    required this.email,
    required this.chaletName,
    required this.description,
    required this.merchantName,
    required this.price,
    required this.chaletArea,
    required this.bedrooms,
    required this.bathrooms,
    required this.availableFrom,
    required this.availableTo,
    required this.childrenCount,
    required this.discountEnabled,
    required this.discountType,
    required this.discountValue,
    required this.features,
  });
}
