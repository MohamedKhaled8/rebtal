import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/payment/models/payment_proof.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/services/email_service.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';

class AdminPaymentsPage extends StatefulWidget {
  const AdminPaymentsPage({super.key});

  @override
  State<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends State<AdminPaymentsPage> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // Cache for booking data to avoid reloading all cards
  final Map<String, Booking> _bookingCache = {};

  @override
  void dispose() {
    _searchController.dispose();
    _bookingCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final isDark =
            state.themeMode == ThemeMode.dark ||
            (state.themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return Scaffold(
          backgroundColor: isDark
              ? ColorManager.darkBackground0F0F1E
              : ColorManager.bookingsBackgroundLight,
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
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeaderSection(isDark),
                        _buildEmptyState(isDark),
                      ],
                    ),
                  );
                }

                // Filter documents first
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final proof = PaymentProof.fromMap({
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  });

                  if (_selectedFilter != 'all') {
                    if (_selectedFilter == 'pending' &&
                        proof.status != PaymentProofStatus.pending) {
                      return false;
                    }
                    if (_selectedFilter == 'approved' &&
                        proof.status != PaymentProofStatus.approved) {
                      return false;
                    }
                    if (_selectedFilter == 'rejected' &&
                        proof.status != PaymentProofStatus.rejected) {
                      return false;
                    }
                  }
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    return proof.bookingId.toLowerCase().contains(query) ||
                        proof.id.toLowerCase().contains(query) ||
                        proof.userName.toLowerCase().contains(query);
                  }
                  return true;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeaderSection(isDark),
                        _buildNoResultsState(isDark),
                      ],
                    ),
                  );
                }

                // Full scrollable page
                return SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildHeaderSection(isDark),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          children: [
                            // Payment Cards List with individual StreamBuilders
                            ...filteredDocs.map((doc) {
                              return StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('payment_proofs')
                                    .doc(doc.id)
                                    .snapshots(),
                                builder: (context, docSnapshot) {
                                  if (!docSnapshot.hasData ||
                                      !docSnapshot.data!.exists) {
                                    return const SizedBox.shrink();
                                  }

                                  final data = docSnapshot.data!.data();
                                  if (data == null) {
                                    return const SizedBox.shrink();
                                  }

                                  final proof = PaymentProof.fromMap({
                                    ...data as Map<String, dynamic>,
                                    'id': docSnapshot.data!.id,
                                  });

                                  // Apply filters again in case status changed
                                  if (_selectedFilter != 'all') {
                                    if (_selectedFilter == 'pending' &&
                                        proof.status !=
                                            PaymentProofStatus.pending) {
                                      return const SizedBox.shrink();
                                    }
                                    if (_selectedFilter == 'approved' &&
                                        proof.status !=
                                            PaymentProofStatus.approved) {
                                      return const SizedBox.shrink();
                                    }
                                    if (_selectedFilter == 'rejected' &&
                                        proof.status !=
                                            PaymentProofStatus.rejected) {
                                      return const SizedBox.shrink();
                                    }
                                  }
                                  if (_searchQuery.isNotEmpty) {
                                    final query = _searchQuery.toLowerCase();
                                    if (!proof.bookingId.toLowerCase().contains(
                                          query,
                                        ) &&
                                        !proof.id.toLowerCase().contains(
                                          query,
                                        ) &&
                                        !proof.userName.toLowerCase().contains(
                                          query,
                                        )) {
                                      return const SizedBox.shrink();
                                    }
                                  }

                                  return _buildPaymentCard(
                                    context,
                                    proof,
                                    isDark,
                                  );
                                },
                              );
                            }),
                          ],
                        ),
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

  Widget _buildHeaderSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? ColorManager.darkBlue1A1A2E : ColorManager.white,
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title - Better spacing
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorManager.chaletAccent,
                      ColorManager.chaletAccent.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ColorManager.chaletAccent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: ColorManager.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة المدفوعات',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? ColorManager.white
                            : ColorManager.chaletTextPrimaryLight,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'مراجعة واعتماد طلبات الدفع',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? ColorManager.white70
                            : ColorManager.grey600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Search - Better design
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.black.withOpacity(isDark ? 0.15 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: isDark
                    ? ColorManager.white
                    : ColorManager.chaletTextPrimaryLight,
                fontSize: 16,
                height: 1.4,
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'بحث برقم الطلب أو اسم المستخدم...',
                hintStyle: TextStyle(
                  color: isDark ? ColorManager.white70 : ColorManager.grey700,
                  fontSize: 15,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search_rounded,
                    size: 24,
                    color: isDark ? ColorManager.white70 : ColorManager.grey600,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Material(
                          color: ColorManager.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Icon(
                              Icons.clear_rounded,
                              size: 20,
                              color: isDark
                                  ? ColorManager.white70
                                  : ColorManager.grey600,
                            ),
                          ),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? ColorManager.darkGrey252540
                    : ColorManager.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: isDark
                        ? ColorManager.white.withOpacity(0.1)
                        : ColorManager.grey200,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: isDark
                        ? ColorManager.white.withOpacity(0.1)
                        : ColorManager.grey200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: ColorManager.chaletAccent,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Filters - Better spacing
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
                  Icons.access_time_rounded,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  'مؤكد',
                  'approved',
                  Icons.check_circle_outline_rounded,
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
        ],
      ),
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
            ? ColorManager.white
            : (isDark ? ColorManager.white70 : ColorManager.grey600),
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
      backgroundColor: isDark
          ? ColorManager.darkBlue1A1A2E
          : ColorManager.white,
      selectedColor: activeColor,
      labelStyle: TextStyle(
        color: isSelected
            ? ColorManager.white
            : (isDark
                  ? ColorManager.white70
                  : ColorManager.chaletTextPrimaryLight),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // Fully rounded pill shape
      ),
      side: BorderSide(
        color: isSelected
            ? ColorManager.transparent
            : (isDark ? ColorManager.white10 : ColorManager.grey300),
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
                  ? ColorManager.white.withOpacity(0.05)
                  : ColorManager.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.payment, size: 80, color: ColorManager.grey400),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد طلبات دفع',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorManager.grey600,
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
                  ? ColorManager.white.withOpacity(0.05)
                  : ColorManager.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 80,
              color: ColorManager.grey400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorManager.grey600,
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
    // Use StreamBuilder with cache to avoid reloading all cards
    Booking? cachedBooking = _bookingCache[proof.bookingId];

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .doc(proof.bookingId)
          .snapshots(),
      builder: (context, snapshot) {
        // Use cached data if available while loading
        if (snapshot.connectionState == ConnectionState.waiting &&
            cachedBooking != null) {
          return _buildCardContent(context, proof, cachedBooking, isDark);
        }

        // Show loading only if no cached data
        if (snapshot.connectionState == ConnectionState.waiting &&
            cachedBooking == null) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? ColorManager.darkBlue1A1A2E : ColorManager.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: ColorManager.chaletAccent,
              ),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Try to use cached data if available
          if (cachedBooking != null) {
            return _buildCardContent(context, proof, cachedBooking, isDark);
          }
          return const SizedBox.shrink();
        }

        // Parse booking from snapshot
        final data = snapshot.data!.data();
        if (data == null) {
          if (cachedBooking != null) {
            return _buildCardContent(context, proof, cachedBooking, isDark);
          }
          return const SizedBox.shrink();
        }

        final booking = _parseBookingFromData(
          snapshot.data!.id,
          data as Map<String, dynamic>,
        );

        if (booking == null) {
          if (cachedBooking != null) {
            return _buildCardContent(context, proof, cachedBooking, isDark);
          }
          return const SizedBox.shrink();
        }

        // Update cache
        _bookingCache[proof.bookingId] = booking;

        return _buildCardContent(context, proof, booking, isDark);
      },
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    PaymentProof proof,
    Booking booking,
    bool isDark,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final nights = booking.to.difference(booking.from).inDays + 1;

    // Use ONLY the first 8 characters for display (The "Order Number")
    final shortId = proof.bookingId.length > 8
        ? proof.bookingId.substring(0, 8).toUpperCase()
        : proof.bookingId.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: isDark ? ColorManager.darkBlue1A1A2E : ColorManager.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? ColorManager.white.withOpacity(0.12)
              : ColorManager.grey200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Order ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 16,
                              color: isDark
                                  ? ColorManager.white70
                                  : ColorManager.grey600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'رقم الطلب',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? ColorManager.white70
                                    : ColorManager.grey600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ColorManager.chaletAccent.withOpacity(
                                        0.15,
                                      ),
                                      ColorManager.chaletAccent.withOpacity(
                                        0.08,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: ColorManager.chaletAccent
                                        .withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '#$shortId',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: ColorManager.chaletAccent,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: ColorManager.transparent,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: shortId),
                                  );
                                  SnackBarHelper.showSuccess(
                                    context,
                                    'تم نسخ رقم الطلب',
                                    icon: Icons.copy_rounded,
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? ColorManager.white.withOpacity(0.1)
                                        : ColorManager.grey100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.copy_rounded,
                                    size: 18,
                                    color: isDark
                                        ? ColorManager.white70
                                        : ColorManager.grey700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(proof.status),
                ],
              ),

              const SizedBox(height: 24),
              Divider(
                height: 1,
                thickness: 1.5,
                color: isDark
                    ? ColorManager.white.withOpacity(0.12)
                    : ColorManager.grey300,
              ),
              const SizedBox(height: 24),

              // Chalet Name
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.chaletName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? ColorManager.white
                                : ColorManager.chaletTextPrimaryLight,
                            height: 1.3,
                          ),
                        ),
                        if (booking.chaletLocation != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: isDark
                                    ? ColorManager.white70
                                    : ColorManager.grey600,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  booking.chaletLocation!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? ColorManager.white70
                                        : ColorManager.grey700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: isDark
                                  ? ColorManager.white70
                                  : ColorManager.grey600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeAgo(proof.uploadedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? ColorManager.white70
                                    : ColorManager.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Booking Details - كل البيانات في سطور واضحة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? ColorManager.darkGrey2A2A3E
                      : ColorManager.grey50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? ColorManager.white.withOpacity(0.15)
                        : ColorManager.grey200,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الوصول
                    _buildDetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'تاريخ الوصول',
                      value: dateFormat.format(booking.from),
                      color: ColorManager.primaryColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    // المغادرة
                    _buildDetailRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'تاريخ المغادرة',
                      value: dateFormat.format(booking.to),
                      color: ColorManager.red,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    // المدة
                    _buildDetailRow(
                      icon: Icons.nights_stay_rounded,
                      label: 'المدة',
                      value: '$nights ليالي',
                      color: ColorManager.purple,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    // المبلغ
                    _buildDetailRow(
                      icon: Icons.monetization_on_rounded,
                      label: 'المبلغ الإجمالي',
                      value: '${booking.amount?.toInt() ?? 0} جنيه',
                      color: ColorManager.green,
                      isDark: isDark,
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact Info - كل البيانات في سطور واضحة
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات الضيف
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? ColorManager.green.withOpacity(0.15)
                          : ColorManager.chaletAvailableLightGreen,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? ColorManager.green.withOpacity(0.4)
                            : ColorManager.green.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'معلومات الضيف',
                          Icons.person_rounded,
                          ColorManager.green,
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildContactRowFull(
                          icon: Icons.person_outline_rounded,
                          label: 'الاسم',
                          value: booking.userName ?? 'غير متوفر',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildContactRowFull(
                          icon: Icons.phone_iphone_rounded,
                          label: 'رقم الهاتف',
                          value: booking.userPhone ?? 'غير متوفر',
                          isDark: isDark,
                        ),
                        if (booking.userEmail != null &&
                            booking.userEmail!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildContactRowFull(
                            icon: Icons.email_rounded,
                            label: 'البريد الإلكتروني',
                            value: booking.userEmail!,
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // معلومات المالك
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? ColorManager.orange.withOpacity(0.15)
                          : ColorManager.grey50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? ColorManager.orange.withOpacity(0.4)
                            : ColorManager.orange.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'معلومات المالك',
                          Icons.business_rounded,
                          ColorManager.orange,
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildContactRowFull(
                          icon: Icons.person_outline_rounded,
                          label: 'الاسم',
                          value: booking.ownerName ?? 'غير متوفر',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildContactRowFull(
                          icon: Icons.phone_iphone_rounded,
                          label: 'رقم الهاتف',
                          value: booking.ownerPhone ?? 'غير متوفر',
                          isDark: isDark,
                        ),
                        if (booking.ownerEmail != null &&
                            booking.ownerEmail!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildContactRowFull(
                            icon: Icons.email_rounded,
                            label: 'البريد الإلكتروني',
                            value: booking.ownerEmail!,
                            isDark: isDark,
                          ),
                        ],
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
                        icon: const Icon(Icons.image_rounded, size: 20),
                        label: const Text(
                          'عرض الإيصال',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: isDark
                                ? ColorManager.white.withOpacity(0.25)
                                : ColorManager.grey300,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  if (proof.imageUrl != null) const SizedBox(width: 14),
                  if (proof.status == PaymentProofStatus.pending)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showReviewDialog(context, proof, booking);
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                        label: const Text(
                          'مراجعة',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.green,
                          foregroundColor: ColorManager.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                  color: isDark ? ColorManager.white70 : ColorManager.grey600,
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
    if (isDark) return ColorManager.white;
    return ColorManager.chaletTextPrimaryLight;
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
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
          Icon(icon, size: 14, color: ColorManager.grey700),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value ?? 'غير متوفر',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? ColorManager.white70
                    : ColorManager.chaletTextPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Detail Row - كل البيانات في سطر واضح
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? ColorManager.white70 : ColorManager.grey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: isDark
                      ? ColorManager.white
                      : ColorManager.chaletTextPrimaryLight,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Contact Row Full - كل البيانات باينة كاملة
  Widget _buildContactRowFull({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ColorManager.grey600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? ColorManager.white70 : ColorManager.grey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? ColorManager.white
                      : ColorManager.chaletTextPrimaryLight,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(PaymentProofStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case PaymentProofStatus.pending:
        color = ColorManager.orange;
        text = 'قيد المراجعة';
        icon = Icons.access_time_rounded;
        break;
      case PaymentProofStatus.approved:
        color = ColorManager.green;
        text = 'مؤكد';
        icon = Icons.check_circle_rounded;
        break;
      case PaymentProofStatus.rejected:
        color = ColorManager.red;
        text = 'مرفوض';
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
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

  // Parse booking from Firestore data (used by StreamBuilder)
  Booking? _parseBookingFromData(String docId, Map<String, dynamic> data) {
    try {
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

      DateTime? parseDateField(dynamic value) {
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

      return Booking(
        id: docId,
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
        userPhone: data['userPhone'] as String?,
        userEmail: data['userEmail'] as String?,
        ownerPhone: data['ownerPhone'] as String?,
        ownerEmail: data['ownerEmail'] as String?,
        chaletLocation: data['chaletLocation'] as String?,
        adminPaymentNotes: data['adminPaymentNotes'] as String?,
        paymentRejected: data['paymentRejected'] as bool? ?? false,
        paymentRejectedAt: parseDateField(data['paymentRejectedAt']),
      );
    } catch (e) {
      debugPrint('Error parsing booking: $e');
      return null;
    }
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
        backgroundColor: ColorManager.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AppImageHelper(path: imageUrl, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.white,
                foregroundColor: ColorManager.chaletTextPrimaryLight,
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
              _rejectPayment(proof.id, notesController.text, booking);
            },
            child: const Text('رفض', style: TextStyle(color: ColorManager.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approvePayment(proof.id, booking, notesController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.green,
            ),
            child: const Text('موافقة'),
          ),
        ],
      ),
    );
  }

  Future<void> _approvePayment(
    String proofId,
    Booking booking,
    String notes,
  ) async {
    try {
      // Show loading indicator
      if (mounted) {
        SnackBarHelper.showInfo(context, 'جاري معالجة الطلب...');
      }

      // Update payment proof status
      await FirebaseFirestore.instance
          .collection('payment_proofs')
          .doc(proofId)
          .update({
            'status': 'approved',
            'reviewedAt': FieldValue.serverTimestamp(),
            'adminNotes': notes,
          });

      // Update booking status
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking.id)
          .update({
            'status': 'confirmed',
            'adminConfirmedPaymentAt': FieldValue.serverTimestamp(),
            'adminPaymentNotes': notes,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update cache
      if (_bookingCache.containsKey(booking.id)) {
        _bookingCache[booking.id] = booking.copyWith(
          status: BookingStatus.confirmed,
          adminConfirmedPaymentAt: DateTime.now(),
          adminPaymentNotes: notes,
        );
      }

      // Send Confirmation Email
      await EmailService().sendBookingConfirmationEmail(booking);

      // Send notification to user
      try {
        await NotificationService().sendNotification(
          userId: booking.userId,
          title: 'تم تأكيد الدفع بنجاح! 🎉',
          body:
              'تم تأكيد دفعتك لحجزك في ${booking.chaletName}. نتمنى لك إقامة سعيدة!',
          type: NotificationType.paymentConfirmed,
          relatedId: booking.id,
          data: {'bookingId': booking.id, 'chaletName': booking.chaletName},
        );
        debugPrint('✅ Notification sent to user: ${booking.userId}');
      } catch (notificationError) {
        debugPrint(
          '⚠️ Error sending notification (non-critical): $notificationError',
        );
        // Don't fail the whole operation if notification fails
      }

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          'تمت الموافقة بنجاح وإرسال الإشعار للمستخدم',
          icon: Icons.check_circle_rounded,
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        SnackBarHelper.showError(context, 'حدث خطأ أثناء الموافقة: $e');
      }
    }
  }

  Future<void> _rejectPayment(
    String proofId,
    String reason,
    Booking? booking,
  ) async {
    try {
      // Show loading indicator
      if (mounted) {
        SnackBarHelper.showInfo(context, 'جاري معالجة الطلب...');
      }

      // Update payment proof status
      await FirebaseFirestore.instance
          .collection('payment_proofs')
          .doc(proofId)
          .update({
            'status': 'rejected',
            'reviewedAt': FieldValue.serverTimestamp(),
            'adminNotes': reason,
          });

      // If booking is available, update it and send notification
      if (booking != null) {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(booking.id)
            .update({
              'status': BookingStatus.awaitingPayment.name,
              'adminPaymentNotes': reason,
              'paymentRejected': true, // Mark as payment rejected
              'paymentRejectedAt': FieldValue.serverTimestamp(),
              'paymentProofUrl': null,
              'paymentProofUploadedAt': null,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        // Update cache
        if (_bookingCache.containsKey(booking.id)) {
          _bookingCache[booking.id] = booking.copyWith(
            status: BookingStatus.awaitingPayment,
            adminPaymentNotes: reason,
            paymentProofUrl: null,
            paymentProofUploadedAt: null,
          );
        }

        // Send notification to user
        try {
          await NotificationService().sendNotification(
            userId: booking.userId,
            title: 'تم رفض إثبات الدفع ❌',
            body:
                'عذراً، تم رفض إثبات الدفع لحجزك في ${booking.chaletName}. يرجى إعادة رفع إثبات الدفع الصحيح.',
            type: NotificationType.bookingRejected,
            relatedId: booking.id,
            data: {
              'bookingId': booking.id,
              'chaletName': booking.chaletName,
              'reason': reason,
            },
          );
          debugPrint(
            '✅ Rejection notification sent to user: ${booking.userId}',
          );
        } catch (notificationError) {
          debugPrint(
            '⚠️ Error sending rejection notification (non-critical): $notificationError',
          );
        }
      }

      if (mounted) {
        SnackBarHelper.showWarning(
          context,
          'تم الرفض وإرسال الإشعار للمستخدم',
          icon: Icons.cancel_rounded,
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        SnackBarHelper.showError(context, 'حدث خطأ أثناء الرفض: $e');
      }
    }
  }
}
