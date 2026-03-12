import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/home/widget/advanced_search/advanced_search_sheet.dart';
import 'package:responsive_screen_master/extensions/orienation_type_value.dart';
import 'package:responsive_screen_master/extensions/responsive_nums.dart';
import 'package:responsive_screen_master/extensions/screen_type_value.dart';

class CleanSearchBarTrigger extends StatelessWidget {
  const CleanSearchBarTrigger({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: stv(
          context: context,
          mobile: 16.sw,
          tablet: 24.sw,
          desktop: 32.sw,
        ),
        vertical: otv(context: context, portrait: 10.sh, landscape: 5.sh),
      ),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AdvancedSearchSheet(),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: stv(
              context: context,
              mobile: 16.sw,
              tablet: 24.sw,
              desktop: 32.sw,
            ),
            vertical: otv(context: context, portrait: 16.sh, landscape: 30.sh),
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(
              stv(
                context: context,
                mobile: 10.sp,
                tablet: 12.sp,
                desktop: 14.sp,
              ),
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: const Color(0xFF2563EB),
                size: otv(
                  context: context,
                  portrait: stv(
                    context: context,
                    mobile: 22.spScaled,
                    tablet: 24.spScaled,
                    desktop: 28.spScaled,
                  ),
                  landscape: stv(
                    context: context,
                    mobile: 24.spScaled,
                    tablet: 28.spScaled,
                    desktop: 32.spScaled,
                  ),
                ),
              ),
              SizedBox(
                width: stv(
                  context: context,
                  mobile: 12.sw,
                  tablet: 16.sw,
                  desktop: 20.sw,
                ),
              ),
              Expanded(
                child: Text(
                  context.tr('home_search_placeholder'),
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: otv(
                      context: context,
                      portrait: stv(
                        context: context,
                        mobile: 14.spScaled,
                        tablet: 16.spScaled,
                        desktop: 18.spScaled,
                      ),
                      landscape: stv(
                        context: context,
                        mobile: 16.spScaled,
                        tablet: 18.spScaled,
                        desktop: 20.spScaled,
                      ),
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.tune,
                size: otv(
                  context: context,
                  portrait: stv(
                    context: context,
                    mobile: 18.spScaled,
                    tablet: 20.spScaled,
                    desktop: 24.spScaled,
                  ),
                  landscape: stv(
                    context: context,
                    mobile: 20.spScaled,
                    tablet: 24.spScaled,
                    desktop: 28.spScaled,
                  ),
                ),
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
