import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/utils/helper/cloudinary_upload_helper.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_contracts.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_repository_contracts.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';

class DefaultImagePickerGateway implements ImagePickerGateway {
  final ImagePicker _imagePicker;

  DefaultImagePickerGateway({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  }) {
    return _imagePicker.pickImage(
      source: source,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }
}

class DefaultPermissionService implements PermissionService {
  @override
  Future<bool> checkAndRequestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      PermissionStatus cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
      }
      return cameraStatus.isGranted;
    }
    return true;
  }
}

class CloudinaryImageUploadGateway implements ImageUploadGateway {
  @override
  Future<String> uploadImage(File imageFile) {
    return CloudinaryUploadHelper.uploadImage(imageFile);
  }
}

class FirebaseProfileRepository implements ProfileRepository {
  @override
  Future<void> updateProfileImage({
    required String uid,
    required String role,
    required String profileImageUrl,
  }) {
    return FirebaseFirestore.instance
        .collection(_resolveCollection(role))
        .doc(uid)
        .update({'profileImageUrl': profileImageUrl});
  }

  String _resolveCollection(String role) {
    final normalizedRole = role.toLowerCase().trim();
    if (normalizedRole == 'owner') return 'Owners';
    if (normalizedRole == 'admin') return 'Admin';
    return 'Users';
  }
}

class FirebaseChaletRepository implements ChaletRepository {
  @override
  Future<String> createChalet(Map<String, dynamic> payload) async {
    final docRef = await FirebaseFirestore.instance.collection("chalets").add(
      payload,
    );
    return docRef.id;
  }

  @override
  Future<void> syncChalet(String chaletId, Map<String, dynamic> payload) {
    return FirebaseDatabase.instance.ref("chalets").child(chaletId).set(payload);
  }
}

class FirebaseAdminNotificationGateway implements AdminNotificationGateway {
  @override
  Future<void> notifyNewChaletForReview({
    required String chaletId,
    required String ownerId,
    required String titleKey,
    required String bodyKey,
    Map<String, dynamic>? bodyParams,
  }) async {
    final adminsSnapshot = await FirebaseFirestore.instance
        .collection('Admin')
        .get();
    final adminIds = adminsSnapshot.docs.map((d) => d.id).toSet();
    for (final adminId in adminIds) {
      await NotificationService().sendNotification(
        userId: adminId,
        titleKey: titleKey,
        bodyKey: bodyKey,
        bodyParams: bodyParams,
        type: NotificationType.chaletSubmission,
        relatedId: chaletId,
        data: {'chaletId': chaletId, 'ownerId': ownerId},
      );
    }
  }
}

class ImageHelperDependencies {
  final ImagePickerGateway imagePickerGateway;
  final PermissionService permissionService;
  final ImageUploadGateway imageUploadGateway;
  final ProfileRepository profileRepository;
  final ChaletRepository chaletRepository;
  final AdminNotificationGateway adminNotificationGateway;

  const ImageHelperDependencies({
    required this.imagePickerGateway,
    required this.permissionService,
    required this.imageUploadGateway,
    required this.profileRepository,
    required this.chaletRepository,
    required this.adminNotificationGateway,
  });

  factory ImageHelperDependencies.defaults() {
    return ImageHelperDependencies(
      imagePickerGateway: DefaultImagePickerGateway(),
      permissionService: DefaultPermissionService(),
      imageUploadGateway: CloudinaryImageUploadGateway(),
      profileRepository: FirebaseProfileRepository(),
      chaletRepository: FirebaseChaletRepository(),
      adminNotificationGateway: FirebaseAdminNotificationGateway(),
    );
  }
}
