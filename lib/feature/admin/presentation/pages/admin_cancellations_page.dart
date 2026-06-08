// Moved from ui/admin_cancellations_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class AdminCancellationsPage extends StatelessWidget {
  const AdminCancellationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.darkBackground121212
          : ColorsManager.lightGreyF9F9F9,
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          if (state is! AppAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
          final cancelledBookings = state.bookings
              .where((b) => b.status == BookingStatus.cancelled)
              .toList();

          cancelledBookings.sort((a, b) {
            final dateA = a.updatedAt ?? DateTime(2000);
            final dateB = b.updatedAt ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });

          if (cancelledBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: isDark ? ColorsManager.white24 : ColorsManager.grey300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد حجوزات ملغاة حالياً',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? ColorsManager.white70 : ColorsManager.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.sw, vertical: 16.sh),
            itemCount: cancelledBookings.length,
            itemBuilder: (context, index) {
              return _AdminCancelledBookingCard(
                booking: cancelledBookings[index],
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminCancelledBookingCard extends StatelessWidget {
  final Booking booking;
  final bool isDark;

  const _AdminCancelledBookingCard({
    required this.booking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cancelDate = booking.updatedAt ?? DateTime.now();
    final originalAmount = booking.amount ?? 0.0;
    final refundAmount = booking.refundAmount ?? 0.0;
    final ownerShare = originalAmount - refundAmount;

    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 0);
    final dateFormat = DateFormat('yyyy-MM-dd');

    final coverImageUrl = booking.chaletImage ?? '';
    final location = booking.chaletLocation ?? 'Unknown Location';

    return Container(
      margin: EdgeInsets.only(bottom: 20.sh),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0F0D) : Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Stack (matches user/owner view & ChaletRequestCard)
          Stack(
            children: [
              SizedBox(
                height: 200.sp,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.sp),
                  ),
                  child: AppImageHelper(
                    path: coverImageUrl,
                    fit: BoxFit.cover,
                    cacheScope: booking.id,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Badge (Cancelled in red)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
                      decoration: BoxDecoration(
                        color: ColorsManager.red.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('booking_status_cancelled').isEmpty ? 'تم الإلغاء' : context.tr('booking_status_cancelled'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Date tag
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Text(
                        dateFormat.format(cancelDate),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(12.sw),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.chaletName,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          verticalSpace(0.5),
                          Text(
                            'المالك: ${booking.ownerName}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    horizintalSpace(2),
                    Text(
                      '#${booking.id.substring(0, 6)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white70 : Colors.grey[400],
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                verticalSpace(1.5),

                // Location Row
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.sp,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    horizintalSpace(1),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                verticalSpace(2),
                Divider(height: 1, thickness: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                verticalSpace(2),

                // Financials Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialItem(
                        'المبلغ الأصلي',
                        '${currencyFormat.format(originalAmount)} ج.م',
                        isDark ? ColorsManager.white70 : ColorsManager.grey700,
                        isDark ? ColorsManager.white : ColorsManager.black,
                      ),
                    ),
                    Expanded(
                      child: _buildFinancialItem(
                        'المسترد للعميل',
                        '${currencyFormat.format(refundAmount)} ج.م',
                        ColorsManager.red.withOpacity(0.7),
                        ColorsManager.red,
                      ),
                    ),
                    Expanded(
                      child: _buildFinancialItem(
                        'حصة المالك',
                        '${currencyFormat.format(ownerShare)} ج.م',
                        ColorsManager.green.withOpacity(0.7),
                        ColorsManager.green,
                      ),
                    ),
                  ],
                ),
                verticalSpace(2),

                // Details Box
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.03) : ColorsManager.greyF9FAFB,
                    borderRadius: BorderRadius.circular(12.sp),
                    border: Border.all(color: isDark ? const Color(0xFF1E293B) : ColorsManager.greyE5E7EB),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.person_outline,
                        'العميل',
                        '${booking.userName}\n${booking.userPhone ?? ""}',
                      ),
                      verticalSpace(1.5),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'تاريخ الحجز',
                        '${dateFormat.format(booking.from)} - ${dateFormat.format(booking.to)}',
                      ),
                      if (booking.refundReason != null) ...[
                        verticalSpace(1.5),
                        _buildDetailRow(
                          Icons.info_outline,
                          'السبب/السياسة',
                          booking.refundReason!,
                          textColor: ColorsManager.orangeF59E0B,
                        ),
                      ],
                    ],
                  ),
                ),
                verticalSpace(2.5),

                // Contact Action Buttons (matches chalet card premium feel)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.sp),
                          border: Border.all(color: ColorsManager.primaryColor.withOpacity(0.3)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _contactUser(booking.userPhone),
                            borderRadius: BorderRadius.circular(12.sp),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.sp),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.phone_outlined, size: 16, color: ColorsManager.primaryColor),
                                  horizintalSpace(1.5),
                                  Text(
                                    'مراسلة العميل',
                                    style: TextStyle(
                                      color: ColorsManager.primaryColor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    horizintalSpace(3),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorsManager.orangeF59E0B.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.sp),
                          border: Border.all(color: ColorsManager.orangeF59E0B.withOpacity(0.3)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _contactUser(booking.ownerPhone),
                            borderRadius: BorderRadius.circular(12.sp),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.sp),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.phone_outlined, size: 16, color: ColorsManager.orangeF59E0B),
                                  horizintalSpace(1.5),
                                  Text(
                                    'مراسلة المالك',
                                    style: TextStyle(
                                      color: ColorsManager.orangeF59E0B,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, Color labelColor, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: labelColor, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: isDark ? Colors.white70 : Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11.sp, color: isDark ? Colors.white70 : Colors.grey[500])),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: textColor ?? (isDark ? Colors.white : ColorsManager.chaletTextPrimaryLight),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _contactUser(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse('https://wa.me/+20$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
