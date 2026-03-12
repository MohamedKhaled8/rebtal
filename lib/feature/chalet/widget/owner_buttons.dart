import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/action_buttons_cubit.dart';

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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(
        children: [
          _BookingToggleButton(requestData: requestData, docId: docId),
          const SizedBox(height: 16),
          const _OwnerStatusButton(),
        ],
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
    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';
    final isBookingAvailable = bookingAvailability == 'available';
    final cubit = context.read<ActionButtonsCubit>();

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
              isBookingAvailable ? 'إيقاف الحجز' : 'تشغيل الحجز',
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
              'Your Chalet',
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
