import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

// ======================= HelperImage =======================
class HelperImage {
  static const String _cloudName = "dwobtaa6a";
  static const String _apiKey = "249478428416757";
  static const String _uploadPreset = "Mmkkkkk";
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> addSampleImages(BuildContext context) async {
    await _showImageSourceDialog(true, context);
  }

  Future<void> _showImageSourceDialog(
    bool isChaletPhoto,
    BuildContext context,
  ) async {
    final parentContext = context;
    final isDark = DynamicThemeManager.isDarkMode(context);

    showDialog(
      context: context,
      barrierColor: ColorManager.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: ColorManager.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? ColorManager.bookingsCardDark
                  : ColorManager.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.black.withOpacity(isDark ? 0.5 : 0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? ColorManager.white.withOpacity(0.1)
                            : ColorManager.black.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: ColorManager.kPrimaryGradient.colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: ColorManager.kPrimaryGradient.colors.first
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isChaletPhoto ? Icons.photo_camera : Icons.person,
                          color: ColorManager.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isChaletPhoto
                                  ? 'إضافة صور الشاليه'
                                  : 'تغيير الصورة الشخصية',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? ColorManager.white
                                    : ColorManager.chaletGrey800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isChaletPhoto
                                  ? 'اختر مصدر الصور'
                                  : 'اختر مصدر الصورة',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? ColorManager.white70
                                    : ColorManager.chaletGrey500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? ColorManager.white70
                              : ColorManager.chaletGrey500,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Options
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Camera Option
                      _buildImageSourceOption(
                        context: context,
                        icon: Icons.camera_alt_rounded,
                        title: 'الكاميرا',
                        subtitle: isChaletPhoto
                            ? 'التقاط صورة واحدة'
                            : 'التقاط صورة جديدة',
                        gradient: LinearGradient(
                          colors: [
                            ColorManager.bookingsAccentPrimary,
                            ColorManager.bookingsAccentSecondary,
                          ],
                        ),
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(
                            ImageSource.camera,
                            isChaletPhoto,
                            parentContext,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Gallery Option
                      _buildImageSourceOption(
                        context: context,
                        icon: Icons.photo_library_rounded,
                        title: 'المعرض',
                        subtitle: isChaletPhoto
                            ? 'اختيار صور متعددة'
                            : 'اختيار صورة من المعرض',
                        gradient: LinearGradient(
                          colors: [
                            ColorManager.cyan00C9FF,
                            ColorManager.green92FE9D,
                          ],
                        ),
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(
                            ImageSource.gallery,
                            isChaletPhoto,
                            parentContext,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: ColorManager.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? ColorManager.white.withOpacity(0.05)
                : ColorManager.greyF9FAFB,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? ColorManager.white.withOpacity(0.1)
                  : ColorManager.black.withOpacity(0.08),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: ColorManager.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? ColorManager.white
                            : ColorManager.grey1F2937,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? ColorManager.white70
                            : ColorManager.grey6B7280,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark
                    ? ColorManager.white.withOpacity(0.3)
                    : ColorManager.grey9CA3AF,
                size: 18,
              ),
            ],
          ),
        ),
      ),
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
                ? 'Chalet photos added successfully!'
                : 'Chalet photo added successfully!',
          );
        } else {
          // Show validation errors
          final errorMessage = validationErrors.join('\n');
          SnackBarHelper.showError(
            context,
            'Some images were not added:\n$errorMessage',
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
            'Permission denied. Please grant camera/gallery access in settings.',
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
            final profileUrl = await _uploadToCloudinary(File(pickedFile.path));

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
              'تم تحديث الصورة الشخصية بنجاح!',
            );
          } catch (e) {
            Navigator.of(context).pop();
            SnackBarHelper.showError(context, 'خطأ في رفع الصورة: $e');
          }
        }
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();

      String errorMessage = 'Error picking image';
      if (e.toString().contains('PlatformException')) {
        errorMessage = 'Camera/Gallery access error. Please check permissions.';
      } else if (e.toString().contains('channel')) {
        errorMessage = 'Plugin connection error. Please restart the app.';
      }

      SnackBarHelper.showError(context, errorMessage);

      print('Image picker error: $e');
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

  Future<void> submitForm(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    final data = context.read<AppCubit>().ownerCubit.currentData;
    if (!formKey.currentState!.validate()) return;

    if (data.uploadedImages.isEmpty) {
      SnackBarHelper.showWarning(context, 'Upload chalet images');
      return;
    }
    if ((data.chaletName?.isEmpty ?? true) ||
        (data.description?.isEmpty ?? true) ||
        (data.phoneNumber?.isEmpty ?? true) ||
        (data.selectedLocation.isEmpty) ||
        (data.chaletArea?.isEmpty ?? true)) {
      SnackBarHelper.showWarning(context, 'Fill all fields');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Upload all chalet images concurrently for better performance
      List<String> chaletImageUrls = await Future.wait(
        data.uploadedImages.map((img) => _uploadToCloudinary(img)),
      );

      final ownerId = context.read<AppCubit>().getCurrentUser()?.uid;
      if (ownerId == null) {
        Navigator.of(context).pop();
        SnackBarHelper.showError(context, 'Error: Owner ID not found');
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final docRef = await firestore.collection("chalets").add({
        "ownerId": ownerId, // 🆕 Add ownerId
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
        "chaletArea": data.chaletArea, // 🆕
        "bedrooms": data.bedrooms, // 🆕
        "bathrooms": data.bathrooms, // 🆕
        "availableFrom": data.availableFrom?.toIso8601String(),
        "availableTo": data.availableTo?.toIso8601String(),
        "email": data.email,
        "amenities": _getAmenitiesList(data), // 🆕 Add amenities list
        "childrenCount": data.childrenCount, // 🆕
        "discountEnabled": data.discountEnabled, // 🆕
        "discountType": data.discountType, // 🆕
        "discountValue": data.discountValue, // 🆕
        "features": data.features, // 🆕
      });

      final realtimeDB = FirebaseDatabase.instance.ref("chalets");
      await realtimeDB.child(docRef.id).set({
        "ownerId": ownerId, // 🆕 Add ownerId
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
        "chaletArea": data.chaletArea, // 🆕
        "bedrooms": data.bedrooms, // 🆕
        "bathrooms": data.bathrooms, // 🆕
        "availableFrom": data.availableFrom?.toIso8601String(),
        "availableTo": data.availableTo?.toIso8601String(),
        "amenities": _getAmenitiesList(data), // 🆕 Add amenities list
        "childrenCount": data.childrenCount, // 🆕
        "discountEnabled": data.discountEnabled, // 🆕
        "discountType": data.discountType, // 🆕
        "discountValue": data.discountValue, // 🆕
        "features": data.features, // 🆕
      });

      Navigator.of(context).pop();
      SnackBarHelper.showSuccess(context, 'Chalet submitted successfully');

      // ✅ Send notification to admins
      try {
        final adminsSnapshot = await FirebaseFirestore.instance
            .collection('Admin')
            .get();
        for (var adminDoc in adminsSnapshot.docs) {
          await NotificationService().sendNotification(
            userId: adminDoc.id,
            title: 'شاليه جديد قيد المراجعة 🏗️',
            body:
                'قام ${data.merchantName} برفع شاليه جديد (${data.chaletName}) وهو بانتظار موافقتك.',
            type: NotificationType.chaletSubmission,
            relatedId: docRef.id,
            data: {'chaletId': docRef.id, 'ownerId': ownerId},
          );
        }
      } catch (e) {
        debugPrint('Error sending admin notification: $e');
      }

      // Close the OwnerScreen and return `true` so callers can refresh their list
      Navigator.of(context).pop(true);
    } catch (e) {
      SnackBarHelper.showError(context, "Error: $e");
    }
  }

  Future<String> _uploadToCloudinary(File imageFile) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['api_key'] = _apiKey
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final jsonResp = jsonDecode(respStr);
        return jsonResp['secure_url'];
      } else {
        final respStr = await response.stream.bytesToString();
        print("🌐 Cloudinary error body: $respStr");
        throw Exception(
          "Cloudinary upload failed with status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("🌐 Cloudinary upload error: $e");
      rethrow;
    }
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
