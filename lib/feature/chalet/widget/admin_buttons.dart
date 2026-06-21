import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/chalet/logic/cubit/action_buttons_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/feature/owner/utils/chalet_edit_review_helper.dart';

class AdminButtons extends StatelessWidget {
  final String status;
  final String docId;
  final Map<String, dynamic> requestData;

  const AdminButtons({
    super.key,
    required this.status,
    required this.docId,
    required this.requestData,
  });

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

        final showApproveActions =
            ChaletEditReviewHelper.shouldShowAdminApproveActions(
              requestData,
              currentStatus,
            );

        return Container(
          margin: EdgeInsets.fromLTRB(16.sp, 0, 16.sp, 40.sp),
          child: showApproveActions
              ? Column(
                  children: [
                    if (state is ActionButtonsLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      // Approve Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.sp),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => cubit.updateStatus(docId: docId, newStatus: 'approved'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 16.sp),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 24.sp, color: Colors.white),
                              horizintalSpace(1),
                              Text(
                                context.tr('admin_approve').isEmpty ? 'قبول الطلب' : context.tr('admin_approve'),
                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpace(1.5),
                      // Reject Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => cubit.updateStatus(docId: docId, newStatus: 'rejected'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            padding: EdgeInsets.symmetric(vertical: 16.sp),
                            side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.5), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
                            backgroundColor: const Color(0xFFFEF2F2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_rounded, size: 24.sp),
                              horizintalSpace(1),
                              Text(
                                context.tr('admin_reject').isEmpty ? 'رفض الطلب' : context.tr('admin_reject'),
                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
                    gradient: LinearGradient(
                      colors: currentStatus == 'approved'
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.sp),
                    boxShadow: [
                      BoxShadow(
                        color: (currentStatus == 'approved' ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      SnackBarHelper.showWarning(context, context.tr('common_already_processed').isEmpty ? 'تم معالجة الطلب مسبقاً' : context.tr('common_already_processed'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 16.sp),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(currentStatus == 'approved' ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 24.sp, color: Colors.white),
                        horizintalSpace(1),
                        Text(
                          currentStatus == 'approved' 
                              ? (context.tr('admin_request_approved').isEmpty ? 'تم قبول الطلب' : context.tr('admin_request_approved'))
                              : (context.tr('admin_request_rejected').isEmpty ? 'تم رفض الطلب' : context.tr('admin_request_rejected')),
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
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
