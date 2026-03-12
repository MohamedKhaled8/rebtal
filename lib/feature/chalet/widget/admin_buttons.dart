import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/action_buttons_cubit.dart';

class AdminButtons extends StatelessWidget {
  final String status;
  final String docId;

  const AdminButtons({super.key, required this.status, required this.docId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActionButtonsCubit, ActionButtonsState>(
      listener: (context, state) {
        if (state is ActionButtonsSuccess) {
          if (state.newStatus == 'rejected') {
            SnackBarHelper.showError(context, state.message);
          } else {
            SnackBarHelper.showSuccess(context, state.message);
          }
        } else if (state is ActionButtonsError) {
          SnackBarHelper.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final cubit = context.read<ActionButtonsCubit>();
        String currentStatus = status;
        if (state is ActionButtonsSuccess && state.newStatus != null) {
          currentStatus = state.newStatus!;
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
          child: currentStatus == 'pending'
              ? Column(
                  children: [
                    if (state is ActionButtonsLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => cubit.updateStatus(
                            docId: docId,
                            newStatus: 'approved',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.chaletActionGreen,
                            foregroundColor: ColorsManager.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shadowColor: ColorsManager.transparent,
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
                          onPressed: () => cubit.updateStatus(
                            docId: docId,
                            newStatus: 'rejected',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorsManager.chaletActionRed,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: const BorderSide(
                              color: ColorsManager.chaletActionRed,
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
                  ],
                )
              : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
                        color: ColorsManager.chaletActionBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      SnackBarHelper.showWarning(
                        context,
                        'Request already processed',
                      );
                    },
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
                          currentStatus == 'approved'
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 22,
                          color: ColorsManager.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          currentStatus == 'approved'
                              ? 'Request Approved'
                              : 'Request Rejected',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: ColorsManager.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
