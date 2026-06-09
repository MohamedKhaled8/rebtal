import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/feature/payment/ui/new_payment_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPaymentMethodPage extends StatefulWidget {
  final Booking booking;
  final double totalAmount;

  const NewPaymentMethodPage({
    super.key,
    required this.booking,
    required this.totalAmount,
  });

  @override
  State<NewPaymentMethodPage> createState() => _NewPaymentMethodPageState();
}

class _NewPaymentMethodPageState extends State<NewPaymentMethodPage> {
  PaymentMethod? _selectedMethod;
  double _calculatedAmount = 0;
  bool _isLoadingPrice = false;

  @override
  void initState() {
    super.initState();
    _calculatedAmount = widget.totalAmount;
    if (_calculatedAmount == 0) {
      _fetchAndCalculatePrice();
    }
  }

  Future<void> _fetchAndCalculatePrice() async {
    setState(() => _isLoadingPrice = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('chalets')
          .doc(widget.booking.chaletId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final price = data['price'];
        final discountEnabled = data['discountEnabled'] == true;
        final discountValue =
            double.tryParse(data['discountValue']?.toString() ?? '0') ?? 0;

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
          final discountType = data['discountType'];
          if (discountType == 'percentage') {
            basePrice = basePrice * (1 - discountValue / 100);
          } else if (discountType == 'fixed') {
            basePrice = basePrice - discountValue;
          }
          if (basePrice < 0) basePrice = 0;
        }

        final duration = widget.booking.to
            .difference(widget.booking.from)
            .inDays;
        final nightsCount = duration > 0 ? duration : 1;
        final total = basePrice * nightsCount;

        if (mounted) {
          setState(() {
            _calculatedAmount = total;
          });
        }
      }
    } catch (e) {
      debugPrint('Error calculating price: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPrice = false);
      }
    }
  }

  void _proceedToPayment() {
    if (_selectedMethod == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewPaymentDetailsPage(
          booking: widget.booking,
          paymentMethod: _selectedMethod!,
          amount: _calculatedAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('payment_screen_title'),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingPrice
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary
                        _buildSummary(isDark),
                        const SizedBox(height: 32),

                        // Payment Methods
                        Text(
                          context.tr('payment_choose_method'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildPaymentOption(
                          isDark,
                          PaymentMethod.instaPay,
                          context.tr('payment_method_instapay'),
                          Icons.flash_on_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentOption(
                          isDark,
                          PaymentMethod.vodafoneCash,
                          context.tr('payment_method_vodafone_cash'),
                          Icons.phone_android_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentOption(
                          isDark,
                          PaymentMethod.bankTransfer,
                          context.tr('payment_method_bank'),
                          Icons.account_balance_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _selectedMethod != null
                            ? _proceedToPayment
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          context.tr('payment_continue'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummary(bool isDark) {
    final nights = widget.booking.to.difference(widget.booking.from).inDays;
    final displayNights = nights > 0 ? nights : 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.booking.chaletName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('payment_nights_label_short').replaceAll(
                  '{count}',
                  '$displayNights',
                ),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('booking_total'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '${_calculatedAmount.round()} ${context.tr('booking_egp_currency')}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    bool isDark,
    PaymentMethod method,
    String title,
    IconData icon,
  ) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF22C55E) : Colors.black)
                : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: isDark ? const Color(0xFF22C55E) : Colors.black,
                size: 24,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
