import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/feature/booking/widgets/booking_ticket_widget.dart';
import 'package:intl/intl.dart' as intl;

class UserInvoicesPage extends StatelessWidget {
  const UserInvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final user = context.read<AuthCubit>().state is AuthSuccess
        ? (context.read<AuthCubit>().state as AuthSuccess).user
        : null;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        body: const Center(child: Text('Please login first')),
      );
    }

    return BlocProvider.value(
      value: context.read<BookingCubit>()..loadUserBookings(user.uid),
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('فواتير الحجز'),
          centerTitle: true,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          leading: BackButton(color: isDark ? Colors.white : Colors.black),
          titleTextStyle: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
        ),
        body: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDark ? Colors.white : ColorManager.primaryColor,
                ),
              );
            }

            final bookings = state.bookings;

            if (bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: isDark ? Colors.white38 : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'لا توجد فواتير حجز حالياً',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ستظهر فواتيرك هنا بعد إتمام الحجوزات',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.grey[500],
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
    switch (booking.status) {
      case BookingStatus.confirmed:
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.paymentUnderReview:
        return Colors.blue;
      case BookingStatus.pending:
      case BookingStatus.awaitingPayment:
        return Colors.orange;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40),
                          BookingTicketWidget(
                            booking: booking,
                            ownerPhone: booking.ownerPhone ?? '201008422234',
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
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
                              color: isDark ? Colors.white : Colors.black87,
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
                                    ? Colors.white54
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '#${booking.id.substring(0, 8)}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
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
                          color: Colors.white,
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
                        Colors.transparent,
                        isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        Colors.transparent,
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
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          intl.DateFormat('dd/MM/yyyy').format(booking.from),
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[700],
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
                            ? ColorManager.chaletAccent.withOpacity(0.2)
                            : ColorManager.chaletAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${booking.amount ?? 0}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ColorManager.chaletAccent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'جنيه',
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorManager.chaletAccent,
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
