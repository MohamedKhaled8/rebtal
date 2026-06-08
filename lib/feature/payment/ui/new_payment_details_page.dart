import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/feature/payment/ui/new_payment_confirmation_page.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';

class NewPaymentDetailsPage extends StatefulWidget {
  final Booking booking;
  final PaymentMethod paymentMethod;
  final double amount;

  const NewPaymentDetailsPage({
    super.key,
    required this.booking,
    required this.paymentMethod,
    required this.amount,
  });

  @override
  State<NewPaymentDetailsPage> createState() => _NewPaymentDetailsPageState();
}

class _NewPaymentDetailsPageState extends State<NewPaymentDetailsPage> {
  bool _isProcessing = false;
  bool _hasSentProofViaWhatsApp = false;

  final Map<PaymentMethod, Map<String, String>> _paymentDetails = {
    PaymentMethod.instaPay: {
      'accountName': 'شركة ريبتال للتطوير العقاري',
      'accountNumber': 'instapay@rebtal',
      'instructions':
          'افتح تطبيق إنستاباي واختر "تحويل" ثم أدخل البيانات أعلاه',
    },
    PaymentMethod.vodafoneCash: {
      'accountName': 'ريبتال',
      'phoneNumber': '01008422234',
      'instructions':
          'استخدم تطبيق فودافون كاش لإتمام التحويل ثم تابع الخطوات داخل التطبيق.',
    },
    PaymentMethod.bankTransfer: {
      'bankName': 'البنك الأهلي المصري',
      'accountName': 'شركة ريبتال للتطوير العقاري',
      'accountNumber': '1234567890123456',
      'iban': 'EG380002000156789012345678901',
      'instructions': 'قم بالتحويل من خلال فرع البنك أو التطبيق البنكي',
    },
    PaymentMethod.cashOnArrival: {
      'instructions':
          'سيتم الدفع نقداً عند استلام مفتاح الشاليه. يرجى إحضار المبلغ كاملاً.',
    },
  };

  String _resolveAccountName(String raw) {
    final v = raw.trim();
    if (v == 'ريبتال' || v.toLowerCase() == 'rebtal') {
      return context.tr('brand_rebtal');
    }
    if (v.contains('شركة') && v.contains('ريبتال')) {
      return context.tr('brand_rebtal_company');
    }
    return raw;
  }

  String _getMethodTitle() {
    switch (widget.paymentMethod) {
      case PaymentMethod.instaPay:
        return context.tr('payment_method_instapay');
      case PaymentMethod.vodafoneCash:
        return context.tr('payment_method_vodafone_cash');
      case PaymentMethod.bankTransfer:
        return context.tr('payment_method_bank');
      case PaymentMethod.cashOnArrival:
        return context.tr('payment_method_cash_on_arrival');
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    SnackBarHelper.showSuccess(
      context,
      '${context.tr('payment_copied_label')} $label',
    );
  }

  Future<void> _sendProofViaWhatsApp() async {
    final phone = '201008422234'; // رقم المالك أو الإدارة
    final message =
        '${context.tr('payment_whatsapp_message_prefix')} ${widget.amount.round()} ${context.tr('booking_egp_currency')} ${context.tr('payment_whatsapp_message_booking')} ${widget.booking.id.substring(0, 8)}. ${context.tr('payment_whatsapp_message_suffix')}';

    try {
      await UriLauncherService.openWhatsApp(phone, message);
      // Enable the confirm button after opening WhatsApp
      setState(() {
        _hasSentProofViaWhatsApp = true;
      });
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, context.tr('payment_whatsapp_error'));
      }
    }
  }

  Future<void> _proceedToConfirmation() async {
    setState(() => _isProcessing = true);

    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewPaymentConfirmationPage(
            booking: widget.booking,
            paymentMethod: widget.paymentMethod,
            amount: widget.amount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final details = _paymentDetails[widget.paymentMethod]!;

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
          context.tr('payment_details_title'),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Method
                  _buildSection(isDark, context.tr('payment_screen_title'), [
                    _buildInfoRow(
                      isDark,
                      context.tr('payment_label_method'),
                      _getMethodTitle(),
                    ),
                    _buildInfoRow(
                      isDark,
                      context.tr('payment_amount_label'),
                      '${widget.amount.round()} ${context.tr('booking_egp_currency')}',
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Payment Details
                  if (widget.paymentMethod != PaymentMethod.cashOnArrival) ...[
                    _buildSection(isDark, context.tr('payment_transfer_details_title'), [
                      if (details.containsKey('bankName'))
                        _buildInfoRow(
                          isDark,
                          context.tr('payment_label_bank_name'),
                          details['bankName']!,
                        ),
                      if (details.containsKey('accountName'))
                        _buildInfoRow(
                          isDark,
                          context.tr('payment_label_account_name'),
                          _resolveAccountName(details['accountName']!),
                        ),
                      if (details.containsKey('accountNumber'))
                        _buildCopyableRow(
                          isDark,
                          context.tr('payment_label_account_number'),
                          details['accountNumber']!,
                        ),
                      if (details.containsKey('iban'))
                        _buildCopyableRow(isDark, 'IBAN', details['iban']!),
                      if (details.containsKey('phoneNumber'))
                        _buildCopyableRow(
                          isDark,
                          context.tr('payment_label_wallet_number'),
                          details['phoneNumber']!,
                        ),
                    ]),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 24),

                  // Send Proof (for non-cash payments)
                  if (widget.paymentMethod != PaymentMethod.cashOnArrival)
                    _buildSendProofSection(isDark),

                  if (widget.paymentMethod != PaymentMethod.cashOnArrival)
                    const SizedBox(height: 24),

                  // Support
                  _buildSupportCard(isDark),
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
                  onPressed:
                      _isProcessing ||
                          (widget.paymentMethod !=
                                  PaymentMethod.cashOnArrival &&
                              !_hasSentProofViaWhatsApp)
                      ? null
                      : _proceedToConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.paymentMethod == PaymentMethod.cashOnArrival
                              ? context.tr('payment_confirm_booking')
                              : context.tr('payment_mark_paid'),
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

  Widget _buildSection(bool isDark, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copyToClipboard(value, label),
            icon: const Icon(Icons.copy, size: 18),
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(bool isDark) {
    return GestureDetector(
      onTap: _sendProofViaWhatsApp,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.support_agent_outlined,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('payment_need_help_title'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('payment_contact_whatsapp'),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.white70 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendProofSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('payment_confirm_section_title'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _sendProofViaWhatsApp,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Text(
                  context.tr('payment_send_receipt_whatsapp'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_hasSentProofViaWhatsApp) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                context.tr('payment_whatsapp_opened_hint'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
