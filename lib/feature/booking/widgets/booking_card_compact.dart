import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/ui/cancellation_details_page.dart';
import 'package:rebtal/feature/booking/ui/rating_page.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// بطاقة حجز بتصميم الصورة: صورة أعلى، حالة، موقع وسعر، عنوان، تواريخ، مضيف، وأزرار.
class BookingCardCompact extends StatelessWidget {
  final Booking booking;

  const BookingCardCompact({super.key, required this.booking});

  static String _statusText(BookingStatus status, bool isPaymentRejected) {
    if (isPaymentRejected) return 'مرفوض الدفع';
    switch (status) {
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.cancelled:
        return 'تم الإلغاء';
      case BookingStatus.approved:
        return 'مقبول';
      case BookingStatus.rejected:
        return 'مرفوض';
      case BookingStatus.paymentUnderReview:
        return 'مراجعة الدفع';
      case BookingStatus.awaitingPayment:
        return 'في انتظار الدفع';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.reOffered:
        return 'معروض للنقاش';
      case BookingStatus.pendingOwnerApproval:
        return 'بانتظار الموافقة';
      case BookingStatus.pending:
        return 'قيد الانتظار';
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
    final isPaymentRejected = booking.status == BookingStatus.awaitingPayment &&
        (booking.paymentRejected == true ||
            (booking.adminPaymentNotes != null &&
                booking.adminPaymentNotes!.isNotEmpty));
    final isConfirmed = booking.status == BookingStatus.confirmed;
    final isApproved = booking.status == BookingStatus.approved;
    final isCancelled = booking.status == BookingStatus.cancelled;
    final isCompleted = booking.status == BookingStatus.completed;
    final statusColor = _statusColor(booking.status, isPaymentRejected);
    final nights = _nights(booking.from, booking.to);
    final locationName = _locationDisplay(booking.chaletLocation, booking.chaletName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  height: 180,
                  width: double.infinity,
                  child: booking.chaletImage != null &&
                          booking.chaletImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: booking.chaletImage!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (_, __, ___) => _placeholderImage(isDark),
                        )
                      : _placeholderImage(isDark),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          _statusText(booking.status, isPaymentRejected),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '${(booking.amount ?? 0).toStringAsFixed(0)} ج.م',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
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
                  Row(
                    children: [
                      _dateChip(
                        Icons.arrow_forward,
                        'الوصول',
                        '${booking.from.day}/${booking.from.month}',
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _dateChip(
                        Icons.arrow_back,
                        'المغادرة',
                        '${booking.to.day}/${booking.to.month}',
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _dateChip(
                        Icons.bed_outlined,
                        'المدة',
                        '$nights ليال',
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
                        'المضيف : ${booking.ownerName}',
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

  Widget _placeholderImage(bool isDark) {
    return Container(
      height: 180,
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
      child: Icon(
        Icons.holiday_village,
        size: 48,
        color: isDark ? Colors.white24 : Colors.grey.shade500,
      ),
    );
  }

  Widget _dateChip(IconData icon, String label, String value, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: isDark ? Colors.white54 : Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '$label $value',
          style: TextStyle(
            fontSize: 12,
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
                      'مرحباً، تم رفض إثبات الدفع لحجز رقم: ${booking.id.substring(0, 8)}',
                );
              },
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: const Text('واتساب', style: TextStyle(fontSize: 13)),
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
              label: const Text('اتصال', style: TextStyle(fontSize: 13)),
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('إلغاء الحجز', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                  const SnackBar(content: Text('تم عرض الحجز للنقاش بنجاح')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('إعادة عرض'),
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment_rounded, size: 20),
              SizedBox(width: 8),
              Text('إتمام الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              MaterialPageRoute(
                builder: (_) => RatingPage(booking: booking),
              ),
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: 20),
              SizedBox(width: 8),
              Text('تقييم الشاليه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              await context.read<AppCubit>().bookingCubit.finalizeTransfer(booking.id);
              if (context.mounted) {
                final appCubit = context.read<AppCubit>();
                final state = appCubit.state;
                if (state is AppAuthenticated) {
                  appCubit.bookingCubit.loadUserBookings(state.user.uid);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نقل الحجز بنجاح ✅')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('حدث خطأ: $e')),
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
          child: const Text('إتمام قبول الموافقة النهائية'),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
