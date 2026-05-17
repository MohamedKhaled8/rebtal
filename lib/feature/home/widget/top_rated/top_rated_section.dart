import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/widgets/rating_display_widget.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';
import 'package:rebtal/feature/home/logic/helpers/top_rated_chalets_helper.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class TopRatedSection extends StatelessWidget {
  const TopRatedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeCubit, HomeState, List<HomeChaletEntity>>(
      selector: (state) =>
          TopRatedChaletsHelper.topRatedSection(state.approvedChalets),
      builder: (context, topRated) {
        if (topRated.isEmpty) return const SizedBox.shrink();

        final isDark = DynamicThemeManager.isDarkMode(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: stv(
                  context: context,
                  mobile: 16.sw,
                  tablet: 24.sw,
                  desktop: 32.sw,
                ),
                vertical: otv(
                  context: context,
                  portrait: 8.sh,
                  landscape: 4.sh,
                ),
              ),
              child: Text(
                context.tr('home_top_rated'),
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
            ),
            SizedBox(
              height: otv(
                context: context,
                portrait: stv(
                  context: context,
                  mobile: 320.sh,
                  tablet: 380.sh,
                  desktop: 440.sh,
                ),
                landscape: stv(
                  context: context,
                  mobile: 450.sh,
                  tablet: 400.sh,
                  desktop: 460.sh,
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                itemCount: topRated.length,
                itemBuilder: (context, index) {
                  return TopRatedSectionCard(
                    entity: topRated[index],
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class TopRatedSectionCard extends StatelessWidget {
  const TopRatedSectionCard({
    super.key,
    required this.entity,
    required this.isDark,
  });

  final HomeChaletEntity entity;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final data = entity.data;
    final reviews = data['reviewCount'] ?? 0;
    final images = data['images'] as List<dynamic>?;
    final imageUrl = (images != null && images.isNotEmpty)
        ? images[0]
        : data['profileImage'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChaletDetailPage(
              requestData: data,
              docId: entity.id,
              status: 'approved',
            ),
          ),
        );
      },
      child: Container(
        width: stv(
          context: context,
          mobile: 70.w,
          tablet: 45.w,
          desktop: 30.w,
        ),
        margin: EdgeInsets.only(
          right: stv(
            context: context,
            mobile: 16.sw,
            tablet: 24.sw,
            desktop: 32.sw,
          ),
          bottom: otv(
            context: context,
            portrait: 8.sh,
            landscape: 4.sh,
          ),
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          borderRadius: BorderRadius.circular(20.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.sp),
                  child: AppImageHelper(
                    path: imageUrl.toString(),
                    cacheScope: entity.id,
                    height: otv(
                      context: context,
                      portrait: stv(
                        context: context,
                        mobile: 200.sh,
                        tablet: 240.sh,
                        desktop: 280.sh,
                      ),
                      landscape: stv(
                        context: context,
                        mobile: 300.sh,
                        tablet: 260.sh,
                        desktop: 300.sh,
                      ),
                    ),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: otv(
                    context: context,
                    portrait: 16.sh,
                    landscape: 8.sh,
                  ),
                  left: stv(
                    context: context,
                    mobile: 16.sw,
                    tablet: 24.sw,
                    desktop: 32.sw,
                  ),
                  child: RatingDisplayWidget(
                    chaletId: entity.id,
                    isDark: isDark,
                    isBadge: true,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                stv(
                  context: context,
                  mobile: 12.sw,
                  tablet: 16.sw,
                  desktop: 20.sw,
                ),
                otv(
                  context: context,
                  portrait: 10.sh,
                  landscape: 8.sh,
                ),
                stv(
                  context: context,
                  mobile: 12.sw,
                  tablet: 16.sw,
                  desktop: 20.sw,
                ),
                otv(
                  context: context,
                  portrait: 5.sh,
                  landscape: 4.sh,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['chaletName'] ?? context.tr('home_chalet_no_name'),
                    style: TextStyle(
                      fontSize: stv(
                        context: context,
                        mobile: 18.spScaled,
                        tablet: 20.spScaled,
                        desktop: 24.spScaled,
                      ),
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: otv(
                      context: context,
                      portrait: 5.sh,
                      landscape: 4.sh,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: stv(
                          context: context,
                          mobile: 15.spScaled,
                          tablet: 17.spScaled,
                          desktop: 19.spScaled,
                        ),
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                      SizedBox(
                        width: stv(
                          context: context,
                          mobile: 2.sw,
                          tablet: 4.sw,
                          desktop: 6.sw,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          data['location'] ??
                              context.tr('home_location_unknown'),
                          style: TextStyle(
                            fontSize: stv(
                              context: context,
                              mobile: 14.spScaled,
                              tablet: 16.spScaled,
                              desktop: 18.spScaled,
                            ),
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '($reviews)',
                        style: TextStyle(
                          fontSize: stv(
                            context: context,
                            mobile: 10.spScaled,
                            tablet: 12.spScaled,
                            desktop: 14.spScaled,
                          ),
                          color: isDark ? Colors.white38 : Colors.grey[400],
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
  }
}
