import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom animated theme toggle button with ripple/wave effect
class AnimatedThemeToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Duration duration;

  const AnimatedThemeToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<AnimatedThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _rippleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.value) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(AnimatedThemeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      // Add haptic feedback for better UX
      HapticFeedback.lightImpact();
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _rippleAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              Container(
                width: 52,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: widget.value
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.grey.shade300,
                ),
              ),
              // Ripple/Wave effect
              Positioned(
                left: widget.value ? null : 0,
                right: widget.value ? 0 : null,
                child: Container(
                  width: 28 + (_rippleAnimation.value * 24),
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.value
                        ? Colors.blue.withOpacity(
                            0.5 - (_rippleAnimation.value * 0.2),
                          )
                        : Colors.grey.shade400.withOpacity(
                            0.5 - ((1 - _rippleAnimation.value) * 0.2),
                          ),
                  ),
                ),
              ),
              // Thumb (the circle button)
              Positioned(
                left: widget.value ? null : 2 + (_rippleAnimation.value * 20),
                right: widget.value
                    ? 2 + ((1 - _rippleAnimation.value) * 20)
                    : null,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: widget.value
                          ? Icon(
                              Icons.nightlight_round,
                              size: 14,
                              color: Colors.blue,
                              key: ValueKey('dark'),
                            )
                          : Icon(
                              Icons.wb_sunny_outlined,
                              size: 14,
                              color: Colors.orange,
                              key: ValueKey('light'),
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

/// A widget that wraps content with a theme transition ripple effect
class ThemeTransitionWrapper extends StatefulWidget {
  final Widget child;
  final ThemeMode currentTheme;

  const ThemeTransitionWrapper({
    super.key,
    required this.child,
    required this.currentTheme,
  });

  @override
  State<ThemeTransitionWrapper> createState() => _ThemeTransitionWrapperState();
}

class _ThemeTransitionWrapperState extends State<ThemeTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutQuart),
    );
  }

  @override
  void didUpdateWidget(ThemeTransitionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentTheme != oldWidget.currentTheme) {
      _rippleController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Full-screen ripple overlay
        AnimatedBuilder(
          animation: _rippleAnimation,
          builder: (context, child) {
            if (_rippleAnimation.value == 0 || _rippleAnimation.value == 1) {
              return const SizedBox.shrink();
            }
            return Positioned.fill(
              child: ClipPath(
                clipper: RippleClipper(_rippleAnimation.value),
                child: Container(
                  color: widget.currentTheme == ThemeMode.dark
                      ? Colors.black.withOpacity(
                          0.3 * (1 - _rippleAnimation.value),
                        )
                      : Colors.white.withOpacity(
                          0.3 * (1 - _rippleAnimation.value),
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

class RippleClipper extends CustomClipper<Path> {
  final double progress;

  RippleClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final currentRadius = size.longestSide * 1.5 * progress;

    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: currentRadius));
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
