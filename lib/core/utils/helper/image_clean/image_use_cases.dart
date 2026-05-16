import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_gateways.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_models.dart';

class ProfileImageUseCase {
  final ImageHelperDependencies dependencies;

  const ProfileImageUseCase({required this.dependencies});

  Future<void> execute({
    required ImageSource source,
    required String uid,
    required String role,
  }) async {
    final hasPermission = await dependencies.permissionService
        .checkAndRequestPermissions(source);
    if (!hasPermission) {
      throw Exception('PermissionDenied');
    }

    final XFile? pickedFile = await dependencies.imagePickerGateway.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (pickedFile == null) return;

    final profileUrl = await dependencies.imageUploadGateway.uploadImage(
      File(pickedFile.path),
    );
    await dependencies.profileRepository.updateProfileImage(
      uid: uid,
      role: role,
      profileImageUrl: profileUrl,
    );
  }
}

class ChaletSubmissionUseCase {
  final ImageHelperDependencies dependencies;

  const ChaletSubmissionUseCase({required this.dependencies});

  Future<ChaletSubmitResult> execute({
    required ChaletDraftSnapshot data,
    required String ownerId,
    required String reviewTitleKey,
    required String reviewBodyKey,
    Map<String, dynamic>? reviewBodyParams,
    required List<String> amenities,
  }) async {
    final List<String> chaletImageUrls = await Future.wait<String>(
      data.uploadedImages.map(
        (imageFile) => dependencies.imageUploadGateway.uploadImage(imageFile),
      ),
    );

    final firestorePayload = ChaletPayloadBuilder.buildFirestore(
      data: data,
      ownerId: ownerId,
      chaletImageUrls: chaletImageUrls,
      amenities: amenities,
    );

    final realtimePayload = ChaletPayloadBuilder.buildRealtime(
      data: data,
      ownerId: ownerId,
      chaletImageUrls: chaletImageUrls,
      amenities: amenities,
    );

    final chaletId = await dependencies.chaletRepository.createChalet(
      firestorePayload,
    );
    await dependencies.chaletRepository.syncChalet(chaletId, realtimePayload);

    try {
      await dependencies.adminNotificationGateway.notifyNewChaletForReview(
        chaletId: chaletId,
        ownerId: ownerId,
        titleKey: reviewTitleKey,
        bodyKey: reviewBodyKey,
        bodyParams: reviewBodyParams,
      );
    } catch (_) {}

    return ChaletSubmitResult(chaletId: chaletId);
  }
}

class ChaletPayloadBuilder {
  static Map<String, dynamic> buildFirestore({
    required ChaletDraftSnapshot data,
    required String ownerId,
    required List<String> chaletImageUrls,
    required List<String> amenities,
  }) {
    return {
      "ownerId": ownerId,
      "images": chaletImageUrls,
      "location": data.selectedLocation,
      "phoneNumber": data.phoneNumber,
      "chaletName": data.chaletName,
      "description": data.description,
      "isAvailable": data.isAvailable,
      "hasWifi": data.hasWifi,
      "hasPool": data.hasPool,
      "hasAirConditioning": data.hasAirConditioning,
      "hasParking": data.hasParking,
      "hasGarden": data.hasGarden,
      "hasBBQ": data.hasBBQ,
      "hasBeachView": data.hasBeachView,
      "hasHousekeeping": data.hasHousekeeping,
      "hasPetsAllowed": data.hasPetsAllowed,
      "hasGym": data.hasGym,
      "hasKitchen": data.hasKitchen,
      "hasTV": data.hasTV,
      "status": data.status,
      "createdAt": FieldValue.serverTimestamp(),
      "merchantName": data.merchantName,
      "price": data.price,
      "chaletArea": data.chaletArea,
      "bedrooms": data.bedrooms,
      "bathrooms": data.bathrooms,
      "availableFrom": data.availableFrom?.toIso8601String(),
      "availableTo": data.availableTo?.toIso8601String(),
      "email": data.email,
      "amenities": amenities,
      "childrenCount": data.childrenCount,
      "discountEnabled": data.discountEnabled,
      "discountType": data.discountType,
      "discountValue": data.discountValue,
      "features": data.features,
    };
  }

  static Map<String, dynamic> buildRealtime({
    required ChaletDraftSnapshot data,
    required String ownerId,
    required List<String> chaletImageUrls,
    required List<String> amenities,
  }) {
    return {
      "ownerId": ownerId,
      "images": chaletImageUrls,
      "location": data.selectedLocation,
      "phoneNumber": data.phoneNumber,
      "chaletName": data.chaletName,
      "description": data.description,
      "isAvailable": data.isAvailable,
      "hasWifi": data.hasWifi,
      "hasPool": data.hasPool,
      "hasAirConditioning": data.hasAirConditioning,
      "hasParking": data.hasParking,
      "hasGarden": data.hasGarden,
      "hasBBQ": data.hasBBQ,
      "hasBeachView": data.hasBeachView,
      "hasHousekeeping": data.hasHousekeeping,
      "hasPetsAllowed": data.hasPetsAllowed,
      "hasGym": data.hasGym,
      "hasKitchen": data.hasKitchen,
      "hasTV": data.hasTV,
      "status": data.status,
      "createdAt": ServerValue.timestamp,
      "merchantName": data.merchantName,
      "price": data.price,
      "chaletArea": data.chaletArea,
      "bedrooms": data.bedrooms,
      "bathrooms": data.bathrooms,
      "availableFrom": data.availableFrom?.toIso8601String(),
      "availableTo": data.availableTo?.toIso8601String(),
      "amenities": amenities,
      "childrenCount": data.childrenCount,
      "discountEnabled": data.discountEnabled,
      "discountType": data.discountType,
      "discountValue": data.discountValue,
      "features": data.features,
    };
  }
}

class ChaletSubmitResult {
  final String chaletId;
  const ChaletSubmitResult({required this.chaletId});
}
