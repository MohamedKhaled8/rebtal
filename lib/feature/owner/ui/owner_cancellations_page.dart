import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class OwnerCancellationsPage extends StatelessWidget {
  const OwnerCancellationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorManager.darkBackground121212
          : ColorManager.lightGreyF9F9F9,
      appBar: AppBar(
        title: const Text('سجل الإلغاءات'),
        centerTitle: true,
        backgroundColor: isDark ? ColorManager.transparent : ColorManager.white,
        elevation: 0,
        foregroundColor: isDark ? ColorManager.white : ColorManager.black,
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
                    color: isDark ? ColorManager.white24 : ColorManager.grey300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد حجوزات ملغاة',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? ColorManager.white70 : ColorManager.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cancelledBookings.length,
            itemBuilder: (context, index) {
              return _CancelledBookingCard(
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
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? ColorManager.darkSurface1E1E1E : ColorManager.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Status and Date
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorManager.red.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: ColorManager.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: ColorManager.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'تم الإلغاء',
                  style: TextStyle(
                    color: ColorManager.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(cancelDate),
                  style: TextStyle(
                    color: isDark ? ColorManager.white70 : ColorManager.grey600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
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
                        ? ColorManager.white
                        : ColorManager.chaletTextPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${booking.id.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? ColorManager.white70 : ColorManager.grey,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Financials Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialItem(
                        'المبلغ الأصلي',
                        currencyFormat.format(originalAmount),
                        isDark ? ColorManager.white70 : ColorManager.grey700,
                        isDark ? ColorManager.white : ColorManager.black,
                      ),
                    ),
                    Expanded(
                      child: _buildFinancialItem(
                        'المسترد للعميل',
                        currencyFormat.format(refundAmount),
                        ColorManager.red.withOpacity(0.7),
                        ColorManager.red,
                      ),
                    ),
                    Expanded(
                      child: _buildFinancialItem(
                        'صافي لك',
                        currencyFormat.format(keptAmount),
                        ColorManager.green.withOpacity(0.7),
                        ColorManager.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // User Details Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? ColorManager.white.withOpacity(0.05)
                        : ColorManager.grey50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? ColorManager.white10
                          : ColorManager.grey200,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.person_outline,
                        'العميل',
                        booking.userName,
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'تاريخ الحجز',
                        '${dateFormat.format(booking.from)} - ${dateFormat.format(booking.to)}',
                        isDark,
                      ),
                      if (booking.refundReason != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.info_outline,
                          'سبب/سياسة',
                          booking.refundReason!,
                          isDark,
                          textColor: ColorManager.orange,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Actions
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _contactUser(booking.userPhone),
                    icon: const Icon(Icons.phone),
                    label: const Text('تواصل مع العميل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.whatsappGreen,
                      foregroundColor: ColorManager.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        const SizedBox(height: 4),
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
          size: 18,
          color: isDark ? ColorManager.white70 : ColorManager.grey400,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? ColorManager.white70 : ColorManager.grey700,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      textColor ??
                      (isDark
                          ? ColorManager.white
                          : ColorManager.chaletTextPrimaryLight),
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
