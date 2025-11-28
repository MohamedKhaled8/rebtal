import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedWaveWidget extends StatefulWidget {
  const AnimatedWaveWidget({super.key});

  @override
  State<AnimatedWaveWidget> createState() => _AnimatedWaveWidgetState();
}

class _AnimatedWaveWidgetState extends State<AnimatedWaveWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();

    // إنشاء 3 controllers مختلفة لسرعات مختلفة
    _controller1 = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _controller2 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _controller3 = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // الموجة الأولى (في الخلف)
          AnimatedBuilder(
            animation: _controller1,
            builder: (context, child) {
              return CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 200),
                painter: WavePainter(
                  animationValue: _controller1.value,
                  color: Colors.white.withOpacity(0.1),
                  waveHeight: 30,
                  waveLength: 1.5,
                ),
              );
            },
          ),

          // الموجة الثانية (في الوسط)
          AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              return CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 200),
                painter: WavePainter(
                  animationValue: _controller2.value,
                  color: Colors.white.withOpacity(0.15),
                  waveHeight: 25,
                  waveLength: 1.2,
                ),
              );
            },
          ),

          // الموجة الثالثة (في المقدمة)
          AnimatedBuilder(
            animation: _controller3,
            builder: (context, child) {
              return CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 200),
                painter: WavePainter(
                  animationValue: _controller3.value,
                  color: Colors.white.withOpacity(0.2),
                  waveHeight: 20,
                  waveLength: 1.0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double waveHeight;
  final double waveLength;

  WavePainter({
    required this.animationValue,
    required this.color,
    required this.waveHeight,
    required this.waveLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // نقطة البداية
    path.moveTo(0, size.height * 0.5);

    // رسم الموجة
    for (double x = 0; x <= size.width; x++) {
      double y =
          size.height * 0.5 +
          waveHeight *
              sin(
                (x / size.width * 2 * pi * waveLength) +
                    (animationValue * 2 * pi),
              );
      path.lineTo(x, y);
    }

    // إكمال الشكل
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Widget للدوائر المتحركة كما في الصورة
class FloatingCircles extends StatefulWidget {
  const FloatingCircles({super.key});

  @override
  State<FloatingCircles> createState() => _FloatingCirclesState();
}

class _FloatingCirclesState extends State<FloatingCircles>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // دائرة كبيرة في الأعلى اليمين
            Positioned(
              top: 20 + _floatAnimation.value,
              right: 30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // دائرة متوسطة في الوسط اليسار
            Positioned(
              top: 100 + (_floatAnimation.value * 0.7),
              left: 20,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),

            // دائرة صغيرة في الأسفل اليمين
            Positioned(
              bottom: 40 + (_floatAnimation.value * 0.5),
              right: 80,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CircularRingsBackground extends StatefulWidget {
  const CircularRingsBackground({super.key});

  @override
  State<CircularRingsBackground> createState() =>
      _CircularRingsBackgroundState();
}

class _CircularRingsBackgroundState extends State<CircularRingsBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 350),
          painter: CircularRingsPainter(animationValue: _animation.value),
        );
      },
    );
  }
}

class CircularRingsPainter extends CustomPainter {
  final double animationValue;

  CircularRingsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // الدائرة الكبيرة في الأعلى اليمين
    _drawAnimatedRing(
      canvas,
      Offset(size.width * 0.85, size.height * 0.15),
      120,
      Colors.white.withOpacity(0.08),
      animationValue,
    );

    // الدائرة المتوسطة في الوسط اليسار
    _drawAnimatedRing(
      canvas,
      Offset(size.width * 0.15, size.height * 0.45),
      80,
      Colors.white.withOpacity(0.06),
      animationValue * 0.8,
    );

    // الدائرة الصغيرة في الأسفل اليمين
    _drawAnimatedRing(
      canvas,
      Offset(size.width * 0.75, size.height * 0.75),
      60,
      Colors.white.withOpacity(0.05),
      animationValue * 1.2,
    );

    // دائرة إضافية صغيرة في الأعلى اليسار
    _drawStaticRing(
      canvas,
      Offset(size.width * 0.25, size.height * 0.25),
      40,
      Colors.white.withOpacity(0.04),
    );

    // دائرة إضافية في المنتصف
    _drawStaticRing(
      canvas,
      Offset(size.width * 0.6, size.height * 0.5),
      70,
      Colors.white.withOpacity(0.03),
    );
  }

  void _drawAnimatedRing(
    Canvas canvas,
    Offset center,
    double baseRadius,
    Color color,
    double animationValue,
  ) {
    final paint = Paint()
      ..color = color.withOpacity(color.opacity * (1 - animationValue * 0.3))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // الدائرة الخارجية المتحركة
    double animatedRadius = baseRadius + (animationValue * 20);
    canvas.drawCircle(center, animatedRadius, paint);

    // الدائرة الداخلية الثابتة
    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, baseRadius * 0.7, innerPaint);
  }

  void _drawStaticRing(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, paint);

    // دائرة داخلية أصغر
    final innerPaint = Paint()
      ..color = color.withOpacity(color.opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius * 0.6, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Widget للنقاط المضيئة الصغيرة
class GlowingDots extends StatefulWidget {
  const GlowingDots({super.key});

  @override
  State<GlowingDots> createState() => _GlowingDotsState();
}

class _GlowingDotsState extends State<GlowingDots>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 350),
          painter: GlowingDotsPainter(glowValue: _glowAnimation.value),
        );
      },
    );
  }
}

class GlowingDotsPainter extends CustomPainter {
  final double glowValue;

  GlowingDotsPainter({required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    // نقاط مضيئة متناثرة
    final positions = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.3),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.9),
    ];

    for (int i = 0; i < positions.length; i++) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.15 * glowValue)
        ..style = PaintingStyle.fill;

      // تأثير الـ glow
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.05 * glowValue)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(positions[i], 6 * glowValue, glowPaint);
      canvas.drawCircle(positions[i], 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
