import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/ui/booking_wizard_page.dart'; // Import Wizard Page
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';

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
    required dynamic price,
  }) {
    // Access AuthCubit through AppCubit
    final appCubit = context.read<AppCubit>();
    final authCubit = appCubit.authCubit;
    final currentUser = authCubit.getCurrentUser();
    if (currentUser == null) {
      SnackBarHelper.showError(context, 'يرجى تسجيل الدخول أولاً');
      return;
    }

    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';
    final isBookingAvailable = bookingAvailability == 'available';

    if (isBookingAvailable) {
      final bool dayUseEnabled = requestData['dayUseEnabled'] == true;

      // If Day Use is enabled, show the quick request sheet
      if (dayUseEnabled) {
        _showDayUseQuickRequest(context, docId, requestData, price);
        return;
      }

      var ownerId = requestData['ownerId'] ?? requestData['userId'] ?? '';
      if (ownerId.isEmpty) {
        ownerId = '';
      }

      final chaletName =
          requestData['chaletName'] ?? requestData['name'] ?? 'شاليه';

      // Navigate to the full screen Wizard Page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingWizardPage(
            chaletId: docId,
            chaletName: chaletName,
            ownerId: ownerId,
            requestData: requestData,
            basePrice: price,
          ),
        ),
      );
    } else {
      SnackBarHelper.showError(context, 'الحجز غير متاح حالياً');
    }
  }

  void _showDayUseQuickRequest(
    BuildContext context,
    String docId,
    Map<String, dynamic> requestData,
    dynamic price,
  ) {
    final chaletName =
        requestData['chaletName'] ?? requestData['name'] ?? 'شاليه';
    final ownerId = requestData['ownerId'] ?? requestData['userId'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final isDarkSheet =
            Theme.of(sheetContext).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDarkSheet ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "بيانات طلب الداي يوز",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDarkSheet ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Request Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkSheet
                      ? Colors.white.withOpacity(0.03)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkSheet
                        ? Colors.white10
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  children: [
                    _buildRequestInfoItem(
                      Icons.calendar_today_rounded,
                      "التاريخ",
                      "اليوم - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                      isDarkSheet,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    _buildRequestInfoItem(
                      Icons.payments_rounded,
                      "التكلفة المتوقعة",
                      "$price EGP",
                      isDarkSheet,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "إلغاء",
                        style: TextStyle(
                          color: isDarkSheet
                              ? Colors.white70
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _submitQuickDayUseRequest(
                          context, // Use outer context
                          docId,
                          ownerId,
                          chaletName,
                          price,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE51D55),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "إرسال الطلب",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestInfoItem(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFFE51D55)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitQuickDayUseRequest(
    BuildContext context,
    String docId,
    String ownerId,
    String chaletName,
    dynamic price,
  ) async {
    // 1. Show Success Dialog Immediately (Optimistic UI)
    _showSuccessCelebration(context);

    try {
      final appCubit = context.read<AppCubit>();
      final currentUser = appCubit.authCubit.getCurrentUser();
      if (currentUser == null) return;

      final bookingRef = FirebaseFirestore.instance
          .collection('bookings')
          .doc();
      final double amount = (price is num)
          ? price.toDouble()
          : double.tryParse(price.toString()) ?? 0.0;

      await bookingRef.set({
        'id': bookingRef.id,
        'chaletId': docId,
        'chaletName': chaletName,
        'ownerId': ownerId,
        'userId': currentUser.uid,
        'userName': currentUser.name,
        'userPhone': currentUser.phone,
        'userEmail': currentUser.email,
        'amount': amount,
        'status': 'pending', // Pending owner approval
        'isDayUse': true, // Correct flag for Day Use
        'bookingType': 'day_use',
        'createdAt': FieldValue.serverTimestamp(),
        'from':
            DateTime.now(), // For Day Use, it's typically immediate or current day
        'to': DateTime.now(), // Same day
      });

      // Send notification to owner
      await NotificationService().sendNotification(
        userId: ownerId,
        title: 'طلب حجز داي يوز جديد! ☀️',
        body: 'قام ${currentUser.name} بطلب حجز داي يوز لشاليه $chaletName.',
        type: NotificationType.bookingRequest,
        relatedId: bookingRef.id,
        data: {
          'bookingId': bookingRef.id,
          'chaletName': chaletName,
          'userName': currentUser.name,
        },
      );

      // 3. No need to show dialog here, it's already shown
    } catch (e) {
      if (context.mounted) {
        // If error, we might want to close the success dialog (if it's still there)
        // and show error. ideally we should track the dialog context.
        // For now, let's just log or show snackbar. The success dialog will auto-close.
        // Maybe better to force close if we can, but simpler is safer for now.
        SnackBarHelper.showError(context, 'حدث خطأ أثناء إرسال الطلب: $e');
      }
    }
  }

  void _showSuccessCelebration(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => const SuccessCelebrationDialog(),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        // Use rootNavigator: true to ensure we pop the dialog specifically
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }
}

class SuccessCelebrationDialog extends StatefulWidget {
  const SuccessCelebrationDialog({super.key});

  @override
  State<SuccessCelebrationDialog> createState() =>
      _SuccessCelebrationDialogState();
}

class _SuccessCelebrationDialogState extends State<SuccessCelebrationDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Backdrop blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),

        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
            Color(0xFFE51D55),
          ],
          numberOfParticles: 20,
          gravity: 0.1,
        ),

        Material(
          color: Colors.transparent,
          child: ZoomIn(
            duration: const Duration(milliseconds: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeInDown(
                  from: 30,
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 84,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "تم إرسال طلبك ✓",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "جاري المراجعة",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
