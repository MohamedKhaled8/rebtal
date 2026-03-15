import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/ui/cancellation_details_page.dart';
import 'package:rebtal/feature/booking/ui/rating_page.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:responsive_screen_master/responsive_screen_master.dart';

/// بطاقة حجز بتصميم الصورة: صورة أعلى، حالة، موقع وسعر، عنوان، تواريخ، مضيف، وأزرار.
class BookingCardCompact extends StatelessWidget {
  final Booking booking;
  final EdgeInsetsGeometry? margin;

  const BookingCardCompact({super.key, required this.booking, this.margin});

  static String _statusText(
    BuildContext ctx,
    BookingStatus status,
    bool isPaymentRejected,
  ) {
    if (isPaymentRejected) return ctx.tr('booking_status_payment_rejected');
    switch (status) {
      case BookingStatus.confirmed:
        return ctx.tr('booking_status_confirmed');
      case BookingStatus.cancelled:
        return ctx.tr('booking_status_cancelled');
      case BookingStatus.approved:
        return ctx.tr('booking_status_accepted');
      case BookingStatus.rejected:
        return ctx.tr('booking_status_rejected');
      case BookingStatus.paymentUnderReview:
        return ctx.tr('booking_status_payment_review');
      case BookingStatus.awaitingPayment:
        return ctx.tr('booking_status_awaiting_payment');
      case BookingStatus.completed:
        return ctx.tr('booking_status_completed');
      case BookingStatus.reOffered:
        return ctx.tr('booking_status_under_discussion');
      case BookingStatus.pendingOwnerApproval:
        return ctx.tr('booking_status_awaiting_approval');
      case BookingStatus.pending:
        return ctx.tr('booking_status_pending');
    }
  }

  static Color _statusColor(BookingStatus status, bool isPaymentRejected) {
    if (isPaymentRejected) return const Color(0xFFEF4444);
    switch (status) {
      case BookingStatus.confirmed:
      case BookingStatus.completed:
      case BookingStatus.approved:
        return const Color(0xFF10B981);
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return Colors.grey;
      case BookingStatus.paymentUnderReview:
        return const Color(0xFF3B82F6);
      case BookingStatus.awaitingPayment:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final isPaymentRejected =
        booking.status == BookingStatus.awaitingPayment &&
        (booking.paymentRejected == true ||
            (booking.adminPaymentNotes != null &&
                booking.adminPaymentNotes!.isNotEmpty));
    final isConfirmed = booking.status == BookingStatus.confirmed;
    final isApproved = booking.status == BookingStatus.approved;
    final isCancelled = booking.status == BookingStatus.cancelled;
    final isCompleted = booking.status == BookingStatus.completed;
    final statusColor = _statusColor(booking.status, isPaymentRejected);
    final nights = _nights(booking.from, booking.to);
    final locationName = _locationDisplay(
      booking.chaletLocation,
      booking.chaletName,
    );

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الشاليه
            Stack(
              children: [
                SizedBox(
                  height: otv(
                    context: context,
                    portrait: stv(
                      context: context,
                      mobile: 230.sh,
                      tablet: 235.sh,
                      desktop: 245.sh,
                    ),
                    landscape: stv(
                      context: context,
                      mobile: 350.sh,
                      tablet: 360.sh,
                      desktop: 370.sh,
                    ),
                  ),
                  width: double.infinity,
                  child:
                      booking.chaletImage != null &&
                          booking.chaletImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: booking.chaletImage!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (_, __, ___) =>
                              _placeholderImage(context, isDark),
                        )
                      : _placeholderImage(context, isDark),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _statusText(
                            context,
                            booking.status,
                            isPaymentRejected,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          locationName,
                          style: TextStyle(
                            fontSize: stv(
                              context: context,
                              mobile: 16.spScaled,
                              tablet: 18.spScaled,
                              desktop: 20.spScaled,
                            ),
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '${(booking.amount ?? 0).toStringAsFixed(0)} ${context.tr('booking_egp')}',
                        style: TextStyle(
                          fontSize: stv(
                            context: context,
                            mobile: 14.spScaled,
                            tablet: 16.spScaled,
                            desktop: 18.spScaled,
                          ),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  if (booking.chaletLocation != null &&
                      booking.chaletLocation!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      booking.chaletLocation!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _dateChip(
                        Icons.login_rounded,
                        context.tr('booking_arrival'),
                        '${booking.from.day}/${booking.from.month}',
                        context,
                        isDark,
                      ),
                      _dateChip(
                        Icons.logout_rounded,
                        context.tr('booking_departure'),
                        '${booking.to.day}/${booking.to.month}',
                        context,
                        isDark,
                      ),
                      _dateChip(
                        Icons.nightlight_round,
                        context.tr('admin_duration'),
                        '${nights} ${context.tr('booking_nights')}',
                        context,
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${context.tr('booking_host')} : ${booking.ownerName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  // أزرار الإجراءات
                  const SizedBox(height: 16),
                  _buildActions(
                    context,
                    isDark,
                    isPaymentRejected,
                    isConfirmed,
                    isApproved,
                    isCancelled,
                    isCompleted,
                    statusColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage(BuildContext context, bool isDark) {
    return Container(
      height: otv(
        context: context,
        portrait: stv(
          context: context,
          mobile: 230.sh,
          tablet: 235.sh,
          desktop: 245.sh,
        ),
        landscape: stv(
          context: context,
          mobile: 200.sh,
          tablet: 220.sh,
          desktop: 240.sh,
        ),
      ),
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
      child: Icon(
        Icons.holiday_village,
        size: 48,
        color: isDark ? Colors.white24 : Colors.grey.shade500,
      ),
    );
  }

  Widget _dateChip(
    IconData icon,
    String label,
    String value,
    BuildContext context,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: stv(
            context: context,
            mobile: 14.spScaled,
            tablet: 16.spScaled,
            desktop: 18.spScaled,
          ),
          color: isDark ? Colors.white54 : Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          '$label $value',
          style: TextStyle(
            fontSize: stv(
              context: context,
              mobile: 11.spScaled,
              tablet: 13.spScaled,
              desktop: 15.spScaled,
            ),
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  int _nights(DateTime from, DateTime to) {
    return to.difference(from).inDays.clamp(0, 365);
  }

  String _locationDisplay(String? chaletLocation, String chaletName) {
    if (chaletLocation != null && chaletLocation.isNotEmpty) {
      final parts = chaletLocation.split(',').map((e) => e.trim()).toList();
      if (parts.isNotEmpty) return parts.first;
    }
    return chaletName;
  }

  Widget _buildActions(
    BuildContext context,
    bool isDark,
    bool isPaymentRejected,
    bool isConfirmed,
    bool isApproved,
    bool isCancelled,
    bool isCompleted,
    Color statusColor,
  ) {
    if (isPaymentRejected) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                UriLauncherService.launchWhatsAppContact(
                  context: context,
                  phone: '201008422234',
                  message:
                      '${context.tr('booking_whatsapp_contact')} ${booking.id.substring(0, 8)}',
                );
              },
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: Text(
                context.tr('booking_whatsapp'),
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () =>
                  UriLauncherService.launchPhoneCall(context, '201008422234'),
              icon: const Icon(Icons.phone_rounded, size: 18),
              label: Text(
                context.tr('booking_call'),
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (isConfirmed) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CancellationDetailsPage(booking: booking),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('booking_cancel_booking_btn'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                context.read<AppCubit>().bookingCubit.updateBookingStatus(
                  booking.id,
                  BookingStatus.reOffered,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('booking_reoffer_success_msg')),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(context.tr('booking_reoffer_btn')),
            ),
          ),
        ],
      );
    }

    if (isApproved) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.paymentMethodSelection,
              arguments: {
                'booking': booking,
                'totalAmount': booking.amount ?? 0.0,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1ED760),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr('booking_complete_payment_btn'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isCompleted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RatingPage(booking: booking)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr('booking_rate_chalet_btn'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (booking.status == BookingStatus.pendingOwnerApproval) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            try {
              await context.read<AppCubit>().bookingCubit.finalizeTransfer(
                booking.id,
              );
              if (context.mounted) {
                final appCubit = context.read<AppCubit>();
                final state = appCubit.state;
                if (state is AppAuthenticated) {
                  appCubit.bookingCubit.loadUserBookings(state.user.uid);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${context.tr('booking_transfer_success_msg')} ✅',
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${context.tr('notifications_error')}: $e'),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(context.tr('booking_final_approval_btn')),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
