import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/payment_proof.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';

class AdminPaymentsPage extends StatefulWidget {
  const AdminPaymentsPage({super.key});

  @override
  State<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends State<AdminPaymentsPage> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark =
            themeState.themeMode == ThemeMode.dark ||
            (themeState.themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0F0F1E)
              : const Color(0xFFF8F9FA),
          body: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('payment_proofs')
                  .orderBy('uploadedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.chaletAccent,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                final proofs = snapshot.data!.docs
                    .map(
                      (doc) => PaymentProof.fromMap({
                        ...doc.data() as Map<String, dynamic>,
                        'id': doc.id,
                      }),
                    )
                    .where((proof) {
                      if (_selectedFilter != 'all') {
                        if (_selectedFilter == 'pending' &&
                            proof.status != PaymentProofStatus.pending)
                          return false;
                        if (_selectedFilter == 'approved' &&
                            proof.status != PaymentProofStatus.approved)
                          return false;
                        if (_selectedFilter == 'rejected' &&
                            proof.status != PaymentProofStatus.rejected)
                          return false;
                      }
                      if (_searchQuery.isNotEmpty) {
                        final query = _searchQuery.toLowerCase();
                        return proof.bookingId.toLowerCase().contains(query) ||
                            proof.id.toLowerCase().contains(query) ||
                            proof.userName.toLowerCase().contains(query);
                      }
                      return true;
                    })
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ColorManager.chaletAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.payment,
                              color: ColorManager.chaletAccent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'إدارة المدفوعات',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Search
                      TextField(
                        controller: _searchController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'بحث برقم الطلب (مثال: 1A2B3C4D)...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade500,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 24,
                            color: isDark
                                ? Colors.white54
                                : Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1A1A2E)
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Filters (Enhanced with Icons & Toggle Logic)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'الكل',
                              'all',
                              Icons.dashboard_outlined,
                              isDark,
                            ),
                            const SizedBox(width: 12),
                            _buildFilterChip(
                              'قيد المراجعة',
                              'pending',
                              Icons.access_time,
                              isDark,
                            ),
                            const SizedBox(width: 12),
                            _buildFilterChip(
                              'مؤكد',
                              'approved',
                              Icons.check_circle_outline,
                              isDark,
                            ),
                            const SizedBox(width: 12),
                            _buildFilterChip(
                              'مرفوض',
                              'rejected',
                              Icons.cancel_outlined,
                              isDark,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Payment Cards
                      if (proofs.isEmpty)
                        _buildNoResultsState(isDark)
                      else
                        ...proofs.map(
                          (proof) => _buildPaymentCard(context, proof, isDark),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _selectedFilter == value;
    final activeColor = ColorManager.chaletAccent;

    return ChoiceChip(
      showCheckmark: false, // Cleaner look without the tick
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white54 : Colors.grey.shade600),
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          // Intelligent Toggle Logic:
          // If clicking "All" -> Select "All"
          // If clicking current active filter (that isn't "All") -> Toggle it off (go back to "All")
          // If clicking a new filter -> Select new filter
          if (value == 'all') {
            _selectedFilter = 'all';
          } else if (isSelected) {
            _selectedFilter = 'all'; // Toggle off
          } else {
            _selectedFilter = value;
          }
        });
      },
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      selectedColor: activeColor,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // Fully rounded pill shape
      ),
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : (isDark ? Colors.white12 : Colors.grey.shade300),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.payment, size: 80, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد طلبات دفع',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    PaymentProof proof,
    bool isDark,
  ) {
    return FutureBuilder<Booking?>(
      future: _fetchBooking(proof.bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) return const SizedBox.shrink();

        final booking = snapshot.data!;
        final dateFormat = DateFormat('dd/MM/yyyy');
        final nights = booking.to.difference(booking.from).inDays + 1;

        // Use ONLY the first 8 characters for display (The "Order Number")
        final shortId = proof.bookingId.length > 8
            ? proof.bookingId.substring(0, 8).toUpperCase()
            : proof.bookingId.toUpperCase();

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Order ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم الطلب',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ColorManager.chaletAccent.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ColorManager.chaletAccent.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: SelectableText(
                                '#$shortId',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.chaletAccent,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: shortId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم نسخ رقم الطلب',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.copy,
                                  size: 20,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(proof.status),
                ],
              ),

              Divider(
                height: 32,
                color: isDark ? Colors.white10 : Colors.grey.shade300,
              ),

              // Chalet Name
              Text(
                booking.chaletName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                _getTimeAgo(proof.uploadedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              // Booking Details Grid (Arranged Icons)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252540) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildArrangedIconItem(
                            icon: Icons.calendar_today,
                            label: 'الوصول',
                            value: dateFormat.format(booking.from),
                            color: Colors.blue,
                            isDark: isDark,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Expanded(
                          child: _buildArrangedIconItem(
                            icon: Icons.calendar_month,
                            label: 'المغادرة',
                            value: dateFormat.format(booking.to),
                            color: Colors.redAccent,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildArrangedIconItem(
                            icon: Icons.nights_stay,
                            label: 'المدة',
                            value: '$nights ليالي',
                            color: Colors.purple,
                            isDark: isDark,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Expanded(
                          child: _buildArrangedIconItem(
                            icon: Icons.monetization_on,
                            label: 'المبلغ الإجمالي',
                            value: '${booking.amount?.toInt() ?? 0} جنيه',
                            color: Colors.green,
                            isDark: isDark,
                            isBold: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact Info (Arranged)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'معلومات الضيف',
                          Icons.person,
                          Colors.green,
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildContactRow(
                          Icons.person_outline,
                          booking.userName,
                          isDark,
                        ),
                        _buildContactRow(
                          Icons.phone_iphone,
                          booking.userPhone,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'معلومات المالك',
                          Icons.business,
                          Colors.orange,
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildContactRow(
                          Icons.person_outline,
                          booking.ownerName,
                          isDark,
                        ),
                        _buildContactRow(
                          Icons.phone_iphone,
                          booking.ownerPhone,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  if (proof.imageUrl != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showProofImage(context, proof.imageUrl!),
                        icon: const Icon(Icons.image, size: 20),
                        label: const Text(
                          'عرض الإيصال',
                          style: TextStyle(fontSize: 15),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (proof.imageUrl != null) const SizedBox(width: 12),
                  if (proof.status == PaymentProofStatus.pending)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showReviewDialog(context, proof, booking),
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: const Text(
                          'مراجعة',
                          style: TextStyle(fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArrangedIconItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: isButtonActive(
                    color,
                    isDark,
                  ), // Custom helper for text color
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color isButtonActive(Color baseColor, bool isDark) {
    if (isDark) return Colors.white;
    return Colors.black87;
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String? value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value ?? 'غير متوفر',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentProofStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case PaymentProofStatus.pending:
        color = Colors.orange;
        text = 'قيد المراجعة';
        icon = Icons.access_time;
        break;
      case PaymentProofStatus.approved:
        color = Colors.green;
        text = 'مؤكد';
        icon = Icons.check_circle;
        break;
      case PaymentProofStatus.rejected:
        color = Colors.red;
        text = 'مرفوض';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) return 'منذ ${difference.inDays} يوم';
    if (difference.inHours > 0) return 'منذ ${difference.inHours} ساعة';
    if (difference.inMinutes > 0) return 'منذ ${difference.inMinutes} دقيقة';
    return 'الآن';
  }

  Future<Booking?> _fetchBooking(String bookingId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;

      DateTime? parseDate(dynamic value) {
        if (value == null) return null;
        if (value is Timestamp) return value.toDate();
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            return null;
          }
        }
        return null;
      }

      final fromDate = parseDate(data['from']) ?? DateTime.now();
      final toDate = parseDate(data['to']) ?? DateTime.now();

      String? userPhone = data['userPhone'] as String?;
      String? userEmail = data['userEmail'] as String?;

      if ((userPhone == null || userEmail == null) && data['userId'] != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(data['userId'])
              .get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            userPhone ??= userData?['phone'] ?? userData?['phoneNumber'];
            userEmail ??= userData?['email'];
          }
        } catch (e) {
          debugPrint('Error: $e');
        }
      }

      String? ownerPhone = data['ownerPhone'] as String?;
      String? ownerEmail = data['ownerEmail'] as String?;

      if ((ownerPhone == null || ownerEmail == null) &&
          data['ownerId'] != null) {
        try {
          final ownerDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(data['ownerId'])
              .get();
          if (ownerDoc.exists) {
            final ownerData = ownerDoc.data();
            ownerPhone ??= ownerData?['phone'] ?? ownerData?['phoneNumber'];
            ownerEmail ??= ownerData?['email'];
          }
        } catch (e) {
          debugPrint('Error: $e');
        }
      }

      return Booking(
        id: doc.id,
        chaletId: data['chaletId'] ?? '',
        chaletName: data['chaletName'] ?? 'شاليه',
        ownerId: data['ownerId'] ?? '',
        ownerName: data['ownerName'] ?? 'غير معروف',
        userId: data['userId'] ?? '',
        userName: data['userName'] ?? 'غير معروف',
        from: fromDate,
        to: toDate,
        status: _parseStatus(data['status']),
        amount: (data['amount'] as num?)?.toDouble() ?? 0,
        userPhone: userPhone,
        userEmail: userEmail,
        ownerPhone: ownerPhone,
        ownerEmail: ownerEmail,
        chaletLocation: data['chaletLocation'] as String?,
      );
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  BookingStatus _parseStatus(dynamic status) {
    if (status == null) return BookingStatus.pending;
    final statusStr = status.toString().toLowerCase();

    switch (statusStr) {
      case 'pending':
        return BookingStatus.pending;
      case 'approved':
        return BookingStatus.approved;
      case 'awaitingpayment':
        return BookingStatus.awaitingPayment;
      case 'paymentunderreview':
        return BookingStatus.paymentUnderReview;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'rejected':
        return BookingStatus.rejected;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  void _showProofImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(
    BuildContext context,
    PaymentProof proof,
    Booking booking,
  ) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مراجعة الدفع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل تريد الموافقة على هذا الدفع أم رفضه؟'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectPayment(proof.id, notesController.text);
            },
            child: const Text('رفض', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approvePayment(proof.id, proof.bookingId, notesController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('موافقة'),
          ),
        ],
      ),
    );
  }

  Future<void> _approvePayment(
    String proofId,
    String bookingId,
    String notes,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('payment_proofs')
          .doc(proofId)
          .update({
            'status': 'approved',
            'reviewedAt': FieldValue.serverTimestamp(),
            'adminNotes': notes,
          });

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': 'confirmed',
            'adminConfirmedPaymentAt': FieldValue.serverTimestamp(),
            'adminPaymentNotes': notes,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت الموافقة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _rejectPayment(String proofId, String reason) async {
    try {
      await FirebaseFirestore.instance
          .collection('payment_proofs')
          .doc(proofId)
          .update({
            'status': 'rejected',
            'reviewedAt': FieldValue.serverTimestamp(),
            'adminNotes': reason,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الرفض'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
