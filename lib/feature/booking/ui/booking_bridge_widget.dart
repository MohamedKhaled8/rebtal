import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  // Normalize owner id formats (some code stores 'user:<uid>').
  String _normOwnerId(String id) {
    // Accept values like 'user:<uid>' or 'owner:<uid>' or raw uid and
    // always return the canonical uid (part after last ':').
    if (id.contains(':')) return id.split(':').last.trim();
    return id.trim();
  }

  bool _showDecisionButtons = false;
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

  Future<void> _saveToFirestore(Booking booking) async {
    try {
      debugPrint('Saving booking to Firestore: ${booking.toMap()}');
      // Defensive: if ownerId is empty, try to resolve from chalet doc
      String ownerId = booking.ownerId;
      if (ownerId.trim().isEmpty) {
        try {
          final resolved = await _resolveOwner();
          ownerId = (resolved['ownerId'] ?? '').toString();
          debugPrint('Resolved ownerId in _saveToFirestore: $ownerId');
        } catch (e) {
          debugPrint('Failed to resolve ownerId: $e');
        }
      }

      final data = {
        ...booking.toMap(),
        'ownerId': _normOwnerId(ownerId),
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (data['ownerId'].toString().trim().isEmpty) {
        debugPrint(
          'Cannot save booking: resolved ownerId is empty. Booking id=${booking.id}',
        );
        return;
      }
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking.id)
          .set(data);
    } catch (e) {
      debugPrint('Error saving booking to Firestore: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _launchedExternal) {
      setState(() {
        _showDecisionButtons = true;
      });
      _launchedExternal = false;
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                ColorManager.chaletAccent,
                                Color(0xFF00A896),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'اختر فترة الحجز',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                            letterSpacing: 0.3,
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
                            label: 'من تاريخ',
                            icon: Icons.login_rounded,
                            selectedDate: _from,
                            onTap: () async {
                              final now = DateTime.now();
                              final availableFrom =
                                  widget.requestData['availableFrom'];
                              final availableTo =
                                  widget.requestData['availableTo'];

                              DateTime firstDate = now;
                              DateTime lastDate = DateTime(now.year + 1);

                              if (availableFrom != null) {
                                try {
                                  firstDate = DateTime.parse(
                                    availableFrom.toString(),
                                  );
                                } catch (e) {
                                  firstDate = now;
                                }
                              }

                              if (availableTo != null) {
                                try {
                                  lastDate = DateTime.parse(
                                    availableTo.toString(),
                                  );
                                } catch (e) {
                                  lastDate = DateTime(now.year + 1);
                                }
                              }

                              if (lastDate.isBefore(firstDate)) {
                                lastDate = firstDate;
                              }

                              final picked = await showDatePicker(
                                context: context,
                                initialDate: firstDate,
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernDateSelector(
                            context,
                            isDark: isDark,
                            label: 'إلى تاريخ',
                            icon: Icons.logout_rounded,
                            selectedDate: _to,
                            onTap: () async {
                              if (_from == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'يرجى اختيار تاريخ البداية أولاً',
                                    ),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                return;
                              }

                              final availableTo =
                                  widget.requestData['availableTo'];
                              DateTime lastDate = DateTime(
                                DateTime.now().year + 1,
                              );

                              if (availableTo != null) {
                                try {
                                  lastDate = DateTime.parse(
                                    availableTo.toString(),
                                  );
                                } catch (e) {
                                  lastDate = DateTime(DateTime.now().year + 1);
                                }
                              }

                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _from!,
                                firstDate: _from!,
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

                    // Duration Display
                    if (_from != null && _to != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'المدة: ${_calculateBookingDays(_from!, _to!)} يوم',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              if (!_showDecisionButtons) ...[
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
                            'يرجى اختيار فترة الحجز أولاً',
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('رقم الهاتف غير متوفر'),
                              ),
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
                                'السلام عليكم، أريد حجز الشاليه للفترة من ${_from!.day}/${_from!.month}/${_from!.year} إلى ${_to!.day}/${_to!.month}/${_to!.year}',
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.chat_bubble_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'فتح WhatsApp',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('رقم الهاتف غير متوفر')),
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
                        'الاتصال',
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
              ] else ...[
                // Decision Buttons
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
                      onTap: () async {
                        final resolved = await _resolveOwner();
                        final booking = Booking(
                          id: _bookingId,
                          chaletId: widget.chaletId,
                          chaletName: widget.chaletName,
                          ownerId: _normOwnerId(
                            resolved['ownerId'] ?? widget.ownerId,
                          ),
                          ownerName: resolved['ownerName'] ?? widget.ownerName,
                          userId: widget.userId,
                          userName: widget.userName,
                          from: _from ?? DateTime.now(),
                          to:
                              _to ??
                              DateTime.now().add(const Duration(days: 1)),
                          status: BookingStatus.pending,
                        );
                        try {
                          widget.parentContext.read<BookingCubit>().addBooking(
                            booking,
                          );
                          _saveToFirestore(booking);
                        } catch (_) {
                          context.read<BookingCubit>().addBooking(booking);
                        }
                        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('تم إرسال الطلب للمالك'),
                          ),
                        );
                        await _showRatingBottomSheet();
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'موافقة على الحجز',
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
                    //   widget.parentContext.read<BookingCubit>().addBooking(
                    //     booking,
                    //   );
                    //   _saveToFirestore(booking);
                    // } catch (_) {
                    //   context.read<BookingCubit>().addBooking(booking);
                    // }
                    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                      const SnackBar(content: Text('تم رفض الطلب')),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: Color(0xFFEF4444),
                  ),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'رفض الحجز',
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected ? const Color(0xFF2A2A2A) : const Color(0xFF1F1F1F))
              : (isSelected ? Colors.white : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? ColorManager.chaletAccent
                : (isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? ColorManager.chaletAccent
                      : (isDark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.grey[600]),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : 'اختر التاريخ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                    : (isDark
                          ? Colors.white.withOpacity(0.4)
                          : Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateBookingDays(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }

  Future<void> _showRatingBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        double tempRating = 0;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SafeArea(
                top: false,
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
                    const Text(
                      'قيّم تجربتك',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'برجاء تقييم الخدمة لمساعدتنا على تحسين التجربة',
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
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: tempRating == 0
                            ? null
                            : () async {
                                try {
                                  final ratingId = const Uuid().v4();
                                  await FirebaseFirestore.instance
                                      .collection('ratings')
                                      .doc(ratingId)
                                      .set({
                                        'id': ratingId,
                                        'chaletId': widget.chaletId,
                                        'userId': widget.userId,
                                        'rating': tempRating,
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                  // Optionally update chalet doc with aggregate fields
                                  await _updateChaletRatingAggregate(
                                    chaletId: widget.chaletId,
                                    newRating: tempRating,
                                  );
                                  if (mounted) Navigator.pop(context);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('شكراً لتقييمك'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('تعذر حفظ التقييم: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: const Color(0xFF1ED760),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'إرسال',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    );
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
}
