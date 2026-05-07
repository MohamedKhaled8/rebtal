import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/helper/cloudinary_upload_helper.dart';

// ======================= HelperImage =======================
class HelperImage {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> addSampleImages(BuildContext context) async {
    await _showImageSourceDialog(true, context);
  }

  Future<File?> pickImageFile(BuildContext context) async {
    final ImageSource? source = await _showImageSourceBottomSheet(
      context,
      false,
    );
    if (source == null) return null;

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<void> _showImageSourceDialog(
    bool isChaletPhoto,
    BuildContext context,
  ) async {
    final ImageSource? source = await _showImageSourceBottomSheet(
      context,
      isChaletPhoto,
    );
    if (source != null) {
      _pickImage(source, isChaletPhoto, context);
    }
  }

  Future<ImageSource?> _showImageSourceBottomSheet(
    BuildContext context,
    bool isChaletPhoto,
  ) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) =>
          _ImagePickerBottomSheet(isChaletPhoto: isChaletPhoto, isDark: isDark),
    );
  }

  Future<void> _pickImage(
    ImageSource source,
    bool isChaletPhoto,
    BuildContext context,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      if (isChaletPhoto) {
        final validationErrors = await context
            .read<AppCubit>()
            .ownerCubit // Access via AppCubit
            .addChaletImage(source);
        Navigator.of(context).pop();

        if (validationErrors.isEmpty) {
          SnackBarHelper.showSuccess(
            context,
            source == ImageSource.gallery
                ? context.tr('owner_chalet_photos_added_success')
                : context.tr('owner_chalet_photo_added_success'),
          );
        } else {
          // Show validation errors
          final errorMessage = validationErrors.join('\n');
          SnackBarHelper.showError(
            context,
            '${context.tr('owner_some_images_not_added')}\n$errorMessage',
          );
        }
      } else {
        // Profile picture - pick image directly
        Navigator.of(context).pop();

        // Check permissions
        bool hasPermission = await _checkAndRequestPermissions(source);
        if (!hasPermission) {
          SnackBarHelper.showError(
            context,
            context.tr('owner_permission_denied_settings'),
          );
          return;
        }

        // Pick image
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1200,
          maxHeight: 1200,
        );

        if (pickedFile != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final profileUrl = await uploadToCloudinary(File(pickedFile.path));

            // Save to Firestore in Users/Owners collection
            final authCubit = context.read<AppCubit>().authCubit;
            final currentUser = authCubit.getCurrentUser();

            if (currentUser != null) {
              String collectionName = 'Users';
              if (currentUser.role.toLowerCase().trim() == 'owner') {
                collectionName = 'Owners';
              } else if (currentUser.role.toLowerCase().trim() == 'admin') {
                collectionName = 'Admin';
              }

              await FirebaseFirestore.instance
                  .collection(collectionName)
                  .doc(currentUser.uid)
                  .update({'profileImageUrl': profileUrl});

              // Reload user data to update the UI
              await authCubit.reloadUserData();
            }

            Navigator.of(context).pop();
            SnackBarHelper.showSuccess(
              context,
              context.tr('profile_picture_updated_success'),
            );
          } catch (e) {
            Navigator.of(context).pop();
            SnackBarHelper.showError(
              context,
              '${context.tr('common_error_uploading_image')} $e',
            );
          }
        }
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();

      String errorMessage = context.tr('common_error_picking_image');
      if (e.toString().contains('PlatformException')) {
        errorMessage = context.tr('common_access_error_permissions');
      } else if (e.toString().contains('channel')) {
        errorMessage = context.tr('common_plugin_error_restart');
      }

      SnackBarHelper.showError(context, errorMessage);
    }
  }

  void addProfilePicture(BuildContext context) {
    _showImageSourceDialog(false, context);
  }

  Future<bool> _checkAndRequestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      PermissionStatus cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
      }
      return cameraStatus.isGranted;
    }
    // Gallery: image_picker uses Android's built-in photo picker (Intent-based)
    // which does NOT require READ_MEDIA_IMAGES or storage permissions.
    // No manual permission request needed for gallery selection.
    return true;
  }

  Future<void> submitForm(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    final data = context.read<AppCubit>().ownerCubit.state.draft;
    if (!formKey.currentState!.validate()) return;

    if (data.uploadedImages.isEmpty) {
      SnackBarHelper.showWarning(
        context,
        context.tr('owner_upload_chalet_images'),
      );
      return;
    }
    if ((data.chaletName?.isEmpty ?? true) ||
        (data.description?.isEmpty ?? true) ||
        (data.phoneNumber?.isEmpty ?? true) ||
        (data.selectedLocation.isEmpty) ||
        (data.chaletArea?.isEmpty ?? true)) {
      SnackBarHelper.showWarning(context, context.tr('owner_fill_all_fields'));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      List<String> chaletImageUrls = await Future.wait(
        data.uploadedImages.map((img) => uploadToCloudinary(img)),
      );

      final ownerId = context.read<AppCubit>().getCurrentUser()?.uid;
      if (ownerId == null) {
        Navigator.of(context).pop();
        SnackBarHelper.showError(context, 'Error: Owner ID not found');
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final docRef = await firestore.collection("chalets").add({
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
        "amenities": _getAmenitiesList(data),
        "childrenCount": data.childrenCount,
        "discountEnabled": data.discountEnabled,
        "discountType": data.discountType,
        "discountValue": data.discountValue,
        "features": data.features,
      });

      final realtimeDB = FirebaseDatabase.instance.ref("chalets");
      await realtimeDB.child(docRef.id).set({
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
        "amenities": _getAmenitiesList(data),
        "childrenCount": data.childrenCount,
        "discountEnabled": data.discountEnabled,
        "discountType": data.discountType,
        "discountValue": data.discountValue,
        "features": data.features,
      });

      Navigator.of(context).pop();
      SnackBarHelper.showSuccess(
        context,
        context.tr('owner_chalet_submitted_success'),
      );

      try {
        final adminsSnapshot = await FirebaseFirestore.instance
            .collection('Admin')
            .get();
        for (var adminDoc in adminsSnapshot.docs) {
          await NotificationService().sendNotification(
            userId: adminDoc.id,
            title: context.tr('notif_new_chalet_review'),
            body: context
                .tr('notif_new_chalet_body')
                .replaceFirst('{name}', data.merchantName ?? '')
                .replaceFirst('{chalet}', data.chaletName ?? ''),
            type: NotificationType.chaletSubmission,
            relatedId: docRef.id,
            data: {'chaletId': docRef.id, 'ownerId': ownerId},
          );
        }
      } catch (e) {}

      Navigator.of(context).pop(true);
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      SnackBarHelper.showError(context, "Error: $e");
    }
  }

  Future<String> uploadToCloudinary(File imageFile) {
    return CloudinaryUploadHelper.uploadImage(imageFile);
  }

  List<String> _getAmenitiesList(dynamic data) {
    final List<String> amenities = [];
    if (data.hasWifi) amenities.add('hasWifi');
    if (data.hasPool) amenities.add('hasPool');
    if (data.hasAirConditioning) amenities.add('hasAirConditioning');
    if (data.hasParking) amenities.add('hasParking');
    if (data.hasGarden) amenities.add('hasGarden');
    if (data.hasBBQ) amenities.add('hasBBQ');
    if (data.hasBeachView) amenities.add('hasBeachView');
    if (data.hasHousekeeping) amenities.add('hasHousekeeping');
    if (data.hasPetsAllowed) amenities.add('hasPetsAllowed');
    if (data.hasGym) amenities.add('hasGym');
    if (data.hasKitchen) amenities.add('hasKitchen');
    if (data.hasTV) amenities.add('hasTV');
    return amenities;
  }
}

class _ImagePickerBottomSheet extends StatelessWidget {
  final bool isChaletPhoto;
  final bool isDark;

  const _ImagePickerBottomSheet({
    required this.isChaletPhoto,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.darkBackground0A0E27.withOpacity(0.95)
            : ColorsManager.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorsManager.blue2563EB.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isChaletPhoto
                        ? Icons.collections_rounded
                        : Icons.account_circle_rounded,
                    color: ColorsManager.blue2563EB,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChaletPhoto
                            ? context.tr('owner_add_chalet_images')
                            : context.tr('profile_change_photo'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        context.tr('common_select_source'),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _ImageSourceOption(
              onTap: () => Navigator.pop(context, ImageSource.camera),
              icon: Icons.camera_enhance_rounded,
              title: context.tr('auth_camera'),
              subtitle: isChaletPhoto
                  ? context.tr('owner_capture_single_photo')
                  : context.tr('profile_capture_new_photo'),
              gradient: const LinearGradient(
                colors: [ColorsManager.blue2563EB, ColorsManager.purple764BA2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _ImageSourceOption(
              onTap: () => Navigator.pop(context, ImageSource.gallery),
              icon: Icons.photo_library_rounded,
              title: context.tr('auth_gallery'),
              subtitle: isChaletPhoto
                  ? context.tr('owner_select_multiple_photos')
                  : context.tr('profile_select_from_gallery'),
              gradient: const LinearGradient(
                colors: [
                  ColorsManager.purple764BA2,
                  ColorsManager.bookingsAccentPrimary,
                ], // Standard branding gradient reversed for variety
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white12
                        : Colors.black.withOpacity(0.08),
                  ),
                ),
              ),
              child: Text(
                context.tr('common_cancel'),
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final bool isDark;

  const _ImageSourceOption({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: isDark ? ColorsManager.darkSurface1E1E1E : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
