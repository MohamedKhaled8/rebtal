import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/booking/ui/booking_bridge_widget.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';

part 'action_buttons_state.dart';

class ActionButtonsCubit extends Cubit<ActionButtonsState> {
  ActionButtonsCubit() : super(ActionButtonsInitial());

  Future<void> updateStatus({
    required String docId,
    required String newStatus,
  }) async {
    emit(ActionButtonsLoading());
    try {
      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'status': newStatus,
      });
      emit(
        ActionButtonsSuccess(
          newStatus == 'approved' ? 'Request Approved' : 'Request Rejected',
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
    emit(ActionButtonsLoading());
    try {
      final currentStatus = requestData['bookingAvailability'] ?? 'available';
      final newStatus = currentStatus == 'available'
          ? 'unavailable'
          : 'available';

      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'bookingAvailability': newStatus,
      });

      emit(
        ActionButtonsSuccess(
          newStatus == 'available' ? 'Booking Enabled' : 'Booking Disabled',
        ),
      );
    } catch (e) {
      emit(ActionButtonsError('Failed to toggle availability: $e'));
    }
  }

  void showBookingSheet(
    BuildContext context, {
    required String docId,
    required Map<String, dynamic> requestData,
  }) {
    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.getCurrentUser();

    if (currentUser == null) return;

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
        backgroundColor: Colors.transparent,
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
