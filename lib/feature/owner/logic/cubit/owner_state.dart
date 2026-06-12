import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:rebtal/core/utils/model/pricing_period.dart';

enum OwnerStatus { initial, loading, loaded, error }

class OwnerState extends Equatable {
  // Dashboard / List State
  final OwnerStatus status;
  // List of chalets as raw Maps to preserve all Firestore fields
  final List<dynamic> chalets;
  final String? errorMessage;

  // Add/Edit Form State
  final ChaletDraft draft;
  final bool isFormSubmitting;
  final String? formError;
  final bool isFormSuccess;

  // Location Search State
  final List<Map<String, dynamic>> locationResults;
  final bool isLocationLoading;

  const OwnerState({
    this.status = OwnerStatus.initial,
    this.chalets = const [],
    this.errorMessage,
    required this.draft,
    this.isFormSubmitting = false,
    this.formError,
    this.isFormSuccess = false,
    this.locationResults = const [],
    this.isLocationLoading = false,
  });

  factory OwnerState.initial() {
    return OwnerState(draft: ChaletDraft.initial());
  }

  OwnerState copyWith({
    OwnerStatus? status,
    List<dynamic>? chalets,
    String? errorMessage,
    ChaletDraft? draft,
    bool? isFormSubmitting,
    String? formError,
    bool? isFormSuccess,
    List<Map<String, dynamic>>? locationResults,
    bool? isLocationLoading,
  }) {
    return OwnerState(
      status: status ?? this.status,
      chalets: chalets ?? this.chalets,
      errorMessage: errorMessage ?? this.errorMessage,
      draft: draft ?? this.draft,
      isFormSubmitting: isFormSubmitting ?? this.isFormSubmitting,
      formError: formError ?? this.formError,
      isFormSuccess: isFormSuccess ?? this.isFormSuccess,
      locationResults: locationResults ?? this.locationResults,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
    );
  }

  /// Helper to clear form error/success state
  OwnerState resetFormState() {
    return copyWith(
      isFormSubmitting: false,
      isFormSuccess: false,
      formError: null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    chalets,
    errorMessage,
    draft,
    isFormSubmitting,
    formError,
    isFormSuccess,
    locationResults,
    isLocationLoading,
  ];
}

class ChaletDraft extends Equatable {
  final List<File> uploadedImages;

  /// Existing remote URLs when editing an approved listing (not mixed with [uploadedImages]).
  final List<String> existingImageUrls;
  final File? profileImage;
  final String selectedLocation;
  final bool isAvailable;

  // Amenities
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
  final List<PricingPeriod> pricingPeriods;

  final double? latitude;
  final double? longitude;

  final int? childrenCount;
  final bool discountEnabled;
  final String? discountType;
  final String? discountValue;
  final List<String> features;
  final bool dayUseEnabled;
  final String? popularDestination;

  const ChaletDraft({
    this.uploadedImages = const [],
    this.existingImageUrls = const [],
    this.profileImage,
    this.selectedLocation = '',
    this.isAvailable = true,
    this.hasWifi = false,
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
    this.status = 'pending',
    this.phoneNumber,
    this.email,
    this.chaletName,
    this.description,
    this.merchantName,
    this.price = '',
    this.chaletArea,
    this.bedrooms,
    this.bathrooms,
    this.availableFrom,
    this.availableTo,
    this.pricingPeriods = const [],
    this.latitude,
    this.longitude,
    this.childrenCount,
    this.discountEnabled = false,
    this.discountType,
    this.discountValue,
    this.features = const [],
    this.dayUseEnabled = false,
    this.popularDestination,
  });

  factory ChaletDraft.initial() => const ChaletDraft();

  ChaletDraft copyWith({
    List<File>? uploadedImages,
    List<String>? existingImageUrls,
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
    String? email,
    String? chaletName,
    String? description,
    String? merchantName,
    String? price,
    String? chaletArea,
    int? bedrooms,
    int? bathrooms,
    DateTime? availableFrom,
    DateTime? availableTo,
    List<PricingPeriod>? pricingPeriods,
    double? latitude,
    double? longitude,
    int? childrenCount,
    bool? discountEnabled,
    String? discountType,
    String? discountValue,
    List<String>? features,
    bool? dayUseEnabled,
    bool clearProfileImage = false,
    String? popularDestination,
  }) {
    return ChaletDraft(
      uploadedImages: uploadedImages ?? this.uploadedImages,
      existingImageUrls: existingImageUrls ?? this.existingImageUrls,
      profileImage: clearProfileImage
          ? null
          : (profileImage ?? this.profileImage),
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
      email: email ?? this.email,
      chaletName: chaletName ?? this.chaletName,
      description: description ?? this.description,
      merchantName: merchantName ?? this.merchantName,
      price: price ?? this.price,
      chaletArea: chaletArea ?? this.chaletArea,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      pricingPeriods: pricingPeriods ?? this.pricingPeriods,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      childrenCount: childrenCount ?? this.childrenCount,
      discountEnabled: discountEnabled ?? this.discountEnabled,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      features: features ?? this.features,
      dayUseEnabled: dayUseEnabled ?? this.dayUseEnabled,
      popularDestination: popularDestination ?? this.popularDestination,
    );
  }

  @override
  List<Object?> get props => [
    uploadedImages,
    existingImageUrls,
    profileImage,
    selectedLocation,
    isAvailable,
    hasWifi,
    hasPool,
    hasAirConditioning,
    hasParking,
    hasGarden,
    hasBBQ,
    hasBeachView,
    hasHousekeeping,
    hasPetsAllowed,
    hasGym,
    hasKitchen,
    hasTV,
    status,
    phoneNumber,
    email,
    chaletName,
    description,
    merchantName,
    price,
    chaletArea,
    bedrooms,
    bathrooms,
    availableFrom,
    availableTo,
    pricingPeriods,
    latitude,
    longitude,
    childrenCount,
    discountEnabled,
    discountType,
    discountValue,
    features,
    dayUseEnabled,
    popularDestination,
  ];
}
