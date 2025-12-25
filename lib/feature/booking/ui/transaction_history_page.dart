import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';

class TransactionHistoryPage extends StatefulWidget {
  final String userId;
  final bool isOwner;

  const TransactionHistoryPage({
    super.key,
    required this.userId,
    this.isOwner = false,
  });

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String _selectedFilter = 'all';
  double _totalEarnings = 0;
  double _totalSpent = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E27)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isOwner ? 'تقرير الإيرادات' : 'سجل المعاملات',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      isDark,
                      widget.isOwner ? 'إجمالي الإيرادات' : 'إجمالي المصروفات',
                      widget.isOwner ? _totalEarnings : _totalSpent,
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      isDark,
                      'عدد المعاملات',
                      0,
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('الكل', 'all', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('مؤكد', 'confirmed', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('مكتمل', 'completed', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('ملغي', 'cancelled', isDark),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Transactions List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where(
                      widget.isOwner ? 'ownerId' : 'userId',
                      isEqualTo: widget.userId,
                    )
                    .where(
                      'status',
                      whereIn: ['confirmed', 'completed', 'cancelled'],
                    )
                    .orderBy('updatedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('خطأ: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد معاملات',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final bookings = snapshot.data!.docs
                      .map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        data['id'] = doc.id;
                        return Booking.fromJson(data);
                      })
                      .whereType<Booking>()
                      .where((booking) {
                        if (_selectedFilter == 'all') return true;
                        if (_selectedFilter == 'confirmed') {
                          return booking.status == BookingStatus.confirmed;
                        }
                        if (_selectedFilter == 'completed') {
                          return booking.status == BookingStatus.completed;
                        }
                        if (_selectedFilter == 'cancelled') {
                          return booking.status == BookingStatus.cancelled;
                        }
                        return true;
                      })
                      .toList();

                  // Calculate totals
                  _calculateTotals(bookings);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(
                        context,
                        bookings[index],
                        isDark,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateTotals(List<Booking> bookings) {
    double earnings = 0;
    double spent = 0;

    for (var booking in bookings) {
      if (booking.status == BookingStatus.completed ||
          booking.status == BookingStatus.confirmed) {
        final amount = booking.amount ?? 0;
        if (widget.isOwner) {
          earnings += amount;
        } else {
          spent += amount;
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _totalEarnings = earnings;
          _totalSpent = spent;
        });
      }
    });
  }

  Widget _buildSummaryCard(
    bool isDark,
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color is MaterialColor ? color.shade600 : color,
            color is MaterialColor ? color.shade700 : color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(0)} جنيه',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      selectedColor: ColorManager.chaletAccent.withOpacity(0.2),
      checkmarkColor: ColorManager.chaletAccent,
      labelStyle: TextStyle(
        color: isSelected
            ? ColorManager.chaletAccent
            : (isDark ? Colors.white70 : Colors.grey.shade700),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? ColorManager.chaletAccent
            : (isDark ? Colors.white12 : Colors.grey.shade300),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Booking booking,
    bool isDark,
  ) {
    final isRefund =
        booking.status == BookingStatus.cancelled &&
        booking.refundAmount != null &&
        booking.refundAmount! > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
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
                  color: _getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(booking.status),
                  color: _getStatusColor(booking.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.chaletName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(booking.from),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isRefund
                        ? '+${booking.refundAmount!.toStringAsFixed(0)}'
                        : (widget.isOwner ? '+' : '-') +
                              (booking.amount?.toStringAsFixed(0) ?? '0'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isRefund
                          ? Colors.green.shade600
                          : (widget.isOwner
                                ? Colors.green.shade600
                                : Colors.red.shade600),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'جنيه',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: isDark ? Colors.white12 : Colors.grey.shade300),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildInfoChip(
                _getStatusText(booking.status),
                _getStatusColor(booking.status),
                isDark,
              ),
              const SizedBox(width: 8),
              if (booking.paymentMethod != null)
                _buildInfoChip(
                  _getPaymentMethodText(booking.paymentMethod!),
                  Colors.blue.shade600,
                  isDark,
                ),
            ],
          ),

          if (isRefund) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تم استرداد ${booking.refundAmount!.toStringAsFixed(0)} جنيه',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green.shade600;
      case BookingStatus.completed:
        return Colors.blue.shade600;
      case BookingStatus.cancelled:
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.verified;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.cancelled:
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case PaymentMethod.vodafoneCash:
        return 'فودافون كاش';
      case PaymentMethod.instaPay:
        return 'إنستاباي';
      case PaymentMethod.cashOnArrival:
        return 'دفع عند الوصول';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
