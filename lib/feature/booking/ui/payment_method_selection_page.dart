import 'package:flutter/material.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodSelectionPage extends StatefulWidget {
  final Booking booking;
  final double totalAmount;

  const PaymentMethodSelectionPage({
    super.key,
    required this.booking,
    required this.totalAmount,
  });

  @override
  State<PaymentMethodSelectionPage> createState() =>
      _PaymentMethodSelectionPageState();
}

class _PaymentMethodSelectionPageState
    extends State<PaymentMethodSelectionPage> {
  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _calculatedAmount = widget.totalAmount;
    if (_calculatedAmount == 0) {
      _fetchAndCalculatePrice();
    }
  }

  double _calculatedAmount = 0;
  bool _isLoadingPrice = false;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nights = widget.booking.to.difference(widget.booking.from).inDays;
    final displayNights = nights > 0 ? nights : 1;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E27)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'اختر طريقة الدفع',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoadingPrice
            ? Center(
                child: CircularProgressIndicator(
                  color: ColorManager.chaletAccent,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  ColorManager.chaletAccent.withOpacity(0.2),
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
                          color: ColorManager.chaletAccent.withOpacity(0.3),
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
                                  gradient: const LinearGradient(
                                    colors: [
                                      ColorManager.chaletAccent,
                                      Color(0xFF00A896),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.villa_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.booking.chaletName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$displayNights ليلة',
                                      style: TextStyle(
                                        fontSize: 14,
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
                          const SizedBox(height: 16),
                          Divider(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'المبلغ الإجمالي:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                '${_calculatedAmount.toStringAsFixed(0)} جنيه',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.chaletAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'اختر طريقة الدفع المناسبة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment Methods
                    _buildPaymentMethodCard(
                      context: context,
                      isDark: isDark,
                      method: PaymentMethod.bankTransfer,
                      icon: Icons.account_balance,
                      title: 'تحويل بنكي',
                      description: 'تحويل آمن عبر البنك',
                      features: [
                        'يتطلب 1-2 يوم عمل',
                        'رسوم: 0 جنيه',
                        'آمن ومضمون',
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildPaymentMethodCard(
                      context: context,
                      isDark: isDark,
                      method: PaymentMethod.vodafoneCash,
                      icon: Icons.phone_android,
                      title: 'فودافون كاش',
                      description: 'تحويل فوري عبر المحفظة',
                      features: ['تحويل فوري', 'رسوم: 0 جنيه', 'سهل وسريع'],
                    ),

                    const SizedBox(height: 12),

                    _buildPaymentMethodCard(
                      context: context,
                      isDark: isDark,
                      method: PaymentMethod.instaPay,
                      icon: Icons.flash_on,
                      title: 'إنستاباي',
                      description: 'دفع فوري عبر إنستاباي',
                      features: ['تحويل فوري', 'رسوم: 0 جنيه', 'آمن وسريع'],
                    ),

                    const SizedBox(height: 12),

                    _buildPaymentMethodCard(
                      context: context,
                      isDark: isDark,
                      method: PaymentMethod.cashOnArrival,
                      icon: Icons.money,
                      title: 'دفع عند الوصول',
                      description: 'ادفع نقداً عند الوصول',
                      features: [
                        'لا حاجة للتحويل',
                        'ادفع عند الاستلام',
                        'مرونة كاملة',
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedMethod == null
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.paymentInstructions,
                                  arguments: {
                                    'booking': widget.booking.copyWith(
                                      amount: _calculatedAmount,
                                    ),
                                    'paymentMethod': _selectedMethod,
                                    'amount': _calculatedAmount,
                                  },
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.chaletAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                        child: const Text(
                          'متابعة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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

  Widget _buildPaymentMethodCard({
    required BuildContext context,
    required bool isDark,
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected
                    ? ColorManager.chaletAccent.withOpacity(0.15)
                    : const Color(0xFF1E1E1E))
              : (isSelected
                    ? ColorManager.chaletAccent.withOpacity(0.1)
                    : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ColorManager.chaletAccent
                : (isDark ? Colors.white12 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorManager.chaletAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [ColorManager.chaletAccent, const Color(0xFF00A896)]
                          : [Colors.grey.shade400, Colors.grey.shade500],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? ColorManager.chaletAccent
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected
                        ? ColorManager.chaletAccent
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: isSelected
                          ? ColorManager.chaletAccent
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (method == PaymentMethod.cashOnArrival) ...[
              const SizedBox(height: 8),
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
                      size: 18,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم الدفع للأدمن عند الوصول',
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
      ),
    );
  }
}
