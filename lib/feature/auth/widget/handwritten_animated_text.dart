import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HandwrittenAnimatedText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Duration animationDuration;
  final bool isDark;
  final String? fontFamily;

  const HandwrittenAnimatedText({
    super.key,
    required this.text,
    this.fontSize = 64,
    required this.color,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.isDark = false,
    this.fontFamily,
  });

  @override
  State<HandwrittenAnimatedText> createState() =>
      _HandwrittenAnimatedTextState();
}

class _HandwrittenAnimatedTextState extends State<HandwrittenAnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    );

    // Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
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
        return _AnimatedTextWidget(
          text: widget.text,
          fontSize: widget.fontSize,
          color: widget.color,
          progress: _animation.value,
          fontFamily: widget.fontFamily,
        );
      },
    );
  }
}

class _AnimatedTextWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final double progress;
  final String? fontFamily;

  const _AnimatedTextWidget({
    required this.text,
    required this.fontSize,
    required this.color,
    required this.progress,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    if (fontFamily != null) {
      return Transform.translate(
        offset: Offset(0, 15.0 * (1 - progress)),
        child: Opacity(
          opacity: progress > 0.1 ? 1.0 : progress * 10,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: const [Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, progress, (progress + 0.1).clamp(0.0, 1.0)],
              ).createShader(rect);
            },
            child: Text(
              text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: fontSize,
                color: Colors.white,
                height: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    final totalChars = text.length;
    final floatIndex = totalChars * progress;
    final int visibleIndex = floatIndex.floor();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: List.generate(totalChars, (index) {
          double opacity = 0.0;
          double slideY = 10.0;

          if (index < visibleIndex) {
            opacity = 1.0;
            slideY = 0.0;
          } else if (index == visibleIndex) {
            final charProgress = floatIndex - visibleIndex;
            opacity = charProgress;
            slideY = 10.0 * (1 - charProgress);
          }

          return Transform.translate(
            offset: Offset(0, slideY),
            child: Opacity(
              opacity: opacity,
              child: Text(
                text[index],
                style: GoogleFonts.grandHotel(
                  fontSize: fontSize,
                  color: color,
                  letterSpacing: 0,
                  height: 1.0,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
