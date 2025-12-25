import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';

class PaymentInstructionsPage extends StatefulWidget {
  final Booking booking;
  final PaymentMethod paymentMethod;
  final double amount;

  const PaymentInstructionsPage({
    super.key,
    required this.booking,
    required this.paymentMethod,
    required this.amount,
  });

  @override
  State<PaymentInstructionsPage> createState() =>
      _PaymentInstructionsPageState();
}

class _PaymentInstructionsPageState extends State<PaymentInstructionsPage> {
  // Mock admin payment info - في التطبيق الحقيقي سيتم جلبها من Firestore
  final String adminBankName = 'البنك الأهلي المصري';
  final String adminBankAccount = '1234567890123456';
  final String adminBankAccountName = 'Rebtal Platform';
  final String adminVodafoneCash = '01012345678';
  final String adminInstaPay = 'rebtal@instapay';

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
        title: const Text(
          'تعليمات الدفع',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ColorManager.chaletAccent, Color(0xFF00A896)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getPaymentIcon(),
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
                            _getPaymentTitle(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.amount.toStringAsFixed(0)} جنيه',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Instructions based on method
              if (widget.paymentMethod == PaymentMethod.bankTransfer)
                _buildBankTransferInstructions(isDark)
              else if (widget.paymentMethod == PaymentMethod.vodafoneCash)
                _buildVodafoneCashInstructions(isDark)
              else if (widget.paymentMethod == PaymentMethod.instaPay)
                _buildInstaPayInstructions(isDark)
              else if (widget.paymentMethod == PaymentMethod.cashOnArrival)
                _buildCashOnArrivalInstructions(isDark),

              const SizedBox(height: 24),

              // Upload Proof Button (not for cash on arrival)
              if (widget.paymentMethod != PaymentMethod.cashOnArrival)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.paymentProofUpload,
                        arguments: {
                          'booking': widget.booking,
                          'paymentMethod': widget.paymentMethod,
                          'amount': widget.amount,
                        },
                      );
                    },
                    icon: const Icon(Icons.upload_file, size: 24),
                    label: const Text(
                      'رفع إيصال الدفع',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.chaletAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate back to home
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.check_circle, size: 24),
                    label: const Text(
                      'تأكيد الحجز',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankTransferInstructions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معلومات الحساب البنكي', isDark),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'البنك',
                adminBankName,
                Icons.account_balance,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'رقم الحساب',
                adminBankAccount,
                Icons.credit_card,
                isDark,
                copyable: true,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'اسم المستفيد',
                adminBankAccountName,
                Icons.person,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'المبلغ',
                '${widget.amount.toStringAsFixed(0)} جنيه',
                Icons.money,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'رقم الحجز',
                '#${widget.booking.id.substring(0, 8).toUpperCase()}',
                Icons.confirmation_number,
                isDark,
                copyable: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTimerCard(isDark),
        const SizedBox(height: 24),
        _buildStepsCard(isDark, 'بعد التحويل:', [
          'التقط صورة واضحة للإيصال',
          'اضغط على "رفع إيصال الدفع"',
          'انتظر تأكيد الأدمن (1-2 ساعة)',
          'استعد لرحلتك! 🎉',
        ]),
      ],
    );
  }

  Widget _buildVodafoneCashInstructions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معلومات فودافون كاش', isDark),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'الرقم',
                adminVodafoneCash,
                Icons.phone_android,
                isDark,
                copyable: true,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'الاسم',
                adminBankAccountName,
                Icons.person,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'المبلغ',
                '${widget.amount.toStringAsFixed(0)} جنيه',
                Icons.money,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'رقم الحجز',
                '#${widget.booking.id.substring(0, 8).toUpperCase()}',
                Icons.confirmation_number,
                isDark,
                copyable: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTimerCard(isDark),
        const SizedBox(height: 24),
        _buildStepsCard(isDark, 'خطوات الدفع:', [
          'افتح تطبيق فودافون كاش',
          'اختر "تحويل أموال"',
          'أدخل الرقم: $adminVodafoneCash',
          'أدخل المبلغ: ${widget.amount.toStringAsFixed(0)}',
          'أدخل رقم الحجز في الملاحظات',
          'التقط screenshot للعملية',
          'ارفع الإيصال في التطبيق',
        ]),
      ],
    );
  }

  Widget _buildInstaPayInstructions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معلومات إنستاباي', isDark),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'حساب إنستاباي',
                adminInstaPay,
                Icons.flash_on,
                isDark,
                copyable: true,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'الاسم',
                adminBankAccountName,
                Icons.person,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'المبلغ',
                '${widget.amount.toStringAsFixed(0)} جنيه',
                Icons.money,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'رقم الحجز',
                '#${widget.booking.id.substring(0, 8).toUpperCase()}',
                Icons.confirmation_number,
                isDark,
                copyable: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTimerCard(isDark),
        const SizedBox(height: 24),
        _buildStepsCard(isDark, 'خطوات الدفع:', [
          'افتح تطبيق البنك الخاص بك',
          'اختر "إنستاباي"',
          'أدخل الحساب: $adminInstaPay',
          'أدخل المبلغ: ${widget.amount.toStringAsFixed(0)}',
          'أدخل رقم الحجز في الملاحظات',
          'التقط screenshot للعملية',
          'ارفع الإيصال في التطبيق',
        ]),
      ],
    );
  }

  Widget _buildCashOnArrivalInstructions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('الدفع عند الوصول', isDark),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade700],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              const Text(
                'حجزك مؤكد مبدئياً!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'المبلغ المطلوب: ${widget.amount.toStringAsFixed(0)} جنيه',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ملاحظات هامة:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildBulletPoint(
                'احضر المبلغ كاملاً نقداً',
                Colors.orange.shade700,
              ),
              const SizedBox(height: 8),
              _buildBulletPoint(
                'سيتم الدفع للأدمن عند الوصول',
                Colors.orange.shade700,
              ),
              const SizedBox(height: 8),
              _buildBulletPoint(
                'سيتم إصدار إيصال رسمي',
                Colors.orange.shade700,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
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
                  Icon(
                    Icons.location_on,
                    color: ColorManager.chaletAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'مكان الدفع:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'مكتب الاستقبال - ${widget.booking.chaletName}',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    bool copyable = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ColorManager.chaletAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (copyable)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('تم النسخ'),
                    ],
                  ),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(Icons.copy, size: 20, color: ColorManager.chaletAccent),
          ),
      ],
    );
  }

  Widget _buildTimerCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'يرجى إتمام الدفع خلال 24 ساعة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(bool isDark, String title, List<String> steps) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: ColorManager.chaletAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getPaymentIcon() {
    switch (widget.paymentMethod) {
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.vodafoneCash:
        return Icons.phone_android;
      case PaymentMethod.instaPay:
        return Icons.flash_on;
      case PaymentMethod.cashOnArrival:
        return Icons.money;
    }
  }

  String _getPaymentTitle() {
    switch (widget.paymentMethod) {
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
}
