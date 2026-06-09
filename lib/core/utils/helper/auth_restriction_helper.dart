import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/profile/ui/personal_info_page.dart';

class AuthRestrictionHelper {
  static bool isGuest(BuildContext context) {
    return context.read<AppCubit>().authCubit.state is AuthGuest;
  }

  static bool hasIdCard(UserModel? user) {
    final url = user?.idCardUrl?.trim();
    return url != null && url.isNotEmpty;
  }

  static void showGuestRegistrationPrompt(BuildContext context) {
    SnackBarHelper.showAction(
      title: context.tr('guest_complete_data_title'),
      actionLabel: context.tr('guest_complete_data_action'),
      icon: Icons.person_add_alt_1_rounded,
      onAction: () {
        Navigator.of(context).pushNamed(Routes.registerScreen);
      },
    );
  }

  static void showIdCardRequiredForBooking(BuildContext context) {
    SnackBarHelper.showAction(
      title: context.tr('identity_verify_booking_title'),
      actionLabel: context.tr('identity_upload_id_action'),
      icon: Icons.badge_outlined,
      onAction: () => _navigateToIdCardUpload(context),
    );
  }

  static void showIdCardRequiredForOwner(BuildContext context) {
    SnackBarHelper.showAction(
      title: context.tr('identity_verify_owner_title'),
      actionLabel: context.tr('identity_upload_id_action'),
      icon: Icons.badge_outlined,
      onAction: () => _navigateToIdCardUpload(context),
    );
  }

  static void _navigateToIdCardUpload(BuildContext context) {
    final user = context.read<AppCubit>().getCurrentUser();
    if (user == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonalInfoPage(
          user: user,
          scrollToIdCard: true,
        ),
      ),
    );
  }

  /// Returns true if the action is allowed to proceed.
  static bool guardBooking(BuildContext context) {
    if (isGuest(context)) {
      showGuestRegistrationPrompt(context);
      return false;
    }

    final user = context.read<AppCubit>().getCurrentUser();
    if (user == null) {
      showGuestRegistrationPrompt(context);
      return false;
    }

    if (!hasIdCard(user)) {
      showIdCardRequiredForBooking(context);
      return false;
    }

    return true;
  }

  /// Returns true if owner can add a chalet.
  static bool guardOwnerAddChalet(BuildContext context) {
    final user = context.read<AppCubit>().getCurrentUser();
    if (user == null) {
      showGuestRegistrationPrompt(context);
      return false;
    }

    if (!hasIdCard(user)) {
      showIdCardRequiredForOwner(context);
      return false;
    }

    return true;
  }
}
