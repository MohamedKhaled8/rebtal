// Moved from ui/admin_cancellations_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

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
            padding: const EdgeInsets.all(16),
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

    final currencyFormat = NumberFormat.currency(symbol: 'EGP', decimalDigits: 0);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkSurface1E1E1E : ColorsManager.white,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.red.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: ColorsManager.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: ColorsManager.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'تم الإلغاء',
                  style: TextStyle(
                    color: ColorsManager.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(cancelDate),
                  style: TextStyle(
                    color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.chaletName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? ColorsManager.white : ColorsManager.chaletTextPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'المالك: ${booking.ownerName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '#${booking.id.substring(0, 6)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? ColorsManager.white70 : ColorsManager.grey400,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildFinancialItem('المبلغ الأصلي', currencyFormat.format(originalAmount), isDark ? ColorsManager.white70 : ColorsManager.grey700, isDark ? ColorsManager.white : ColorsManager.black)),
                    Expanded(child: _buildFinancialItem('المسترد للعميل', currencyFormat.format(refundAmount), ColorsManager.red.withOpacity(0.7), ColorsManager.red)),
                    Expanded(child: _buildFinancialItem('حصة المالك', currencyFormat.format(ownerShare), ColorsManager.green.withOpacity(0.7), ColorsManager.green)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? ColorsManager.white.withOpacity(0.05) : ColorsManager.grey50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? ColorsManager.white10 : ColorsManager.grey200),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.person_outline, 'العميل', '${booking.userName}\n${booking.userPhone ?? ""}', isDark),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.calendar_today_outlined, 'تاريخ الحجز', '${dateFormat.format(booking.from)} - ${dateFormat.format(booking.to)}', isDark),
                      if (booking.refundReason != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(Icons.info_outline, 'السبب/السياسة', booking.refundReason!, isDark, textColor: ColorsManager.orange),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _contactUser(booking.userPhone),
                        icon: const Icon(Icons.phone),
                        label: const Text('العميل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.primaryColor,
                          foregroundColor: ColorsManager.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _contactUser(booking.ownerPhone),
                        icon: const Icon(Icons.phone),
                        label: const Text('المالك'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.orange,
                          foregroundColor: ColorsManager.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
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
        Text(label, style: TextStyle(fontSize: 11, color: labelColor)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark, {Color? textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: isDark ? ColorsManager.white70 : ColorsManager.grey400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: isDark ? ColorsManager.white70 : ColorsManager.grey700)),
              Text(value, style: TextStyle(fontSize: 14, color: textColor ?? (isDark ? ColorsManager.white : ColorsManager.chaletTextPrimaryLight), fontWeight: FontWeight.w500, height: 1.3)),
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
