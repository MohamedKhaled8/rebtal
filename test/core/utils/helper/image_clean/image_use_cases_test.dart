import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_contracts.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_gateways.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_models.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_repository_contracts.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_use_cases.dart';

class _FakeImagePickerGateway implements ImagePickerGateway {
  XFile? result;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  }) async {
    return result;
  }
}

class _FakePermissionService implements PermissionService {
  bool granted = true;
  @override
  Future<bool> checkAndRequestPermissions(ImageSource source) async => granted;
}

class _FakeImageUploadGateway implements ImageUploadGateway {
  final List<File> uploaded = [];
  @override
  Future<String> uploadImage(File imageFile) async {
    uploaded.add(imageFile);
    return 'https://cdn.test/${imageFile.path}';
  }
}

class _FakeProfileRepository implements ProfileRepository {
  String? uid;
  String? role;
  String? profileUrl;
  @override
  Future<void> updateProfileImage({
    required String uid,
    required String role,
    required String profileImageUrl,
  }) async {
    this.uid = uid;
    this.role = role;
    profileUrl = profileImageUrl;
  }
}

class _FakeChaletRepository implements ChaletRepository {
  Map<String, dynamic>? firestorePayload;
  Map<String, dynamic>? realtimePayload;

  @override
  Future<String> createChalet(Map<String, dynamic> payload) async {
    firestorePayload = payload;
    return 'chalet-id-1';
  }

  @override
  Future<void> syncChalet(String chaletId, Map<String, dynamic> payload) async {
    realtimePayload = payload;
  }
}

class _FakeAdminNotificationGateway implements AdminNotificationGateway {
  bool notified = false;
  @override
  Future<void> notifyNewChaletForReview({
    required String chaletId,
    required String ownerId,
    required String titleKey,
    required String bodyKey,
    Map<String, dynamic>? bodyParams,
  }) async {
    notified = true;
  }
}

void main() {
  group('ProfileImageUseCase', () {
    test('throws when permission denied', () async {
      final picker = _FakeImagePickerGateway();
      final permission = _FakePermissionService()..granted = false;
      final upload = _FakeImageUploadGateway();
      final profileRepo = _FakeProfileRepository();
      final chaletRepo = _FakeChaletRepository();
      final adminNotify = _FakeAdminNotificationGateway();

      final dependencies = ImageHelperDependencies(
        imagePickerGateway: picker,
        permissionService: permission,
        imageUploadGateway: upload,
        profileRepository: profileRepo,
        chaletRepository: chaletRepo,
        adminNotificationGateway: adminNotify,
      );

      final useCase = ProfileImageUseCase(dependencies: dependencies);

      expect(
        () => useCase.execute(source: ImageSource.gallery, uid: 'u1', role: 'user'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ChaletSubmissionUseCase', () {
    test('uploads images and writes payloads', () async {
      final picker = _FakeImagePickerGateway();
      final permission = _FakePermissionService();
      final upload = _FakeImageUploadGateway();
      final profileRepo = _FakeProfileRepository();
      final chaletRepo = _FakeChaletRepository();
      final adminNotify = _FakeAdminNotificationGateway();

      final dependencies = ImageHelperDependencies(
        imagePickerGateway: picker,
        permissionService: permission,
        imageUploadGateway: upload,
        profileRepository: profileRepo,
        chaletRepository: chaletRepo,
        adminNotificationGateway: adminNotify,
      );

      final useCase = ChaletSubmissionUseCase(dependencies: dependencies);
      final draft = ChaletDraftSnapshot(
        uploadedImages: [File('a.jpg'), File('b.jpg')],
        selectedLocation: 'Cairo',
        isAvailable: true,
        hasWifi: true,
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
        status: 'pending',
        phoneNumber: '01000000000',
        email: 'a@b.com',
        chaletName: 'Chalet',
        description: 'Desc',
        merchantName: 'Owner',
        price: '100',
        chaletArea: '200',
        bedrooms: 3,
        bathrooms: 2,
        availableFrom: null,
        availableTo: null,
        childrenCount: 1,
        discountEnabled: false,
        discountType: null,
        discountValue: null,
        features: const ['x'],
      );

      final result = await useCase.execute(
        data: draft,
        ownerId: 'owner-1',
        reviewTitleKey: 'notif_new_chalet_review',
        reviewBodyKey: 'notif_new_chalet_body',
        reviewBodyParams: const {'name': 'Owner', 'chalet': 'Chalet'},
        amenities: const ['hasWifi'],
      );

      expect(result.chaletId, 'chalet-id-1');
      expect(upload.uploaded.length, 2);
      expect(chaletRepo.firestorePayload?['ownerId'], 'owner-1');
      expect(chaletRepo.realtimePayload?['ownerId'], 'owner-1');
      expect(adminNotify.notified, isTrue);
    });
  });
}
