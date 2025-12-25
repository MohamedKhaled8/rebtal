import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/helper/extensions.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/services/invoice_service.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:rebtal/core/utils/model/chat_model.dart';

import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/feature/booking/widgets/booking_ticket_widget.dart';

class BookingConfirmationPage extends StatefulWidget {
  final List<ChatModel>? requests;
  final Booking? booking;

  const BookingConfirmationPage({super.key, this.requests, this.booking});

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.getCurrentUser();
    if (user != null) {
      // keep lightweight logging for debugging
      // ignore: avoid_print
      print('BookingConfirmationPage loaded for user ${user.uid}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.booking != null) {
      return _buildSuccessView(context, widget.booking!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات الحجز الخاصة بي'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: widget.requests == null || widget.requests!.isEmpty
              ? _EmptyRequestsView(onRefresh: () => setState(() {}))
              : RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: widget.requests!.length,
                    itemBuilder: (context, index) =>
                        BookingRequestCard(chat: widget.requests![index]),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, Booking booking) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              Text(
                'تم استلام طلبك بنجاح',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Display Ticket wrapped in RepaintBoundary
              RepaintBoundary(
                key: _repaintKey,
                child: BookingTicketWidget(booking: booking),
              ),

              const SizedBox(height: 16),

              // Print and Save Buttons with Dark Mode support
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        InvoiceService.printInvoice(
                          context,
                          _repaintKey,
                          booking,
                        );
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('طباعة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.3)
                              : Colors.black12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                          booking,
                        );
                      },
                      icon: const Icon(Icons.save_alt),
                      label: const Text('حفظ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.3)
                              : Colors.black12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'سيقوم الأدمن بمراجعة الدفع وتأكيد حجزك قريباً.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to home and clear stack
                    context.pushNamedAndRemoveUntil(
                      Routes.bottomNavigationBarScreen,
                      predicate: (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'العودة للرئيسية',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRequestsView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyRequestsView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: 64,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'لا توجد طلبات حجز حتى الآن',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'عند استلام طلبات جديدة ستظهر هنا. يمكنك تحديث الصفحة أو التواصل مع الدعم.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  // open phone to support — leave phone empty if not configured
                  await UriLauncherService.launchPhoneCall(context, '');
                },
                icon: const Icon(Icons.phone),
                label: const Text('اتصل بالدعم'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BookingRequestCard extends StatelessWidget {
  final ChatModel chat;

  const BookingRequestCard({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blue.shade50,
                  child: Text(
                    (chat.chaletName.isNotEmpty ? chat.chaletName[0] : 'ش'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.chaletName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'صاحب الشاليه: ${chat.ownerName}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: chat.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'تاريخ الطلب: ${_formatDate(chat.createdAt)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'آخر تحديث: ${_formatTime(chat.lastMessageTime)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final phone = chat.userId; // fallback
                      await UriLauncherService.launchPhoneCall(context, phone);
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('اتصال'),
                  ),
                ),
                const SizedBox(width: 10),
                if (chat.status == 'pending')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showCancelDialog(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('إلغاء الطلب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد أنك تريد إلغاء طلب الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // implement cancellation logic in calling code or via bloc/cubit
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays} يوم';
    if (diff.inHours > 0) return '${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return '${diff.inMinutes} دقيقة';
    return 'الآن';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade800;
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'cancelled':
        return Colors.red.shade400;
      case 'completed':
        return Colors.blue.shade700;
      case 'paymentUnderReview':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'تم الإلغاء';
      case 'completed':
        return 'مكتمل';
      case 'paymentUnderReview':
        return 'قيد مراجعة الدفع';
      default:
        return 'غير معروف';
    }
  }
}
