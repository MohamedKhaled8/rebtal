import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rebtal/core/utils/constant/popular_destinations.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';
import 'package:rebtal/feature/owner/domain/repository/base_owner_repository.dart';
import 'package:rebtal/feature/owner/domain/usecases/add_chalet_usecase.dart';
import 'package:rebtal/feature/owner/domain/usecases/get_owner_chalets_usecase.dart';
import 'package:rebtal/feature/owner/domain/entities/chalet_entity.dart';
import 'package:rebtal/core/utils/services/local_notification_service.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/utils/model/pricing_period.dart';
import 'package:rebtal/core/utils/services/chalet_pricing_service.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/feature/owner/utils/owner_helper.dart';
import 'package:rebtal/feature/owner/utils/chalet_edit_review_helper.dart';

int? _intFromFirestore(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.round();
  final s = v.toString().trim();
  final d = double.tryParse(s);
  if (d != null) return d.round();
  return int.tryParse(s);
}

DateTime? _pricingPeriodDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is String) return DateTime.tryParse(v);
  if (v is DateTime) return v;
  return null;
}

List<PricingPeriod> _pricingPeriodsFromMap(Map<String, dynamic> m) {
  final fromFirestore = PricingPeriod.listFromFirestore(m['pricingPeriods']);
  if (fromFirestore.isNotEmpty) return fromFirestore;

  final from = _pricingPeriodDate(m['availableFrom']);
  final to = _pricingPeriodDate(m['availableTo']);
  final priceRaw = m['price'];
  final price = priceRaw is num
      ? priceRaw.toDouble()
      : double.tryParse(priceRaw?.toString() ?? '') ?? 0;

  if (from != null && to != null && price > 0) {
    return [
      PricingPeriod(
        id: 'legacy',
        from: PricingPeriod.dateOnly(from),
        to: PricingPeriod.dateOnly(to),
        price: price,
      ),
    ];
  }
  return const [];
}

bool _amenityFlagFromMap(
  Map<String, dynamic> m,
  List<String> amenityKeys,
  String key,
) {
  if (m[key] == true) return true;
  if (amenityKeys.contains(key)) return true;
  final short = key.startsWith('has')
      ? key.substring(3).toLowerCase()
      : key.toLowerCase();
  for (final raw in amenityKeys) {
    final a = raw.toString();
    if (a == key) return true;
    if (a.toLowerCase() == short) return true;
  }
  return false;
}

class OwnerCubit extends Cubit<OwnerState> {
  final AddChaletUseCase addChaletUseCase;
  final GetOwnerChaletsUseCase getOwnerChaletsUseCase;
  final BaseOwnerRepository ownerRepository;
  final ImagePicker _imagePicker = ImagePicker();
  final Dio _dio = Dio();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _editingChaletId;
  Map<String, dynamic>? _editSource;
  String? _preserveBookingAvailability;

  OwnerCubit({
    required this.addChaletUseCase,
    required this.getOwnerChaletsUseCase,
    required this.ownerRepository,
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
    emit(
      state.copyWith(
        draft: OwnerHelper.applyAmenityUpdate(
          state.draft,
          amenityKey,
          value,
        ),
      ),
    );
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

  void updateDayUseEnabled(bool enabled) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        dayUseEnabled: enabled,
        dayUseOnly: enabled ? false : state.draft.dayUseOnly,
        dayUsePrice: enabled && !state.draft.dayUseEnabled
            ? ''
            : state.draft.dayUsePrice,
      ),
    ),
  );

  void updateDayUseOnly(bool only) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        dayUseOnly: only,
        dayUseEnabled: only ? false : state.draft.dayUseEnabled,
        dayUsePrice: only && !state.draft.dayUseOnly
            ? ''
            : state.draft.dayUsePrice,
      ),
    ),
  );

  void updateDayUsePrice(String price) =>
      emit(state.copyWith(draft: state.draft.copyWith(dayUsePrice: price)));

  bool addPricingPeriod({
    required DateTime from,
    required DateTime to,
    required double price,
  }) {
    final normalizedFrom = PricingPeriod.dateOnly(from);
    final normalizedTo = PricingPeriod.dateOnly(to);
    if (normalizedTo.isBefore(normalizedFrom)) return false;
    if (price <= 0) return false;

    final newPeriod = PricingPeriod(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      from: normalizedFrom,
      to: normalizedTo,
      price: price,
    );

    for (final existing in state.draft.pricingPeriods) {
      if (ChaletPricingService.periodsOverlap(existing, newPeriod)) {
        return false;
      }
    }

    final updated = [...state.draft.pricingPeriods, newPeriod]
      ..sort((a, b) => a.from.compareTo(b.from));
    _emitDraftWithSyncedPeriods(updated);
    return true;
  }

  void removePricingPeriod(String id) {
    final updated = state.draft.pricingPeriods
        .where((p) => p.id != id)
        .toList();
    _emitDraftWithSyncedPeriods(updated);
  }

  void _emitDraftWithSyncedPeriods(List<PricingPeriod> periods) {
    if (periods.isEmpty) {
      emit(
        state.copyWith(
          draft: state.draft.copyWith(
            pricingPeriods: const [],
            availableFrom: null,
            availableTo: null,
          ),
        ),
      );
      return;
    }

    final envelopeFrom = periods
        .map((p) => p.from)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final envelopeTo = periods
        .map((p) => p.to)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final minPrice = periods
        .map((p) => p.price)
        .reduce((a, b) => a < b ? a : b);

    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          pricingPeriods: periods,
          availableFrom: envelopeFrom,
          availableTo: envelopeTo,
          price: minPrice.toStringAsFixed(
            minPrice.truncateToDouble() == minPrice ? 0 : 2,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _pricingPeriodsPayload() =>
      state.draft.pricingPeriods.map((p) => p.toMap()).toList();

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

  /// Select / clear a popular destination (by [destinationKey] from [PopularDestinations]).
  /// Keeps `features` in sync with Arabic destination name for filters.
  void selectPopularDestination(String? destinationKey) {
    final currentDraft = state.draft;
    final popularNames = PopularDestinations.namesAr;

    final cleanedFeatures = currentDraft.features
        .where((f) => !popularNames.contains(f))
        .toList();

    String? resolvedKey;
    if (destinationKey != null && destinationKey.isNotEmpty) {
      final dest = PopularDestinations.getByKey(destinationKey);
      if (dest != null) {
        resolvedKey = dest.key;
        cleanedFeatures.add(dest.nameAr);
      }
    }

    emit(
      state.copyWith(
        draft: currentDraft.copyWith(
          popularDestination: resolvedKey,
          features: cleanedFeatures,
        ),
      ),
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
    _editingChaletId = null;
    _editSource = null;
    _preserveBookingAvailability = null;
    emit(
      state.copyWith(
        draft: ChaletDraft.initial(),
        isFormSubmitting: false,
        formError: null,
        isFormSuccess: false,
      ),
    );
  }

  DateTime? _parseFirestoreDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  String _priceStringFromFirestore(dynamic raw) {
    if (raw == null) return '';
    return raw is num ? raw.toString() : raw.toString();
  }

  Map<String, dynamic> _dayUseAmenityFlagPayload(ChaletDraft draft) {
    final flags = OwnerHelper.dayUseAmenityFlags(draft);
    return {
      for (final entry in flags.entries)
        entry.key: entry.value,
    };
  }

  /// Firestore expects `available` | `unavailable` (see [BookingAvailability]).
  String _normalizeBookingAvailability(String? raw) {
    final v = (raw ?? 'available').toLowerCase().trim();
    return v == 'unavailable' ? 'unavailable' : 'available';
  }

  /// Keeps [pending] (and [rejected] → pending resubmission) after save; only
  /// listings that were already [approved] stay approved.
  String _statusForEditSave() {
    final raw = _editSource?['status']?.toString().toLowerCase().trim() ?? '';
    if (raw == 'approved') return 'approved';
    if (raw == 'pending') return 'pending';
    if (raw == 'rejected') return 'pending';
    if (raw.isNotEmpty) return raw;
    return 'approved';
  }

  /// Hydrate the add/edit draft from an existing Firestore map (owner edit flow).
  void loadChaletDataForEdit(Map<String, dynamic> m, String docId) {
    _editingChaletId = docId;
    _editSource = Map<String, dynamic>.from(m);
    final source = ChaletEditReviewHelper.dataForOwnerEditForm(m);
    _preserveBookingAvailability =
        source['bookingAvailability']?.toString() ??
        m['bookingAvailability']?.toString() ??
        'available';

    final amenities = List<String>.from(
      (source['amenities'] as List?)?.map((e) => e.toString()) ?? const [],
    );
    final features = List<String>.from(source['features'] ?? []);

    final List<String> sanitizedImageUrls = [];
    final rawImages = source['images'];
    if (rawImages is List) {
      for (final e in rawImages) {
        if (e == null) continue;
        final s = e.toString().trim();
        if (s.isNotEmpty && s != 'null') sanitizedImageUrls.add(s);
      }
    }

    String? popularKey;
    for (final d in PopularDestinations.all) {
      if (features.contains(d.nameAr)) {
        popularKey = d.key;
        break;
      }
    }

    final priceRaw = source['price'];
    final priceStr = priceRaw == null
        ? ''
        : (priceRaw is num ? priceRaw.toString() : priceRaw.toString());

    final lat = source['latitude'] ?? source['lat'];
    final lon = source['longitude'] ?? source['lon'];

    emit(
      state.copyWith(
        draft: ChaletDraft(
          uploadedImages: const [],
          existingImageUrls: sanitizedImageUrls,
          selectedLocation: source['location']?.toString() ?? '',
          isAvailable: source['isAvailable'] ?? true,
          hasWifi: _amenityFlagFromMap(source, amenities, 'hasWifi'),
          hasPool: _amenityFlagFromMap(source, amenities, 'hasPool'),
          hasAirConditioning: _amenityFlagFromMap(
            source,
            amenities,
            'hasAirConditioning',
          ),
          hasParking: _amenityFlagFromMap(source, amenities, 'hasParking'),
          hasGarden: _amenityFlagFromMap(source, amenities, 'hasGarden'),
          hasBBQ: _amenityFlagFromMap(source, amenities, 'hasBBQ'),
          hasBeachView: _amenityFlagFromMap(source, amenities, 'hasBeachView'),
          hasHousekeeping: _amenityFlagFromMap(
            source,
            amenities,
            'hasHousekeeping',
          ),
          hasPetsAllowed: _amenityFlagFromMap(source, amenities, 'hasPetsAllowed'),
          hasGym: _amenityFlagFromMap(source, amenities, 'hasGym'),
          hasKitchen: _amenityFlagFromMap(source, amenities, 'hasKitchen'),
          hasTV: _amenityFlagFromMap(source, amenities, 'hasTV'),
          status: m['status']?.toString() ?? 'approved',
          phoneNumber: source['phoneNumber']?.toString(),
          email: source['email']?.toString(),
          chaletName: source['chaletName']?.toString(),
          description: source['description']?.toString(),
          merchantName: source['merchantName']?.toString(),
          price: priceStr,
          chaletArea: source['chaletArea']?.toString(),
          bedrooms: _intFromFirestore(source['bedrooms']),
          bathrooms: _intFromFirestore(source['bathrooms']),
          availableFrom: _parseFirestoreDate(source['availableFrom']),
          availableTo: _parseFirestoreDate(source['availableTo']),
          latitude: lat is num ? lat.toDouble() : double.tryParse('$lat'),
          longitude: lon is num ? lon.toDouble() : double.tryParse('$lon'),
          childrenCount: _intFromFirestore(source['childrenCount']),
          discountEnabled: source['discountEnabled'] ?? false,
          discountType: source['discountType']?.toString(),
          discountValue: source['discountValue']?.toString(),
          features: features,
          dayUseEnabled: source['dayUseEnabled'] ?? false,
          dayUseOnly: source['dayUseOnly'] ?? false,
          dayUsePrice: _priceStringFromFirestore(source['dayUsePrice']),
          dayUseAmenities: List<String>.from(
            (source['dayUseAmenities'] as List?)?.map((e) => e.toString()) ??
                const [],
          ),
          popularDestination: popularKey,
          pricingPeriods: _pricingPeriodsFromMap(source),
        ),
        isFormSubmitting: false,
        formError: null,
        isFormSuccess: false,
      ),
    );
  }

  void removeExistingImageUrl(int index) {
    final list = List<String>.from(state.draft.existingImageUrls);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      emit(
        state.copyWith(draft: state.draft.copyWith(existingImageUrls: list)),
      );
    }
  }

  /// Merge saved fields into the in-memory chalet list so UI updates immediately
  /// (before the Firestore snapshot round-trips).
  void patchChaletInListAfterSave(String docId, Map<String, dynamic> updates) {
    final cleaned = Map<String, dynamic>.from(updates);
    cleaned.removeWhere((k, v) => v is FieldValue);
    final list = state.chalets.map((c) {
      if (c is Map && c['id']?.toString() == docId) {
        final m = Map<String, dynamic>.from(c);
        cleaned.forEach((k, v) {
          m[k] = v;
        });
        return m;
      }
      return c;
    }).toList();
    emit(state.copyWith(chalets: list));
  }

  /// Delete listing from Firestore and refresh owner list.
  Future<bool> deleteChaletAsOwner(String docId, String ownerId) async {
    final result = await ownerRepository.deleteChalet(docId);
    return result.fold((_) => false, (_) {
      fetchChalets(ownerId);
      return true;
    });
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

  Future<bool> toggleChaletVisibility(
    String chaletId,
    bool currentVisibility,
  ) async {
    Map<String, dynamic>? chaletMap;
    for (final c in state.chalets) {
      if (c is Map && c['id']?.toString() == chaletId) {
        chaletMap = Map<String, dynamic>.from(c);
        break;
      }
    }
    if (chaletMap != null &&
        ChaletEditReviewHelper.isEditReviewPending(chaletMap)) {
      return false;
    }

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
    return true;
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
    // Gallery: image_picker uses Android's built-in photo picker (Intent-based)
    // which does NOT require READ_MEDIA_IMAGES or storage permissions.
    return true;
  }

  // ==========================================
  // Use Case Interactions
  // ==========================================

  StreamSubscription? _chaletsSubscription;

  /// Streams Firestore chalets for [ownerId]. Only emits [OwnerStatus.loading]
  /// when there is no cached list yet — avoids wiping UI after auth/UI revisions
  /// or silent reconnects when switching tabs / owner↔user view mode.
  Future<void> fetchChalets(String ownerId) async {
    final bool hasCachedList = state.chalets.isNotEmpty;

    // Only show loading shimmer on first cold fetch (no cached data).
    if (!hasCachedList) {
      emit(state.copyWith(status: OwnerStatus.loading));
    }

    // Preserve the current list while the new subscription establishes.
    final List<dynamic> cachedChalets = List.from(state.chalets);

    await _chaletsSubscription?.cancel();

    _chaletsSubscription = getOwnerChaletsUseCase
        .stream(ownerId)
        .listen(
          (chalets) {
            _checkExpiredChalets(chalets);
            emit(state.copyWith(status: OwnerStatus.loaded, chalets: chalets));
          },
          onError: (error) {
            // On error, keep showing cached data if available instead of
            // hiding everything with an error state.
            if (cachedChalets.isNotEmpty) {
              emit(
                state.copyWith(
                  status: OwnerStatus.loaded,
                  chalets: cachedChalets,
                ),
              );
            } else {
              emit(
                state.copyWith(
                  status: OwnerStatus.error,
                  errorMessage: error.toString(),
                ),
              );
            }
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

  void reset() {
    emit(OwnerState.initial());
  }

  Future<void> submitChalet(String ownerId, String ownerName) async {
    if (state.isFormSubmitting) return;

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

    if (state.draft.pricingPeriods.isEmpty &&
        (state.draft.price.isEmpty ||
            double.tryParse(state.draft.price) == null)) {
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

    if (state.draft.pricingPeriods.isEmpty) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "يجب إضافة فترة توفر واحدة على الأقل مع السعر",
        ),
      );
      return;
    }

    if (state.draft.availableFrom == null || state.draft.availableTo == null) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "فترة التوفر غير مكتملة",
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
    final amenitiesList = OwnerHelper.buildGeneralAmenitiesList(state.draft);
    final dayUseAmenitiesList = OwnerHelper.buildDayUseAmenitiesList(
      state.draft,
    );

    if (OwnerHelper.requiresDayUsePrice(state.draft)) {
      final dayUsePrice = double.tryParse(state.draft.dayUsePrice.trim());
      if (dayUsePrice == null || dayUsePrice <= 0) {
        emit(
          state.copyWith(
            isFormSubmitting: false,
            formError: 'سعر حجز اليوم الواحد مطلوب ويجب أن يكون رقماً صحيحاً',
          ),
        );
        return;
      }
    }

    final hasDayUseOption = OwnerHelper.requiresDayUsePrice(state.draft);

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
      dayUseEnabled: state.draft.dayUseEnabled,
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
        dayUseEnabled: state.draft.dayUseEnabled,
        dayUseOnly: state.draft.dayUseOnly,
        dayUsePrice: hasDayUseOption
            ? double.tryParse(state.draft.dayUsePrice.trim())
            : null,
        dayUseAmenities: dayUseAmenitiesList,
        pricingPeriods: _pricingPeriodsPayload(),
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

  /// Notify admins that an owner submitted edits to an approved listing.
  Future<void> _notifyAdminsChaletEditReview({
    required String ownerName,
    required String chaletName,
    required String chaletId,
    required String ownerId,
  }) async {
    try {
      final adminsSnapshot = await _firestore.collection('Admin').get();
      final adminIds = adminsSnapshot.docs.map((d) => d.id).toSet();
      for (final adminId in adminIds) {
        await NotificationService().sendNotification(
          userId: adminId,
          titleKey: 'notif_chalet_edit_review',
          bodyKey: 'notif_chalet_edit_body',
          bodyParams: {'name': ownerName, 'chalet': chaletName},
          type: NotificationType.chaletSubmission,
          relatedId: chaletId,
          data: {
            'chaletId': chaletId,
            'ownerId': ownerId,
            'ownerName': ownerName,
            'submissionType': ChaletEditReviewHelper.submissionTypeEdit,
          },
        );
      }
    } catch (_) {}
  }

  /// Update an existing listing (same fields as add flow).
  Future<void> submitChaletEdit(String ownerId, String ownerName) async {
    final docId = _editingChaletId;
    if (docId == null) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: 'خطأ في حفظ التعديل',
        ),
      );
      return;
    }

    if (state.isFormSubmitting) return;

    final editSource = _editSource ?? <String, dynamic>{};
    final requiresAdminReview =
        ChaletEditReviewHelper.isApprovedListing(editSource) ||
        ChaletEditReviewHelper.isEditReviewPending(editSource);

    emit(
      state.copyWith(
        isFormSubmitting: true,
        formError: null,
        isFormSuccess: false,
        editReviewSubmitted: false,
      ),
    );

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

    if (state.draft.pricingPeriods.isEmpty &&
        (state.draft.price.isEmpty ||
            double.tryParse(state.draft.price) == null)) {
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

    if (state.draft.existingImageUrls.isEmpty &&
        state.draft.uploadedImages.isEmpty) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "يجب إضافة صورة واحدة على الأقل",
        ),
      );
      return;
    }

    if (state.draft.pricingPeriods.isEmpty) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "يجب إضافة فترة توفر واحدة على الأقل مع السعر",
        ),
      );
      return;
    }

    if (state.draft.availableFrom == null || state.draft.availableTo == null) {
      emit(
        state.copyWith(
          isFormSubmitting: false,
          formError: "فترة التوفر غير مكتملة",
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

    final uploadedUrls = <String>[];
    for (final file in state.draft.uploadedImages) {
      final up = await ownerRepository.uploadChaletImage(file);
      final ok = up.fold(
        (f) {
          emit(state.copyWith(isFormSubmitting: false, formError: f.message));
          return false;
        },
        (url) {
          uploadedUrls.add(url);
          return true;
        },
      );
      if (!ok) return;
    }

    final allImages = [...state.draft.existingImageUrls, ...uploadedUrls];

    final amenitiesList = OwnerHelper.buildGeneralAmenitiesList(state.draft);
    final dayUseAmenitiesList = OwnerHelper.buildDayUseAmenitiesList(
      state.draft,
    );

    if (OwnerHelper.requiresDayUsePrice(state.draft)) {
      final dayUsePrice = double.tryParse(state.draft.dayUsePrice.trim());
      if (dayUsePrice == null || dayUsePrice <= 0) {
        emit(
          state.copyWith(
            isFormSubmitting: false,
            formError: 'سعر حجز اليوم الواحد مطلوب ويجب أن يكون رقماً صحيحاً',
          ),
        );
        return;
      }
    }

    final hasDayUseOption = OwnerHelper.requiresDayUsePrice(state.draft);

    final name = state.draft.chaletName!.trim();
    final loc = state.draft.selectedLocation.trim();
    final desc = (state.draft.description ?? '').trim();
    final phone = state.draft.phoneNumber!.trim();
    final email = state.draft.email!.trim();

    final data = <String, dynamic>{
      'chaletName': name,
      'location': loc,
      'description': desc,
      'images': allImages,
      'price': state.draft.dayUseOnly
          ? (_editSource?['price'] is num
                ? (_editSource!['price'] as num).toDouble()
                : double.tryParse(state.draft.price.trim()) ?? 0.0)
          : double.tryParse(state.draft.price.trim()) ?? 0.0,
      'bedrooms': state.draft.bedrooms ?? 0,
      'bathrooms': state.draft.bathrooms ?? 0,
      'amenities': amenitiesList,
      'hasWifi': state.draft.hasWifi,
      'hasPool': state.draft.hasPool,
      'hasAirConditioning': state.draft.hasAirConditioning,
      'hasParking': state.draft.hasParking,
      'hasGarden': state.draft.hasGarden,
      'hasBBQ': state.draft.hasBBQ,
      'hasBeachView': state.draft.hasBeachView,
      'hasHousekeeping': state.draft.hasHousekeeping,
      'hasPetsAllowed': state.draft.hasPetsAllowed,
      'hasGym': state.draft.hasGym,
      'hasKitchen': state.draft.hasKitchen,
      'hasTV': state.draft.hasTV,
      'phoneNumber': phone,
      'email': email,
      'merchantName': (state.draft.merchantName ?? ownerName).trim(),
      'ownerName': ownerName.trim(),
      'isAvailable': state.draft.isAvailable,
      'bookingAvailability': _normalizeBookingAvailability(
        _preserveBookingAvailability,
      ),
      'availableFrom': state.draft.availableFrom!.toIso8601String(),
      'availableTo': state.draft.availableTo!.toIso8601String(),
      'pricingPeriods': _pricingPeriodsPayload(),
      'discountEnabled': state.draft.discountEnabled,
      'features': state.draft.features,
      'dayUseEnabled': state.draft.dayUseEnabled,
      'dayUseOnly': state.draft.dayUseOnly,
    };

    if (state.draft.chaletArea != null &&
        state.draft.chaletArea!.trim().isNotEmpty) {
      data['chaletArea'] = state.draft.chaletArea!.trim();
    }
    if (state.draft.childrenCount != null) {
      data['childrenCount'] = state.draft.childrenCount;
    }
    if (state.draft.discountType != null) {
      data['discountType'] = state.draft.discountType;
    }
    if (state.draft.discountValue != null) {
      data['discountValue'] = state.draft.discountValue;
    }
    if (hasDayUseOption) {
      data['dayUsePrice'] =
          double.tryParse(state.draft.dayUsePrice.trim()) ?? 0.0;
      data['dayUseAmenities'] = dayUseAmenitiesList;
      data.addAll(_dayUseAmenityFlagPayload(state.draft));
    } else {
      data['dayUseOnly'] = false;
      data['dayUseEnabled'] = false;
      if (!requiresAdminReview) {
        data['dayUsePrice'] = FieldValue.delete();
        data['dayUseAmenities'] = FieldValue.delete();
      }
    }
    if (state.draft.latitude != null) {
      data['latitude'] = state.draft.latitude;
      data['lat'] = state.draft.latitude;
    }
    if (state.draft.longitude != null) {
      data['longitude'] = state.draft.longitude;
      data['lon'] = state.draft.longitude;
    }

    late final Map<String, dynamic> firestorePayload;
    final editReviewSubmitted = requiresAdminReview;

    if (requiresAdminReview) {
      final pendingData = Map<String, dynamic>.from(data)
        ..removeWhere((k, v) => v is FieldValue);
      firestorePayload = {
        'pendingEditData': pendingData,
        'editReviewStatus': ChaletEditReviewHelper.editReviewPending,
        'submissionType': ChaletEditReviewHelper.submissionTypeEdit,
        'isVisible': false,
        'editSubmittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
    } else {
      data['status'] = _statusForEditSave();
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['isVisible'] = _editSource?['isVisible'] ?? false;
      firestorePayload = data;
    }

    final result = await ownerRepository.updateChaletFields(
      docId,
      firestorePayload,
    );

    final failure = result.fold<Failure?>((l) => l, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(isFormSubmitting: false, formError: failure.message),
      );
      return;
    }

    try {
      if (requiresAdminReview) {
        await _notifyAdminsChaletEditReview(
          ownerName: ownerName.trim(),
          chaletName: name,
          chaletId: docId,
          ownerId: ownerId,
        );
        final pendingData = Map<String, dynamic>.from(data)
          ..removeWhere((k, v) => v is FieldValue);
        patchChaletInListAfterSave(docId, {
          'editReviewStatus': ChaletEditReviewHelper.editReviewPending,
          'submissionType': ChaletEditReviewHelper.submissionTypeEdit,
          'isVisible': false,
          'pendingEditData': pendingData,
          'editSubmittedAt': DateTime.now().toIso8601String(),
        });
      } else {
        final forList = Map<String, dynamic>.from(data);
        forList.removeWhere((k, v) => v is FieldValue);
        patchChaletInListAfterSave(docId, forList);
      }
    } catch (_) {
      // Firestore save succeeded; notification/list patch must not block UX.
    }

    _editingChaletId = null;
    _editSource = null;
    _preserveBookingAvailability = null;
    emit(
      state.copyWith(
        isFormSubmitting: false,
        isFormSuccess: true,
        editReviewSubmitted: editReviewSubmitted,
        draft: ChaletDraft.initial(),
        formError: null,
      ),
    );
    fetchChalets(ownerId);
  }
}
