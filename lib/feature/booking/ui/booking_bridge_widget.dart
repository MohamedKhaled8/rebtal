import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/widgets/premium_loading_overlay.dart';

class BookingBridgeWidget extends StatefulWidget {
  final BuildContext parentContext;
  final String userId;
  final String userName;
  final String chaletId;
  final String chaletName;
  final String ownerId;
  final String ownerName;
  final Map<String, dynamic> requestData;

  const BookingBridgeWidget({
    super.key,
    required this.parentContext,
    required this.userId,
    required this.userName,
    required this.chaletId,
    required this.chaletName,
    required this.ownerId,
    required this.ownerName,
    required this.requestData,
  });

  @override
  State<BookingBridgeWidget> createState() => _BookingBridgeWidgetState();
}

class _BookingBridgeWidgetState extends State<BookingBridgeWidget>
    with WidgetsBindingObserver {
  /// تحويل تاريخ من requestData (قد يكون Timestamp أو String أو DateTime).
  /// يُرجع التاريخ فقط (بدون وقت) لاستخدامه في منتقي الأيام.
  static DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    DateTime? d;
    if (val is Timestamp) {
      d = val.toDate();
    } else if (val is DateTime) {
      d = val;
    } else if (val is String) {
      d = DateTime.tryParse(val);
    }
    if (d == null) return null;
    return DateTime(d.year, d.month, d.day);
  }

  // Normalize owner id formats (some code stores 'user:<uid>').
  String _normOwnerId(String id) {
    // Accept values like 'user:<uid>' or 'owner:<uid>' or raw uid and
    // always return the canonical uid (part after last ':').
    if (id.contains(':')) return id.split(':').last.trim();
    return id.trim();
  }

  bool _launchedExternal = false;
  late final String _bookingId;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bookingId = const Uuid().v4();

    _from = null;
    _to = null;

    // Do not add booking on init. Booking will be created only when the
    // user explicitly confirms or rejects after returning from external app.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _launchedExternal) {
      _launchedExternal = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Handle
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            ColorManager.chaletAccent.withOpacity(0.15),
                            ColorManager.chaletAccent.withOpacity(0.05),
                          ]
                        : [
                            ColorManager.chaletAccent.withOpacity(0.1),
                            ColorManager.chaletAccent.withOpacity(0.03),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorManager.chaletAccent.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            ColorManager.chaletAccent,
                            Color(0xFF00A896),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.chaletAccent.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.villa_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chaletName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 16,
                                color: isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.userName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Date Selection Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF252525)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D27F).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event_available_rounded,
                            color: Color(0xFF00D27F),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('booking_select_dates'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.tr('booking_select_start_end'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernDateSelector(
                            context,
                            isDark: isDark,
                            label: context.tr('booking_from_date'),
                            icon: Icons.login_rounded,
                            selectedDate: _from,
                            onTap: () async {
                              final now = DateTime.now();
                              final today = DateTime(now.year, now.month, now.day);
                              // قد تكون التواريخ في availableFrom/availableTo أو from/to (عروض/حجوزات)
                              final rawFrom = widget.requestData['availableFrom'] ??
                                  widget.requestData['from'];
                              final rawTo = widget.requestData['availableTo'] ??
                                  widget.requestData['to'];

                              final from = _parseDate(rawFrom);
                              final to = _parseDate(rawTo);

                              DateTime firstDate;
                              DateTime lastDate;
                              if (from != null && to != null && !to.isBefore(from)) {
                                firstDate = from.isBefore(today) ? today : from;
                                lastDate = to;
                                if (lastDate.isBefore(firstDate)) {
                                  lastDate = firstDate;
                                }
                              } else {
                                firstDate = today;
                                lastDate = today.add(const Duration(days: 60));
                                if (mounted) {
                                  SnackBarHelper.showWarning(
                                    context,
                                    context.tr('booking_undef_period_msg'),
                                  );
                                }
                              }

                              final picked = await showDatePicker(
                                context: widget.parentContext,
                                initialDate: _from ?? firstDate,
                                firstDate: firstDate,
                                lastDate: lastDate,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: ColorManager.chaletAccent,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  _from = picked;
                                  if (_to != null && _to!.isBefore(picked)) {
                                    _to = null;
                                  }
                                });
                              }
                            },
                          ),
                        ),

                        // Timeline Connector
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF4CAF50),
                                      const Color(0xFFFF5252),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: _buildModernDateSelector(
                            context,
                            isDark: isDark,
                            label: context.tr('booking_to_date'),
                            icon: Icons.logout_rounded,
                            selectedDate: _to,
                            onTap: () async {
                              if (_from == null) {
                                SnackBarHelper.showWarning(
                                  context,
                                  context.tr('booking_select_start_first'),
                                );
                                return;
                              }

                              final fromDate = _from!;
                              final rawTo = widget.requestData['availableTo'] ??
                                  widget.requestData['to'];
                              final parsedTo = _parseDate(rawTo);
                              final lastDate = (parsedTo != null &&
                                      !parsedTo.isBefore(fromDate))
                                  ? parsedTo
                                  : fromDate.add(const Duration(days: 60));

                              final picked = await showDatePicker(
                                context: widget.parentContext,
                                initialDate: _to ?? fromDate,
                                firstDate: fromDate,
                                lastDate: lastDate,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: ColorManager.chaletAccent,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() => _to = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (_from != null && _to != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ColorManager.chaletAccent.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('booking_days_label'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_getDays(_from!, _to!)}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('booking_nights_label'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_getNights(_from!, _to!)}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.chaletAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('booking_price_per_night'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_calculateNightlyPrice().toStringAsFixed(0)} جنيه',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('booking_total_label'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '${_calculateTotalAmount(_from!, _to!).toStringAsFixed(0)} جنيه',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.chaletAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Action Buttons
              if (_from == null || _to == null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.orange[700],
                        size: 22,
                      ),
                      const SizedBox(width: 12),  
                      Expanded(
                        child: Text(
                          context.tr('booking_select_period_first_msg'),
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // WhatsApp/Call buttons kept for future use; condition intentionally false.
                // ignore: dead_code
                if (false) ...[
                  // WhatsApp Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final phone = await _resolvePhone();
                          if (phone == null || phone.trim().isEmpty) {
                            SnackBarHelper.showWarning(
                              context,
                              context.tr('booking_phone_unavailable'),
                              icon: Icons.phone_disabled,
                            );
                            return;
                          }
                          // REMOVED: Do not save booking here. Wait for user confirmation.
                          // try {
                          //   final resolved = await _resolveOwner();
                          //   final updated = Booking(
                          //     id: _bookingId,
                          //     chaletId: widget.chaletId,
                          //     chaletName: widget.chaletName,
                          //     ownerId: _normOwnerId(
                          //       resolved['ownerId'] ?? widget.ownerId,
                          //     ),
                          //     ownerName:
                          //         resolved['ownerName'] ?? widget.ownerName,
                          //     userId: widget.userId,
                          //     userName: widget.userName,
                          //     from: _from!,
                          //     to: _to!,
                          //     status: BookingStatus.pending,
                          //   );
                          //   try {
                          //     widget.parentContext
                          //         .read<BookingCubit>()
                          //         .addBooking(updated);
                          //     _saveToFirestore(updated);
                          //   } catch (_) {
                          //     context.read<BookingCubit>().addBooking(updated);
                          //   }
                          // } catch (_) {}
                          setState(() => _launchedExternal = true);
                          await UriLauncherService.launchWhatsAppContact(
                            context: context,
                            phone: phone,
                            message:
                                '${context.tr('booking_whatsapp_message')} ${_from!.day}/${_from!.month}/${_from!.year} ${context.tr('booking_to')} ${_to!.day}/${_to!.month}/${_to!.year}',
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
                              Icon(
                                Icons.chat_bubble_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 12),
                              Text(
                                context.tr('booking_open_whatsapp'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Call Button
                  OutlinedButton.icon(
                    onPressed: () async {
                      final phone = await _resolvePhone();
                      if (phone == null || phone.trim().isEmpty) {
                        SnackBarHelper.showWarning(
                          context,
                          'رقم الهاتف غير متوفر',
                          icon: Icons.phone_disabled,
                        );
                        return;
                      }
                      setState(() => _launchedExternal = true);
                      await UriLauncherService.launchPhoneCall(context, phone);
                    },
                    icon: Icon(
                      Icons.call_rounded,
                      color: isDark
                          ? ColorManager.chaletAccent
                          : const Color(0xFF1D4ED8),
                    ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        context.tr('booking_call'),
                        style: TextStyle(
                          color: isDark
                              ? ColorManager.chaletAccent
                              : const Color(0xFF1D4ED8),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: BorderSide(
                        color: isDark
                            ? ColorManager.chaletAccent
                            : const Color(0xFF1D4ED8),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'بعد العودة سيظهر لك زري التأكيد/الرفض',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                // Decision Buttons: open confirmation sheet first, then create booking + rating
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showBookingConfirmationSheet(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:  [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Text(
                              context.tr('booking_approve_booking_bridge'),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    // REMOVED: Do not save rejected booking since it was never created.
                    // final resolved = await _resolveOwner();
                    // final booking = Booking(
                    //   id: _bookingId,
                    //   chaletId: widget.chaletId,
                    //   chaletName: widget.chaletName,
                    //   ownerId: _normOwnerId(
                    //     resolved['ownerId'] ?? widget.ownerId,
                    //   ),
                    //   ownerName: resolved['ownerName'] ?? widget.ownerName,
                    //   userId: widget.userId,
                    //   userName: widget.userName,
                    //   from: _from ?? DateTime.now(),
                    //   to: _to ?? DateTime.now().add(const Duration(days: 1)),
                    //   status: BookingStatus.rejected,
                    // );
                    // try {
                    //   widget.parentContext.read<AppCubit>().bookingCubit.addBooking(
                    //     booking,
                    //   );
                    //   _saveToFirestore(booking);
                    // } catch (_) {
                    //   context.read<AppCubit>().bookingCubit.addBooking(booking);
                    // }
                    SnackBarHelper.showError(
                      widget.parentContext,
                      context.tr('booking_request_rejected'),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: Color(0xFFEF4444),
                  ),
                  label:   Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      context.tr('booking_reject_booking_bridge'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    side: const BorderSide(color: Color(0xFFEF4444), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _resolvePhone() async {
    String phone =
        (widget.requestData['phoneNumber'] ?? widget.requestData['phone'] ?? '')
            .toString();
    if (phone.trim().isEmpty) {
      try {
        final chaletDoc = await FirebaseFirestore.instance
            .collection('chalets')
            .doc(widget.chaletId)
            .get();
        if (chaletDoc.exists) {
          final data = chaletDoc.data();
          phone = (data?['phoneNumber'] ?? data?['phone'] ?? '') ?? '';
        }
      } catch (e) {
        // ignore
      }
    }
    return phone;
  }

  Future<Map<String, String>> _resolveOwner() async {
    String ownerId = widget.ownerId;
    String ownerName = widget.ownerName;

    if (ownerId.trim().isEmpty || ownerName.trim().isEmpty) {
      try {
        final chaletDoc = await FirebaseFirestore.instance
            .collection('chalets')
            .doc(widget.chaletId)
            .get();
        if (chaletDoc.exists) {
          final data = chaletDoc.data();
          ownerId = ownerId.trim().isEmpty
              ? (data?['ownerId'] ?? data?['merchantId'] ?? '') ?? ownerId
              : ownerId;
          ownerName = ownerName.trim().isEmpty
              ? (data?['merchantName'] ?? data?['ownerName'] ?? '') ?? ownerName
              : ownerName;
        }
      } catch (e) {
        // ignore
      }
    }

    return {'ownerId': ownerId, 'ownerName': ownerName};
  }

  Widget _buildModernDateSelector(
    BuildContext context, {
    required bool isDark,
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedDate != null;

    // Color coding: green for start, red for end (use isFromDate param)
    final isFromDate = icon == Icons.login_rounded;
    final accentColor = isFromDate
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF5252);

    final cardBg = isDark ? const Color(0xFF252525) : const Color(0xFFF8F9FA);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.shade200;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white60 : Colors.grey.shade600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor.withOpacity(0.5) : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withOpacity(0.15)
                    : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? accentColor : textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textSecondary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Date
            Text(
              selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : context.tr('booking_select_date'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? textPrimary : textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingConfirmationSheet(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final from = _from!;
    final to = _to!;
    final totalAmount = _calculateTotalAmount(from, to);
    final days = _getDays(from, to);
    final nights = _getNights(from, to);
    final dateStr = (DateTime d) => '${d.day}/${d.month}/${d.year}';

    int selectedChildren = 0;
    bool termsAccepted = false;
    bool expandedPolicy = false;
    final childrenController = TextEditingController(text: '0');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final canConfirm = termsAccepted;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.tr('booking_confirm'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _confirmationRow(
                      isDark,
                      context.tr('booking_final_price'),
                      '${totalAmount.toStringAsFixed(0)} EGP',
                      valueColor: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 12),
                    _confirmationRow(
                      isDark,
                      context.tr('booking_from_to'),
                      '${dateStr(from)} → ${dateStr(to)}',
                    ),
                    const SizedBox(height: 10),
                    _confirmationRow(isDark, context.tr('booking_days_label'), '$days'),
                    const SizedBox(height: 6),
                    _confirmationRow(isDark, context.tr('booking_nights_label'), '$nights'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('booking_children_count_label'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setModalState(() {
                                      selectedChildren = (selectedChildren - 1)
                                          .clamp(0, 30);
                                      childrenController.text =
                                          '$selectedChildren';
                                    });
                                  },
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 50,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                child: TextField(
                                  controller: childrenController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.grey[400],
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  onChanged: (v) {
                                    final n = int.tryParse(v.trim());
                                    setModalState(() {
                                      if (n != null && n >= 0 && n <= 30) {
                                        selectedChildren = n;
                                      } else if (v.trim().isEmpty) {
                                        selectedChildren = 0;
                                      }
                                    });
                                  },
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setModalState(() {
                                      selectedChildren = (selectedChildren + 1)
                                          .clamp(0, 30);
                                      childrenController.text =
                                          '$selectedChildren';
                                    });
                                  },
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Terms & policies
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => setModalState(
                              () => termsAccepted = !termsAccepted,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: termsAccepted,
                                    onChanged: (v) => setModalState(
                                      () => termsAccepted = v ?? false,
                                    ),
                                    activeColor: ColorManager.chaletAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    context.tr('booking_agree_policies'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('booking_policy_summary'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => setModalState(
                              () => expandedPolicy = !expandedPolicy,
                            ),
                            child: Text(
                              expandedPolicy
                                  ? context.tr('booking_hide_details')
                                  : context.tr('booking_view_full_policy'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.chaletAccent,
                              ),
                            ),
                          ),
                          if (expandedPolicy) ...[
                            const SizedBox(height: 8),
                            Text(
                              context.tr('booking_policy_full'),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: canConfirm
                            ? () async {
                                Navigator.of(ctx).pop();
                                if (!mounted) return;
                                await _submitBooking(selectedChildren);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canConfirm
                              ? ColorManager.chaletAccent
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          context.tr('booking_confirm'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => childrenController.dispose());
  }

  Widget _confirmationRow(
    bool isDark,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  Future<void> _submitBooking(int childrenCount) async {
    PremiumLoadingOverlay.show(context);

    try {
      final resolved = await _resolveOwner();
      final totalAmount = _calculateTotalAmount(_from!, _to!);

      String? userPhone;
      String? userEmail;
      try {
        var userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .get();
        if (!userDoc.exists) {
          userDoc = await FirebaseFirestore.instance
              .collection('Owners')
              .doc(widget.userId)
              .get();
        }
        if (userDoc.exists) {
          final userData = userDoc.data();
          userPhone = userData?['phone'] ?? userData?['phoneNumber'];
          userEmail = userData?['email'];
        }
      } catch (e) {
        debugPrint('Error fetching user details: $e');
      }

      String? ownerPhone;
      String? ownerEmail;
      try {
        final ownerId = _normOwnerId(resolved['ownerId'] ?? widget.ownerId);
        var ownerDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(ownerId)
            .get();
        if (!ownerDoc.exists) {
          ownerDoc = await FirebaseFirestore.instance
              .collection('Owners')
              .doc(ownerId)
              .get();
        }
        if (ownerDoc.exists) {
          final ownerData = ownerDoc.data();
          ownerPhone = ownerData?['phone'] ?? ownerData?['phoneNumber'];
          ownerEmail = ownerData?['email'];
        }
      } catch (e) {
        debugPrint('Error fetching owner details: $e');
      }

      final booking = Booking(
        id: _bookingId,
        chaletId: widget.chaletId,
        chaletName: widget.chaletName,
        ownerId: _normOwnerId(resolved['ownerId'] ?? widget.ownerId),
        ownerName: resolved['ownerName'] ?? widget.ownerName,
        userId: widget.userId,
        userName: widget.userName,
        from: _from ?? DateTime.now(),
        to: _to ?? DateTime.now().add(const Duration(days: 1)),
        status: BookingStatus.pending,
        amount: totalAmount,
        userPhone: userPhone,
        userEmail: userEmail,
        ownerPhone: ownerPhone,
        ownerEmail: ownerEmail,
        chaletLocation: widget.requestData['location'] as String?,
        childrenCount: childrenCount,
      );

      final docRef = FirebaseFirestore.instance.collection('bookings').doc();
      final bookingWithId = booking.copyWith(id: docRef.id);

      widget.parentContext.read<AppCubit>().bookingCubit.addBooking(
        bookingWithId,
      );
      await docRef.set(bookingWithId.toMap());

      await NotificationService().sendNotification(
        userId: bookingWithId.ownerId,
        title: '${context.tr('booking_new_request_notif')} 📩',
        body:
            '${context.tr('booking_new_request_body')} ${bookingWithId.chaletName} ${context.tr('booking_from')} ${bookingWithId.userName}. ${context.tr('booking_review_approve')}',
        type: NotificationType.bookingRequest,
        relatedId: bookingWithId.id,
        data: {
          'bookingId': bookingWithId.id,
          'chaletId': bookingWithId.chaletId,
        },
      );

      if (mounted) {
        PremiumLoadingOverlay.dismiss(context);
        SnackBarHelper.showSuccess(
          widget.parentContext,
          context.tr('booking_sent_to_owner'),
        );
        await _showRatingBottomSheet();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('Error confirming booking: $e');
      if (mounted) {
        PremiumLoadingOverlay.dismiss(context);
        SnackBarHelper.showError(context, '${context.tr('booking_error_msg')} $e');
      }
    }
  }

  Future<void> _showRatingBottomSheet() async {
    double tempRating = 0;
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = DynamicThemeManager.isDarkMode(context);
            final canSubmit =
                tempRating > 0 && controller.text.trim().isNotEmpty;
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          context.tr('booking_rate_experience'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('booking_rate_help'),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final filled = tempRating >= i + 1;
                            return IconButton(
                              onPressed: () => setModalState(
                                () => tempRating = (i + 1).toDouble(),
                              ),
                              icon: Icon(
                                filled ? Icons.star : Icons.star_border,
                                color: const Color(0xFFFFC107),
                                size: 36,
                              ),
                            );
                          }),
                        ),

                        if (tempRating > 0) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              _getRatingLabel(context, tempRating),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorManager.chaletAccent,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        TextField(
                          controller: controller,
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(
                            color: Colors.black, // Always Black
                            fontSize: 16,
                          ),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            hintText: context.tr('booking_write_comment'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(
                              0xFFF9FAFB,
                            ), // Very light gray, almost white
                          ),
                          onChanged: (val) => setModalState(() {}),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                (tempRating == 0 ||
                                    controller.text.trim().isEmpty)
                                ? null
                                : () async {
                                    // Show loading overlay
                                    PremiumLoadingOverlay.show(
                                      context,
                                      message: context.tr('common_loading'),
                                    );

                                    try {
                                      // Fetch latest user details for the review
                                      String userImage = '';
                                      String displayName = widget.userName;
                                      try {
                                        final userDoc = await FirebaseFirestore
                                            .instance
                                            .collection('users')
                                            .doc(widget.userId)
                                            .get();
                                        if (userDoc.exists) {
                                          userImage =
                                              userDoc.data()?['profileImage'] ??
                                              '';
                                          displayName =
                                              userDoc.data()?['name'] ??
                                              widget.userName;
                                        }
                                      } catch (_) {}

                                      final ratingData = {
                                        'chaletId': widget.chaletId,
                                        'chaletName': widget.chaletName,
                                        'userId': widget.userId,
                                        'userName': displayName,
                                        'userImage': userImage,
                                        'rating': tempRating,
                                        'review': controller.text.trim(),
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      };

                                      await FirebaseFirestore.instance
                                          .collection('chalet_ratings')
                                          .add(ratingData);
                                      // Optionally update chalet doc with aggregate fields
                                      await _updateChaletRatingAggregate(
                                        chaletId: widget.chaletId,
                                        newRating: tempRating,
                                      );
                                      if (mounted) {
                                        PremiumLoadingOverlay.dismiss(context);
                                        Navigator.pop(context);
                                        SnackBarHelper.showSuccess(
                                          context,
                                          context.tr('booking_thanks_rating'),
                                          icon: Icons.star,
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        PremiumLoadingOverlay.dismiss(context);
                                        SnackBarHelper.showError(
                                          context,
                                          '${context.tr('booking_save_rating_error')} $e',
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              backgroundColor: canSubmit
                                  ? ColorManager.chaletAccent
                                  : (isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[300]),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              disabledForegroundColor: isDark
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.grey[500],
                              elevation: canSubmit ? 2 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  canSubmit
                                      ? Icons.send_rounded
                                      : Icons.edit_outlined,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  canSubmit
                                      ? context.tr('booking_send_rating')
                                      : context.tr('booking_complete_data'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getRatingLabel(BuildContext ctx, double rating) {
    if (rating == 5) return '${ctx.tr('booking_rating_excellent')} 🌟';
    if (rating == 4) return '${ctx.tr('booking_rating_great')} 👍';
    if (rating == 3) return '${ctx.tr('booking_rating_good')} ✓';
    if (rating == 2) return ctx.tr('booking_rating_ok');
    return ctx.tr('booking_weak');
  }

  Future<void> _updateChaletRatingAggregate({
    required String chaletId,
    required double newRating,
  }) async {
    final chaletRef = FirebaseFirestore.instance
        .collection('chalets')
        .doc(chaletId);
    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(chaletRef);
      final data = snap.data() ?? {};
      final num count = (data['ratingCount'] ?? 0);
      final num sum = (data['ratingSum'] ?? 0);
      final double newCount = (count.toDouble() + 1);
      final double newSum = (sum.toDouble() + newRating);
      final double avg = newCount == 0 ? newRating : newSum / newCount;
      txn.update(chaletRef, {
        'ratingCount': newCount,
        'ratingSum': newSum,
        'rating': double.parse(avg.toStringAsFixed(2)),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Full days between check-in and check-out (e.g. Jan10→Jan15 = 5 days).
  int _getDays(DateTime from, DateTime to) {
    return to.difference(from).inDays.clamp(0, 365);
  }

  /// Nights = days - 1; billing is per night (e.g. Jan10→Jan15 = 4 nights).
  int _getNights(DateTime from, DateTime to) {
    final d = _getDays(from, to);
    return (d - 1).clamp(0, 364);
  }

  double _calculateNightlyPrice() {
    final price = widget.requestData['price'];
    final discountEnabled = widget.requestData['discountEnabled'] == true;
    final discountValue =
        double.tryParse(
          widget.requestData['discountValue']?.toString() ?? '0',
        ) ??
        0;

    double basePrice;
    if (price is num) {
      basePrice = price.toDouble();
    } else {
      basePrice =
          double.tryParse(
            (price ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0;
    }

    if (discountEnabled && discountValue > 0) {
      final discountType = widget.requestData['discountType'];
      if (discountType == 'percentage') {
        basePrice = basePrice * (1 - discountValue / 100);
      } else if (discountType == 'fixed') {
        basePrice = basePrice - discountValue;
      }
      if (basePrice < 0) basePrice = 0;
    }

    return basePrice;
  }

  double _calculateTotalAmount(DateTime from, DateTime to) {
    final nights = _getNights(from, to);
    return _calculateNightlyPrice() * nights;
  }
}
