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
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // pull handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Chalet info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chaletName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المستخدم: ${widget.userName}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تاريخ: ${DateTime.now().toLocal().toString().split(' ').first}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Date Selection Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.purple.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'اختر فترة الحجز',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBookingDateSelector(
                          context,
                          label: 'من تاريخ',
                          icon: Icons.play_arrow,
                          selectedDate: _from,
                          onTap: () async {
                            final now = DateTime.now();
                            // استخدام التواريخ المتاحة من صاحب الشاليه فقط
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

                            // Ensure valid range: lastDate >= firstDate and initialDate within range
                            if (lastDate.isBefore(firstDate)) {
                              lastDate = firstDate;
                            }
                            // اجعل التاريخ الابتدائي مطابقاً لأول تاريخ متاح من المالك
                            final initialFrom = firstDate;

                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initialFrom,
                              firstDate: firstDate,
                              lastDate: lastDate,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.blue,
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
                                // إذا كان التاريخ النهائي قبل التاريخ الجديد، امسحه
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
                        child: _buildBookingDateSelector(
                          context,
                          label: 'إلى تاريخ',
                          icon: Icons.stop,
                          selectedDate: _to,
                          onTap: () async {
                            if (_from == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'يرجى اختيار تاريخ البداية أولاً',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // استخدام التواريخ المتاحة من صاحب الشاليه فقط
                            final availableFrom =
                                widget.requestData['availableFrom'];
                            final availableTo =
                                widget.requestData['availableTo'];

                            DateTime firstDate = _from ?? DateTime.now();
                            DateTime lastDate = DateTime(
                              DateTime.now().year + 1,
                            );

                            if (availableFrom != null) {
                              try {
                                final parsedFrom = DateTime.parse(
                                  availableFrom.toString(),
                                );
                                // الحد الأدنى لتاريخ النهاية هو الأكبر بين تاريخ البداية المختار المتاح وتاريخ توفر المالك
                                if (parsedFrom.isAfter(firstDate)) {
                                  firstDate = parsedFrom;
                                }
                              } catch (_) {}
                            }

                            if (availableTo != null) {
                              try {
                                lastDate = DateTime.parse(
                                  availableTo.toString(),
                                );
                              } catch (e) {
                                lastDate = DateTime(DateTime.now().year + 1);
                              }
                            }

                            // Ensure valid range: lastDate >= firstDate and initialDate within range
                            // نطاق الكالندر مطابق تماماً لفترة المالك
                            // إذا اختير تاريخ بداية، نبدأ منه أو من availableFrom أيهما أكبر
                            if (_from != null && lastDate.isBefore(_from!)) {
                              lastDate = _from!;
                            }
                            if (_from != null && _from!.isAfter(firstDate)) {
                              firstDate = _from!;
                            }
                            if (firstDate.isAfter(lastDate)) {
                              firstDate = lastDate;
                            }
                            // اجعل التاريخ الابتدائي لنهاية الحجز عند أول تاريخ صالح داخل الفترة
                            final initialTo = firstDate;

                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initialTo,
                              firstDate: firstDate,
                              lastDate: lastDate,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.purple,
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
                  // معلومات التواريخ المتاحة
                  if (widget.requestData['availableFrom'] != null ||
                      widget.requestData['availableTo'] != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'التواريخ المتاحة: ${_formatAvailableDates()}',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_from != null && _to != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'المدة: ${_calculateBookingDays(_from!, _to!)} يوم',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Contact / Decision area
            if (!_showDecisionButtons) ...[
              // Check if dates are selected
              if (_from == null || _to == null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'يرجى اختيار فترة الحجز أولاً',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Show contact buttons only when dates are selected
                ElevatedButton.icon(
                  onPressed: () async {
                    final phone = await _resolvePhone();
                    if (phone == null || phone.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('رقم الهاتف غير متوفر')),
                      );
                      return;
                    }
                    // update booking dates before launching
                    try {
                      // Resolve owner from chalet doc if not provided
                      final resolved = await _resolveOwner();
                      final updated = Booking(
                        id: _bookingId,
                        chaletId: widget.chaletId,
                        chaletName: widget.chaletName,
                        ownerId: _normOwnerId(
                          resolved['ownerId'] ?? widget.ownerId,
                        ),
                        ownerName: resolved['ownerName'] ?? widget.ownerName,
                        userId: widget.userId,
                        userName: widget.userName,
                        from: _from!,
                        to: _to!,
                        status: BookingStatus.pending,
                      );
                      // replace the booking in cubit by a remove+add approach
                      try {
                        widget.parentContext.read<BookingCubit>().addBooking(
                          updated,
                        );
                        _saveToFirestore(updated);
                      } catch (_) {
                        context.read<BookingCubit>().addBooking(updated);
                      }
                    } catch (_) {}
                    setState(() => _launchedExternal = true);
                    await UriLauncherService.launchWhatsAppContact(
                      context: context,
                      phone: phone,
                      message:
                          'السلام عليكم، أريد حجز الشاليه للفترة من ${_from!.day}/${_from!.month}/${_from!.year} إلى ${_to!.day}/${_to!.month}/${_to!.year}',
                    );
                  },
                  icon: const Icon(Icons.message, color: Colors.white),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'فتح WhatsApp',
                      style: TextStyle(
                        color: ColorManager.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF25D366),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'الاتصال',
                      style: TextStyle(
                        color: ColorManager.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF1D4ED8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'بعد العودة سيظهر لك زري التأكيد/الرفض',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 8),
              ],
            ] else ...[
              // Decision big buttons stacked
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // User confirms the booking locally — create a pending
                      // booking and send it to the owner (owner will approve/decline).
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
                        to: _to ?? DateTime.now().add(const Duration(days: 1)),
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
                        const SnackBar(content: Text('تم إرسال الطلب للمالك')),
                      );
                      await _showRatingBottomSheet();
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'موافقة على الحجز',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      // User rejects—create a rejected record so user sees status
                      // immediately in UserBookingsPage.
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
                        to: _to ?? DateTime.now().add(const Duration(days: 1)),
                        status: BookingStatus.rejected,
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
                        const SnackBar(content: Text('تم رفض الطلب')),
                      );
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'رفض الحجز',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 8),
          ],
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

  Widget _buildBookingDateSelector(
    BuildContext context, {
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedDate != null
                ? Colors.blue.shade300
                : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selectedDate != null
                    ? Colors.blue.shade100
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: selectedDate != null
                    ? Colors.blue.shade600
                    : Colors.grey.shade600,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDate != null
                        ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                        : "اختر التاريخ",
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedDate != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: selectedDate != null
                  ? Colors.blue.shade600
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateBookingDays(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }

  String _formatAvailableDates() {
    final availableFrom = widget.requestData['availableFrom'];
    final availableTo = widget.requestData['availableTo'];

    if (availableFrom == null && availableTo == null) {
      return 'غير محدد';
    }

    try {
      String fromStr = '';
      String toStr = '';

      if (availableFrom != null) {
        final fromDate = DateTime.parse(availableFrom.toString());
        fromStr = '${fromDate.day}/${fromDate.month}/${fromDate.year}';
      }

      if (availableTo != null) {
        final toDate = DateTime.parse(availableTo.toString());
        toStr = '${toDate.day}/${toDate.month}/${toDate.year}';
      }

      if (fromStr.isNotEmpty && toStr.isNotEmpty) {
        return 'من $fromStr إلى $toStr';
      } else if (fromStr.isNotEmpty) {
        return 'من $fromStr';
      } else if (toStr.isNotEmpty) {
        return 'حتى $toStr';
      }

      return 'غير محدد';
    } catch (e) {
      return 'غير محدد';
    }
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
