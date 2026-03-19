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
          height: otv(context: context, portrait: 65.sh, landscape: 70.sh),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 8.sw),
              Container(
                padding: EdgeInsets.all(stv(
                  context: context,
                  mobile: 10.sp,
                  tablet: 12.sp,
                  desktop: 14.sp,
                )),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981), // primary green
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: stv(
                    context: context,
                    mobile: 22.spScaled,
                    tablet: 24.spScaled,
                    desktop: 28.spScaled,
                  ),
                ),
              ),
              SizedBox(width: 16.sw),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('home_search'),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: otv(
                          context: context,
                          portrait: stv(
                            context: context,
                            mobile: 15.spScaled,
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
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('home_search_placeholder'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                        fontSize: otv(
                          context: context,
                          portrait: stv(
                            context: context,
                            mobile: 12.spScaled,
                            tablet: 13.spScaled,
                            desktop: 14.spScaled,
                          ),
                          landscape: stv(
                            context: context,
                            mobile: 13.spScaled,
                            tablet: 14.spScaled,
                            desktop: 15.spScaled,
                          ),
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 12.sw, left: 12.sw),
                padding: EdgeInsets.all(stv(
                  context: context,
                  mobile: 8.sp,
                  tablet: 10.sp,
                  desktop: 12.sp,
                )),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: stv(
                    context: context,
                    mobile: 18.spScaled,
                    tablet: 20.spScaled,
                    desktop: 24.spScaled,
                  ),
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
