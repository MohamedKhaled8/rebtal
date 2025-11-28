import 'dart:io';

abstract class OwnerState {
  const OwnerState();
}

class OwnerInitial extends OwnerState {}

class OwnerData extends OwnerState {
  final List<File> uploadedImages;
  final File? profileImage;
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

  // 🆕
  final String? merchantName;
  final String price; // 🆕
  final String? chaletArea; // 🆕 Area in sqm
  final int? bedrooms;
  final int? bathrooms;

  // 🆕 التواريخ
  final DateTime? availableFrom;
  final DateTime? availableTo;
  // Geo
  final double? latitude;
  final double? longitude;
  // 🆕 Children Count
  final int? childrenCount;
  // 🆕 Discount
  final bool discountEnabled;
  final String? discountType; // 'percentage' or 'fixed'
  final String? discountValue;
  // 🆕 Features
  final List<String> features; // Pool, Sea, Family Gathering, Luxury, Mountain

  const OwnerData({
    required this.uploadedImages,
    this.profileImage,
    this.email,
    required this.selectedLocation,
    required this.isAvailable,
    required this.hasWifi,
    this.hasPool = false,
    this.hasAirConditioning = false,
    this.hasParking = false,
    this.hasGarden = false,
    this.hasBBQ = false,
    this.hasBeachView = false,
    this.hasHousekeeping = false,
    this.hasPetsAllowed = false,
    this.hasGym = false,
    this.hasKitchen = false,
    this.hasTV = false,
    this.status = "pending",
    this.phoneNumber,
    this.chaletName,
    this.description,
    this.merchantName,
    required this.price,
    this.chaletArea,
    this.bedrooms,
    this.bathrooms,
    this.availableFrom,
    this.availableTo,
    this.latitude,
    this.longitude,
    this.childrenCount,
    this.discountEnabled = false,
    this.discountType,
    this.discountValue,
    this.features = const [],
  });

  OwnerData copyWith({
    List<File>? uploadedImages,
    File? profileImage,
    String? selectedLocation,
    bool? isAvailable,
    bool? hasWifi,
    bool? hasPool,
    bool? hasAirConditioning,
    bool? hasParking,
    bool? hasGarden,
    bool? hasBBQ,
    bool? hasBeachView,
    bool? hasHousekeeping,
    bool? hasPetsAllowed,
    bool? hasGym,
    bool? hasKitchen,
    bool? hasTV,
    String? status,
    String? phoneNumber,
    String? chaletName,
    String? description,
    String? merchantName,
    String? email,
    String? price,
    String? chaletArea,
    int? bedrooms,
    int? bathrooms,
    bool clearProfileImage = false,
    DateTime? availableFrom,
    DateTime? availableTo,
    double? latitude,
    double? longitude,
    int? childrenCount,
    bool? discountEnabled,
    String? discountType,
    String? discountValue,
    List<String>? features,
  }) {
    return OwnerData(
      uploadedImages: uploadedImages ?? this.uploadedImages,
      profileImage: clearProfileImage
          ? null
          : profileImage ?? this.profileImage,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      isAvailable: isAvailable ?? this.isAvailable,
      hasWifi: hasWifi ?? this.hasWifi,
      hasPool: hasPool ?? this.hasPool,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasParking: hasParking ?? this.hasParking,
      hasGarden: hasGarden ?? this.hasGarden,
      hasBBQ: hasBBQ ?? this.hasBBQ,
      hasBeachView: hasBeachView ?? this.hasBeachView,
      hasHousekeeping: hasHousekeeping ?? this.hasHousekeeping,
      hasPetsAllowed: hasPetsAllowed ?? this.hasPetsAllowed,
      hasGym: hasGym ?? this.hasGym,
      hasKitchen: hasKitchen ?? this.hasKitchen,
      hasTV: hasTV ?? this.hasTV,
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      chaletName: chaletName ?? this.chaletName,
      description: description ?? this.description,
      merchantName: merchantName ?? this.merchantName,
      price: price ?? this.price,
      chaletArea: chaletArea ?? this.chaletArea,
      email: email ?? this.email,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      childrenCount: childrenCount ?? this.childrenCount,
      discountEnabled: discountEnabled ?? this.discountEnabled,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      features: features ?? this.features,
    );
  }
}

final class OwnerLoading extends OwnerState {}

final class OwnerLoaded extends OwnerState {
  final List<Map<String, dynamic>> chalets;
  OwnerLoaded(this.chalets);
}

final class OwnerError extends OwnerState {
  final String message;
  OwnerError(this.message);
}
