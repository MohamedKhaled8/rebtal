import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/action_buttons_cubit.dart';

class AdminButtons extends StatelessWidget {
  final String status;
  final String docId;

  const AdminButtons({super.key, required this.status, required this.docId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ActionButtonsCubit>();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: status == 'pending'
          ? Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        cubit.updateStatus(docId: docId, newStatus: 'approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.chaletActionGreen,
                      foregroundColor: ColorManager.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shadowColor: ColorManager.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'Approve Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        cubit.updateStatus(docId: docId, newStatus: 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorManager.chaletActionRed,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(
                        color: ColorManager.chaletActionRed,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_outlined, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'Reject Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    ColorManager.chaletActionBlue,
                    ColorManager.chaletActionDarkBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.chaletActionBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Request already processed',
                        style: TextStyle(color: ColorManager.white),
                      ),
                      backgroundColor: ColorManager.chaletGrey800,
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
                      status == 'approved' ? Icons.check_circle : Icons.cancel,
                      size: 22,
                      color: ColorManager.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      status == 'approved'
                          ? 'Request Approved'
                          : 'Request Rejected',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
