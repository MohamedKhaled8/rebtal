import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';

// ======================= HelperImage =======================
class HelperImage {
  static const String _cloudName = "dwobtaa6a";
  static const String _apiKey = "249478428416757";
  static const String _uploadPreset = "Mmkkkkk";

  Future<void> addSampleImages(BuildContext context) async {
    await _showImageSourceDialog(true, context);
  }

  Future<void> _showImageSourceDialog(
    bool isChaletPhoto,
    BuildContext context,
  ) async {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isChaletPhoto ? 'Add Chalet Photo' : 'Add Profile Photo',
            style: TextStyle(
              color: ColorManager.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: ColorManager.kPrimaryGradient.colors.first,
                ),
                title: Text('Camera'),
                subtitle: isChaletPhoto
                    ? const Text('Take a single photo')
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isChaletPhoto, parentContext);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: ColorManager.kPrimaryGradient.colors.first,
                ),
                title: Text('Gallery'),
                subtitle: isChaletPhoto
                    ? const Text('Select multiple photos')
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isChaletPhoto, parentContext);
                },
              ),
            ],
          ),
        );
      },
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
            .read<OwnerCubit>()
            .addChaletImage(source);
        Navigator.of(context).pop();

        if (validationErrors.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.gallery
                    ? 'Chalet photos added successfully!'
                    : 'Chalet photo added successfully!',
              ),
              backgroundColor: ColorManager.green,
            ),
          );
        } else {
          // Show validation errors
          final errorMessage = validationErrors.join('\n');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Some images were not added:\n$errorMessage'),
              backgroundColor: ColorManager.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        await context.read<OwnerCubit>().addProfileImage(source);
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: ColorManager.green,
          ),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();

      String errorMessage = 'Error picking image';
      if (e.toString().contains('PlatformException')) {
        errorMessage = 'Camera/Gallery access error. Please check permissions.';
      } else if (e.toString().contains('channel')) {
        errorMessage = 'Plugin connection error. Please restart the app.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: ColorManager.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: ColorManager.white,
            onPressed: () => _pickImage(source, isChaletPhoto, context),
          ),
        ),
      );

      print('Image picker error: $e');
    }
  }

  void addProfilePicture(BuildContext context) {
    _showImageSourceDialog(false, context);
  }

  Future<void> submitForm(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    final data = context.read<OwnerCubit>().currentData;
    if (!formKey.currentState!.validate()) return;

    if (data.profileImage == null || data.uploadedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload profile & chalet images')),
      );
      return;
    }
    if ((data.chaletName?.isEmpty ?? true) ||
        (data.description?.isEmpty ?? true) ||
        (data.phoneNumber?.isEmpty ?? true) ||
        (data.selectedLocation.isEmpty) ||
        (data.chaletArea?.isEmpty ?? true)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final profileUrl = await _uploadToCloudinary(data.profileImage!);

      // Upload all chalet images concurrently for better performance
      List<String> chaletImageUrls = await Future.wait(
        data.uploadedImages.map((img) => _uploadToCloudinary(img)),
      );

      final ownerId = context.read<AuthCubit>().getCurrentUser()?.uid;
      if (ownerId == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Owner ID not found')),
        );
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final docRef = await firestore.collection("chalets").add({
        "ownerId": ownerId, // 🆕 Add ownerId
        "profileImage": profileUrl,
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
        "profileImage": profileUrl,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chalet submitted successfully')),
      );
      // Close the OwnerScreen and return `true` so callers can refresh their list
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
