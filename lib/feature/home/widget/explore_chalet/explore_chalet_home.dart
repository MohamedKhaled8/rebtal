import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/extensions/orienation_type_value.dart';
import 'package:responsive_screen_master/extensions/responsive_nums.dart';
import 'package:responsive_screen_master/extensions/screen_type_value.dart';

class ExploreChaletHome extends StatelessWidget {
  const ExploreChaletHome({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        stv(context: context, mobile: 20.sw, tablet: 28.sw, desktop: 36.sw),
        otv(context: context, portrait: 20.sh, landscape: 10.sh),
        stv(context: context, mobile: 20.sw, tablet: 28.sw, desktop: 36.sw),
        otv(context: context, portrait: 10.sh, landscape: 5.sh),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.tr('home_explore_chalets'),
            style: TextStyle(
              fontSize: stv(
                context: context,
                mobile: 18.spScaled,
                tablet: 22.spScaled,
                desktop: 26.spScaled,
              ),
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          ValueListenableBuilder<SearchFilters>(
            valueListenable: HomeSearch.filters,
            builder: (context, filters, _) {
              if (filters.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => HomeSearch.clear(),
                child: Text(
                  context.tr('home_reset'),
                  style: TextStyle(
                    fontSize: stv(
                      context: context,
                      mobile: 14.spScaled,
                      tablet: 16.spScaled,
                      desktop: 18.spScaled,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
