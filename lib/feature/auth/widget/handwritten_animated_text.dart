import 'package:flutter/material.dart';

class HandwrittenAnimatedText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Duration animationDuration;
  final bool isDark;

  const HandwrittenAnimatedText({
    super.key,
    required this.text,
    this.fontSize = 64,
    required this.color,
    this.animationDuration = const Duration(milliseconds: 2800),
    this.isDark = false,
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
      curve: const Interval(0.0, 0.95, curve: Curves.easeInOut),
    );

    // Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 400), () {
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

  const _AnimatedTextWidget({
    required this.text,
    required this.fontSize,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate how many characters to show
    final totalChars = text.length;
    final charsToShow = (totalChars * progress).floor();
    final remainingProgress = (totalChars * progress) - charsToShow;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalChars, (index) {
        if (index < charsToShow) {
          // Fully visible character
          return _HandwrittenChar(
            char: text[index],
            fontSize: fontSize,
            color: color,
            opacity: 1.0,
            index: index,
          );
        } else if (index == charsToShow && remainingProgress > 0) {
          // Partially visible character (being drawn)
          return _HandwrittenChar(
            char: text[index],
            fontSize: fontSize,
            color: color,
            opacity: remainingProgress,
            index: index,
          );
        } else {
          // Not yet visible
          return _HandwrittenChar(
            char: text[index],
            fontSize: fontSize,
            color: color,
            opacity: 0.0,
            index: index,
          );
        }
      }),
    );
  }
}

class _HandwrittenChar extends StatelessWidget {
  final String char;
  final double fontSize;
  final Color color;
  final double opacity;
  final int index;

  const _HandwrittenChar({
    required this.char,
    required this.fontSize,
    required this.color,
    required this.opacity,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Add slight rotation for handwriting effect
    final rotation = (char.hashCode % 7 - 3) * 0.03;
    final offsetY = (char.hashCode % 5 - 2) * 1.5;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: opacity),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: rotation * value,
          child: Transform.translate(
            offset: Offset(0, offsetY * (1 - value)),
              child: Opacity(
              opacity: value,
              child: Text(
                char,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                  color: color,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.25 * value),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                    Shadow(
                      color: color.withOpacity(0.15 * value),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

