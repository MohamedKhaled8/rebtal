import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/helper/extensions.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/services/invoice_service.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
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
    final authCubit = context.read<AppCubit>().authCubit;
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
        title: Text(context.tr('booking_my_requests')),
        centerTitle: true,
        backgroundColor: ColorManager.white,
        foregroundColor: ColorManager.chaletTextPrimaryLight,
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
      backgroundColor: isDark
          ? ColorManager.darkBackground121212
          : ColorManager.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: ColorManager.green, size: 80),
              const SizedBox(height: 24),
              Text(
                context.tr('booking_request_received'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ColorManager.white
                      : ColorManager.chaletTextPrimaryLight,
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
                      label: Text(context.tr('booking_print')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? ColorManager.white
                            : ColorManager.chaletTextPrimaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isDark
                              ? ColorManager.white.withOpacity(0.3)
                              : ColorManager.grey300,
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
                      label: Text(context.tr('booking_save')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? ColorManager.white
                            : ColorManager.chaletTextPrimaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isDark
                              ? ColorManager.white.withOpacity(0.3)
                              : ColorManager.grey300,
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
                context.tr('booking_admin_review'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? ColorManager.white70
                      : ColorManager.chaletTextPrimaryLight,
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
                    backgroundColor: ColorManager.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    context.tr('booking_back_home'),
                    style: TextStyle(color: ColorManager.white, fontSize: 18),
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
              color: ColorManager.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: 64,
              color: ColorManager.chaletActionDarkBlue,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.tr('booking_no_requests'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('booking_no_requests_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(color: ColorManager.grey600),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: Text(context.tr('booking_refresh')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.chaletActionDarkBlue,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  // open phone to support — leave phone empty if not configured
                  await UriLauncherService.launchPhoneCall(context, '');
                },
                icon: const Icon(Icons.phone),
                label: Text(context.tr('booking_contact_support_btn')),
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
                  backgroundColor: ColorManager.chaletIconBackgroundLight,
                  child: Text(
                    (chat.chaletName.isNotEmpty ? chat.chaletName[0] : context.tr('common_fallback_chalet')),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.primaryColor,
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
                        '${context.tr('booking_chalet_owner')} ${chat.ownerName}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: chat.status, context: context),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: ColorManager.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  '${context.tr('booking_request_date')} ${_formatDate(chat.createdAt)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: ColorManager.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  '${context.tr('booking_last_update')} ${_formatTime(context, chat.lastMessageTime)}',
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
                    label: Text(context.tr('booking_call')),
                  ),
                ),
                const SizedBox(width: 10),
                if (chat.status == 'pending')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showCancelDialog(context),
                      icon: const Icon(Icons.cancel),
                      label: Text(context.tr('booking_cancel_request_btn')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.red,
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
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('booking_cancel_dialog_title')),
        content: Text(ctx.tr('booking_cancel_dialog_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.tr('common_no')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // implement cancellation logic in calling code or via bloc/cubit
            },
            child: Text(ctx.tr('common_yes')),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays} ${context.tr('booking_day')}';
    if (diff.inHours > 0) return '${diff.inHours} ${context.tr('booking_hour')}';
    if (diff.inMinutes > 0) return '${diff.inMinutes} ${context.tr('booking_minute')}';
    return context.tr('common_now');
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final BuildContext parentContext;
  const _StatusChip({required this.status, required BuildContext context}) : parentContext = context;

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
        _getStatusText(parentContext, status),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return ColorManager.orange;
      case 'approved':
        return ColorManager.chaletActionGreen;
      case 'rejected':
        return ColorManager.chaletActionDarkRed;
      case 'cancelled':
        return ColorManager.red;
      case 'completed':
        return ColorManager.chaletActionDarkBlue;
      case 'paymentUnderReview':
        return ColorManager.purple;
      default:
        return ColorManager.grey700;
    }
  }

  String _getStatusText(BuildContext ctx, String status) {
    switch (status) {
      case 'pending':
        return ctx.tr('booking_status_pending');
      case 'approved':
        return ctx.tr('booking_status_accepted');
      case 'rejected':
        return ctx.tr('booking_status_rejected');
      case 'cancelled':
        return ctx.tr('booking_status_cancelled');
      case 'completed':
        return ctx.tr('booking_status_completed');
      case 'paymentUnderReview':
        return ctx.tr('booking_status_payment_review');
      default:
        return ctx.tr('common_unknown_status');
    }
  }
}
