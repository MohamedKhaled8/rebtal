import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:rebtal/core/utils/widgets/rating_display_widget.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class TopRatedSection extends StatelessWidget {
  const TopRatedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return StreamBuilder<QuerySnapshot>(
      // Ordering by rating if possible, or just limit and filter in builder
      stream: FirebaseFirestore.instance
          .collection('chalets')
          .where('status', isEqualTo: 'approved')
          .limit(10) // Ideally order by averageRating descending
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        // Sort locally because Firestore composite indexes might be missing
        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final ra = (a.data() as Map<String, dynamic>)['averageRating'] ?? 0.0;
          final rb = (b.data() as Map<String, dynamic>)['averageRating'] ?? 0.0;
          return rb.compareTo(ra);
        });

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
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
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
                            docId: docId,
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
                          // Large Image with Glass Rating
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24.sp),
                                child: AppImageHelper(
                                  path: imageUrl.toString(),
                                  cacheScope: docId,
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
                                  chaletId: docId,
                                  isDark: isDark,
                                  isBadge: true,
                                ),
                              ),
                            ],
                          ),

                          // Info
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
                                  data['chaletName'] ?? 'شاليه',
                                  style: TextStyle(
                                    fontSize: stv(
                                      context: context,
                                      mobile: 18.spScaled,
                                      tablet: 20.spScaled,
                                      desktop: 24.spScaled,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
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
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey,
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
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.grey,
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
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.grey[400],
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
              ),
            ),
          ],
        );
      },
    );
  }
}
