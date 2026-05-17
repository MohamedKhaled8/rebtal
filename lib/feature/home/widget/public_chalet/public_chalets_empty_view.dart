import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PublicChaletsEmptyView extends StatelessWidget {
  const PublicChaletsEmptyView({
    super.key,
    required this.shrinkWrap,
    required this.listPhysics,
    required this.isDark,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
  });

  final bool shrinkWrap;
  final ScrollPhysics listPhysics;
  final bool isDark;
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: listPhysics,
      padding: EdgeInsets.symmetric(vertical: 20.sh),
      children: [
        SizedBox(
          height: 220.sh,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.sw),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    emptyIcon ?? Icons.search_off_rounded,
                    size: 60.spScaled,
                    color: isDark ? Colors.white24 : Colors.grey[400],
                  ),
                ),
                SizedBox(height: 20.sh),
                Text(
                  emptyTitle ?? context.tr('home_no_results'),
                  style: TextStyle(
                    fontSize: 18.spScaled,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
