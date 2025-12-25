import 'package:flutter/material.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/services/invoice_service.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/feature/booking/widgets/booking_ticket_widget.dart';

class BookingSuccessPage extends StatelessWidget {
  final Booking? booking;

  const BookingSuccessPage({super.key, this.booking});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final GlobalKey _repaintKey = GlobalKey();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Success Icon and Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.green.withOpacity(0.2)
                      : Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 80,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'تم إرسال طلب الحجز بنجاح',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'طلبك قيد المراجعة الآن من قبل المالك.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // Invoice Display
              if (booking != null) ...[
                const SizedBox(height: 32),
                Text(
                  'فاتورة الحجز',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Wrap invoice in RepaintBoundary for screenshot/PDF
                RepaintBoundary(
                  key: _repaintKey,
                  child: BookingTicketWidget(
                    booking: booking!,
                    ownerPhone: booking!.ownerPhone,
                  ),
                ),
                const SizedBox(height: 24),

                // Print and Save Buttons with Dark Mode support
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          InvoiceService.printInvoice(
                            context,
                            _repaintKey,
                            booking!,
                          );
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('طباعة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.white
                              : ColorManager.chaletAccent,
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : ColorManager.chaletAccent,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          InvoiceService.showSaveOptions(
                            context,
                            _repaintKey,
                            booking!,
                          );
                        },
                        icon: const Icon(Icons.save_alt),
                        label: const Text('حفظ'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.white
                              : ColorManager.chaletAccent,
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : ColorManager.chaletAccent,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Back to Home Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to home and clear stack
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.bottomNavigationBarScreen,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'العودة للرئيسية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
