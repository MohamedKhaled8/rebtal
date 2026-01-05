import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    this.animationDuration = const Duration(milliseconds: 2000),
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
    final totalChars = text.length;
    // Calculate visible characters based on progress
    // We want a fluid reveal, so we use the fractional part for opacity of the current char
    final floatIndex = totalChars * progress;
    final int visibleIndex = floatIndex.floor();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: List.generate(totalChars, (index) {
        double opacity = 0.0;
        double slideY = 10.0;

        if (index < visibleIndex) {
          // Fully visible
          opacity = 1.0;
          slideY = 0.0;
        } else if (index == visibleIndex) {
          // Fading in
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
                // Zero or negative spacing to connect letters
                letterSpacing: 0,
                height: 1.0,
              ),
            ),
          ),
        );
      }),
    );
  }
}
