import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/helper/booking_helper.dart';
import 'package:rebtal/feature/owner/widget/booking_status_chip.dart';
import 'package:rebtal/feature/owner/widget/guest_info_card.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isDark;

  const BookingCard({super.key, required this.booking, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final nights = (booking.to.difference(booking.from).inDays + 1).clamp(
      1,
      365,
    );
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkSurface1E1E1E : ColorsManager.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: ColorsManager.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to BookingDetailsPage
            // Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailsPage(booking: booking)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الشاليه في الأعلى
              Stack(
                children: [
                  // الصورة
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (booking.chaletImage == null ||
                              booking.chaletImage!.isEmpty)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    ColorsManager.chaletActionBlue,
                                    ColorsManager.chaletActionDarkBlue,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.villa,
                                color: ColorsManager.white,
                                size: 60,
                              ),
                            )
                          else
                            AppImageHelper(
                              path: booking.chaletImage!,
                              fit: BoxFit.cover,
                            ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  ColorsManager.transparent,
                                  ColorsManager.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          // اسم الشاليه والموقع على الصورة
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.chaletName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ColorsManager.white,
                                    shadows: [
                                      Shadow(
                                        color: ColorsManager.black.withOpacity(
                                          0.45,
                                        ),
                                        offset: Offset(0, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: ColorsManager.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        booking.chaletLocation ??
                                            context.tr('common_undetermined'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: ColorsManager.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Status chip في الزاوية
                  Positioned(
                    top: 12,
                    right: 12,
                    child: BookingStatusChip(
                      status: booking.status,
                      isDark: isDark,
                      booking: booking,
                    ),
                  ),
                ],
              ),

              // باقي المحتوى
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الضيف
                    GuestInfoCard(booking: booking, isDark: isDark),

                    const SizedBox(height: 16),

                    // التواريخ وعدد الليالي
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorsManager.white.withOpacity(0.05)
                            : ColorsManager.chaletIconBackgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ColorsManager.chaletActionBlue.withOpacity(
                            0.5,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flight_land,
                                          size: 16,
                                          color:
                                              ColorsManager.chaletActionGreen,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          context.tr('booking_check_in'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white60
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      BookingHelper.formatDate(booking.from),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: ColorsManager.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flight_takeoff,
                                          size: 16,
                                          color: Colors.red.shade600,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          context.tr('booking_check_out'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white60
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      BookingHelper.formatDate(booking.to),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.nights_stay,
                                  color: ColorsManager.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$nights ${context.tr('booking_nights')}',
                                  style: const TextStyle(
                                    color: ColorsManager.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // رقم الحجز
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.confirmation_number,
                            size: 18,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('owner_booking_number'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  BookingHelper.getShortId(booking.id),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              size: 18,
                              color: Colors.blue.shade600,
                            ),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: booking.id),
                              );
                              if (context.mounted) {
                                SnackBarHelper.showSuccess(
                                  context,
                                  context.tr('owner_booking_copied'),
                                  icon: Icons.copy,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // أزرار الإجراءات للحجوزات المعلقة
                    if (booking.status == BookingStatus.pending) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateStatus(
                                context,
                                BookingStatus.approved,
                              ),
                              icon: const Icon(Icons.check_circle, size: 20),
                              label: Text(context.tr('owner_accept_booking')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1D4ED8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateStatus(
                                context,
                                BookingStatus.rejected,
                              ),
                              icon: const Icon(Icons.cancel, size: 20),
                              label: Text(context.tr('owner_reject_booking')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // زر الموافقة النهائية على نقل الحجز

                    // معلومات إضافية للحجوزات المقبولة
                    if (booking.status == BookingStatus.approved) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: Color(0xFF1E40AF),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.tr('owner_accept_success'),
                                style: TextStyle(
                                  color: Color(0xFF1E40AF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // معلومات الإلغاء
                    if (booking.status == BookingStatus.cancelled) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade700,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.cancel,
                                    color: ColorsManager.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    context.tr('owner_cancelled_by_client'),
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (booking.updatedAt != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ColorsManager.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.tr(
                                              'owner_cancellation_datetime',
                                            ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            BookingHelper.formatDateTime(
                                              booking.updatedAt!,
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context, BookingStatus status) async {
    // إذا كانت الموافقة، إظهار ملخص سياسة الإلغاء أولاً
    if (status == BookingStatus.approved) {
      final shouldProceed = await _showCancellationPolicySummary(context);
      if (!shouldProceed) return; // المستخدم ألغى العملية
    }

    // إظهار شاشة التحميل الفاخرة
    PremiumLoadingOverlay.show(context);

    try {
      await context.read<AppCubit>().bookingCubit.updateBookingStatus(
        booking.id,
        status,
      );

      if (context.mounted) {
        // إخفاء التحميل
        PremiumLoadingOverlay.dismiss(context);

        final isApproved = status == BookingStatus.approved;
        if (isApproved) {
          SnackBarHelper.showSuccess(
            context,
            context.tr('owner_accept_success'),
          );
        } else {
          SnackBarHelper.showError(
            context,
            context.tr('owner_reject_success'),
            icon: Icons.info,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        // إخفاء التحميل عند الخطأ
        PremiumLoadingOverlay.dismiss(context);
        SnackBarHelper.showError(
          context,
          '${context.tr('booking_error_msg')} $e',
        );
      }
    }
  }

  Future<bool> _showCancellationPolicySummary(BuildContext context) async {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final now = DateTime.now();
    final daysRemaining = booking.from.difference(now).inDays;

    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: ColorsManager.chaletAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('owner_cancellation_summary'),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('owner_policy_apply_msg'),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPolicyCard(
                      isDark,
                      context.tr('booking_policy_7_nights'),
                      context.tr('booking_policy_7_refund'),
                      const Color(0xFF4CAF50),
                      daysRemaining >= 7,
                    ),
                    const SizedBox(height: 10),
                    _buildPolicyCard(
                      isDark,
                      context.tr('booking_policy_3_6_nights'),
                      context.tr('booking_policy_3_6_refund'),
                      const Color(0xFFFF9800),
                      daysRemaining >= 3 && daysRemaining < 7,
                    ),
                    const SizedBox(height: 10),
                    _buildPolicyCard(
                      isDark,
                      context.tr('booking_policy_less_3'),
                      context.tr('booking_policy_less_3_refund'),
                      const Color(0xFFF44336),
                      daysRemaining > 0 && daysRemaining < 3,
                    ),
                    const SizedBox(height: 10),
                    _buildPolicyCard(
                      isDark,
                      context.tr('booking_policy_same_day'),
                      context.tr('booking_policy_no_refund'),
                      const Color(0xFFD32F2F),
                      daysRemaining <= 0,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorsManager.chaletAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ColorsManager.chaletAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: ColorsManager.chaletAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              daysRemaining < 0
                                  ? context.tr('booking_arrival_passed_short')
                                  : (daysRemaining == 0
                                        ? context.tr('booking_today')
                                        : context
                                              .tr('booking_remaining_days')
                                              .replaceFirst(
                                                '{}',
                                                daysRemaining.toString(),
                                              )),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('booking_policy_summary'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? Colors.white70
                        : Colors.grey.shade700,
                  ),
                  child: Text(context.tr('common_cancel')),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.chaletAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(context.tr('owner_accept_booking')),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildPolicyCard(
    bool isDark,
    String title,
    String text,
    Color color,
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : color.withOpacity(0.4),
          width: isActive ? 2.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.check_circle : Icons.info_outline,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
