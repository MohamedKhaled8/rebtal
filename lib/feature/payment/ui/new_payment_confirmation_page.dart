import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';

class NewPaymentConfirmationPage extends StatefulWidget {
  final Booking booking;
  final PaymentMethod paymentMethod;
  final double amount;

  const NewPaymentConfirmationPage({
    super.key,
    required this.booking,
    required this.paymentMethod,
    required this.amount,
  });

  @override
  State<NewPaymentConfirmationPage> createState() =>
      _NewPaymentConfirmationPageState();
}

class _NewPaymentConfirmationPageState
    extends State<NewPaymentConfirmationPage> {
  bool _isSubmitting = false;
  bool _showDoneOverlay = false;

  @override
  void initState() {
    super.initState();
    // Auto-submit after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _confirmBooking();
      }
    });
  }

  /// Get admin user ID from Firestore
  Future<String?> _getAdminUserId() async {
    try {
      // Query Admin collection - get first admin
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .limit(1)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        return adminSnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting admin ID: $e');
      return null;
    }
  }

  /// Send notification to admin about new payment
  Future<void> _notifyAdminPaymentCompleted() async {
    try {
      final adminId = await _getAdminUserId();
      if (adminId == null) {
        debugPrint('No admin found to notify');
        return;
      }

      final notificationService = NotificationService();
      await notificationService.sendNotification(
        userId: adminId,
        title: 'دفع جديد مستلم',
        body:
            'تم استلام دفع جديد للحجز #${widget.booking.id.substring(0, 8).toUpperCase()} - ${widget.booking.chaletName}',
        type: NotificationType.paymentConfirmed,
        relatedId: widget.booking.id,
        data: {
          'bookingId': widget.booking.id,
          'chaletName': widget.booking.chaletName,
          'amount': widget.amount.toString(),
          'paymentMethod': widget.paymentMethod.name,
        },
      );

      debugPrint('Notification sent to admin: $adminId');
    } catch (e) {
      debugPrint('Error sending admin notification: $e');
    }
  }

  /// Show Done overlay and then navigate to invoice
  void _showDoneAndNavigateToInvoice() {
    setState(() => _showDoneOverlay = true);

    // Show Done overlay for 2 seconds then navigate to invoice
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.bookingConfirmationPage,
          (route) => false,
          arguments: widget.booking,
        );
      }
    });
  }

  String _getMethodTitle() {
    switch (widget.paymentMethod) {
      case PaymentMethod.instaPay:
        return 'إنستاباي';
      case PaymentMethod.vodafoneCash:
        return 'فودافون كاش';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case PaymentMethod.cashOnArrival:
        return 'الدفع عند الوصول';
    }
  }

  Future<void> _confirmBooking() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await context.read<AppCubit>().bookingCubit.uploadPaymentProof(
        bookingId: widget.booking.id,
        proofImageUrl: null,
        transactionNumber: widget.paymentMethod == PaymentMethod.cashOnArrival
            ? 'CASH_ON_ARRIVAL'
            : 'PENDING_VERIFICATION',
      );

      // Send notification to admin
      await _notifyAdminPaymentCompleted();

      if (mounted) {
        // Show Done overlay then navigate to invoice
        _showDoneAndNavigateToInvoice();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        SnackBarHelper.showError(context, 'حدث خطأ: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final nights = widget.booking.to.difference(widget.booking.from).inDays;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'تأكيد الحجز',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.bottomNavigationBarScreen,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Success Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 48,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Success Message
                      Text(
                        widget.paymentMethod == PaymentMethod.cashOnArrival
                            ? 'تم تأكيد الحجز'
                            : 'تم استلام طلب الدفع',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        widget.paymentMethod == PaymentMethod.cashOnArrival
                            ? 'حجزك مؤكد! سيتم الدفع عند استلام المفتاح'
                            : 'سيتم مراجعة الدفع والتأكيد خلال 24 ساعة',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Booking Details
                      _buildSection(isDark, 'تفاصيل الحجز', [
                        _buildRow(isDark, 'الشاليه', widget.booking.chaletName),
                        _buildRow(
                          isDark,
                          'تاريخ الوصول',
                          '${widget.booking.from.day}/${widget.booking.from.month}/${widget.booking.from.year}',
                        ),
                        _buildRow(
                          isDark,
                          'تاريخ المغادرة',
                          '${widget.booking.to.day}/${widget.booking.to.month}/${widget.booking.to.year}',
                        ),
                        _buildRow(isDark, 'عدد الليالي', '$nights ليلة'),
                        _buildRow(
                          isDark,
                          'رقم الحجز',
                          '#${widget.booking.id.substring(0, 8).toUpperCase()}',
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // Payment Details
                      _buildSection(isDark, 'تفاصيل الدفع', [
                        _buildRow(isDark, 'طريقة الدفع', _getMethodTitle()),
                        _buildRow(
                          isDark,
                          'المبلغ',
                          '${widget.amount.round()} ج.م',
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // Next Steps
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'الخطوات القادمة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildStep(
                              isDark,
                              widget.paymentMethod ==
                                      PaymentMethod.cashOnArrival
                                  ? 'حجزك مؤكد ومضمون'
                                  : 'سيتم مراجعة الدفع خلال 24 ساعة',
                            ),
                            _buildStep(isDark, 'سيتم إرسال إشعار بالتأكيد'),
                            _buildStep(
                              isDark,
                              'يمكنك مراجعة حجوزاتك من قسم "حجوزاتي"',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Done Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.bottomNavigationBarScreen,
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'تم',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

          // Done Overlay with Blur
          if (_showDoneOverlay) _buildDoneOverlay(isDark),
        ],
      ),
    );
  }

  /// Build Done overlay with blur effect
  Widget _buildDoneOverlay(bool isDark) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success checkmark circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 24),
                // Done text
                Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'جاري تحضير الفاتورة...',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(bool isDark, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(bool isDark, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
