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
import 'package:rebtal/core/utils/localization/translation_extension.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        titleKey: 'notifications_admin_new_payment_title',
        bodyKey: 'notifications_admin_new_payment_body',
        bodyParams: {
          'bookingShort': widget.booking.id.substring(0, 8).toUpperCase(),
          'chaletName': widget.booking.chaletName,
        },
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

  String _getMethodTitle(BuildContext context) {
    switch (widget.paymentMethod) {
      case PaymentMethod.instaPay:
        return context.tr('payment_method_instapay');
      case PaymentMethod.vodafoneCash:
        return context.tr('payment_method_vodafone_cash');
      case PaymentMethod.bankTransfer:
        return context.tr('payment_method_bank');
      case PaymentMethod.cashOnArrival:
        return context.tr('payment_method_cash_on_arrival');
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
        SnackBarHelper.showError(
          context,
          '${context.tr('booking_error_msg')} $e',
        );
        Navigator.pop(context); // Go back on error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      body: _buildDoneOverlay(isDark),
    );
  }

  /// Build Done overlay with blur effect
  Widget _buildDoneOverlay(bool isDark) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
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
                    color: Colors.green.withValues(alpha: 0.4),
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
              context.tr('common_done'),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.white,
                decoration: TextDecoration.none, // Fix overlay text style
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('payment_invoice_preparing'),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.white70,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
