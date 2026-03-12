import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/helper/extensions.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
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
        backgroundColor: ColorsManager.white,
        foregroundColor: ColorsManager.chaletTextPrimaryLight,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: stv(context: context, mobile: 12.sw, tablet: 16.sw, desktop: 20.sw),
            vertical: 8,
          ),
          child: widget.requests == null || widget.requests!.isEmpty
              ? _EmptyRequestsView(onRefresh: () => setState(() {}))
              : RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.separated(
                    padding: EdgeInsets.only(
                      top: 8,
                      bottom: otv(context: context, portrait: 24.sh, landscape: 12.sh),
                    ),
                    separatorBuilder: (_, __) => SizedBox(height: otv(context: context, portrait: 8.sh, landscape: 4.sh)),
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
          ? ColorsManager.darkBackground121212
          : ColorsManager.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(stv(context: context, mobile: 24.sw, tablet: 32.sw, desktop: 40.sw)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                  if (isLandscape) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: ColorsManager.green, size: stv(context: context, mobile: 60.spScaled, tablet: 70.spScaled, desktop: 80.spScaled)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            context.tr('booking_request_received'),
                            style: TextStyle(
                              fontSize: stv(context: context, mobile: 20.spScaled, tablet: 24.spScaled, desktop: 28.spScaled),
                              fontWeight: FontWeight.bold,
                              color: isDark ? ColorsManager.white : ColorsManager.chaletTextPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Icon(Icons.check_circle, color: ColorsManager.green, size: 80),
                      const SizedBox(height: 24),
                      Text(
                        context.tr('booking_request_received'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? ColorsManager.white : ColorsManager.chaletTextPrimaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }
              ),

              SizedBox(height: otv(context: context, portrait: 24.sh, landscape: 16.sh)),

              // Display Ticket wrapped in RepaintBoundary
              RepaintBoundary(
                key: _repaintKey,
                child: BookingTicketWidget(booking: booking),
              ),

              SizedBox(height: otv(context: context, portrait: 16.sh, landscape: 8.sh)),

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
                            ? ColorsManager.white
                            : ColorsManager.chaletTextPrimaryLight,
                        padding: EdgeInsets.symmetric(vertical: otv(context: context, portrait: 12.sh, landscape: 8.sh)),
                        side: BorderSide(
                          color: isDark
                              ? ColorsManager.white.withOpacity(0.3)
                              : ColorsManager.grey300,
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
                            ? ColorsManager.white
                            : ColorsManager.chaletTextPrimaryLight,
                        padding: EdgeInsets.symmetric(vertical: otv(context: context, portrait: 12.sh, landscape: 8.sh)),
                        side: BorderSide(
                          color: isDark
                              ? ColorsManager.white.withOpacity(0.3)
                              : ColorsManager.grey300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: otv(context: context, portrait: 24.sh, landscape: 16.sh)),
              Text(
                context.tr('booking_admin_review'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: stv(context: context, mobile: 16.spScaled, tablet: 18.spScaled, desktop: 20.spScaled),
                  color: isDark
                      ? ColorsManager.white70
                      : ColorsManager.chaletTextPrimaryLight,
                ),
              ),
              SizedBox(height: otv(context: context, portrait: 48.sh, landscape: 24.sh)),
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
                    backgroundColor: ColorsManager.green,
                    padding: EdgeInsets.symmetric(vertical: otv(context: context, portrait: 16.sh, landscape: 12.sh)),
                  ),
                  child: Text(
                    context.tr('booking_back_home'),
                    style: TextStyle(
                      color: ColorsManager.white,
                      fontSize: stv(context: context, mobile: 18.spScaled, tablet: 20.spScaled, desktop: 22.spScaled),
                    ),
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
            padding: EdgeInsets.all(stv(context: context, mobile: 18.sw, tablet: 22.sw, desktop: 26.sw)),
            decoration: BoxDecoration(
              color: ColorsManager.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: stv(context: context, mobile: 64.spScaled, tablet: 72.spScaled, desktop: 80.spScaled),
              color: ColorsManager.chaletActionDarkBlue,
            ),
          ),
          SizedBox(height: otv(context: context, portrait: 18.sh, landscape: 12.sh)),
          Text(
            context.tr('booking_no_requests'),
            style: TextStyle(
              fontSize: stv(context: context, mobile: 18.spScaled, tablet: 20.spScaled, desktop: 22.spScaled),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('booking_no_requests_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorsManager.grey600,
              fontSize: stv(context: context, mobile: 14.spScaled, tablet: 15.spScaled, desktop: 16.spScaled),
            ),
          ),
          SizedBox(height: otv(context: context, portrait: 18.sh, landscape: 12.sh)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: Text(context.tr('booking_refresh')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.chaletActionDarkBlue,
                  padding: EdgeInsets.symmetric(
                    horizontal: stv(context: context, mobile: 16.sw, tablet: 20.sw, desktop: 24.sw),
                    vertical: otv(context: context, portrait: 12.sh, landscape: 8.sh),
                  ),
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
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: stv(context: context, mobile: 16.sw, tablet: 20.sw, desktop: 24.sw),
                    vertical: otv(context: context, portrait: 12.sh, landscape: 8.sh),
                  ),
                ),
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
                  radius: stv(context: context, mobile: 26.sw, tablet: 30.sw, desktop: 34.sw),
                  backgroundColor: ColorsManager.chaletIconBackgroundLight,
                  child: Text(
                    (chat.chaletName.isNotEmpty
                        ? chat.chaletName[0]
                        : context.tr('common_fallback_chalet')),
                    style: TextStyle(
                      fontSize: stv(context: context, mobile: 20.spScaled, tablet: 22.spScaled, desktop: 24.spScaled),
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.primaryColor,
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
                  color: ColorsManager.grey,
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
                  color: ColorsManager.grey,
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
                        backgroundColor: ColorsManager.red,
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
    if (diff.inHours > 0)
      return '${diff.inHours} ${context.tr('booking_hour')}';
    if (diff.inMinutes > 0)
      return '${diff.inMinutes} ${context.tr('booking_minute')}';
    return context.tr('common_now');
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final BuildContext parentContext;
  const _StatusChip({required this.status, required BuildContext context})
    : parentContext = context;

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
        return ColorsManager.orange;
      case 'approved':
        return ColorsManager.chaletActionGreen;
      case 'rejected':
        return ColorsManager.chaletActionDarkRed;
      case 'cancelled':
        return ColorsManager.red;
      case 'completed':
        return ColorsManager.chaletActionDarkBlue;
      case 'paymentUnderReview':
        return ColorsManager.purple;
      default:
        return ColorsManager.grey700;
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
