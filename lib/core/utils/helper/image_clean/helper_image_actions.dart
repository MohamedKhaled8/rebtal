import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_models.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class LoadingOverlayController {
  final BuildContext context;
  bool _isVisible = false;

  LoadingOverlayController(this.context);

  void show() {
    if (_isVisible) return;
    _isVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void hideIfVisible() {
    if (!_isVisible) return;
    _isVisible = false;
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}

class PickImageErrorResolver {
  const PickImageErrorResolver();

  String resolveMessage(BuildContext context, Object error) {
    final value = error.toString();
    if (value.contains('PlatformException')) {
      return context.tr('common_access_error_permissions');
    }
    if (value.contains('channel')) {
      return context.tr('common_plugin_error_restart');
    }
    return context.tr('common_error_picking_image');
  }
}

class ChaletDraftValidator {
  const ChaletDraftValidator();

  String? validate(ChaletDraftSnapshot data) {
    if (data.uploadedImages.isEmpty) return 'owner_upload_chalet_images';
    if ((data.chaletName?.isEmpty ?? true) ||
        (data.description?.isEmpty ?? true) ||
        (data.phoneNumber?.isEmpty ?? true) ||
        data.selectedLocation.isEmpty ||
        (data.chaletArea?.isEmpty ?? true)) {
      return 'owner_fill_all_fields';
    }
    return null;
  }
}

class ChaletAmenitiesExtractor {
  const ChaletAmenitiesExtractor();

  List<String> extract(ChaletDraftSnapshot data) {
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

class ChaletImageSelectionAction {
  const ChaletImageSelectionAction();

  Future<void> execute({
    required BuildContext context,
    required AppCubit appCubit,
    required ImageSource source,
    required LoadingOverlayController loader,
  }) async {
    final validationErrors = await appCubit.ownerCubit.addChaletImage(source);
    loader.hideIfVisible();

    if (validationErrors.isEmpty) {
      SnackBarHelper.showSuccess(
        context,
        source == ImageSource.gallery
            ? context.tr('owner_chalet_photos_added_success')
            : context.tr('owner_chalet_photo_added_success'),
      );
      return;
    }

    final errorMessage = validationErrors.join('\n');
    SnackBarHelper.showError(
      context,
      '${context.tr('owner_some_images_not_added')}\n$errorMessage',
    );
  }
}
