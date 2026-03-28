import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class AuthCleanScaffold extends StatelessWidget {
  const AuthCleanScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer,
    this.heroTitle,
    this.heroSubtitle,
    this.heroAssetPath = 'assets/images/jpg/logo2.jpeg',
    this.maxFormWidth = 520,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget? footer;

  final String? heroTitle;
  final String? heroSubtitle;
  final String heroAssetPath;
  final double maxFormWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.darkBackground121212
          : ColorsManager.greyF9FAFB,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          final formPanel = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxFormWidth),
              child: _FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(logoAssetPath: heroAssetPath),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : ColorsManager.grey1F2937,
                        height: 1.1,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: isDark
                            ? Colors.white70
                            : ColorsManager.grey6B7280,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    form,
                    if (footer != null) ...[
                      const SizedBox(height: 18),
                      footer!,
                    ],
                  ],
                ),
              ),
            ),
          );

          final content = isWide
              ? Row(
                  children: [
                    Expanded(
                      child: _HeroPanel(
                        assetPath: heroAssetPath,
                        title: heroTitle ?? 'Rebtal',
                        subtitle:
                            heroSubtitle ??
                            'مصايف، شاليهات، وتجربة حجز سريعة بأفضل العروض.',
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: viewInsets.bottom),
                        child: formPanel,
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    _MobileHeroHeader(assetPath: heroAssetPath),
                    SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          160,
                          20,
                          20 + viewInsets.bottom,
                        ),
                        child: formPanel,
                      ),
                    ),
                  ],
                );

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: isWide
                ? EdgeInsets.fromLTRB(
                    constraints.maxWidth * 0.06,
                    24,
                    constraints.maxWidth * 0.06,
                    24,
                  )
                : EdgeInsets.zero,
            child: content,
          );
        },
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkSurface1E1E1E : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : ColorsManager.greyE5E7EB,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.logoAssetPath});

  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white70 : ColorsManager.grey6B7280,
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: (isDark ? Colors.white : ColorsManager.skyBlue0EA5E9)
                  .withOpacity(isDark ? 0.18 : 0.35),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: AppImageHelper(path: logoAssetPath, fit: BoxFit.cover),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.assetPath,
    required this.title,
    required this.subtitle,
  });

  final String assetPath;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    ColorsManager.darkBackground0F121F,
                    ColorsManager.navyBlue0F3460,
                  ]
                : [ColorsManager.skyBlue0EA5E9, ColorsManager.cyan06B6D4],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -50,
              child: _Blob(
                color: Colors.white.withOpacity(isDark ? 0.06 : 0.22),
                size: 220,
              ),
            ),
            Positioned(
              left: -70,
              bottom: -80,
              child: _Blob(
                color: Colors.white.withOpacity(isDark ? 0.05 : 0.18),
                size: 260,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppImageHelper(path: assetPath, fit: BoxFit.cover),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.8,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _HeroChip(label: 'حجز سريع'),
                      _HeroChip(label: 'أفضل العروض'),
                      _HeroChip(label: 'وجهات مميزة'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MobileHeroHeader extends StatelessWidget {
  const _MobileHeroHeader({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Container(
      height: 230,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  ColorsManager.darkBackground0F121F,
                  ColorsManager.navyBlue0F3460,
                ]
              : [ColorsManager.skyBlue0EA5E9, ColorsManager.cyan06B6D4],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -40,
            child: _Blob(
              color: Colors.white.withOpacity(isDark ? 0.06 : 0.18),
              size: 180,
            ),
          ),
          Positioned(
            left: 20,
            top: 56,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.35)),
              ),
              clipBehavior: Clip.antiAlias,
              child: AppImageHelper(path: assetPath, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: _CurveClipper(),
                child: Container(
                  height: 64,
                  color: isDark
                      ? ColorsManager.darkBackground121212
                      : ColorsManager.greyF9FAFB,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, 0);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height,
    );
    path.quadraticBezierTo(size.width * 0.75, size.height, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _CurveClipper oldClipper) => false;
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 18)],
      ),
    );
  }
}
