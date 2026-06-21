import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/booking/ui/booking_bridge_widget.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/auth_restriction_helper.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/owner/utils/chalet_edit_review_helper.dart';

part 'action_buttons_state.dart';

class ActionButtonsCubit extends Cubit<ActionButtonsState> {
  ActionButtonsCubit() : super(const ActionButtonsInitial());

  Future<void> updateStatus({
    required String docId,
    required String newStatus,
  }) async {
    emit(const ActionButtonsLoading());
    try {
      final docRef = FirebaseFirestore.instance
          .collection('chalets')
          .doc(docId);
      final chaletDoc = await docRef.get();
      if (!chaletDoc.exists) {
        emit(const ActionButtonsError('Chalet not found'));
        return;
      }

      final chaletData = chaletDoc.data() as Map<String, dynamic>;
      final isEditReview = ChaletEditReviewHelper.isEditReviewPending(
        chaletData,
      );

      if (isEditReview) {
        if (newStatus == 'approved') {
          final pending = chaletData['pendingEditData'];
          final merge = pending is Map
              ? Map<String, dynamic>.from(pending)
              : <String, dynamic>{};
          merge['status'] = 'approved';
          merge['isVisible'] = true;
          merge['editReviewStatus'] = FieldValue.delete();
          merge['pendingEditData'] = FieldValue.delete();
          merge['submissionType'] = FieldValue.delete();
          merge['editSubmittedAt'] = FieldValue.delete();
          merge['updatedAt'] = FieldValue.serverTimestamp();
          ChaletEditReviewHelper.applyDayUseFieldDeletesIfNeeded(merge);
          await docRef.update(merge);
        } else if (newStatus == 'rejected') {
          await docRef.update({
            'editReviewStatus': FieldValue.delete(),
            'pendingEditData': FieldValue.delete(),
            'submissionType': FieldValue.delete(),
            'editSubmittedAt': FieldValue.delete(),
            'isVisible': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await docRef.update({
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        await docRef.update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
          if (newStatus == 'approved') 'isVisible': true,
        });
      }

      // Send notification to owner
      {
        // Use merchantId or userId as fallback for ownerId
        String? ownerId =
            (chaletData['ownerId'] ??
                    chaletData['merchantId'] ??
                    chaletData['userId'])
                ?.toString();
        final chaletName = chaletData['chaletName'] ?? 'شاليهك';

        if (ownerId != null && ownerId.isNotEmpty) {
          // Normalize ID just in case it has a prefix (e.g., 'user:ABC')
          if (ownerId.contains(':')) {
            ownerId = ownerId.split(':').last.trim();
          }

          if (isEditReview && newStatus == 'approved') {
            await NotificationService().sendNotification(
              userId: ownerId,
              titleKey: 'notif_chalet_edit_approved_title',
              bodyKey: 'notif_chalet_edit_approved_body',
              bodyParams: {'chalet': chaletName},
              type: NotificationType.chaletApproved,
              relatedId: docId,
              data: {'chaletId': docId},
            );
          } else if (isEditReview && newStatus == 'rejected') {
            await NotificationService().sendNotification(
              userId: ownerId,
              titleKey: 'notif_chalet_edit_rejected_title',
              bodyKey: 'notif_chalet_edit_rejected_body',
              bodyParams: {'chalet': chaletName},
              type: NotificationType.chaletRejected,
              relatedId: docId,
              data: {'chaletId': docId},
            );
          } else {
          NotificationType type = NotificationType.general;
          String title = 'تحديث حالة الشاليه';
          String body = 'تمت مراجعة شاليهك $chaletName من قبل الإدارة.';

          if (newStatus == 'approved') {
            type = NotificationType.chaletApproved;
            title = 'تهانينا! تمت الموافقة 🎉';
            body =
                'تمت الموافقة على شاليهك $chaletName من قبل الإدارة وهو الآن متاح للمستخدمين.';
          } else if (newStatus == 'rejected') {
            type = NotificationType.chaletRejected;
            title = 'تم رفض الشاليه ❌';
            body =
                'عذراً، تم رفض طلبك لإضافة شاليه $chaletName. يرجى مراجعة التفاصيل والتعديل.';
          }

          await NotificationService().sendNotification(
            userId: ownerId,
            title: title,
            body: body,
            type: type,
            relatedId: docId,
            data: {'chaletId': docId},
          );
          }
        }
      }
      emit(
        ActionButtonsSuccess(
          newStatus == 'approved' ? 'Request Approved' : 'Request Rejected',
          newStatus: newStatus,
        ),
      );
    } catch (e) {
      emit(ActionButtonsError('Failed to update status: $e'));
    }
  }

  Future<void> toggleBookingAvailability({
    required String docId,
    required Map<String, dynamic> requestData,
  }) async {
    final currentStatus =
        state.bookingAvailability ??
        requestData['bookingAvailability'] ??
        'available';
    emit(ActionButtonsLoading(bookingAvailability: currentStatus));
    try {
      final newStatus = currentStatus == 'available'
          ? 'unavailable'
          : 'available';

      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'bookingAvailability': newStatus,
      });

      emit(
        ActionButtonsSuccess(
          newStatus == 'available' ? 'Booking Enabled' : 'Booking Disabled',
          bookingAvailability: newStatus,
        ),
      );
    } catch (e) {
      emit(
        ActionButtonsError(
          'Failed to toggle availability: $e',
          bookingAvailability: currentStatus,
        ),
      );
    }
  }

  void showBookingSheet(
    BuildContext context, {
    required String docId,
    required Map<String, dynamic> requestData,
  }) {
    if (!AuthRestrictionHelper.guardBooking(context)) return;

    final currentUser = context.read<AppCubit>().getCurrentUser()!;

    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';
    final isBookingAvailable = bookingAvailability == 'available';

    if (isBookingAvailable) {
      var ownerId = requestData['ownerId'] ?? requestData['userId'] ?? '';
      if (ownerId.isEmpty) {
        ownerId = '';
      }

      final chaletName =
          requestData['chaletName'] ?? requestData['name'] ?? 'شاليه';
      final ownerName =
          requestData['merchantName'] ??
          requestData['ownerName'] ??
          'صاحب الشاليه';

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: ColorsManager.transparent,
        builder: (ctx) => BookingBridgeWidget(
          parentContext: context,
          userId: currentUser.uid,
          userName: (currentUser.name.isNotEmpty
              ? currentUser.name
              : currentUser.uid),
          chaletId: docId,
          chaletName: chaletName,
          ownerId: ownerId,
          ownerName: ownerName,
          requestData: requestData,
        ),
      );
    } else {
      emit(ActionButtonsError('الحجز غير متاح حالياً'));
    }
  }
}
