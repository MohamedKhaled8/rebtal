import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';

class RefundRequestPage extends StatefulWidget {
  final Booking booking;

  const RefundRequestPage({super.key, required this.booking});

  @override
  State<RefundRequestPage> createState() => _RefundRequestPageState();
}

class _RefundRequestPageState extends State<RefundRequestPage> {
  final TextEditingController _reasonController = TextEditingController();
  double _refundPercentage = 0;
  double _refundAmount = 0;
  String _refundPolicyKey = '';

  @override
  void initState() {
    super.initState();
    _calculateRefund();
  }

  void _calculateRefund() {
    final now = DateTime.now();
    final daysUntilBooking = widget.booking.from.difference(now).inDays;
    final amount = widget.booking.amount ?? 0;

    if (daysUntilBooking >= 7) {
      _refundPercentage = 100;
      _refundPolicyKey = 'booking_refund_7_days';
    } else if (daysUntilBooking >= 3) {
      _refundPercentage = 50;
      _refundPolicyKey = 'booking_refund_3_7_days';
    } else {
      _refundPercentage = 0;
      _refundPolicyKey = 'booking_refund_less_3';
    }

    _refundAmount = amount * (_refundPercentage / 100);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.darkBackground0A0E27
          : ColorsManager.lightBackgroundF5F7FA,
      appBar: AppBar(
        backgroundColor: ColorsManager.transparent,
        elevation: 0,
        title: Text(
          context.tr('booking_refund_request_title'),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? ColorsManager.darkSurface1E1E1E
                      : ColorsManager.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? ColorsManager.white10
                        : ColorsManager.grey300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.villa,
                          color: ColorsManager.chaletAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          context.tr('booking_booking_info'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? ColorsManager.white
                                : ColorsManager.chaletTextPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context.tr('common_chalet'),
                      widget.booking.chaletName,
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context.tr('booking_amount_paid_label'),
                      '${widget.booking.amount?.toStringAsFixed(0) ?? 0} ${context.tr('booking_egp_currency')}',
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context.tr('booking_booking_date'),
                      '${widget.booking.from.day}/${widget.booking.from.month}/${widget.booking.from.year}',
                      isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Refund Calculation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _refundPercentage > 0
                        ? [
                            ColorsManager.mainBlue,
                            ColorsManager.chaletActionDarkBlue,
                          ]
                        : [
                            ColorsManager.red,
                            ColorsManager.chaletActionDarkRed,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      context.tr(_refundPolicyKey),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: ColorsManager.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                context.tr('booking_refund_percentage'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorsManager.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_refundPercentage.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsManager.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: ColorsManager.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                context.tr('booking_refund_amount'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorsManager.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_refundAmount.toStringAsFixed(0)} جنيه',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsManager.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reason Input
              Text(
                context.tr('booking_cancel_reason'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: context.tr('booking_cancel_reason_hint'),
                  filled: true,
                  fillColor: isDark
                      ? ColorsManager.darkSurface1E1E1E
                      : ColorsManager.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? ColorsManager.white10
                          : ColorsManager.grey300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? ColorsManager.white10
                          : ColorsManager.grey300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorsManager.chaletAccent,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: isDark
                      ? ColorsManager.white
                      : ColorsManager.chaletTextPrimaryLight,
                ),
              ),

              const SizedBox(height: 24),

              // Warning
              if (_refundPercentage == 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorsManager.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorsManager.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: ColorsManager.chaletActionDarkRed,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('booking_no_refund_policy'),
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorsManager.chaletActionDarkRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_reasonController.text.trim().isEmpty) {
                      SnackBarHelper.showWarning(
                        context,
                        context.tr('booking_enter_cancel_reason'),
                      );
                      return;
                    }

                    try {
                      await context.read<AppCubit>().bookingCubit.requestRefund(
                        bookingId: widget.booking.id,
                        reason: _reasonController.text.trim(),
                        refundAmount: _refundAmount,
                      );

                      if (context.mounted) {
                        SnackBarHelper.showSuccess(
                          context,
                          context.tr('booking_refund_success'),
                        );

                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        SnackBarHelper.showError(
                          context,
                          '${context.tr('notifications_error')}: $e',
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.send, size: 20),
                  label: Text(
                    context.tr('booking_submit_refund'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.red,
                    foregroundColor: ColorsManager.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // View Policy Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cancellation-policy');
                  },
                  icon: const Icon(Icons.policy, size: 20),
                  label: Text(
                    context.tr('booking_view_cancel_policy'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsManager.chaletAccent,
                    side: BorderSide(color: ColorsManager.chaletAccent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
