import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';

class AuthNeoScaffold extends StatelessWidget {
  const AuthNeoScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer,
    this.accentColor,
    this.logoAssetPath = 'assets/images/jpg/logo2.jpeg',
    this.maxFormWidth = 520,
    this.onBack,
    this.onTopRight,
    this.topRightIcon = Icons.refresh_rounded,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget? footer;
  final Color? accentColor;
  final String logoAssetPath;
  final double maxFormWidth;
  final VoidCallback? onBack;
  final VoidCallback? onTopRight;
  final IconData topRightIcon;

  @override
  Widget build(BuildContext context) {
    // This scaffold is intentionally "Neo Dark" to match the provided reference.
    // We still allow the caller to pick an accent color from Rebtal palette.
    final accent = accentColor ?? ColorsManager.chaletAccent;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF070B08),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          final card = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxFormWidth),
            child: _NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: ColorsManager.white,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: Colors.white.withOpacity(0.72),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  form,
                  if (footer != null) ...[const SizedBox(height: 16), footer!],
                ],
              ),
            ),
          );

          final body = isWide
              ? Row(
                  children: [
                    Expanded(
                      child: _NeoHero(
                        accent: accent,
                        logoAssetPath: logoAssetPath,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: viewInsets.bottom),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _TopActionsRow(
                                onBack:
                                    onBack ??
                                    () => Navigator.of(context).maybePop(),
                                onTopRight: onTopRight,
                                topRightIcon: topRightIcon,
                              ),
                              const SizedBox(height: 14),
                              _OrbHeader(accent: accent),
                              const SizedBox(height: 18),
                              card,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Positioned.fill(child: _NeoBackground(accent: accent)),
                    SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          18,
                          18,
                          18,
                          18 + viewInsets.bottom,
                        ),
                        child: Column(
                          children: [
                            _TopActionsRow(
                              onBack:
                                  onBack ??
                                  () => Navigator.of(context).maybePop(),
                              onTopRight: onTopRight,
                              topRightIcon: topRightIcon,
                            ),
                            const SizedBox(height: 16),
                            _OrbHeader(accent: accent),
                            const SizedBox(height: 18),
                            Center(child: card),
                          ],
                        ),
                      ),
                    ),
                  ],
                );

          return body;
        },
      ),
    );
  }
}

class _TopActionsRow extends StatelessWidget {
  const _TopActionsRow({
    required this.onBack,
    required this.onTopRight,
    required this.topRightIcon,
  });

  final VoidCallback onBack;
  final VoidCallback? onTopRight;
  final IconData topRightIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RoundIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
        _RoundIconButton(icon: topRightIcon, onTap: onTopRight),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, size: 18, color: Colors.white.withOpacity(0.86)),
      ),
    );
  }
}

class _NeoBackground extends StatelessWidget {
  const _NeoBackground({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.4),
              radius: 1.2,
              colors: [Color(0xFF111A0F), Color(0xFF070B08), Color(0xFF050705)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SizedBox.expand(),
        ),
        Positioned(
          top: -140,
          left: -120,
          child: _Glow(color: accent.withOpacity(0.18), size: 320),
        ),
        Positioned(
          top: 90,
          right: -160,
          child: _Glow(
            color: ColorsManager.cyan06B6D4.withOpacity(0.10),
            size: 360,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _DotGridPainter(color: Colors.white.withOpacity(0.06)),
          ),
        ),
      ],
    );
  }
}

class _NeoHero extends StatelessWidget {
  const _NeoHero({required this.accent, required this.logoAssetPath});

  final Color accent;
  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Positioned.fill(child: _NeoBackground(accent: accent)),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AppImageHelper(
                        path: logoAssetPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Rebtal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'مصايف وشاليهات\nبستايل Premium',
                  style: TextStyle(
                    fontSize: 42,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'حجز أسرع • تجربة أنعم • عروض أوضح',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _NeoChip(label: 'وجهات مميزة', accent: accent),
                    _NeoChip(label: 'إلغاء مرن', accent: accent),
                    _NeoChip(label: 'دفع آمن', accent: accent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NeoChip extends StatelessWidget {
  const _NeoChip({required this.label, required this.accent});
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.88),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _OrbHeader extends StatelessWidget {
  const _OrbHeader({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              accent.withOpacity(0.20),
              const Color(0xFF0B0F0D),
              const Color(0xFF070B08),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
          border: Border.all(color: accent.withOpacity(0.28)),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.18),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeoCard extends StatelessWidget {
  const _NeoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F0D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 26)],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    const gap = 18.0;
    const r = 1.2;

    // concentrate dots towards top-right like reference
    for (double y = 0; y < size.height * 0.55; y += gap) {
      for (double x = size.width * 0.45; x < size.width; x += gap) {
        // subtle random-ish fade based on trig (deterministic)
        final t = (math.sin(x * 0.08) + math.cos(y * 0.10)) * 0.5 + 0.5;
        final a = (0.20 + t * 0.80) * color.opacity;
        paint.color = color.withOpacity(a.clamp(0.0, 1.0));
        canvas.drawCircle(Offset(x, y + 12), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.color != color;
}
