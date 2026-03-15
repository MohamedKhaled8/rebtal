import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';

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
      await context.read<AppCubit>().bookingCubit.uploadPaymentProof(
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
        SnackBarHelper.showError(context, 'حدث خطأ: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? ColorsManager.darkBackground0A0E27
        : ColorsManager.lightBackgroundF5F7FA;

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
                      color: isDark
                          ? ColorsManager.white
                          : ColorsManager.chaletTextPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'إتمام الحجز',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? ColorsManager.white
                          : ColorsManager.chaletTextPrimaryLight,
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
                        color: ColorsManager.chaletAccent,
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0.3, 0.0),
                          end: Offset.zero,
                        ).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(_currentStep),
                        child: _buildStepContent(isDark),
                      ),
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
                  ? ColorsManager.chaletAccent
                  : (isDark ? ColorsManager.white10 : ColorsManager.grey300),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: ColorsManager.chaletAccent.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: isActive
                ? const Icon(Icons.check, size: 18, color: ColorsManager.white)
                : Center(
                    child: Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isDark
                            ? ColorsManager.white70
                            : ColorsManager.grey600,
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
                  ? (isDark
                        ? ColorsManager.white
                        : ColorsManager.chaletTextPrimaryLight)
                  : (isDark ? ColorsManager.white70 : ColorsManager.grey),
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
              ? ColorsManager.chaletAccent
              : (isDark ? ColorsManager.white10 : ColorsManager.grey300),
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
              color: isDark
                  ? ColorsManager.white
                  : ColorsManager.chaletTextPrimaryLight,
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
              backgroundColor: ColorsManager.chaletAccent,
              foregroundColor: ColorsManager.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: isDark
                  ? ColorsManager.white10
                  : ColorsManager.grey300,
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
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.chaletAccent.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Background Pattern/Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            ColorsManager.darkBlue2A2E4B,
                            ColorsManager.darkBlue161B30,
                          ]
                        : [
                            ColorsManager.chaletIconBackgroundLight,
                            ColorsManager.white,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Subtle accent circle
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorsManager.chaletAccent.withOpacity(0.05),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorsManager.chaletAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: ColorsManager.chaletAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'ملخص الدفع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? ColorsManager.white70
                              : ColorsManager.grey600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Total Amount with Label
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'إجمالي المبلغ المستحق',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? ColorsManager.white70
                              : ColorsManager.grey600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: _calculatedAmount),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutExpo,
                        builder: (context, value, child) {
                          return Text(
                            CurrencyFormatter.egp(context, value),
                            style: TextStyle(
                              color: isDark
                                  ? ColorsManager.white
                                  : ColorsManager.chaletAccent,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Detail Row ( frosted style )
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? ColorsManager.white.withOpacity(0.05)
                          : ColorsManager.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? ColorsManager.white10
                            : ColorsManager.black.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          isDark,
                          Icons.nights_stay_rounded,
                          '$displayNights ليالي',
                          'مدة الإقامة',
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: isDark
                              ? ColorsManager.white10
                              : ColorsManager.grey300,
                        ),
                        _buildSummaryItem(
                          isDark,
                          Icons.home_work_rounded,
                          widget.booking.chaletName,
                          'الشاليه',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    bool isDark,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: ColorsManager.chaletAccent),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark
                    ? ColorsManager.white
                    : ColorsManager.chaletTextPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? ColorsManager.white70 : ColorsManager.grey700,
          ),
        ),
      ],
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
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedMethod = method);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected
                    ? ColorsManager.chaletAccent.withOpacity(0.12)
                    : ColorsManager.darkBlue1E2235)
              : (isSelected
                    ? ColorsManager.chaletAccent.withOpacity(0.06)
                    : ColorsManager.white),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? ColorsManager.chaletAccent
                : (isDark
                      ? ColorsManager.white.withOpacity(0.05)
                      : ColorsManager.black.withOpacity(0.05)),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorsManager.chaletAccent.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon Container with fixed size
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          ColorsManager.chaletAccent,
                          ColorsManager.chaletAccent.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: isDark
                            ? [
                                ColorsManager.white.withOpacity(0.05),
                                ColorsManager.white.withOpacity(0.02),
                              ]
                            : [ColorsManager.grey100, ColorsManager.grey50],
                      ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? ColorsManager.white
                    : (isDark ? ColorsManager.white70 : ColorsManager.grey600),
                size: 26,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: isDark ? ColorsManager.white : ColorsManager.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? ColorsManager.white70
                          : ColorsManager.grey700,
                    ),
                  ),
                ],
              ),
            ),
            // Custom Radio-like indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? ColorsManager.chaletAccent
                      : ColorsManager.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1 : 0,
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorsManager.chaletAccent,
                    ),
                  ),
                ),
              ),
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
          // Step Identification Card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        ColorsManager.darkBlue2A2D4E,
                        ColorsManager.darkBlue161B30,
                      ]
                    : [
                        ColorsManager.darkBlue2E335A.withOpacity(0.05),
                        ColorsManager.white,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isDark
                    ? ColorsManager.white.withOpacity(0.08)
                    : ColorsManager.chaletAccent.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorsManager.chaletAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _selectedMethod == PaymentMethod.vodafoneCash
                        ? Icons.phone_android
                        : Icons.account_balance_wallet_rounded,
                    color: ColorsManager.chaletAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'تفاصيل التحويل عبر $methodTitle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? ColorsManager.white
                        : ColorsManager.chaletTextPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'يرجى تحويل المبلغ الموضح أدناه إلى الرقم المحدد، ثم الاحتفاظ بصورة الإيصال.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? ColorsManager.white70
                        : ColorsManager.grey600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.chaletAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: ColorsManager.chaletAccent.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_rounded,
                        color: ColorsManager.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        CurrencyFormatter.egp(context, _calculatedAmount),
                        style: const TextStyle(
                          color: ColorsManager.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          if (_selectedMethod == PaymentMethod.cashOnArrival) ...[
            _buildInfoCard(
              isDark,
              Icons.check_circle_rounded,
              'تأكيد الدفع نقداً',
              'سيتم التواصل معك هاتفياً لتأكيد حضورك وموعد الاستلام.',
              ColorsManager.green,
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: ColorsManager.chaletAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'بيانات الحساب',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? ColorsManager.white
                              : ColorsManager.chaletTextPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCopyableFieldNew(
                    isDark,
                    'رقم التحويل (كاش)',
                    _adminPhone,
                  ),
                  const SizedBox(height: 16),
                  _buildCopyableFieldNew(
                    isDark,
                    'اسم المستلم',
                    'إدارة شاليهات ربتال',
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 48),

          // Action Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.chaletAccent.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.chaletAccent,
                foregroundColor: ColorsManager.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedMethod == PaymentMethod.cashOnArrival
                        ? 'تأكيد الحجز النهائي'
                        : 'تم التحويل بنجاح، التالي',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    bool isDark,
    IconData icon,
    String title,
    String desc,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 54, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableFieldNew(bool isDark, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.white.withOpacity(0.03)
            : ColorsManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ColorsManager.white10
              : ColorsManager.black.withOpacity(0.05),
        ),
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: ColorsManager.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
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
                    color: isDark
                        ? ColorsManager.white70
                        : ColorsManager.grey700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? ColorsManager.white
                        : ColorsManager.chaletTextPrimaryLight,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: ColorsManager.chaletAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                Clipboard.setData(ClipboardData(text: value));
                SnackBarHelper.showSuccess(
                  context,
                  'تم نسخ $label',
                  icon: Icons.copy,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.copy_rounded,
                  color: ColorsManager.chaletAccent,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 3: Proof Upload / Confirmation ---
  Widget _buildProofUploadStep(bool isDark) {
    if (_selectedMethod == PaymentMethod.cashOnArrival) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: ColorsManager.chaletAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 100,
                  color: ColorsManager.chaletAccent,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'جاهز لتأكيد حجزك؟',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Text(
                'لقد اخترت الدفع نقداً عند الوصول. سيتم مراجعة طلبك وتأكيده من قبل الإدارة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.chaletAccent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.chaletAccent,
                    foregroundColor: ColorsManager.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: ColorsManager.white,
                        )
                      : const Text(
                          'إنهاء وتأكيد الحجز',
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
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Frosted WhatsApp Card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        ColorsManager.darkGreen1E3C29,
                        ColorsManager.darkGreen0F1E15,
                      ]
                    : [ColorsManager.lightGreenE8F5E9, ColorsManager.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: ColorsManager.whatsappGreen.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorsManager.whatsappGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone,
                    size: 54,
                    color: ColorsManager.whatsappGreen,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'خطوة أخيرة للـتأكيد',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  'يرجى إرسال لقطة شاشة (Screenshot) لإيصال التحويل عبر واتساب للمسؤول.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? ColorsManager.white70
                        : ColorsManager.grey600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Premium WhatsApp Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.whatsappGreen.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                HapticFeedback.heavyImpact();
                setState(() => _whatsAppOpened = true);
                await UriLauncherService.launchWhatsAppContact(
                  context: context,
                  phone: _adminPhone,
                  message:
                      'مرحباً، لقد قمت بتحويل مبلغ ${CurrencyFormatter.egp(context, _calculatedAmount)} لحجز شاليه ${widget.booking.chaletName} رقم الحجز: ${widget.booking.id.substring(0, 8)}',
                );
              },
              icon: const Icon(Icons.send_to_mobile_rounded, size: 22),
              label: const Text('فتح واتساب وإرسال الإيصال'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.whatsappGreen,
                foregroundColor: ColorsManager.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Animated confirmation box
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _whatsAppOpened
                ? Container(
                    key: const ValueKey('confirmation_ui'),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? ColorsManager.white.withOpacity(0.05)
                          : ColorsManager.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: ColorsManager.chaletAccent.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.help_outline_rounded,
                              color: ColorsManager.chaletAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'هل قمت بإرسال الإيصال؟',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? ColorsManager.white
                                    : ColorsManager.chaletTextPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitConfirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.chaletAccent,
                            foregroundColor: ColorsManager.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            minimumSize: const Size(double.infinity, 58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: ColorsManager.white,
                                )
                              : const Text(
                                  'نعم، تم الإرسال - إنهاء الحجز',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
