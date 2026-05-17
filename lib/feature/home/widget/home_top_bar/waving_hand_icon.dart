import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// Animated wave emoji — requires [StatefulWidget] for [AnimationController].
class WavingHandIcon extends StatefulWidget {
  const WavingHandIcon({super.key});

  @override
  State<WavingHandIcon> createState() => WavingHandIconState();
}

class WavingHandIconState extends State<WavingHandIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: -0.1, end: 0.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Text(
        '👋',
        style: TextStyle(
          fontSize: stv(
            context: context,
            mobile: 16.spScaled,
            tablet: 18.spScaled,
            desktop: 20.spScaled,
          ),
        ),
      ),
    );
  }
}
