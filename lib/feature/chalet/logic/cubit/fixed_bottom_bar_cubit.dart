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
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';

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
      // إظهار شاشة التحميل الفاخرة
      PremiumLoadingOverlay.show(context);

      try {
        final appCubit = context.read<AppCubit>();
        final currentUser = appCubit.authCubit.getCurrentUser();
        if (currentUser == null) {
          PremiumLoadingOverlay.dismiss(context);
          return;
        }

        final oldBooking = s.booking!;

        // المرحلة الأولى: تغيير الحالة إلى pendingOwnerApproval فقط
        // نحفظ معلومات المستأجر الجديد في حقول مؤقتة
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(oldBooking.id)
            .update({
              'status': 'pendingOwnerApproval',
              'pendingNewTenantId': currentUser.uid,
              'pendingNewTenantName': currentUser.name,
              'pendingNewTenantPhone': currentUser.phone,
              'pendingNewTenantEmail': currentUser.email,
              'pendingApprovalAt': FieldValue.serverTimestamp(),
            });

        // إرسال إشعار للمالك بأن هناك موافقة مبدئية تنتظر موافقته (في الخلفية)
        NotificationService()
            .sendNotification(
              userId: oldBooking.ownerId,
              title: 'موافقة مبدئية على نقل حجز',
              body:
                  'قام ${currentUser.name} بالموافقة المبدئية على نقل الحجز. يرجى المراجعة والموافقة النهائية.',
              type: NotificationType.transferTicket,
              relatedId: oldBooking.id,
              data: {
                'newTenantName': currentUser.name,
                'bookingId': oldBooking.id,
                'requiresOwnerApproval': true,
              },
            )
            .then((_) {
              debugPrint('Notification sent successfully');
            })
            .catchError((e) {
              debugPrint('Notification error: $e');
            });

        if (context.mounted) {
          // إخفاء التحميل
          PremiumLoadingOverlay.dismiss(context);

          SnackBarHelper.showSuccess(
            context,
            'تم إرسال الموافقة المبدئية! في انتظار موافقة المالك النهائية.',
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          // إخفاء التحميل عند الخطأ
          PremiumLoadingOverlay.dismiss(context);
          SnackBarHelper.showError(context, 'حدث خطأ: $e');
        }
      }
    }
  }

  // المرحلة الثانية: التحويل الفعلي بعد موافقة المالك
  Future<void> finalizeTransfer(BuildContext context, String bookingId) async {
    try {
      // جلب بيانات الحجز
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) {
        if (context.mounted) {
          SnackBarHelper.showError(context, 'الحجز غير موجود');
        }
        return;
      }

      final bookingData = bookingDoc.data()!;
      final oldBooking = Booking.fromJson({
        ...bookingData,
        'id': bookingDoc.id,
      });

      // التأكد من وجود معلومات المستأجر الجديد
      final newTenantId = bookingData['pendingNewTenantId'] as String?;
      final newTenantName = bookingData['pendingNewTenantName'] as String?;
      final newTenantPhone = bookingData['pendingNewTenantPhone'] as String?;
      final newTenantEmail = bookingData['pendingNewTenantEmail'] as String?;

      if (newTenantId == null || newTenantName == null) {
        if (context.mounted) {
          SnackBarHelper.showError(
            context,
            'معلومات المستأجر الجديد غير موجودة',
          );
        }
        return;
      }

      // تنفيذ التحويل الفعلي
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': 'confirmed',
            'userId': newTenantId,
            'userName': newTenantName,
            'userPhone': newTenantPhone,
            'userEmail': newTenantEmail,
            'originalTenantId': oldBooking.userId,
            'originalTenantName': oldBooking.userName,
            'originalTenantPhone': oldBooking.userPhone,
            'originalTenantEmail': oldBooking.userEmail,
            'transferredAt': FieldValue.serverTimestamp(),
            'paymentStatus': 'paid',
            // حذف الحقول المؤقتة
            'pendingNewTenantId': FieldValue.delete(),
            'pendingNewTenantName': FieldValue.delete(),
            'pendingNewTenantPhone': FieldValue.delete(),
            'pendingNewTenantEmail': FieldValue.delete(),
            'pendingApprovalAt': FieldValue.delete(),
          });

      // إرسال إشعار للمستأجر الجديد
      try {
        await NotificationService().sendNotification(
          userId: newTenantId,
          title: 'تم قبول طلب نقل الحجز',
          body: 'تم الموافقة على نقل الحجز إليك من قبل المالك. مبروك!',
          type: NotificationType.transferTicket,
          relatedId: bookingId,
          data: {'bookingId': bookingId, 'chaletName': oldBooking.chaletName},
        );
      } catch (e) {
        debugPrint('Notification error: $e');
      }

      // إرسال إيميل للمستأجر الجديد
      if (newTenantEmail != null && newTenantEmail.isNotEmpty) {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': [newTenantEmail],
          'message': {
            'subject': 'تأكيد حجز الشاليه: ${oldBooking.chaletName}',
            'html':
                '''
\u003ch2\u003eتم تأكيد حجزك!\u003c/h2\u003e
\u003cp\u003eمرحباً $newTenantName،\u003c/p\u003e
\u003cp\u003eتم نقل حجز الشاليه (\u003cstrong\u003e${oldBooking.chaletName}\u003c/strong\u003e) إليك بنجاح.\u003c/p\u003e
\u003ch3\u003eتفاصيل الحجز:\u003c/h3\u003e
\u003cul\u003e
  \u003cli\u003e\u003cstrong\u003eمن:\u003c/strong\u003e ${_formatDate(oldBooking.from)}\u003c/li\u003e
  \u003cli\u003e\u003cstrong\u003eإلى:\u003c/strong\u003e ${_formatDate(oldBooking.to)}\u003c/li\u003e
  \u003cli\u003e\u003cstrong\u003eالمبلغ:\u003c/strong\u003e ${oldBooking.amount} EGP\u003c/li\u003e
\u003c/ul\u003e
\u003cp\u003eنتمنى لك إقامة سعيدة!\u003c/p\u003e
''',
          },
        });
      }

      if (context.mounted) {
        SnackBarHelper.showSuccess(context, 'تم إعادة العرض بنجاح! ✅');
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'حدث خطأ: $e');
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
