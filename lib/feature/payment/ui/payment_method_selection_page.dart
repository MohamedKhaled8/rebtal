import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:rebtal/core/utils/format/currency.dart';

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
  // Stepper State
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Data State
  PaymentMethod? _selectedMethod;
  double _calculatedAmount = 0;
  bool _isLoadingPrice = false;

  // Proof Upload State
  bool _isSubmitting = false;
  final String _adminPhone = '201008422234';
  bool _whatsAppOpened = false;

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

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitConfirmation() async {
    setState(() => _isSubmitting = true);

    try {
      await context.read<BookingCubit>().uploadPaymentProof(
        bookingId: widget.booking.id,
        proofImageUrl: null,
        transactionNumber: 'SENT_VIA_WHATSAPP',
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.bookingConfirmationPage,
          (route) => false,
          arguments: widget.booking,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0A0E27)
        : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _prevStep,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'إتمام الحجز',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40), // Balance the back button
                ],
              ),
            ),

            // Stepper Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildStepperHeader(isDark),
            ),

            // Content Area
            Expanded(
              child: _isLoadingPrice
                  ? Center(
                      child: CircularProgressIndicator(
                        color: ColorManager.chaletAccent,
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _buildStepContent(isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader(bool isDark) {
    return Row(
      children: [
        _buildStepIndicator(0, 'طريقة الدفع', isDark),
        _buildStepConnector(0, isDark),
        _buildStepIndicator(1, 'التفاصيل', isDark),
        _buildStepConnector(1, isDark),
        _buildStepIndicator(2, 'التأكيد', isDark),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isDark) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      flex: 0,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? ColorManager.chaletAccent
                  : (isDark ? Colors.white10 : Colors.grey.shade300),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: ColorManager.chaletAccent.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: isActive
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Center(
                    child: Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark ? Colors.white38 : Colors.grey),
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step, bool isDark) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? ColorManager.chaletAccent
              : (isDark ? Colors.white10 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildPaymentMethodStep(isDark);
      case 1:
        return _buildPaymentInstructionsStep(isDark);
      case 2:
        return _buildProofUploadStep(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Step 1: Payment Method Selection ---
  Widget _buildPaymentMethodStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAmountSummaryCard(isDark),
          const SizedBox(height: 32),
          Text(
            'اختر طريقة الدفع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildMethodTile(
            isDark,
            PaymentMethod.bankTransfer,
            Icons.account_balance,
            'تحويل بنكي',
            'تحويل آمن عبر البنك',
          ),
          const SizedBox(height: 12),
          _buildMethodTile(
            isDark,
            PaymentMethod.vodafoneCash,
            Icons.phone_android,
            'فودافون كاش',
            'تحويل فوري عبر المحفظة',
          ),
          const SizedBox(height: 12),
          _buildMethodTile(
            isDark,
            PaymentMethod.instaPay,
            Icons.flash_on,
            'إنستاباي',
            'دفع فوري عبر تطبيق إنستاباي',
          ),
          const SizedBox(height: 12),
          _buildMethodTile(
            isDark,
            PaymentMethod.cashOnArrival,
            Icons.money,
            'دفع عند الوصول',
            'ادفع نقداً عند استلام الشاليه',
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _selectedMethod == null ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.chaletAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: isDark
                  ? Colors.white10
                  : Colors.grey.shade300,
            ),
            child: const Text(
              'متابعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSummaryCard(bool isDark) {
    final nights = widget.booking.to.difference(widget.booking.from).inDays;
    final displayNights = nights > 0 ? nights : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF1E2746), Color(0xFF161B30)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي المبلغ',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              Text(
                CurrencyFormatter.egp(_calculatedAmount),
                style: TextStyle(
                  color: ColorManager.chaletAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.white10 : Colors.grey.shade200),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.nights_stay_outlined,
                size: 20,
                color: isDark ? Colors.white60 : Colors.grey.shade500,
              ),
              const SizedBox(width: 8),
              Text(
                '$displayNights ليالي',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Text(
                widget.booking.chaletName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(
    bool isDark,
    PaymentMethod method,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected
                    ? ColorManager.chaletAccent.withOpacity(0.15)
                    : const Color(0xFF1E1E1E))
              : (isSelected
                    ? ColorManager.chaletAccent.withOpacity(0.08)
                    : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ColorManager.chaletAccent
                : (isDark ? Colors.white12 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorManager.chaletAccent
                    : (isDark ? Colors.white10 : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey.shade600),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorManager.chaletAccent,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  // --- Step 2: Instructions ---
  Widget _buildPaymentInstructionsStep(bool isDark) {
    final methodTitle = _selectedMethod == PaymentMethod.instaPay
        ? 'إنستاباي'
        : _selectedMethod == PaymentMethod.vodafoneCash
        ? 'فودافون كاش'
        : _selectedMethod == PaymentMethod.bankTransfer
        ? 'تحويل بنكي'
        : 'دفع عند الوصول';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ColorManager.chaletAccent, Color(0xFF00A896)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.chaletAccent.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'المبلغ المطلوب تحويله',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.egp(_calculatedAmount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    methodTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_selectedMethod == PaymentMethod.cashOnArrival) ...[
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: isDark ? Colors.white70 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا يتطلب تحويل مسبق',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك الدفع نقداً عند الوصول للمالك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
          ] else ...[
            Text(
              'تفاصيل التحويل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildCopyableField(
              isDark,
              'رقم التحويل',
              _adminPhone, // TODO: Fetch from config if needed
              Icons.copy,
            ),
          ],
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.chaletAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _selectedMethod == PaymentMethod.cashOnArrival
                  ? 'تأكيد الحجز'
                  : 'تم التحويل، متابعة',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableField(
    bool isDark,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم النسخ')));
            },
            icon: Icon(icon, color: ColorManager.chaletAccent),
          ),
        ],
      ),
    );
  }

  // --- Step 3: Proof Upload / Confirmation ---
  Widget _buildProofUploadStep(bool isDark) {
    if (_selectedMethod == PaymentMethod.cashOnArrival) {
      // Auto submit for cash on arrival or show simple button
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: ColorManager.chaletAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'تأكيد الحجز النهائي',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'اضغط أدناه لإنهاء الحجز.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.chaletAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'إنهاء',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.payment, size: 48, color: Colors.green),
                const SizedBox(height: 12),
                const Text(
                  'إرسال إيصال التحويل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يرجى إرسال صورة الإيصال عبر واتساب للمسؤول لتأكيد حجزك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() => _whatsAppOpened = true);
              await UriLauncherService.launchWhatsAppContact(
                context: context,
                phone: _adminPhone,
                message:
                    'مرحباً، لقد قمت بتحويل مبلغ ${CurrencyFormatter.egp(_calculatedAmount)} لحجز شاليه ${widget.booking.chaletName} رقم الحجز: ${widget.booking.id.substring(0, 8)}',
              );
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('فتح واتساب وإرسال الإيصال'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 48),
          if (_whatsAppOpened) ...[
            const Text(
              'هل قمت بالإرسال؟',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.chaletAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'نعم، تم الإرسال وإنهاء الحجز',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
