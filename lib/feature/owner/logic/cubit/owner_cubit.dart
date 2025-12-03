import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';

class OwnerCubit extends Cubit<OwnerState> {
  final ImagePicker _imagePicker = ImagePicker();

  OwnerCubit() : super(OwnerInitial()) {
    _initializeState();
  }

  void _initializeState() {
    emit(
      const OwnerData(
        uploadedImages: [],
        profileImage: null,
        selectedLocation: 'Sharm El Sheikh',
        isAvailable: true,
        hasWifi: false,
        status: "pending",
        // 🆕
        hasPool: false,
        hasAirConditioning: false,
        hasParking: false,
        hasGarden: false,
        hasBBQ: false,
        hasBeachView: false,
        hasHousekeeping: false,
        hasPetsAllowed: false,
        hasGym: false,
        hasKitchen: false,
        hasTV: false,
        price: '',
        chaletArea: '',
        latitude: null,
        longitude: null,
        childrenCount: null,
        discountEnabled: false,
        discountType: null,
        discountValue: null,
        features: [],
      ),
    );
  }

  // Get current data state
  OwnerData get currentData {
    final state = this.state;
    if (state is OwnerData) {
      return state;
    }
    return const OwnerData(
      uploadedImages: [],
      profileImage: null,
      selectedLocation: 'Sharm El Sheikh',
      isAvailable: true,
      hasWifi: false,

      // 🆕
      hasPool: false,
      hasAirConditioning: false,
      hasParking: false,
      price: '',
      chaletArea: '',
      latitude: null,
      longitude: null,
      childrenCount: null,
      discountEnabled: false,
      discountType: null,
      discountValue: null,
      features: [],
    );
  }

  // Location management
  void updateLocation(String location) {
    emit(currentData.copyWith(selectedLocation: location));
  }

  void updateGeo({required double lat, required double lon, String? address}) {
    emit(
      currentData.copyWith(
        latitude: lat,
        longitude: lon,
        selectedLocation: address ?? currentData.selectedLocation,
      ),
    );
  }

  // Availability management
  void updateAvailability(bool isAvailable) {
    emit(currentData.copyWith(isAvailable: isAvailable));
  }

  // WiFi management
  void updateWifiStatus(bool hasWifi) {
    emit(currentData.copyWith(hasWifi: hasWifi));
  }

  // 🆕 Pool management
  void updatePoolStatus(bool hasPool) {
    emit(currentData.copyWith(hasPool: hasPool));
  }

  // 🆕 Air conditioning management
  void updateAirConditioningStatus(bool hasAirConditioning) {
    emit(currentData.copyWith(hasAirConditioning: hasAirConditioning));
  }

  // 🆕 Parking management
  void updateParkingStatus(bool hasParking) {
    emit(currentData.copyWith(hasParking: hasParking));
  }

  // Extended amenities management
  void updateAmenity(String amenityKey, bool value) {
    switch (amenityKey) {
      case 'hasWifi':
        emit(currentData.copyWith(hasWifi: value));
        break;
      case 'hasPool':
        emit(currentData.copyWith(hasPool: value));
        break;
      case 'hasAirConditioning':
        emit(currentData.copyWith(hasAirConditioning: value));
        break;
      case 'hasParking':
        emit(currentData.copyWith(hasParking: value));
        break;
      case 'hasGarden':
        emit(currentData.copyWith(hasGarden: value));
        break;
      case 'hasBBQ':
        emit(currentData.copyWith(hasBBQ: value));
        break;
      case 'hasBeachView':
        emit(currentData.copyWith(hasBeachView: value));
        break;
      case 'hasHousekeeping':
        emit(currentData.copyWith(hasHousekeeping: value));
        break;
      case 'hasPetsAllowed':
        emit(currentData.copyWith(hasPetsAllowed: value));
        break;
      case 'hasGym':
        emit(currentData.copyWith(hasGym: value));
        break;
      case 'hasKitchen':
        emit(currentData.copyWith(hasKitchen: value));
        break;
      case 'hasTV':
        emit(currentData.copyWith(hasTV: value));
        break;
    }
  }

  // Get all amenities as a map
  Map<String, bool> getAmenitiesMap() {
    final data = currentData;
    return {
      'hasWifi': data.hasWifi,
      'hasPool': data.hasPool,
      'hasAirConditioning': data.hasAirConditioning,
      'hasParking': data.hasParking,
      'hasGarden': data.hasGarden,
      'hasBBQ': data.hasBBQ,
      'hasBeachView': data.hasBeachView,
      'hasHousekeeping': data.hasHousekeeping,
      'hasPetsAllowed': data.hasPetsAllowed,
      'hasGym': data.hasGym,
      'hasKitchen': data.hasKitchen,
      'hasTV': data.hasTV,
    };
  }

  void updatePhoneNumber(String phone) =>
      emit(currentData.copyWith(phoneNumber: phone));
  void updateChaletName(String name) =>
      emit(currentData.copyWith(chaletName: name));
  void updateDescription(String desc) =>
      emit(currentData.copyWith(description: desc));

  void updateEmail(String email) => emit(currentData.copyWith(email: email));
  // Add profile image
  Future<void> addProfileImage(ImageSource source) async {
    try {
      bool hasPermission = await _checkAndRequestPermissions(source);
      if (!hasPermission) {
        throw Exception(
          'Permission denied. Please grant camera/gallery access in settings.',
        );
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        emit(currentData.copyWith(profileImage: File(pickedFile.path)));
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add chalet images - supports multiple selection
  Future<List<String>> addChaletImage(ImageSource source) async {
    try {
      bool hasPermission = await _checkAndRequestPermissions(source);
      if (!hasPermission) {
        throw Exception(
          'Permission denied. Please grant camera/gallery access in settings.',
        );
      }

      const int maxTotalImages = 20; // Maximum total images allowed
      final currentCount = currentData.uploadedImages.length;

      if (currentCount >= maxTotalImages) {
        return ['Maximum of $maxTotalImages images allowed'];
      }

      List<File> validImages = [];
      Set<String> validationErrors = {}; // Use Set to deduplicate errors

      if (source == ImageSource.gallery) {
        // For gallery, allow multiple selection
        final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1200,
          maxHeight: 1200,
        );

        // Check if adding these images would exceed the limit
        final remainingSlots = maxTotalImages - currentCount;
        final filesToProcess = pickedFiles.length > remainingSlots
            ? pickedFiles.take(remainingSlots).toList()
            : pickedFiles;

        if (pickedFiles.length > remainingSlots) {
          validationErrors.add(
            'Only $remainingSlots more image(s) can be added (max $maxTotalImages total)',
          );
        }

        for (var pickedFile in filesToProcess) {
          final validationResult = _validateImage(File(pickedFile.path));
          if (validationResult == null) {
            validImages.add(File(pickedFile.path));
          } else {
            validationErrors.add(validationResult);
          }
        }
      } else {
        // For camera, single image only
        if (currentCount >= maxTotalImages) {
          return ['Maximum of $maxTotalImages images allowed'];
        }

        final XFile? pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1200,
          maxHeight: 1200,
        );

        if (pickedFile != null) {
          final validationResult = _validateImage(File(pickedFile.path));
          if (validationResult == null) {
            validImages.add(File(pickedFile.path));
          } else {
            validationErrors.add(validationResult);
          }
        }
      }

      if (validImages.isNotEmpty) {
        final updatedImages = List<File>.from(currentData.uploadedImages)
          ..addAll(validImages);
        emit(currentData.copyWith(uploadedImages: updatedImages));
      }

      return validationErrors.toList();
    } catch (e) {
      rethrow;
    }
  }

  // Validate image file
  String? _validateImage(File imageFile) {
    const int maxSizeInBytes = 5 * 1024 * 1024; // 5MB

    // Check file size
    final fileSize = imageFile.lengthSync();
    if (fileSize > maxSizeInBytes) {
      return 'Image size exceeds 5MB limit';
    }

    // Check file extension
    // Check file extension - REMOVED to allow all formats
    // final fileName = imageFile.path.toLowerCase();
    // final hasValidExtension = allowedExtensions.any(
    //   (ext) => fileName.endsWith('.$ext'),
    // );
    // if (!hasValidExtension) {
    //   return 'Only JPG, JPEG, and PNG formats are allowed';
    // }

    return null; // Valid
  }

  // Remove chalet image
  void removeChaletImage(int index) {
    final updatedImages = List<File>.from(currentData.uploadedImages);
    if (index < updatedImages.length) {
      updatedImages.removeAt(index);
      emit(currentData.copyWith(uploadedImages: updatedImages));
    }
  }

  Future<bool> _checkAndRequestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      PermissionStatus cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
      }
      return cameraStatus.isGranted;
    } else {
      // On Android there are two common gallery permission sets:
      // - older devices: READ_EXTERNAL_STORAGE / WRITE_EXTERNAL_STORAGE (Permission.storage)
      // - Android 13+: separate media permissions (Permission.photos maps to READ_MEDIA_IMAGES)
      // We'll try storage first, then photos, to cover both cases.
      if (Platform.isAndroid) {
        PermissionStatus storageStatus = await Permission.storage.status;
        if (storageStatus.isDenied) {
          storageStatus = await Permission.storage.request();
        }
        if (storageStatus.isGranted) return true;

        // Fallback / Android 13+
        PermissionStatus photosStatus = await Permission.photos.status;
        if (photosStatus.isDenied) {
          photosStatus = await Permission.photos.request();
        }
        return photosStatus.isGranted;
      } else {
        // iOS: request photos permission
        PermissionStatus photosStatus = await Permission.photos.status;
        if (photosStatus.isDenied) {
          photosStatus = await Permission.photos.request();
        }
        return photosStatus.isGranted;
      }
    }
  }

  void updateMerchantName(String name) =>
      emit(currentData.copyWith(merchantName: name));

  void updatePrice(String price) => emit(currentData.copyWith(price: price));

  void updateChaletArea(String area) =>
      emit(currentData.copyWith(chaletArea: area));

  void updateBedrooms(int bedrooms) =>
      emit(currentData.copyWith(bedrooms: bedrooms));

  void updateBathrooms(int bathrooms) =>
      emit(currentData.copyWith(bathrooms: bathrooms));
  // 🆕 تحديث التواريخ
  void updateAvailableFrom(DateTime date) =>
      emit(currentData.copyWith(availableFrom: date));

  void updateAvailableTo(DateTime date) =>
      emit(currentData.copyWith(availableTo: date));

  // 🆕 Children Count management
  void updateChildrenCount(int? count) =>
      emit(currentData.copyWith(childrenCount: count));

  // 🆕 Discount management
  void updateDiscountEnabled(bool enabled) => emit(
    currentData.copyWith(
      discountEnabled: enabled,
      discountType: enabled ? currentData.discountType : null,
      discountValue: enabled ? currentData.discountValue : null,
    ),
  );

  void updateDiscountType(String? type) =>
      emit(currentData.copyWith(discountType: type));

  void updateDiscountValue(String? value) =>
      emit(currentData.copyWith(discountValue: value));

  // 🆕 Features management
  void toggleFeature(String feature) {
    final currentFeatures = List<String>.from(currentData.features);
    if (currentFeatures.contains(feature)) {
      currentFeatures.remove(feature);
    } else {
      currentFeatures.add(feature);
    }
    emit(currentData.copyWith(features: currentFeatures));
  }

  // Fetch chalets from the database
  Future<void> fetchChalets() async {
    if (isClosed) return;
    emit(OwnerLoading());
    try {
      // Simulate fetching data from a database
      await Future.delayed(const Duration(seconds: 2));

      if (isClosed) return;

      final List<Map<String, dynamic>> chalets = [
        {
          'chaletName': 'شاليه البحر',
          'location': 'جدة',
          'price': 500,
          'status': 'approved',
          'images': ['https://example.com/chalet1.jpg'],
        },
        {
          'chaletName': 'شاليه الجبل',
          'location': 'الطائف',
          'price': 300,
          'status': 'pending',
          'images': ['https://example.com/chalet2.jpg'],
        },
      ];

      if (isClosed) return;
      emit(OwnerLoaded(chalets));
    } catch (e) {
      if (isClosed) return;
      emit(OwnerError(e.toString()));
    }
  }

  // 🆕 Add getter for current user ID
  String? get currentUserId {
    // Replace this with the actual logic to fetch the current user ID
    // For example, if using FirebaseAuth:
    // return FirebaseAuth.instance.currentUser?.uid;
    return null; // Placeholder
  }
}
