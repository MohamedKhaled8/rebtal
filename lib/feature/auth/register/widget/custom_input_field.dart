import 'package:flutter/material.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);

    // Glow animation for focus state
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Shimmer effect animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Ripple effect on focus
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Spring-based scale animation
    _scaleAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.elasticOut,
    );

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    widget.controller.addListener(_handleTextChanged);
    _hasText = widget.controller.text.isNotEmpty;
  }

  void _handleTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _glowController.forward();
      _rippleController.forward(from: 0);
    } else {
      _glowController.reverse();
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant CustomInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
      _hasText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final showFloatingLabel = isFocused || _hasText;

    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _rippleController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // Outer glow effect
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF3B82F6,
                ).withOpacity(isFocused ? 0.3 * _glowController.value : 0.0),
                blurRadius: 20 + (15 * _glowController.value),
                spreadRadius: -5 + (3 * _glowController.value),
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isFocused ? 0.05 : 0.08),
                blurRadius: isFocused ? 25 : 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // Vibrant gradient on focus
              gradient: isFocused
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFDEEBFF),
                        const Color(0xFFF0F7FF),
                        const Color(0xFFE6F2FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.5, 1.0],
                    )
                  : LinearGradient(
                      colors: [
                        const Color(0xFFFAFAFA),
                        const Color(0xFFFFFFFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              // Subtle border
              border: Border.all(
                color: isFocused
                    ? const Color(0xFF3B82F6).withOpacity(0.3)
                    : const Color(0xFFE2E8F0).withOpacity(0.6),
                width: isFocused ? 1.5 : 1.0,
              ),
            ),
            child: Stack(
              children: [
                // Animated shimmer effect on focus
                if (isFocused)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, _) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF3B82F6).withOpacity(0.08),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment(_shimmerAnimation.value, -1),
                              end: Alignment(_shimmerAnimation.value + 0.5, 1),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Ripple effect on focus
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _rippleController,
                    builder: (context, _) {
                      return Opacity(
                        opacity: (1 - _rippleController.value) * 0.4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF3B82F6).withOpacity(0.2),
                                Colors.transparent,
                              ],
                              stops: [
                                _rippleController.value * 0.5,
                                _rippleController.value,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Main content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Floating label with scale animation
                      if (showFloatingLabel)
                        Padding(
                          padding: EdgeInsets.only(bottom: 0.4.h),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: showFloatingLabel ? 1 : 0,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 300),
                              scale: showFloatingLabel ? 1.0 : 0.8,
                              curve: Curves.easeOutBack,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.label,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: isFocused
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Input row with proper vertical centering
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Animated icon with pulse effect
                          AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (0.12 * _scaleAnimation.value),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: EdgeInsets.all(isFocused ? 6 : 5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isFocused
                                        ? LinearGradient(
                                            colors: [
                                              const Color(
                                                0xFF3B82F6,
                                              ).withOpacity(0.15),
                                              const Color(
                                                0xFF2563EB,
                                              ).withOpacity(0.08),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                  ),
                                  child: Icon(
                                    widget.icon,
                                    color: isFocused
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF94A3B8),
                                    size: 19,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 2.w),

                          // Text field
                          Expanded(
                            child: TextFormField(
                              controller: widget.controller,
                              focusNode: _focusNode,
                              obscureText: widget.obscureText,
                              keyboardType: widget.keyboardType,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                              decoration: InputDecoration(
                                hintText: showFloatingLabel
                                    ? null
                                    : widget.label,
                                hintStyle: TextStyle(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.1,
                                ),
                                border: InputBorder.none,
                                suffixIcon: widget.suffixIcon,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
