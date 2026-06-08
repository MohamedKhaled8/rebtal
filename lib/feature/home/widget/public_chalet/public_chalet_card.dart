import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/widgets/rating_display_widget.dart';
import 'package:rebtal/core/utils/widgets/glass_badge.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:rebtal/feature/home/logic/helpers/chalet_card_display_helper.dart';
import 'package:rebtal/feature/home/widget/public_chalet/chalet_favorite_button.dart';
import 'package:rebtal/feature/home/widget/public_chalet/chalet_image_carousel.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PublicChaletCard extends StatelessWidget {
  const PublicChaletCard({
    super.key,
    required this.chaletData,
    required this.docId,
    this.onDetailsPressed,
    this.badge,
    this.margin,
  });

  final Map<String, dynamic> chaletData;
  final String docId;
  final VoidCallback? onDetailsPressed;
  final Widget? badge;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return PublicChaletCardBody(
      chaletData: chaletData,
      docId: docId,
      onDetailsPressed: onDetailsPressed,
      badge: badge,
      margin: margin,
    );
  }
}

class PublicChaletCardBody extends StatelessWidget {
  const PublicChaletCardBody({
    super.key,
    required this.chaletData,
    required this.docId,
    this.onDetailsPressed,
    this.badge,
    this.margin,
  });

  final Map<String, dynamic> chaletData;
  final String docId;
  final VoidCallback? onDetailsPressed;
  final Widget? badge;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final chaletName =
        chaletData['chaletName'] ?? context.tr('home_chalet_no_name');
    final location =
        chaletData['location'] ?? context.tr('home_location_unknown');
    final rawImages = collectChaletImageUrls(chaletData);
    final images = rawImages.isEmpty ? const [''] : rawImages;
    final isDark = DynamicThemeManager.isDarkMode(context);
    final dayUseUnavailable = ChaletCardDisplayHelper.isDayUseUnavailableToday(
      chaletData,
    );
    final hasDiscount = ChaletCardDisplayHelper.hasDiscount(chaletData);
    final isNew = ChaletCardDisplayHelper.isNewChalet(chaletData);

    return RepaintBoundary(
      child: Container(
        margin:
            margin ??
            EdgeInsets.only(
              bottom: otv(context: context, portrait: 24.sh, landscape: 12.sh),
              left: stv(
                context: context,
                mobile: 16.sw,
                tablet: 24.sw,
                desktop: 32.sw,
              ),
              right: stv(
                context: context,
                mobile: 16.sw,
                tablet: 24.sw,
                desktop: 32.sw,
              ),
            ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B0F0D) : Colors.white,
          borderRadius: BorderRadius.circular(12.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap:
              onDetailsPressed ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChaletDetailPage(
                      requestData: chaletData,
                      docId: docId,
                      status: 'approved',
                    ),
                  ),
                );
              },
          borderRadius: BorderRadius.circular(12.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.sp),
                    ),
                    child: ChaletImageCarousel(docId: docId, images: images),
                  ),
                  Positioned(
                    top: 20,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RatingDisplayWidget(
                          chaletId: docId,
                          isDark: false,
                          isBadge: true,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (dayUseUnavailable)
                              PublicChaletDayUseBadge(
                                label: context.tr('chalet_unavailable'),
                              ),
                            if (isNew)
                              PublicChaletNewBadge(
                                label: context.tr('common_new_badge'),
                              ),
                            ChaletFavoriteButton(
                              chaletId: docId,
                              chaletData: chaletData,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GlassBadge(
                        backgroundColor: const Color(
                          0xFF2563EB,
                        ).withOpacity(0.75),
                        borderColor: Colors.white.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        borderRadius: 8,
                        child: Text(
                          context.tr('home_special_offer'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(
                  stv(
                    context: context,
                    mobile: 10.sw,
                    tablet: 12.sw,
                    desktop: 15.sw,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chaletName,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: stv(
                                context: context,
                                mobile: 18.spScaled,
                                tablet: 22.spScaled,
                                desktop: 26.spScaled,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: stv(
                            context: context,
                            mobile: 8.sw,
                            tablet: 12.sw,
                            desktop: 16.sw,
                          ),
                        ),
                        PublicChaletPriceSection(
                          chaletData: chaletData,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: otv(
                        context: context,
                        portrait: 4.sh,
                        landscape: 2.sh,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: stv(
                            context: context,
                            mobile: 14.spScaled,
                            tablet: 16.spScaled,
                            desktop: 18.spScaled,
                          ),
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                        SizedBox(
                          width: stv(
                            context: context,
                            mobile: 4.sw,
                            tablet: 6.sw,
                            desktop: 8.sw,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              fontSize: stv(
                                context: context,
                                mobile: 12.spScaled,
                                tablet: 14.spScaled,
                                desktop: 16.spScaled,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: otv(
                        context: context,
                        portrait: 12.sh,
                        landscape: 6.sh,
                      ),
                    ),
                    PublicChaletStatsRow(
                      chaletData: chaletData,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PublicChaletDayUseBadge extends StatelessWidget {
  const PublicChaletDayUseBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GlassBadge(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class PublicChaletNewBadge extends StatelessWidget {
  const PublicChaletNewBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GlassBadge(
        backgroundColor: const Color(0xFF2563EB).withOpacity(0.75),
        borderColor: Colors.white.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class PublicChaletStatsRow extends StatelessWidget {
  const PublicChaletStatsRow({
    super.key,
    required this.chaletData,
    required this.isDark,
  });

  final Map<String, dynamic> chaletData;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PublicChaletStatItem(
          icon: Icons.bed_outlined,
          label:
              '${chaletData['bedrooms'] ?? 0} ${context.tr('common_beds_short')}',
          isDark: isDark,
        ),
        SizedBox(
          width: stv(
            context: context,
            mobile: 16.sw,
            tablet: 24.sw,
            desktop: 32.sw,
          ),
        ),
        PublicChaletStatItem(
          icon: Icons.bathtub_outlined,
          label:
              '${chaletData['bathrooms'] ?? 0} ${context.tr('common_baths_short')}',
          isDark: isDark,
        ),
        if (chaletData['chaletArea'] != null) ...[
          SizedBox(
            width: stv(
              context: context,
              mobile: 16.sw,
              tablet: 24.sw,
              desktop: 32.sw,
            ),
          ),
          PublicChaletStatItem(
            icon: Icons.square_foot_outlined,
            label: '${chaletData['chaletArea']} ${context.tr('common_m2')}',
            isDark: isDark,
          ),
        ],
      ],
    );
  }
}

class PublicChaletStatItem extends StatelessWidget {
  const PublicChaletStatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: stv(
            context: context,
            mobile: 14.spScaled,
            tablet: 16.spScaled,
            desktop: 18.spScaled,
          ),
          color: isDark ? Colors.white70 : Colors.grey[600], // Changed from black45 for better contrast in light mode too
        ),
        SizedBox(
          width: stv(
            context: context,
            mobile: 4.sw,
            tablet: 6.sw,
            desktop: 8.sw,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: stv(
              context: context,
              mobile: 11.spScaled,
              tablet: 13.spScaled,
              desktop: 15.spScaled,
            ),
            color: isDark ? Colors.white70 : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PublicChaletPriceSection extends StatelessWidget {
  const PublicChaletPriceSection({
    super.key,
    required this.chaletData,
    required this.isDark,
  });

  final Map<String, dynamic> chaletData;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final price = chaletData['price'];
    final hasDisc = ChaletCardDisplayHelper.hasDiscount(chaletData);
    final discounted = ChaletCardDisplayHelper.calculateDiscountedPrice(
      chaletData,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasDisc)
          Text(
            '$price',
            style: TextStyle(
              fontSize: stv(
                context: context,
                mobile: 15.spScaled,
                tablet: 17.spScaled,
                desktop: 19.spScaled,
              ),
              color: isDark ? Colors.white70 : Colors.grey[700],
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.red.withOpacity(0.5),
              decorationThickness: 2,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              hasDisc ? discounted : '$price',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: stv(
                  context: context,
                  mobile: 18.spScaled,
                  tablet: 22.spScaled,
                  desktop: 26.spScaled,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: stv(
                context: context,
                mobile: 4.sw,
                tablet: 6.sw,
                desktop: 8.sw,
              ),
            ),
            Text(
              context.tr('booking_egp_currency'),
              style: TextStyle(
                fontSize: stv(
                  context: context,
                  mobile: 10.spScaled,
                  tablet: 12.spScaled,
                  desktop: 14.spScaled,
                ),
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
