import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class OwnerCancellationsPage extends StatelessWidget {
  const OwnerCancellationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.darkBackground121212
          : ColorsManager.lightGreyF9F9F9,
      appBar: AppBar(
        title: Text(context.tr('owner_cancellation_log')),
        centerTitle: true,
        backgroundColor: isDark
            ? ColorsManager.transparent
            : ColorsManager.white,
        elevation: 0,
        foregroundColor: isDark ? ColorsManager.white : ColorsManager.black,
      ),
      body: BlocBuilder<AppCubit, AppState>(
        buildWhen: (previous, current) {
          if (current is AppAuthenticated && previous is AppAuthenticated) {
            return current.bookings != previous.bookings;
          }
          return true;
        },
        builder: (context, state) {
          if (state is! AppAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
          final cancelledBookings = state.bookings
              .where((b) => b.status == BookingStatus.cancelled)
              .toList();

          // Sort by date (newest first)
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
                    color: isDark
                        ? ColorsManager.white24
                        : ColorsManager.grey300,
                  ),
                  SizedBox(height: 16.sh),
                  Text(
                    context.tr('owner_no_cancellations'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: isDark
                          ? ColorsManager.white70
                          : ColorsManager.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Builder(
            builder: (context) {
              final bool showTwoColumns = otv(
                context: context,
                portrait: stv(
                  context: context,
                  mobile: false,
                  tablet: true,
                  desktop: true,
                ),
                landscape: true,
              );

              if (showTwoColumns) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: stv(
                      context: context,
                      mobile: 16.sw,
                      tablet: 24.sw,
                      desktop: 32.sw,
                    ),
                    vertical: 16.sh,
                  ),
                  itemCount: (cancelledBookings.length / 2).ceil(),
                  itemBuilder: (context, i) {
                    final firstIndex = i * 2;
                    final secondIndex = firstIndex + 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 8.sw,
                              bottom: 20.sh,
                            ),
                            child: _CancelledBookingCard(
                              booking: cancelledBookings[firstIndex],
                              isDark: isDark,
                            ),
                          ),
                        ),
                        if (secondIndex < cancelledBookings.length)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 8.sw,
                                bottom: 20.sh,
                              ),
                              child: _CancelledBookingCard(
                                booking: cancelledBookings[secondIndex],
                                isDark: isDark,
                              ),
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    );
                  },
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: stv(
                    context: context,
                    mobile: 16.sw,
                    tablet: 24.sw,
                    desktop: 32.sw,
                  ),
                  vertical: 16.sh,
                ),
                itemCount: cancelledBookings.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: 20.sh,
                      left: stv(
                        context: context,
                        mobile: 0.sw,
                        tablet: 8.sw,
                        desktop: 16.sw,
                      ),
                      right: stv(
                        context: context,
                        mobile: 0.sw,
                        tablet: 8.sw,
                        desktop: 16.sw,
                      ),
                    ),
                    child: _CancelledBookingCard(
                      booking: cancelledBookings[index],
                      isDark: isDark,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CancelledBookingCard extends StatelessWidget {
  final Booking booking;
  final bool isDark;

  const _CancelledBookingCard({required this.booking, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cancelDate = booking.updatedAt ?? DateTime.now();
    final originalAmount = booking.amount ?? 0.0;
    final refundAmount = booking.refundAmount ?? 0.0;
    final keptAmount = originalAmount - refundAmount;

    // Formatting
    final currencyFormat = NumberFormat.currency(
      symbol: 'EGP',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Container(
      margin: EdgeInsets.only(bottom: 20.sh),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkSurface1E1E1E : ColorsManager.white,
        borderRadius: BorderRadius.circular(20.sp),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Status and Date
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: ColorsManager.red.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.sp),
                  decoration: const BoxDecoration(
                    color: ColorsManager.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: ColorsManager.white,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 12.sw),
                Text(
                  context.tr('booking_status_cancelled'),
                  style: TextStyle(
                    color: ColorsManager.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(cancelDate),
                  style: TextStyle(
                    color: isDark
                        ? ColorsManager.white70
                        : ColorsManager.grey600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chalet Info
                Text(
                  booking.chaletName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? ColorsManager.white
                        : ColorsManager.chaletTextPrimaryLight,
                  ),
                ),
                SizedBox(height: 4.sh),
                Text(
                  '#${booking.id.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? ColorsManager.white70 : ColorsManager.grey,
                  ),
                ),

                SizedBox(height: 20.sh),
                const Divider(),
                SizedBox(height: 20.sh),

                // Financials Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialItem(
                        context.tr('owner_original_amount'),
                        currencyFormat.format(originalAmount),
                        isDark ? ColorsManager.white70 : ColorsManager.grey700,
                        isDark ? ColorsManager.white : ColorsManager.black,
                      ),
                    ),
                    Expanded(
                      child: _buildFinancialItem(
                        context.tr('owner_refunded_to_client'),
                        currencyFormat.format(refundAmount),
                        ColorsManager.red.withOpacity(0.7),
                        ColorsManager.red,
                      ),
                    ),
                    Expanded(
                      child: _buildFinancialItem(
                        context.tr('owner_net_for_you'),
                        currencyFormat.format(keptAmount),
                        ColorsManager.green.withOpacity(0.7),
                        ColorsManager.green,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.sh),

                // User Details Section
                Container(
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: isDark
                        ? ColorsManager.white.withOpacity(0.05)
                        : ColorsManager.grey50,
                    borderRadius: BorderRadius.circular(16.sp),
                    border: Border.all(
                      color: isDark
                          ? ColorsManager.white10
                          : ColorsManager.grey200,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.person_outline,
                        context.tr('common_client'),
                        booking.userName,
                        isDark,
                      ),
                      SizedBox(height: 12.sh),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        context.tr('owner_booking_date'),
                        '${dateFormat.format(booking.from)} - ${dateFormat.format(booking.to)}',
                        isDark,
                      ),
                      if (booking.refundReason != null) ...[
                        SizedBox(height: 12.sh),
                        _buildDetailRow(
                          Icons.info_outline,
                          context.tr('owner_reason_policy'),
                          booking.refundReason!,
                          isDark,
                          textColor: ColorsManager.orange,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 20.sh),

                // Actions
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _contactUser(booking.userPhone),
                    icon: const Icon(Icons.phone),
                    label: Text(context.tr('owner_contact_client')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.mainBlue,
                      foregroundColor: ColorsManager.white,
                      padding: EdgeInsets.symmetric(vertical: 16.sh),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: labelColor),
        ),
        SizedBox(height: 4.sh),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Color? textColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: isDark ? ColorsManager.white70 : ColorsManager.grey400,
        ),
        SizedBox(width: 12.sw),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? ColorsManager.white70 : ColorsManager.grey700,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color:
                      textColor ??
                      (isDark
                          ? ColorsManager.white
                          : ColorsManager.chaletTextPrimaryLight),
                  fontWeight: FontWeight.w500,
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
