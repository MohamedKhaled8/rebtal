import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

/// Resort-style photo used behind the auth header (login / register / forgot password).
const String kDefaultAuthHeaderBackground =
    'assets/images/jpg/onboarding_1.jpg';

/// Keeps the curved header from exceeding short viewports (landscape / split-screen).
double _authMobileHeaderHeight(BuildContext context) {
  final h = MediaQuery.sizeOf(context).height;
  final insetBottom = MediaQuery.viewInsetsOf(context).bottom;
  final effectiveH = (h - insetBottom).clamp(240.0, 900.0);
  if (effectiveH < 520) {
    return (effectiveH * 0.40).clamp(150.0, 240.0);
  }
  if (effectiveH < 680) {
    return (effectiveH * 0.38).clamp(200.0, 280.0);
  }
  return 300.0;
}

/// Scroll padding so the form overlaps the header curve (tuned with header height).
double _authMobileScrollTopPadding(double headerHeight) {
  return (headerHeight - 82).clamp(88.0, 240.0);
}

class AuthWanderlyScaffold extends StatelessWidget {
  const AuthWanderlyScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer,
    this.appName = 'ابدأ الآن',
    this.brandSubtitle = '',
    this.primaryColor = ColorsManager.blue2563EB,
    this.logoAssetPath = 'assets/images/jpg/logo2.jpeg',
    /// Full-bleed header image; set empty to use the solid/gradient fallback only.
    this.headerBackgroundAssetPath = kDefaultAuthHeaderBackground,
    this.maxWidth = 520,
  });

  final String appName;
  final String brandSubtitle;

  final String title;
  final String subtitle;
  final Widget form;
  final Widget? footer;

  final Color primaryColor;
  final String logoAssetPath;
  /// Background for the top brand strip (mobile + desktop left panel).
  final String headerBackgroundAssetPath;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final isDark = DynamicThemeManager.isDarkMode(context);

    final scaffoldBg =
        isDark ? ColorsManager.darkBackground121212 : Colors.white;
    final cardBg = isDark ? ColorsManager.darkSurface1E1E1E : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.transparent;
    final titleColor = isDark ? Colors.white : ColorsManager.grey1F2937;
    final subtitleColor =
        isDark ? Colors.white70 : ColorsManager.grey6B7280;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: scaffoldBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final mobileHeaderH = _authMobileHeaderHeight(context);
          final mobileScrollTop = _authMobileScrollTopPadding(mobileHeaderH);

          final card = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.45 : 0.08),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  form,
                  if (footer != null) ...[const SizedBox(height: 14), footer!],
                ],
              ),
            ),
          );

          final content = isWide
              ? Row(
                  children: [
                    Expanded(
                      child: _BrandPanel(
                        appName: appName,
                        brandSubtitle: brandSubtitle,
                        primaryColor: primaryColor,
                        logoAssetPath: logoAssetPath,
                        headerBackgroundAssetPath: headerBackgroundAssetPath,
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            24,
                            24,
                            24 + viewInsets.bottom,
                          ),
                          child: card,
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    _MobileHeader(
                      appName: appName,
                      brandSubtitle: brandSubtitle,
                      primaryColor: primaryColor,
                      logoAssetPath: logoAssetPath,
                      headerBackgroundAssetPath: headerBackgroundAssetPath,
                      headerHeight: mobileHeaderH,
                      isDark: isDark,
                    ),
                    SafeArea(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          18,
                          mobileScrollTop,
                          18,
                          18 + viewInsets.bottom,
                        ),
                        child: Center(child: card),
                      ),
                    ),
                  ],
                );

          return content;
        },
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({
    required this.appName,
    required this.brandSubtitle,
    required this.primaryColor,
    required this.logoAssetPath,
    required this.headerBackgroundAssetPath,
    required this.isDark,
  });

  final String appName;
  final String brandSubtitle;
  final Color primaryColor;
  final String logoAssetPath;
  final String headerBackgroundAssetPath;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final usePhoto = headerBackgroundAssetPath.trim().isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (usePhoto)
          Positioned.fill(
            child: Image.asset(
              headerBackgroundAssetPath,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.15),
              errorBuilder: (context, error, stackTrace) =>
                  _AuthHeaderGradientFallback(primaryColor: primaryColor, isDark: isDark),
            ),
          )
        else
          Positioned.fill(
            child: _AuthHeaderGradientFallback(primaryColor: primaryColor, isDark: isDark),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(isDark ? 0.34 : 0.28),
                  Colors.black.withOpacity(isDark ? 0.52 : 0.42),
                ],
              ),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(28),
              child: Align(
                alignment: Alignment.topCenter,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: math.min(420, constraints.maxWidth - 8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        _WanderlyLogoMark(text: appName),
                        const SizedBox(height: 10),
                        Text(
                          brandSubtitle,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: Colors.white.withOpacity(0.90),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({
    required this.appName,
    required this.brandSubtitle,
    required this.primaryColor,
    required this.logoAssetPath,
    required this.headerBackgroundAssetPath,
    required this.headerHeight,
    required this.isDark,
  });

  final String appName;
  final String brandSubtitle;
  final Color primaryColor;
  final String logoAssetPath;
  final String headerBackgroundAssetPath;
  final double headerHeight;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final usePhoto = headerBackgroundAssetPath.trim().isNotEmpty;
    final topPad = MediaQuery.paddingOf(context).top + 6;

    return SizedBox(
      height: headerHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final innerMaxH =
              math.max(40.0, constraints.maxHeight - topPad - 8);
          return Stack(
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: _BottomCurveClipper(),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (usePhoto)
                        Image.asset(
                          headerBackgroundAssetPath,
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, -0.2),
                          errorBuilder: (context, error, stackTrace) =>
                              _AuthHeaderGradientFallback(primaryColor: primaryColor, isDark: isDark),
                        )
                      else
                        _AuthHeaderGradientFallback(primaryColor: primaryColor, isDark: isDark),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(isDark ? 0.28 : 0.22),
                              Colors.black.withOpacity(isDark ? 0.45 : 0.38),
                            ],
                          ),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: topPad,
                    left: 16,
                    right: 16,
                    bottom: 6,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: innerMaxH > 0 ? innerMaxH : 1,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: math.min(340, constraints.maxWidth - 32),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _WanderlyLogoMark(text: appName),
                              const SizedBox(height: 6),
                              Text(
                                brandSubtitle,
                                textAlign: TextAlign.center,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                  color: Colors.white.withOpacity(0.92),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Original solid / navy gradient when no photo is used or [Image.asset] fails.
class _AuthHeaderGradientFallback extends StatelessWidget {
  const _AuthHeaderGradientFallback({
    required this.primaryColor,
    required this.isDark,
  });

  final Color primaryColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorsManager.darkBackground0F121F,
                  ColorsManager.navyBlue0F3460,
                ],
              )
            : null,
        color: isDark ? null : primaryColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 52);
    path.quadraticBezierTo(
      size.width * 0.50,
      size.height + 18,
      size.width,
      size.height - 52,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _BottomCurveClipper oldClipper) => false;
}

class _WanderlyLogoMark extends StatefulWidget {
  const _WanderlyLogoMark({required this.text});

  final String text;

  @override
  State<_WanderlyLogoMark> createState() => _WanderlyLogoMarkState();
}

class _WanderlyLogoMarkState extends State<_WanderlyLogoMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      width: 340,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _FlightDoodlesPainter(
                    color: Colors.white.withOpacity(0.95),
                    t: _controller.value,
                  ),
                ),
              ),
              Text(
                widget.text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.pacifico(
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FlightDoodlesPainter extends CustomPainter {
  _FlightDoodlesPainter({required this.color, required this.t});

  final Color color;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final dotted = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(0.50);

    // 3 مسارات مختلفة للطائرات
    // مسار 1: حركة دائرية علوية (عكس عقارب الساعة)
    final path1 = Path()
      ..moveTo(size.width * 0.72, size.height * 0.22)
      ..cubicTo(
        size.width * 0.90,
        size.height * 0.15,
        size.width * 0.95,
        size.height * 0.35,
        size.width * 0.78,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.48,
        size.width * 0.58,
        size.height * 0.28,
        size.width * 0.72,
        size.height * 0.22,
      );

    // مسار 2: حركة موجة سفلية (باتجاه عقارب الساعة)
    final path2 = Path()
      ..moveTo(size.width * 0.25, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.82,
        size.width * 0.50,
        size.height * 0.70,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.58,
        size.width * 0.75,
        size.height * 0.68,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.78,
        size.width * 0.92,
        size.height * 0.62,
      );

    // مسار 3: حركة رقم 8 أفقي (infinity loop)
    final path3 = Path()
      ..moveTo(size.width * 0.45, size.height * 0.35)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.20,
        size.width * 0.15,
        size.height * 0.40,
        size.width * 0.32,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.60,
        size.width * 0.48,
        size.height * 0.45,
        size.width * 0.55,
        size.height * 0.38,
      )
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.28,
        size.width * 0.70,
        size.height * 0.50,
        size.width * 0.55,
        size.height * 0.55,
      )
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.58,
        size.width * 0.42,
        size.height * 0.48,
        size.width * 0.45,
        size.height * 0.35,
      );

    // رسم المسارات بنقاط متحركة بسرعات مختلفة
    _drawDottedPath(canvas, path1, dotted, phase: (t * 1.0) % 1.0, speed: 1.0);
    _drawDottedPath(
      canvas,
      path2,
      dotted..color = color.withOpacity(0.45),
      phase: (t * 0.8 + 0.33) % 1.0,
      speed: 0.8,
    );
    _drawDottedPath(
      canvas,
      path3,
      dotted..color = color.withOpacity(0.40),
      phase: (t * 1.2 + 0.66) % 1.0,
      speed: 1.2,
    );

    // رسم الطائرات على المسارات
    final planePaint = Paint()..color = color.withOpacity(0.95);

    final plane1 = _tangentOnPath(path1, (t * 1.0) % 1.0);
    final plane2 = _tangentOnPath(path2, (t * 0.8 + 0.33) % 1.0);
    final plane3 = _tangentOnPath(path3, (t * 1.2 + 0.66) % 1.0);

    if (plane1 != null) {
      _drawEnhancedPlane(
        canvas,
        plane1.position,
        planePaint,
        rotation: plane1.angle,
        scale: 1.0,
      );
    }
    if (plane2 != null) {
      _drawEnhancedPlane(
        canvas,
        plane2.position,
        planePaint,
        rotation: plane2.angle,
        scale: 0.9,
      );
    }
    if (plane3 != null) {
      _drawEnhancedPlane(
        canvas,
        plane3.position,
        planePaint,
        rotation: plane3.angle,
        scale: 0.85,
      );
    }

    // نقاط لامعة متناثرة (twinkle effect)
    _drawSparkles(canvas, size, t);
  }

  void _drawDottedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double phase,
    required double speed,
  }) {
    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      final length = metric.length;
      const dash = 3.0;
      const gap = 5.0;
      // سرعة الحركة تختلف لكل مسار
      double distance = (phase * length * speed) % (dash + gap);
      while (distance < length) {
        final next = (distance + dash).clamp(0.0, length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  void _drawSparkles(Canvas canvas, Size size, double t) {
    final sparklePaint = Paint()
      ..color = color.withOpacity(0.6 + 0.4 * math.sin(t * math.pi * 2));

    final sparkles = [
      Offset(size.width * 0.12, size.height * 0.25),
      Offset(size.width * 0.88, size.height * 0.30),
      Offset(size.width * 0.20, size.height * 0.72),
      Offset(size.width * 0.82, size.height * 0.75),
      Offset(size.width * 0.50, size.height * 0.18),
    ];

    for (var i = 0; i < sparkles.length; i++) {
      final offset = sparkles[i];
      final pulse = 0.5 + 0.5 * math.sin((t + i * 0.2) * math.pi * 2);
      final radius = 1.2 + pulse * 0.8;
      canvas.drawCircle(
        offset,
        radius,
        sparklePaint..color = color.withOpacity(0.4 + pulse * 0.4),
      );
    }
  }

  ui.Tangent? _tangentOnPath(Path path, double tt) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return null;
    final metric = metrics.first;
    if (metric.length == 0) return null;
    return metric.getTangentForOffset(metric.length * tt);
  }

  void _drawEnhancedPlane(
    Canvas canvas,
    Offset center,
    Paint paint, {
    required double rotation,
    required double scale,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(scale);

    // جسم الطائرة (شكل أجمل)
    final bodyPaint = paint..color = color.withOpacity(0.95);
    final wingPaint = paint..color = color.withOpacity(0.75);

    // الجسم الرئيسي
    final body = Path()
      ..moveTo(-7, 0)
      ..lineTo(5, -1.5)
      ..lineTo(8, 0)
      ..lineTo(5, 1.5)
      ..close();
    canvas.drawPath(body, bodyPaint);

    // الجناح
    final wing = Path()
      ..moveTo(0, -4)
      ..lineTo(3, 0)
      ..lineTo(0, 4)
      ..lineTo(-2, 0)
      ..close();
    canvas.drawPath(wing, wingPaint);

    // ذيل الطائرة
    final tail = Path()
      ..moveTo(-6, -2)
      ..lineTo(-8, -4)
      ..lineTo(-5, 0)
      ..close();
    canvas.drawPath(tail, wingPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlightDoodlesPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.t != t;
}
