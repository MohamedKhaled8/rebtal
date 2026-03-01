import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/booking_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';

class CancellationDetailsPage extends StatelessWidget {
  final Booking booking;

  const CancellationDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = DynamicThemeManager.isDarkMode(context);
    final now = DateTime.now();
    final dateToday = DateTime(now.year, now.month, now.day);
    final dateCheckIn = DateTime(
      booking.from.year,
      booking.from.month,
      booking.from.day,
    );
    final daysRemaining = dateCheckIn.difference(dateToday).inDays;
    final refundInfo = BookingHelper.calculateRefund(
      booking.from,
      booking.amount ?? 0.0,
    );

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'تفاصيل الإلغاء',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Cancellation Policy Timeline
            const Text(
              'سياسة الإلغاء المتبعة',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            const SizedBox(height: 16),
            _buildPolicyItem(
              isDarkMode,
              '7 ليالٍ أو أكثر قبل الوصول',
              'استرداد المبلغ بالكامل (100%)',
              'تمنح هذه الفترة وقتاً كافياً لإعادة تأجير الوحدة دون خسائر للمالك.',
              const Color(0xFF10B981),
              refundInfo.tier == 0,
              Icons.check_circle_rounded,
              delay: 200,
            ),
            _buildPolicyItem(
              isDarkMode,
              '3-6 ليالٍ قبل الوصول',
              'خصم حتى 50% من المبلغ',
              'نظراً لقصر المدة المتبقية، يتم خصم نسبة لتعويض المالك عن ضيق وقت إعادة العرض.',
              const Color(0xFFF59E0B),
              refundInfo.tier == 1,
              Icons.info_rounded,
              delay: 300,
            ),
            _buildPolicyItem(
              isDarkMode,
              'أقل من 3 ليالٍ قبل الوصول',
              'خصم 50% من قيمة الحجز',
              'الإلغاء المتأخر جداً يصعّب إيجاد مستأجر بديل لهذه الفترة.',
              const Color(0xFFEF4444),
              refundInfo.tier == 2,
              Icons.warning_rounded,
              delay: 400,
            ),
            _buildPolicyItem(
              isDarkMode,
              'يوم الوصول',
              'لا يوجد مبلغ مسترد (0%)',
              'لا يمكن الإلغاء في نفس اليوم نظراً لالتزام المالك بتجهيز الوحدة وتعطيل الطلبات الأخرى.',
              const Color(0xFF991B1B),
              refundInfo.tier == 3,
              Icons.block_rounded,
              delay: 500,
            ),

            const SizedBox(height: 32),

            // 3. Financial Breakdown
            const Text(
              'تفاصيل الحساب النقدي',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            const SizedBox(height: 16),
            _buildFinancialCard(isDarkMode, booking, refundInfo, daysRemaining),

            const SizedBox(height: 40),

            // 4. Confirmation Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _handleCancellation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'تأكيد إلغاء الحجز',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'التراجع والعودة',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyItem(
    bool isDarkMode,
    String title,
    String subtitle,
    String description,
    Color color,
    bool isActive,
    IconData icon, {
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? color
                : (isDarkMode ? Colors.white10 : Colors.grey.shade200),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? color : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.white38 : Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(
    bool isDarkMode,
    Booking booking,
    dynamic refundInfo,
    int daysRemaining,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          _buildAmountRow(
            'المبلغ الإجمالي المدفوع',
            '${(booking.amount ?? 0).toStringAsFixed(0)} ج.م',
            isDarkMode,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildAmountRow(
            'قيمة الخصم المستحق',
            '-${((booking.amount ?? 0) - refundInfo.refundAmount).toStringAsFixed(0)} ج.م',
            isDarkMode,
            valueColor: Colors.red,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المبلغ المسترد الصافي',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${refundInfo.refundAmount.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                size: 16,
                color: Colors.blue.shade400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  refundInfo.message,
                  style: TextStyle(
                    color: Colors.blue.shade400,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    String value,
    bool isDarkMode, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: valueColor ?? (isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  void _handleCancellation(BuildContext context) {
    final refundInfo = BookingHelper.calculateRefund(
      booking.from,
      booking.amount ?? 0.0,
    );

    // Show final confirmation dialog to prevent accidental clicks
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الإلغاء النهائي'),
        content: const Text(
          'هل أنت متأكد من رغبتك في إلغاء الحجز بشكل نهائي؟ لا يمكن التراجع عن هذا الإجراء بعد تنفيذه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              context.read<AppCubit>().bookingCubit.cancelBookingWithRefund(
                booking.id,
                refundInfo.refundAmount,
                refundInfo.message,
              );
              Navigator.pop(context); // Go back to bookings list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
  }
}
