import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class CancellationPolicyPage extends StatelessWidget {
  const CancellationPolicyPage({super.key});

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
          'سياسة الإلغاء والاسترداد',
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
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ColorManager.chaletAccent, Color(0xFF00A896)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.policy, color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'سياسة الإلغاء والاسترداد',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'يرجى قراءة السياسة بعناية قبل إلغاء حجزك',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cancellation Rules
              _buildSectionCard(
                isDark,
                'قواعد الإلغاء',
                Icons.cancel_outlined,
                [
                  _PolicyItem(
                    title: 'الإلغاء قبل 7 أيام',
                    description: 'استرداد كامل المبلغ (100%)',
                    percentage: 100,
                    color: Colors.green,
                  ),
                  _PolicyItem(
                    title: 'الإلغاء قبل 3-7 أيام',
                    description: 'استرداد 50% من المبلغ',
                    percentage: 50,
                    color: Colors.orange,
                  ),
                  _PolicyItem(
                    title: 'الإلغاء قبل أقل من 3 أيام',
                    description: 'لا يوجد استرداد',
                    percentage: 0,
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Refund Process
              _buildSectionCard(
                isDark,
                'عملية الاسترداد',
                Icons.account_balance_wallet,
                [
                  _ProcessStep(
                    number: '1',
                    title: 'تقديم طلب الإلغاء',
                    description: 'قم بإلغاء الحجز من صفحة حجوزاتي',
                  ),
                  _ProcessStep(
                    number: '2',
                    title: 'مراجعة الطلب',
                    description: 'سيتم مراجعة طلبك من قبل الأدمن',
                  ),
                  _ProcessStep(
                    number: '3',
                    title: 'حساب المبلغ المسترد',
                    description: 'يتم حساب المبلغ حسب سياسة الإلغاء',
                  ),
                  _ProcessStep(
                    number: '4',
                    title: 'استرداد المبلغ',
                    description: 'يتم تحويل المبلغ خلال 3-5 أيام عمل',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Important Notes
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
                          'ملاحظات هامة',
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
                      'يتم حساب المدة من تاريخ بداية الحجز',
                      Colors.orange.shade700,
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'الاسترداد يتم عبر نفس طريقة الدفع',
                      Colors.orange.shade700,
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'في حالة الدفع عند الوصول، لا يوجد استرداد',
                      Colors.orange.shade700,
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'قد تستغرق عملية الاسترداد 3-5 أيام عمل',
                      Colors.orange.shade700,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact Support Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to support
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text(
                    'تواصل مع الدعم',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorManager.chaletAccent,
                    side: BorderSide(
                      color: ColorManager.chaletAccent,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildSectionCard(
    bool isDark,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
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
          Row(
            children: [
              Icon(icon, color: ColorManager.chaletAccent, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
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
          child: Text(text, style: TextStyle(fontSize: 14, color: color)),
        ),
      ],
    );
  }
}

class _PolicyItem extends StatelessWidget {
  final String title;
  final String description;
  final int percentage;
  final Color color;

  const _PolicyItem({
    required this.title,
    required this.description,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _ProcessStep({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ColorManager.chaletAccent, Color(0xFF00A896)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
