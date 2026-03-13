import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class ChaletStatsRow extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final String rating;
  final String reviewsCount;

  const ChaletStatsRow({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.rating,
    required this.reviewsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ChaletStatItem(
              isDark: isDark,
              textColor: textColor,
              mainText: rating,
              subText: context.tr('chalet_rating_label'),
              icon: Icons.star,
              showIcon: true,
            ),
            ChaletVerticalDivider(isDark: isDark),
            const GuestFavoriteBadge(),
            ChaletVerticalDivider(isDark: isDark),
            ChaletStatItem(
              isDark: isDark,
              textColor: textColor,
              mainText: reviewsCount,
              subText: context.tr('chalet_reviews_label'),
            ),
          ],
        ),
    );
  }
}

class ChaletStatItem extends StatelessWidget {
  final String mainText;
  final String subText;
  final IconData? icon;
  final bool showIcon;
  final bool isDark;
  final Color textColor;

  const ChaletStatItem({
    super.key,
    required this.mainText,
    required this.subText,
    this.icon,
    this.showIcon = false,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mainText,
                style: TextStyle(
                  fontSize: stv(
                    context: context,
                    mobile: 16.spScaled,
                    tablet: 18.spScaled,
                    desktop: 20.spScaled,
                  ),
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (showIcon) ...[
                SizedBox(
                  width: stv(
                    context: context,
                    mobile: 4.sw,
                    tablet: 6.sw,
                    desktop: 8.sw,
                  ),
                ),
                Icon(
                  icon,
                  size: stv(
                    context: context,
                    mobile: 14.spScaled,
                    tablet: 16.spScaled,
                    desktop: 18.spScaled,
                  ),
                  color: textColor,
                ),
              ],
            ],
          ),
          if (subText.isNotEmpty)
            Text(
              subText,
              style: TextStyle(
                fontSize: stv(
                  context: context,
                  mobile: 12.spScaled,
                  tablet: 14.spScaled,
                  desktop: 16.spScaled,
                ),
                color: isDark ? Colors.white70 : Colors.grey[600],
                decoration: TextDecoration.underline,
              ),
            ),
        ],
      ),
    );
  }
}

class GuestFavoriteBadge extends StatefulWidget {
  const GuestFavoriteBadge({super.key});

  @override
  State<GuestFavoriteBadge> createState() => _GuestFavoriteBadgeState();
}

class _GuestFavoriteBadgeState extends State<GuestFavoriteBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black);
    return Expanded(
      child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textDirection: TextDirection.ltr,
                    children: [
                      _LaurelBranch(
                        isLeft: true,
                        progress: value,
                        textColor: textColor,
                      ),
                      const SizedBox(width: 4),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr('chalet_guest_label'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('chalet_favourite_label'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      _LaurelBranch(
                        isLeft: false,
                        progress: value,
                        textColor: textColor,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
    );
  }
}

class _LaurelBranch extends StatelessWidget {
  final bool isLeft;
  final double progress;
  final Color textColor;

  const _LaurelBranch({
    required this.isLeft,
    required this.progress,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 40,
      child: Stack(
        children: [
          _buildLeaf(bottom: 2, offset: 8, rotate: isLeft ? -0.8 : 0.8, size: 8),
          _buildLeaf(bottom: 8, offset: 4, rotate: isLeft ? -0.6 : 0.6, size: 10),
          _buildLeaf(bottom: 16, offset: 2, rotate: isLeft ? -0.4 : 0.4, size: 11),
          _buildLeaf(bottom: 24, offset: 6, rotate: isLeft ? -0.2 : 0.2, size: 10),
          _buildLeaf(bottom: 32, offset: 10, rotate: 0, size: 8),
        ],
      ),
    );
  }

  Widget _buildLeaf({
    required double bottom,
    required double offset,
    required double rotate,
    required double size,
  }) {
    return Positioned(
      left: isLeft ? offset : null,
      right: isLeft ? null : offset,
      bottom: bottom * progress,
      child: Transform.rotate(
        angle: rotate,
        child: Opacity(
          opacity: progress,
          child: Icon(
            Icons.spa_rounded,
            size: size,
            color: textColor.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}

class ChaletVerticalDivider extends StatelessWidget {
  final bool isDark;

  const ChaletVerticalDivider({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: otv(
        context: context,
        portrait: 40.sh,
        landscape: 20.sh,
      ),
      width: 1,
      color: isDark ? Colors.white24 : const Color(0xFFDDDDDD),
    );
  }
}

