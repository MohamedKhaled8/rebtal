import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.profileBackgroundDark
          : ColorsManager.white,
      appBar: AppBar(
        title: Text(context.tr('profile_privacy_policy_title')),
        backgroundColor: isDark
            ? ColorsManager.transparent
            : ColorsManager.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? ColorsManager.white : ColorsManager.black,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? ColorsManager.white : ColorsManager.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('profile_privacy_policy_title'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? ColorsManager.white
                    : ColorsManager.chaletTextPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('profile_last_updated').replaceFirst('{}', DateTime.now().year.toString()),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_info_collect_title'),
              content: context.tr('profile_info_collect_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_how_use_info_title'),
              content: context.tr('profile_how_use_info_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_data_protection_title'),
              content: context.tr('profile_data_protection_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_your_rights_title'),
              content: context.tr('profile_your_rights_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_cookies_tracking_title'),
              content: context.tr('profile_cookies_tracking_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_third_party_title'),
              content: context.tr('profile_third_party_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_children_privacy_title'),
              content: context.tr('profile_children_privacy_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_policy_changes_title'),
              content: context.tr('profile_policy_changes_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: _serviceNatureTitle(context),
              content: _serviceNatureContent(context),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: _infoAccuracyTitle(context),
              content: _infoAccuracyContent(context),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: _liabilityTitle(context),
              content: _liabilityContent(context),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_contact'),
              content: context
                  .tr('profile_privacy_policy_contact')
                  .replaceFirst('{}', 'rebtal.service@gmail.com')
                  .replaceFirst('{}', '01507277511'),
            ),
            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorsManager.profileAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ColorsManager.profileAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('profile_privacy_agree_info'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? ColorsManager.white70
                            : ColorsManager.grey600,
                      ),
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

  Widget _buildSection({
    required bool isDark,
    required String title,
    required String content,
  }) {
    return Column(
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
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ar');

  String _serviceNatureTitle(BuildContext context) => _isArabic(context)
      ? 'بند طبيعة الخدمة (الوساطة التقنية)'
      : 'Nature of Service (Technical Mediation)';

  String _serviceNatureContent(BuildContext context) {
    if (_isArabic(context)) {
      return 'يقر المستخدم بأن التطبيق هو منصة إلكترونية للربط بين أصحاب الشاليهات (المؤجرين) وبين الراغبين في الاستئجار (المستأجرين). ولا يعد التطبيق مالكاً، أو مديراً، أو موظفاً، أو وكيلاً عن أي من العقارات المعروضة. إن عقد الإيجار يتم مباشرة بين المؤجر والمستأجر، ولا يتحمل التطبيق أي التزامات ناتجة عن هذا التعاقد، غير تأمين المبلغ المالي للأطراف طبقاً لسياسة التطبيق.';
    }
    return 'The app is an electronic platform connecting chalet owners (lessors) with renters (lessees). The app is not the owner, manager, employee, or agent of listed properties. The rental contract is concluded directly between lessor and lessee. The app is not liable for obligations arising from that contract, except securing the rental amount according to app policy.';
  }

  String _infoAccuracyTitle(BuildContext context) => _isArabic(context)
      ? '2. إخلاء المسؤولية عن دقة المعلومات'
      : '2. Information Accuracy Disclaimer';

  String _infoAccuracyContent(BuildContext context) {
    if (_isArabic(context)) {
      return 'بما أن محتوى الإعلانات يتم رفعه من قبل المؤجرين، فإن التطبيق لا يضمن دقة أو اكتمال أو جودة الصور، أو الأوصاف، أو المرافق المذكورة في الإعلان. تقع مسؤولية التحقق من مطابقة الشاليه للواقع بالكامل على عاتق المستأجر.';
    }
    return 'Since listing content is uploaded by lessors, the app does not guarantee the accuracy, completeness, or quality of photos, descriptions, or listed amenities. The renter is fully responsible for verifying that the chalet matches reality.';
  }

  String _liabilityTitle(BuildContext context) => _isArabic(context)
      ? '3. المسؤولية عن الأضرار والإصابات'
      : '3. Liability for Damages and Injuries';

  String _liabilityContent(BuildContext context) {
    if (_isArabic(context)) {
      return 'لا يتحمل مالك التطبيق أو إدارته أي مسؤولية قانونية عن:\n'
          '• أي إصابات جسدية أو حوادث تقع للمستأجر أو مرافقيه داخل الشاليه.\n'
          '• فقدان أو سرقة الممتلكات الشخصية الخاصة بالمستخدمين.\n'
          '• الأضرار التي قد يلحقها المستأجر بالعقار؛ حيث يتم تسوية هذه النزاعات بين الطرفين مباشرة بعيداً عن المنصة.';
    }
    return 'The app owner/management bears no legal liability for:\n'
        '• Any bodily injuries or incidents affecting renters or their companions inside the chalet.\n'
        '• Loss or theft of users’ personal belongings.\n'
        '• Damages caused by renters to the property; such disputes are settled directly between the parties outside the platform.';
  }
}
