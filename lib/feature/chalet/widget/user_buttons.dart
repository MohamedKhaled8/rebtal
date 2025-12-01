import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/chalet/logic/cubit/action_buttons_cubit.dart';

class UserButtons extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String docId;

  const UserButtons({
    super.key,
    required this.requestData,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: _BookingButton(requestData: requestData, docId: docId),
    );
  }
}

class _BookingButton extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String docId;

  const _BookingButton({required this.requestData, required this.docId});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.getCurrentUser();
    final cubit = context.read<ActionButtonsCubit>();

    if (currentUser == null) return const SizedBox.shrink();

    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';
    final isBookingAvailable = bookingAvailability == 'available';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isBookingAvailable
            ? const LinearGradient(
                colors: [
                  ColorManager.chaletActionGreen,
                  ColorManager.chaletActionDarkGreen,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  ColorManager.chaletActionGrey,
                  ColorManager.chaletActionDarkGrey,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (isBookingAvailable
                        ? ColorManager.chaletActionGreen
                        : ColorManager.chaletActionGrey)
                    .withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isBookingAvailable
            ? () => cubit.showBookingSheet(
                context,
                docId: docId,
                requestData: requestData,
              )
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'الحجز غير متاح حالياً',
                      style: TextStyle(color: ColorManager.white),
                    ),
                    backgroundColor: ColorManager.chaletActionRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.transparent,
          shadowColor: ColorManager.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBookingAvailable ? Icons.bookmark_outline : Icons.lock,
              size: 22,
              color: ColorManager.white,
            ),
            const SizedBox(width: 12),
            Text(
              isBookingAvailable ? 'Booking Now' : 'الحجز مغلق',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorManager.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
