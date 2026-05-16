import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/image_clean/helper_image_actions.dart';
import 'package:rebtal/core/utils/helper/image_clean/helper_image_contract.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_gateways.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_models.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_source_bottom_sheet.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_use_cases.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_state.dart';

class HelperImage implements HelperImageContract {
  final ImageHelperDependencies _dependencies;
  final ProfileImageUseCase _profileImageUseCase;
  final ChaletSubmissionUseCase _chaletSubmissionUseCase;
  final ChaletDraftValidator _draftValidator;
  final ChaletAmenitiesExtractor _amenitiesExtractor;
  final ChaletImageSelectionAction _chaletImageSelectionAction;
  final PickImageErrorResolver _pickImageErrorResolver;

  factory HelperImage({
    ImageHelperDependencies? dependencies,
    ProfileImageUseCase? profileImageUseCase,
    ChaletSubmissionUseCase? chaletSubmissionUseCase,
    ChaletDraftValidator? draftValidator,
    ChaletAmenitiesExtractor? amenitiesExtractor,
    ChaletImageSelectionAction? chaletImageSelectionAction,
    PickImageErrorResolver? pickImageErrorResolver,
  }) {
    final resolvedDependencies = dependencies ?? ImageHelperDependencies.defaults();
    return HelperImage._(
      dependencies: resolvedDependencies,
      profileImageUseCase:
          profileImageUseCase ??
          ProfileImageUseCase(dependencies: resolvedDependencies),
      chaletSubmissionUseCase:
          chaletSubmissionUseCase ??
          ChaletSubmissionUseCase(dependencies: resolvedDependencies),
      draftValidator: draftValidator ?? const ChaletDraftValidator(),
      amenitiesExtractor: amenitiesExtractor ?? const ChaletAmenitiesExtractor(),
      chaletImageSelectionAction:
          chaletImageSelectionAction ?? const ChaletImageSelectionAction(),
      pickImageErrorResolver:
          pickImageErrorResolver ?? const PickImageErrorResolver(),
    );
  }

  const HelperImage._({
    required ImageHelperDependencies dependencies,
    required ProfileImageUseCase profileImageUseCase,
    required ChaletSubmissionUseCase chaletSubmissionUseCase,
    required ChaletDraftValidator draftValidator,
    required ChaletAmenitiesExtractor amenitiesExtractor,
    required ChaletImageSelectionAction chaletImageSelectionAction,
    required PickImageErrorResolver pickImageErrorResolver,
  }) : _dependencies = dependencies,
       _profileImageUseCase = profileImageUseCase,
       _chaletSubmissionUseCase = chaletSubmissionUseCase,
       _draftValidator = draftValidator,
       _amenitiesExtractor = amenitiesExtractor,
       _chaletImageSelectionAction = chaletImageSelectionAction,
       _pickImageErrorResolver = pickImageErrorResolver;

  @override
  Future<void> addSampleImages(BuildContext context) async {
    await _showImageSourceDialog(isChaletPhoto: true, context: context);
  }

  @override
  Future<File?> pickImageFile(BuildContext context) async {
    final ImageSource? source = await _showImageSourceBottomSheet(
      context: context,
      isChaletPhoto: false,
    );
    if (source == null) return null;

    final XFile? pickedFile = await _dependencies.imagePickerGateway.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1000,
      maxHeight: 1000,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  @override
  void addProfilePicture(BuildContext context) {
    _showImageSourceDialog(isChaletPhoto: false, context: context);
  }

  @override
  Future<void> submitForm(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    final appCubit = context.read<AppCubit>();
    final draft = appCubit.ownerCubit.state.draft;
    final data = _toSnapshot(draft);
    if (!formKey.currentState!.validate()) return;

    final validationKey = _draftValidator.validate(data);
    if (validationKey != null) {
      SnackBarHelper.showWarning(context, context.tr(validationKey));
      return;
    }

    final loader = LoadingOverlayController(context)..show();
    try {
      final ownerId = appCubit.getCurrentUser()?.uid;
      if (ownerId == null) {
        loader.hideIfVisible();
        SnackBarHelper.showError(context, 'Error: Owner ID not found');
        return;
      }

      await _chaletSubmissionUseCase.execute(
        data: data,
        ownerId: ownerId,
        reviewTitleKey: 'notif_new_chalet_review',
        reviewBodyKey: 'notif_new_chalet_body',
        reviewBodyParams: {
          'name': draft.merchantName ?? '',
          'chalet': draft.chaletName ?? '',
        },
        amenities: _amenitiesExtractor.extract(data),
      );

      loader.hideIfVisible();
      SnackBarHelper.showSuccess(
        context,
        context.tr('owner_chalet_submitted_success'),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      loader.hideIfVisible();
      SnackBarHelper.showError(context, "Error: $e");
    }
  }

  @override
  Future<String> uploadToCloudinary(File imageFile) {
    return _dependencies.imageUploadGateway.uploadImage(imageFile);
  }

  Future<void> _showImageSourceDialog({
    required bool isChaletPhoto,
    required BuildContext context,
  }) async {
    final source = await _showImageSourceBottomSheet(
      context: context,
      isChaletPhoto: isChaletPhoto,
    );
    if (source != null) {
      await _handleImageAction(
        context: context,
        source: source,
        isChaletPhoto: isChaletPhoto,
      );
    }
  }

  Future<ImageSource?> _showImageSourceBottomSheet({
    required BuildContext context,
    required bool isChaletPhoto,
  }) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (_) =>
          ImageSourceBottomSheet(isChaletPhoto: isChaletPhoto, isDark: isDark),
    );
  }

  Future<void> _handleImageAction({
    required BuildContext context,
    required ImageSource source,
    required bool isChaletPhoto,
  }) async {
    final loader = LoadingOverlayController(context);
    try {
      loader.show();
      final appCubit = context.read<AppCubit>();

      if (isChaletPhoto) {
        await _chaletImageSelectionAction.execute(
          context: context,
          appCubit: appCubit,
          source: source,
          loader: loader,
        );
        return;
      }

      await _handleProfileSelection(
        context: context,
        source: source,
        appCubit: appCubit,
        loader: loader,
      );
    } catch (e) {
      loader.hideIfVisible();
      SnackBarHelper.showError(
        context,
        _pickImageErrorResolver.resolveMessage(context, e),
      );
    }
  }

  Future<void> _handleProfileSelection({
    required BuildContext context,
    required ImageSource source,
    required AppCubit appCubit,
    required LoadingOverlayController loader,
  }) async {
    loader.hideIfVisible();
    final currentUser = appCubit.authCubit.getCurrentUser();
    if (currentUser == null) return;

    loader.show();
    try {
      await _profileImageUseCase.execute(
        source: source,
        uid: currentUser.uid,
        role: currentUser.role,
      );
      await appCubit.authCubit.reloadUserData();
      loader.hideIfVisible();
      SnackBarHelper.showSuccess(
        context,
        context.tr('profile_picture_updated_success'),
      );
    } catch (e) {
      loader.hideIfVisible();
      if (e.toString().contains('PermissionDenied')) {
        SnackBarHelper.showError(
          context,
          context.tr('owner_permission_denied_settings'),
        );
        return;
      }
      SnackBarHelper.showError(
        context,
        '${context.tr('common_error_uploading_image')} $e',
      );
    }
  }

  ChaletDraftSnapshot _toSnapshot(ChaletDraft draft) {
    return ChaletDraftSnapshot(
      uploadedImages: List<File>.from(draft.uploadedImages),
      selectedLocation: draft.selectedLocation,
      isAvailable: draft.isAvailable,
      hasWifi: draft.hasWifi,
      hasPool: draft.hasPool,
      hasAirConditioning: draft.hasAirConditioning,
      hasParking: draft.hasParking,
      hasGarden: draft.hasGarden,
      hasBBQ: draft.hasBBQ,
      hasBeachView: draft.hasBeachView,
      hasHousekeeping: draft.hasHousekeeping,
      hasPetsAllowed: draft.hasPetsAllowed,
      hasGym: draft.hasGym,
      hasKitchen: draft.hasKitchen,
      hasTV: draft.hasTV,
      status: draft.status,
      phoneNumber: draft.phoneNumber,
      email: draft.email,
      chaletName: draft.chaletName,
      description: draft.description,
      merchantName: draft.merchantName,
      price: draft.price,
      chaletArea: draft.chaletArea,
      bedrooms: draft.bedrooms,
      bathrooms: draft.bathrooms,
      availableFrom: draft.availableFrom,
      availableTo: draft.availableTo,
      childrenCount: draft.childrenCount,
      discountEnabled: draft.discountEnabled,
      discountType: draft.discountType,
      discountValue: draft.discountValue,
      features: List<String>.from(draft.features),
    );
  }
}
