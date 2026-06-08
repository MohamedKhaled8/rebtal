import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBadge extends StatelessWidget {
  const GlassBadge({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.borderRadius = 20.0,
    this.blurSigma = 8.0,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
