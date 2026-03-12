import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/services/invoice_service.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';

import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/feature/booking/widgets/booking_ticket_widget.dart';
import 'package:intl/intl.dart' as intl;

class UserInvoicesPage extends StatelessWidget {
  const UserInvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final appCubit = context.read<AppCubit>();
    final user = appCubit.getCurrentUser();

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark
            ? ColorsManager.darkBackground121212
            : ColorsManager.white,
        body: const Center(child: Text('Please login first')),
      );
    }

    // Trigger booking load
    appCubit.bookingCubit.loadUserBookings(user.uid);

    return BlocProvider.value(
      value: appCubit,
      child: Scaffold(
        backgroundColor: isDark
            ? ColorsManager.darkBackground121212
            : ColorsManager.lightBackgroundF5F7FA,
        appBar: AppBar(
          title: const Text('فواتير الحجز'),
          centerTitle: true,
          backgroundColor: isDark
              ? ColorsManager.transparent
              : ColorsManager.white,
          elevation: 0,
          leading: BackButton(
            color: isDark ? ColorsManager.white : ColorsManager.black,
          ),
          titleTextStyle: TextStyle(
            color: isDark ? ColorsManager.white : ColorsManager.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: isDark
                  ? ColorsManager.white.withOpacity(0.1)
                  : ColorsManager.black.withOpacity(0.05),
            ),
          ),
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            bool isLoading = false;
            List<Booking> bookings = [];

            if (state is AppAuthenticated) {
              isLoading = state.isBookingsLoading;
              bookings = state.bookings;
            }

            if (isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDark
                      ? ColorsManager.white
                      : ColorsManager.primaryColor,
                ),
              );
            }

            // final bookings = state.bookings; // Already assigned above

            if (bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorsManager.white.withOpacity(0.05)
                            : ColorsManager.grey100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: isDark
                            ? ColorsManager.white70
                            : ColorsManager.grey400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'لا توجد فواتير حجز حالياً',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark
                            ? ColorsManager.white70
                            : ColorsManager.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ستظهر فواتيرك هنا بعد إتمام الحجوزات',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? ColorsManager.white70
                            : ColorsManager.grey700,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _InvoiceCard(booking: booking, isDark: isDark);
              },
            );
          },
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Booking booking;
  final bool isDark;

  const _InvoiceCard({required this.booking, required this.isDark});

  Color _getStatusColor() {
    // Check if payment was rejected
    final isPaymentRejected =
        booking.status == BookingStatus.awaitingPayment &&
        (booking.paymentRejected == true ||
            (booking.adminPaymentNotes != null &&
                booking.adminPaymentNotes!.isNotEmpty));

    if (isPaymentRejected) {
      return ColorsManager.red;
    }

    switch (booking.status) {
      case BookingStatus.confirmed:
      case BookingStatus.completed:
        return ColorsManager.green;
      case BookingStatus.paymentUnderReview:
        return ColorsManager.primaryColor;
      case BookingStatus.pending:
      case BookingStatus.awaitingPayment:
        return ColorsManager.orange;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return ColorsManager.red;
      default:
        return ColorsManager.grey;
    }
  }

  String _getStatusText() {
    // Check if payment was rejected
    final isPaymentRejected =
        booking.status == BookingStatus.awaitingPayment &&
        (booking.paymentRejected == true ||
            (booking.adminPaymentNotes != null &&
                booking.adminPaymentNotes!.isNotEmpty));

    if (isPaymentRejected) {
      return 'مرفوض';
    }

    switch (booking.status) {
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.paymentUnderReview:
        return 'قيد المراجعة';
      case BookingStatus.pending:
        return 'قيد الانتظار';
      case BookingStatus.awaitingPayment:
        return 'في انتظار الدفع';
      case BookingStatus.rejected:
        return 'مرفوض';
      case BookingStatus.cancelled:
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  IconData _getStatusIcon() {
    switch (booking.status) {
      case BookingStatus.confirmed:
      case BookingStatus.completed:
        return Icons.check_circle_rounded;
      case BookingStatus.paymentUnderReview:
        return Icons.hourglass_empty_rounded;
      case BookingStatus.pending:
      case BookingStatus.awaitingPayment:
        return Icons.pending_rounded;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkSurface1E1E1E : ColorsManager.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? ColorsManager.black.withOpacity(0.3)
                : ColorsManager.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: ColorsManager.transparent,
        child: InkWell(
          onTap: () {
            final GlobalKey repaintKey = GlobalKey();

            showDialog(
              context: context,
              builder: (ctx) => Dialog(
                backgroundColor: ColorsManager.transparent,
                insetPadding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button at top
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? ColorsManager.grey800
                              : ColorsManager.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ColorsManager.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? ColorsManager.white
                                : ColorsManager.black,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                    ),

                    // Invoice wrapped in RepaintBoundary
                    Flexible(
                      child: SingleChildScrollView(
                        child: RepaintBoundary(
                          key: repaintKey,
                          child: BookingTicketWidget(
                            booking: booking,
                            ownerPhone: booking.ownerPhone ?? '201008422234',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorsManager.darkSurface1E1E1E
                            : ColorsManager.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ColorsManager.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                InvoiceService.printInvoice(
                                  context,
                                  repaintKey,
                                  booking,
                                );
                              },
                              icon: const Icon(Icons.print_rounded),
                              label: const Text('طباعة'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? ColorsManager.white
                                    : ColorsManager.chaletTextPrimaryLight,
                                side: BorderSide(
                                  color: isDark
                                      ? ColorsManager.white.withOpacity(0.3)
                                      : ColorsManager.grey300,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                InvoiceService.showSaveOptions(
                                  context,
                                  repaintKey,
                                  booking,
                                );
                              },
                              icon: const Icon(Icons.save_alt_rounded),
                              label: const Text('حفظ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsManager.chaletAccent,
                                foregroundColor: ColorsManager.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Status Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withOpacity(0.2),
                            statusColor.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getStatusIcon(),
                        color: statusColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Booking Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.chaletName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark
                                  ? ColorsManager.white
                                  : ColorsManager.chaletTextPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.confirmation_number_outlined,
                                size: 14,
                                color: isDark
                                    ? ColorsManager.white70
                                    : ColorsManager.grey600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '#${booking.id.substring(0, 8)}',
                                style: TextStyle(
                                  color: isDark
                                      ? ColorsManager.white70
                                      : ColorsManager.grey600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusText(),
                        style: const TextStyle(
                          color: ColorsManager.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorsManager.transparent,
                        isDark
                            ? ColorsManager.white.withOpacity(0.1)
                            : ColorsManager.black.withOpacity(0.05),
                        ColorsManager.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: isDark
                              ? ColorsManager.white70
                              : ColorsManager.grey600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          intl.DateFormat('dd/MM/yyyy').format(booking.from),
                          style: TextStyle(
                            color: isDark
                                ? ColorsManager.white70
                                : ColorsManager.grey700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Amount
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorsManager.chaletAccent.withOpacity(0.2)
                            : ColorsManager.chaletAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${booking.amount ?? 0}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ColorsManager.chaletAccent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'جنيه',
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorsManager.chaletAccent,
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }
}
