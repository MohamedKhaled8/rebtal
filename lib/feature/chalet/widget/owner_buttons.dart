import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/action_buttons_cubit.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/owner/ui/add_chalet_screen.dart';

class OwnerButtons extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String docId;

  const OwnerButtons({
    super.key,
    required this.requestData,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final statusRaw = (requestData['status'] ?? '').toString().toLowerCase();
    final isApproved = statusRaw == 'approved';
    // Owner can refine listing while awaiting admin (same edit screen as approved).
    final canEdit = isApproved || statusRaw == 'pending';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(
        children: [
          _BookingToggleButton(requestData: requestData, docId: docId),
          if (canEdit) ...[
            const SizedBox(height: 12),
            _OwnerEditChaletButton(
              docId: docId,
              requestData: requestData,
            ),
          ],
          if (isApproved) ...[
            const SizedBox(height: 12),
            _OwnerDeleteChaletButton(docId: docId, requestData: requestData),
          ],
          const SizedBox(height: 16),
          const _OwnerStatusButton(),
        ],
      ),
    );
  }
}

class _OwnerEditChaletButton extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> requestData;

  const _OwnerEditChaletButton({
    required this.docId,
    required this.requestData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ColorsManager.blue2563EB,
            ColorsManager.purple764BA2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.blue2563EB.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AddChaletScreen(
                editDocId: docId,
                initialChaletData: Map<String, dynamic>.from(requestData),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.edit_rounded, color: ColorsManager.white),
        label: Text(
          context.tr('owner_edit_chalet'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ColorsManager.white,
          ),
        ),
      ),
    );
  }
}

class _OwnerDeleteChaletButton extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> requestData;

  const _OwnerDeleteChaletButton({
    required this.docId,
    required this.requestData,
  });

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(context.tr('owner_delete_chalet_confirm_title')),
          content: Text(context.tr('owner_delete_chalet_confirm_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.tr('common_cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(
                foregroundColor: ColorsManager.chaletActionRed,
              ),
              child: Text(context.tr('common_confirm')),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    final ownerId = requestData['ownerId']?.toString();
    if (ownerId == null || ownerId.isEmpty) {
      SnackBarHelper.showError(
        context,
        context.tr('owner_error_id_not_found'),
      );
      return;
    }

    PremiumLoadingOverlay.show(context);
    var ok = false;
    try {
      ok = await context.read<AppCubit>().ownerCubit.deleteChaletAsOwner(
            docId,
            ownerId,
          );
    } finally {
      if (context.mounted) {
        PremiumLoadingOverlay.dismiss(context);
      }
    }

    if (!context.mounted) return;

    if (ok) {
      SnackBarHelper.showSuccess(
        context,
        context.tr('owner_delete_chalet_success'),
      );
      Navigator.of(context).pop();
    } else {
      SnackBarHelper.showError(
        context,
        context.tr('owner_delete_chalet_failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsManager.chaletActionRed.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorsManager.chaletActionRed.withOpacity(0.5),
        ),
      ),
      child: OutlinedButton.icon(
        onPressed: () => _confirmAndDelete(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorsManager.chaletActionRed,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.delete_forever_rounded),
        label: Text(
          context.tr('owner_delete_chalet'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BookingToggleButton extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String docId;

  const _BookingToggleButton({required this.requestData, required this.docId});

  @override
  Widget build(BuildContext context) {
    final initialAvailability =
        requestData['bookingAvailability'] ?? 'available';
    final cubit = context.read<ActionButtonsCubit>();

    return BlocConsumer<ActionButtonsCubit, ActionButtonsState>(
      listener: (context, state) {
        if (state is ActionButtonsSuccess) {
          SnackBarHelper.showSuccess(
            context,
            state.message == 'Booking Enabled'
                ? context.tr('owner_start_booking')
                : context.tr('owner_stop_booking'),
          );
        } else if (state is ActionButtonsError) {
          SnackBarHelper.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final bookingAvailability =
            state.bookingAvailability ?? initialAvailability;
        final isBookingAvailable = bookingAvailability == 'available';

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isBookingAvailable
                ? const LinearGradient(
                    colors: [
                      ColorsManager.chaletActionRed,
                      ColorsManager.chaletActionDarkRed,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [
                      ColorsManager.chaletActionBlue,
                      ColorsManager.chaletActionDarkBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    (isBookingAvailable
                            ? ColorsManager.chaletActionRed
                            : ColorsManager.chaletActionGreen)
                        .withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => cubit.toggleBookingAvailability(
              docId: docId,
              requestData: requestData,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.transparent,
              shadowColor: ColorsManager.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isBookingAvailable ? Icons.pause : Icons.play_arrow,
                  size: 22,
                  color: ColorsManager.white,
                ),
                const SizedBox(width: 12),
                Text(
                  isBookingAvailable ? context.tr('owner_stop_booking') : context.tr('owner_start_booking'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OwnerStatusButton extends StatelessWidget {
  const _OwnerStatusButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsManager.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 22, color: ColorsManager.grey[600]),
            const SizedBox(width: 12),
            Text(
              context.tr('owner_your_chalet'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorsManager.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
