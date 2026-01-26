import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/feature/owner/domain/usecases/add_chalet_usecase.dart';
import 'package:rebtal/feature/owner/domain/usecases/get_owner_chalets_usecase.dart';
import 'package:rebtal/feature/owner/domain/entities/chalet_entity.dart';
import 'package:rebtal/core/utils/services/local_notification_service.dart';

class OwnerCubit extends Cubit<OwnerState> {
  final AddChaletUseCase addChaletUseCase;
  final GetOwnerChaletsUseCase getOwnerChaletsUseCase;
  final ImagePicker _imagePicker = ImagePicker();
  final Dio _dio = Dio();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OwnerCubit({
    required this.addChaletUseCase,
    required this.getOwnerChaletsUseCase,
  }) : super(OwnerState.initial()) {
    // Optionally load chalets on init if we have user ID available
    // But usually fetchChalets is called with ID.
  }

  // ==========================================
  // Form Updates (Draft Management)
  // ==========================================

  void updateLocation(String location) {
    emit(
      state.copyWith(draft: state.draft.copyWith(selectedLocation: location)),
    );
  }

  void updateGeo({required double lat, required double lon, String? address}) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          latitude: lat,
          longitude: lon,
          selectedLocation: address ?? state.draft.selectedLocation,
        ),
      ),
    );
  }

  void updateAvailability(bool isAvailable) {
    emit(state.copyWith(draft: state.draft.copyWith(isAvailable: isAvailable)));
  }

  // Amenities
  void updateAmenity(String amenityKey, bool value) {
    ChaletDraft newDraft;
    switch (amenityKey) {
      case 'hasWifi':
        newDraft = state.draft.copyWith(hasWifi: value);
        break;
      case 'hasPool':
        newDraft = state.draft.copyWith(hasPool: value);
        break;
      case 'hasAirConditioning':
        newDraft = state.draft.copyWith(hasAirConditioning: value);
        break;
      case 'hasParking':
        newDraft = state.draft.copyWith(hasParking: value);
        break;
      case 'hasGarden':
        newDraft = state.draft.copyWith(hasGarden: value);
        break;
      case 'hasBBQ':
        newDraft = state.draft.copyWith(hasBBQ: value);
        break;
      case 'hasBeachView':
        newDraft = state.draft.copyWith(hasBeachView: value);
        break;
      case 'hasHousekeeping':
        newDraft = state.draft.copyWith(hasHousekeeping: value);
        break;
      case 'hasPetsAllowed':
        newDraft = state.draft.copyWith(hasPetsAllowed: value);
        break;
      case 'hasGym':
        newDraft = state.draft.copyWith(hasGym: value);
        break;
      case 'hasKitchen':
        newDraft = state.draft.copyWith(hasKitchen: value);
        break;
      case 'hasTV':
        newDraft = state.draft.copyWith(hasTV: value);
        break;
      default:
        newDraft = state.draft;
    }
    emit(state.copyWith(draft: newDraft));
  }

  void updatePhoneNumber(String phone) =>
      emit(state.copyWith(draft: state.draft.copyWith(phoneNumber: phone)));

  void updateChaletName(String name) =>
      emit(state.copyWith(draft: state.draft.copyWith(chaletName: name)));

  void updateDescription(String desc) =>
      emit(state.copyWith(draft: state.draft.copyWith(description: desc)));

  void updateEmail(String email) =>
      emit(state.copyWith(draft: state.draft.copyWith(email: email)));

  void updateMerchantName(String name) =>
      emit(state.copyWith(draft: state.draft.copyWith(merchantName: name)));

  void updatePrice(String price) =>
      emit(state.copyWith(draft: state.draft.copyWith(price: price)));

  void updateChaletArea(String area) =>
      emit(state.copyWith(draft: state.draft.copyWith(chaletArea: area)));

  void updateBedrooms(int bedrooms) =>
      emit(state.copyWith(draft: state.draft.copyWith(bedrooms: bedrooms)));

  void updateBathrooms(int bathrooms) =>
      emit(state.copyWith(draft: state.draft.copyWith(bathrooms: bathrooms)));

  void updateAvailableFrom(DateTime date) =>
      emit(state.copyWith(draft: state.draft.copyWith(availableFrom: date)));

  void updateAvailableTo(DateTime date) =>
      emit(state.copyWith(draft: state.draft.copyWith(availableTo: date)));

  void updateChildrenCount(int? count) =>
      emit(state.copyWith(draft: state.draft.copyWith(childrenCount: count)));

  void updateDiscountEnabled(bool enabled) => emit(
    state.copyWith(draft: state.draft.copyWith(discountEnabled: enabled)),
  );

  void updateDiscountType(String? type) =>
      emit(state.copyWith(draft: state.draft.copyWith(discountType: type)));

  void updateDiscountValue(String? value) =>
      emit(state.copyWith(draft: state.draft.copyWith(discountValue: value)));

  void toggleFeature(String feature) {
    final currentFeatures = List<String>.from(state.draft.features);
    if (currentFeatures.contains(feature)) {
      currentFeatures.remove(feature);
    } else {
      currentFeatures.add(feature);
    }
    emit(
      state.copyWith(draft: state.draft.copyWith(features: currentFeatures)),
    );
  }

  // ==========================================
  // Date Selection
  // ==========================================

  void selectAvailableFromDate(DateTime date) {
    emit(state.copyWith(draft: state.draft.copyWith(availableFrom: date)));
  }

  void selectAvailableToDate(DateTime date) {
    emit(state.copyWith(draft: state.draft.copyWith(availableTo: date)));
  }

  // ==========================================
  // Form Management
  // ==========================================

  void resetForm() {
    emit(
      state.copyWith(
        draft: ChaletDraft.initial(),
        isFormSubmitting: false,
        formError: null,
        isFormSuccess: false,
      ),
    );
  }

  void initializeFormWithUserData({
    required String ownerName,
    required String email,
    required String phone,
  }) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          merchantName: ownerName,
          email: email,
          phoneNumber: phone,
        ),
      ),
    );
  }

  // ==========================================
  // Location & Geocoding
  // ==========================================

  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(locationResults: []));
      return;
    }

    emit(state.copyWith(isLocationLoading: true));
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {'q': query, 'format': 'json', 'limit': 5},
        options: Options(headers: {'User-Agent': 'rebtal-app/1.0'}),
      );
      final List data = res.data as List;
      final results = data
          .map(
            (e) => {
              'display': e['display_name'],
              'lat': double.tryParse(e['lat'] ?? '0') ?? 0,
              'lon': double.tryParse(e['lon'] ?? '0') ?? 0,
            },
          )
          .toList();
      emit(state.copyWith(locationResults: results, isLocationLoading: false));
    } catch (_) {
      emit(state.copyWith(isLocationLoading: false));
    }
  }

  Future<void> reverseGeocode({
    required double lat,
    required double lon,
  }) async {
    emit(state.copyWith(isLocationLoading: true));
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {'lat': lat, 'lon': lon, 'format': 'json', 'zoom': 16},
        options: Options(headers: {'User-Agent': 'rebtal-app/1.0'}),
      );
      final display = res.data['display_name'] as String?;
      if (display != null) {
        updateGeo(lat: lat, lon: lon, address: display);
      }
      emit(state.copyWith(isLocationLoading: false));
    } catch (_) {
      emit(state.copyWith(isLocationLoading: false));
    }
  }

  void clearLocationResults() {
    emit(state.copyWith(locationResults: []));
  }

  // ==========================================
  // Management Actions
  // ==========================================

  Future<void> toggleChaletVisibility(
    String chaletId,
    bool currentVisibility,
  ) async {
    final newVisibility = !currentVisibility;
    // Optimistic Update
    final updatedChalets = state.chalets.map((c) {
      if (c['id'] == chaletId) {
        final Map<String, dynamic> newC = Map.from(c);
        newC['isVisible'] = newVisibility;
        return newC;
      }
      return c;
    }).toList();
    emit(state.copyWith(chalets: updatedChalets));

    try {
      await _firestore.collection('chalets').doc(chaletId).update({
        'isVisible': newVisibility,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Revert if failed (optional, but good practice)
      fetchChalets(state.chalets.first['ownerId']);
    }
  }

  Future<void> toggleBookingAvailability(
    String chaletId,
    String currentAvailability,
  ) async {
    final newAvailability = currentAvailability == 'available'
        ? 'unavailable'
        : 'available';

    // Optimistic Update
    final updatedChalets = state.chalets.map((c) {
      if (c['id'] == chaletId) {
        final Map<String, dynamic> newC = Map.from(c);
        newC['bookingAvailability'] = newAvailability;
        return newC;
      }
      return c;
    }).toList();
    emit(state.copyWith(chalets: updatedChalets));

    try {
      await _firestore.collection('chalets').doc(chaletId).update({
        'bookingAvailability': newAvailability,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Revert/Refresh if failed
      if (state.chalets.isNotEmpty) {
        fetchChalets(state.chalets.first['ownerId']);
      }
    }
  }

  // ==========================================
  // Image Management
  // ==========================================

  Future<void> addProfileImage(ImageSource source) async {
    try {
      bool hasPermission = await _checkAndRequestPermissions(source);
      if (!hasPermission) {
        throw Exception('Permission denied');
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        emit(
          state.copyWith(
            draft: state.draft.copyWith(profileImage: File(pickedFile.path)),
          ),
        );
      }
    } catch (e) {
      // Handle error (maybe set formError?)
    }
  }

  Future<List<String>> addChaletImage(ImageSource source) async {
    try {
      bool hasPermission = await _checkAndRequestPermissions(source);
      if (!hasPermission) throw Exception('Permission denied');

      final currentImages = state.draft.uploadedImages;
      if (currentImages.length >= 20) return ['Max images reached'];

      List<File> newImages = [];
      if (source == ImageSource.gallery) {
        final pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 80);
        newImages = pickedFiles.map((e) => File(e.path)).toList();
      } else {
        final pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: 80,
        );
        if (pickedFile != null) newImages.add(File(pickedFile.path));
      }

      if (newImages.isNotEmpty) {
        emit(
          state.copyWith(
            draft: state.draft.copyWith(
              uploadedImages: [...currentImages, ...newImages],
            ),
          ),
        );
      }
      return [];
    } catch (e) {
      return [e.toString()];
    }
  }

  void removeChaletImage(int index) {
    final currentImages = List<File>.from(state.draft.uploadedImages);
    if (index < currentImages.length) {
      currentImages.removeAt(index);
      emit(
        state.copyWith(
          draft: state.draft.copyWith(uploadedImages: currentImages),
        ),
      );
    }
  }

  Future<bool> _checkAndRequestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      return await Permission.camera.request().isGranted;
    }
    return await Permission.photos.request().isGranted ||
        await Permission.storage.request().isGranted;
  }

  // ==========================================
  // Use Case Interactions
  // ==========================================

  StreamSubscription? _chaletsSubscription;

  Future<void> fetchChalets(String ownerId) async {
    emit(state.copyWith(status: OwnerStatus.loading));

    // Cancel any existing subscription
    await _chaletsSubscription?.cancel();

    _chaletsSubscription = getOwnerChaletsUseCase
        .stream(ownerId)
        .listen(
          (chalets) {
            _checkExpiredChalets(chalets);
            emit(state.copyWith(status: OwnerStatus.loaded, chalets: chalets));
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: OwnerStatus.error,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  Future<void> _checkExpiredChalets(List<dynamic> chalets) async {
    final now = DateTime.now();
    for (var chalet in chalets) {
      if (chalet is Map<String, dynamic>) {
        // Check availability flag
        bool isAvailable = false;
        if (chalet['isAvailable'] == true) isAvailable = true;
        if (chalet['bookingAvailability'] == 'available') isAvailable = true;

        if (!isAvailable) continue;

        DateTime? availableTo;
        final availableToRaw = chalet['availableTo'];
        if (availableToRaw is Timestamp) {
          availableTo = availableToRaw.toDate();
        } else if (availableToRaw is String) {
          availableTo = DateTime.tryParse(availableToRaw);
        }

        // If expired
        if (availableTo != null && now.isAfter(availableTo)) {
          try {
            // Update Firestore
            await _firestore.collection('chalets').doc(chalet['id']).update({
              'isAvailable': false,
              'bookingAvailability': 'unavailable',
            });

            // Show Local Notification
            await LocalNotificationService().showNotification(
              id: chalet['id'].hashCode,
              title: 'انتهت فترة الحجز ⏳',
              body:
                  'انتهت الفترة المتاحة لحجز شاليه "${chalet['chaletName'] ?? 'غير معروف'}". تم تحديث حالته إلى غير متاح.',
            );
          } catch (e) {
            print('Error updating expired chalet: $e');
          }
        }
      }
    }
  }

  @override
  Future<void> close() {
    _chaletsSubscription?.cancel();
    return super.close();
  }

  Future<void> submitChalet(String ownerId, String ownerName) async {
    emit(
      state.copyWith(
        isFormSubmitting: true,
        formError: null,
        isFormSuccess: false,
      ),
    );

    // Comprehensive Validation - All fields are required
    if (state.draft.chaletName == null || state.draft.chaletName!.isEmpty) {
      emit(
        state.copyWith(isFormSubmitting: false, formError: "اسم الشاليه مطلوب"),
      );
      return;
    }

    if (state.draft.description == null || state.draft.description!.isEmpty) {
      emit(
        state.copyWith(isFormSubmitting: false, formError: "وصف الشاليه مطلوب"),
      );
      return;
    }

    if (state.draft.price.isEmpty ||
        double.tryParse(state.draft.price) == null) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "السعر مطلوب ويجب أن يكون رقماً صحيحاً",
        ),
      );
      return;
    }

    if (state.draft.selectedLocation.isEmpty) {
      emit(state.copyWith(isFormSubmitting: false, formError: "الموقع مطلوب"));
      return;
    }

    if (state.draft.bedrooms == null || state.draft.bedrooms! <= 0) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "عدد غرف النوم مطلوب",
        ),
      );
      return;
    }

    if (state.draft.bathrooms == null || state.draft.bathrooms! <= 0) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "عدد الحمامات مطلوب",
        ),
      );
      return;
    }

    if (state.draft.uploadedImages.isEmpty &&
        state.draft.profileImage == null) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "يجب إضافة صورة واحدة على الأقل",
        ),
      );
      return;
    }

    if (state.draft.availableFrom == null) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "تاريخ البداية مطلوب",
        ),
      );
      return;
    }

    if (state.draft.availableTo == null) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "تاريخ النهاية مطلوب",
        ),
      );
      return;
    }

    if (state.draft.phoneNumber == null || state.draft.phoneNumber!.isEmpty) {
      emit(
        state.copyWith(isFormSubmitting: false, formError: "رقم الهاتف مطلوب"),
      );
      return;
    }

    if (state.draft.email == null || state.draft.email!.isEmpty) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "البريد الإلكتروني مطلوب",
        ),
      );
      return;
    }

    // Construct Entity
    // Collect amenities list with full keys (hasWifi, hasPool, etc.)
    final amenitiesList = <String>[];
    if (state.draft.hasWifi) amenitiesList.add('hasWifi');
    if (state.draft.hasPool) amenitiesList.add('hasPool');
    if (state.draft.hasAirConditioning) amenitiesList.add('hasAirConditioning');
    if (state.draft.hasParking) amenitiesList.add('hasParking');
    if (state.draft.hasGarden) amenitiesList.add('hasGarden');
    if (state.draft.hasBBQ) amenitiesList.add('hasBBQ');
    if (state.draft.hasBeachView) amenitiesList.add('hasBeachView');
    if (state.draft.hasHousekeeping) amenitiesList.add('hasHousekeeping');
    if (state.draft.hasPetsAllowed) amenitiesList.add('hasPetsAllowed');
    if (state.draft.hasGym) amenitiesList.add('hasGym');
    if (state.draft.hasKitchen) amenitiesList.add('hasKitchen');
    if (state.draft.hasTV) amenitiesList.add('hasTV');

    final chalet = ChaletEntity(
      id: '', // Will be generated by Repo
      chaletName: state.draft.chaletName!,
      location: state.draft.selectedLocation,
      description: state.draft.description ?? '',
      ownerId: ownerId,
      ownerName: ownerName,
      price: double.tryParse(state.draft.price) ?? 0.0,
      bedrooms: state.draft.bedrooms ?? 0,
      bathrooms: state.draft.bathrooms ?? 0,
      images: [], // Will be filled by Repo
      amenities: amenitiesList, // Should map boolean flags to list strings
      latitude: state.draft.latitude,
      longitude: state.draft.longitude,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: ChaletStatus.pending,
      isVisible: true,
      chaletArea: state.draft.chaletArea,
      childrenCount: state.draft.childrenCount,
      discountEnabled: state.draft.discountEnabled,
      discountType: state.draft.discountType,
      discountValue: state.draft.discountValue,
      features: state.draft.features,
    );

    final result = await addChaletUseCase(
      AddChaletParams(
        chalet: chalet,
        images: state.draft.uploadedImages,
        profileImage: state.draft.profileImage,
        phoneNumber: state.draft.phoneNumber,
        email: state.draft.email,
        merchantName: state.draft.merchantName,
        isAvailable: state.draft.isAvailable,
        availableFrom: state.draft.availableFrom,
        availableTo: state.draft.availableTo,
        chaletArea: state.draft.chaletArea,
        childrenCount: state.draft.childrenCount,
        discountEnabled: state.draft.discountEnabled,
        discountType: state.draft.discountType,
        discountValue: state.draft.discountValue,
        features: state.draft.features,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isFormSubmitting: false, formError: failure.message),
      ),
      (success) {
        emit(
          state.copyWith(
            isFormSubmitting: false,
            isFormSuccess: true,
            draft: ChaletDraft.initial(), // Reset form
          ),
        );
        fetchChalets(ownerId); // Refresh list
      },
    );
  }
}
