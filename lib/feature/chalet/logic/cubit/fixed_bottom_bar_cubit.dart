import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/ui/booking_bridge_widget.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';

part 'fixed_bottom_bar_state.dart';

class FixedBottomBarCubit extends Cubit<FixedBottomBarState> {
  FixedBottomBarCubit() : super(FixedBottomBarInitial());

  Future<void> loadData({
    required dynamic price,
    required Map<String, dynamic> requestData,
    String? bookingId,
    String? currentUserId,
  }) async {
    final formattedPrice = CurrencyFormatter.egp(
      (price is num) ? price : double.tryParse((price ?? '').toString()) ?? 0,
      withSuffixPerNight: true,
    );

    final discountEnabled = requestData['discountEnabled'] == true;
    final discountValue =
        double.tryParse(requestData['discountValue']?.toString() ?? '0') ?? 0;

    String displayPrice;
    String? originalPriceStr;

    if (discountEnabled && discountValue > 0) {
      final basePrice = (price is num)
          ? price.toDouble()
          : double.tryParse(
                  (price ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), ''),
                ) ??
                0.0;

      final discountType = requestData['discountType'];
      double finalPrice = basePrice;

      if (discountType == 'percentage') {
        finalPrice = basePrice * (1 - discountValue / 100);
      } else if (discountType == 'fixed') {
        finalPrice = basePrice - discountValue;
      }
      if (finalPrice < 0) finalPrice = 0;

      displayPrice = CurrencyFormatter.egp(
        finalPrice,
        withSuffixPerNight: true,
      );
      originalPriceStr = CurrencyFormatter.egp(
        basePrice,
        withSuffixPerNight: false,
      );
    } else {
      displayPrice = formattedPrice;
      originalPriceStr = null;
    }

    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';
    final isBookingAvailable = bookingAvailability == 'available';

    Booking? booking;
    if (bookingId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .get();
        if (doc.exists) {
          booking = Booking.fromJson({...doc.data()!, 'id': doc.id});
        }
      } catch (e) {
        debugPrint("Error fetching booking: $e");
      }
    }

    emit(
      FixedBottomBarLoaded(
        displayPrice: displayPrice,
        originalPrice: originalPriceStr,
        isBookingAvailable: isBookingAvailable,
        booking: booking,
        hasContactedOriginalTenant: false,
        isOriginalOfferOwner: booking?.userId == currentUserId,
      ),
    );
  }

  void markContacted() {
    if (state is FixedBottomBarLoaded) {
      final curr = state as FixedBottomBarLoaded;
      emit(
        FixedBottomBarLoaded(
          displayPrice: curr.displayPrice,
          originalPrice: curr.originalPrice,
          isBookingAvailable: curr.isBookingAvailable,
          booking: curr.booking,
          hasContactedOriginalTenant: true,
          isOriginalOfferOwner: curr.isOriginalOfferOwner,
        ),
      );
    }
  }

  Future<void> cancelOffer(
    BuildContext context, {
    required String docId,
  }) async {
    final s = state;
    if (s is FixedBottomBarLoaded && s.booking != null) {
      final oldBooking = s.booking!;
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(oldBooking.id)
            .update({'status': 'confirmed'});

        if (context.mounted) {
          SnackBarHelper.showSuccess(
            context,
            'تم إلغاء العرض واستعادة الحجز بنجاح!',
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.showError(context, 'حدث خطأ: $e');
        }
      }
    }
  }

  Future<void> confirmTransfer(BuildContext context) async {
    final s = state;
    if (s is FixedBottomBarLoaded && s.booking != null) {
      try {
        final appCubit = context.read<AppCubit>();
        final currentUser = appCubit.authCubit.getCurrentUser();
        if (currentUser == null) return;

        final oldBooking = s.booking!;

        // CASE 2: Transfer to New Tenant (Update existing booking)
        // We update the existing document to avoid creating a new invoice/booking ID
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(oldBooking.id)
            .update({
              'status': 'confirmed',
              'userId': currentUser.uid,
              'userName': currentUser.name,
              'userPhone': currentUser.phone,
              'userEmail': currentUser.email,
              'originalTenantId': oldBooking.userId,
              'originalTenantName': oldBooking.userName,
              'originalTenantPhone': oldBooking.userPhone,
              'originalTenantEmail': oldBooking.userEmail,
              'transferredAt': FieldValue.serverTimestamp(),
              'paymentStatus': 'paid',
            });

        // 3. Notify Owner (Using NotificationService for OneSignal Push)
        // Ensure we handle case where notification service might be unitialized safely?
        // Usually safe to call instance().
        try {
          await NotificationService().sendNotification(
            userId: oldBooking.ownerId,
            title: 'تم نقل حجز',
            body:
                'تم نقل الحجز من ${oldBooking.userName} إلى ${currentUser.name}',
            type: NotificationType.transferTicket,
            relatedId: oldBooking.id,
            data: {
              'oldTenantName': oldBooking.userName,
              'newTenantName': currentUser.name,
              'bookingId': oldBooking.id,
            },
          );
        } catch (e) {
          debugPrint('Notification error: $e');
        }

        // 4. Send Email to New Tenant (Via Mail Collection Trigger)
        // This relies on Firebase Trigger Email extension being installed
        if (currentUser.email.isNotEmpty) {
          await FirebaseFirestore.instance.collection('mail').add({
            'to': [currentUser.email],
            'message': {
              'subject': 'تأكيد حجز الشاليه: ${oldBooking.chaletName}',
              'html':
                  '''
<h2>تم تأكيد حجزك!</h2>
<p>مرحباً ${currentUser.name}،</p>
<p>تم نقل حجز الشاليه (<strong>${oldBooking.chaletName}</strong>) إليك بنجاح.</p>
<h3>تفاصيل الحجز:</h3>
<ul>
  <li><strong>من:</strong> ${_formatDate(oldBooking.from)}</li>
  <li><strong>إلى:</strong> ${_formatDate(oldBooking.to)}</li>
  <li><strong>المبلغ:</strong> ${oldBooking.amount} EGP</li>
</ul>
<p>نتمنى لك إقامة سعيدة!</p>
''',
            },
          });
        }

        if (context.mounted) {
          SnackBarHelper.showSuccess(context, 'تم نقل الحجز بنجاح!');
          Navigator.pop(context); // Return to offers or details
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.showError(context, 'حدث خطأ: $e');
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void handleBooking(
    BuildContext context, {
    required String docId,
    required Map<String, dynamic> requestData,
  }) {
    // Access AuthCubit through AppCubit
    final appCubit = context.read<AppCubit>();
    final authCubit = appCubit.authCubit;
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
        backgroundColor: ColorManager.transparent,
        builder: (context) => BookingBridgeWidget(
          chaletId: docId,
          chaletName: chaletName,
          ownerId: ownerId,
          ownerName: ownerName,
          userId: currentUser.uid,
          userName: currentUser.name,
          requestData: requestData,
          parentContext: context,
        ),
      );
    } else {
      SnackBarHelper.showError(context, 'الحجز غير متاح حالياً');
    }
  }
}
