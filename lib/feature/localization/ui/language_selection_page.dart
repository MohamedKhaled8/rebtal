import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/localization/logic/locale_cubit.dart';

/// صفحة اختيار اللغة - StatelessWidget
/// BlocProvider يوضع فوق الصفحة عند التنقل
class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F121F)
          : const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          _buildBackgroundDecorations(isDark),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildBackButton(context, isDark),
                    const SizedBox(height: 40),
                    _buildTitleSection(context, isDark),
                    const SizedBox(height: 60),
                    _buildLanguageCards(context, isDark),
                    const SizedBox(height: 40),
                    _buildConfirmButton(context, isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: CircleAvatar(
            radius: 150,
            backgroundColor: ColorsManager.chaletAccent.withOpacity(0.05),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: CircleAvatar(
            radius: 120,
            backgroundColor: Colors.blue.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('language_select_title'),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('language_select_subtitle'),
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCards(BuildContext context, bool isDark) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final selectedCode = state is LocaleSelected
            ? state.selectedLanguageCode
            : 'ar';

        return Column(
          children: [
            _buildLanguageCard(
              context,
              isDark: isDark,
              langCode: 'ar',
              title: context.tr('language_arabic'),
              subtitle: context.tr('language_arabic_subtitle'),
              flag: '🇪🇬',
              isSelected: selectedCode == 'ar',
              index: 1,
            ),
            const SizedBox(height: 20),
            _buildLanguageCard(
              context,
              isDark: isDark,
              langCode: 'en',
              title: context.tr('language_english'),
              subtitle: context.tr('language_english_subtitle'),
              flag: '🇺🇸',
              isSelected: selectedCode == 'en',
              index: 2,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageCard(
    BuildContext context, {
    required bool isDark,
    required String langCode,
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 200)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: GestureDetector(
        onTap: () => context.read<LocaleCubit>().selectLanguage(langCode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? (isSelected
                      ? ColorsManager.chaletAccent.withOpacity(0.15)
                      : const Color(0xFF1B1E2B))
                : (isSelected
                      ? ColorsManager.chaletAccent.withOpacity(0.08)
                      : Colors.white),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected
                  ? ColorsManager.chaletAccent
                  : (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05)),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ColorsManager.chaletAccent.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(flag, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? ColorsManager.chaletAccent
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? ColorsManager.chaletAccent
                        : Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.chaletAccent.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            await context.read<LocaleCubit>().confirmSelection();
            if (context.mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsManager.chaletAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: Text(
            context.tr('language_confirm'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
