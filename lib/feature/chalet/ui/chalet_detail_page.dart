import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';
import 'package:rebtal/feature/chalet/widget/fixed_bottom_bar.dart';
import 'package:rebtal/feature/chalet/widget/image_header_section.dart';
import 'package:rebtal/feature/chalet/widget/action_buttons.dart';
import 'package:rebtal/feature/chalet/widget/availability_card.dart';
import 'package:rebtal/feature/chalet/widget/location_map_card.dart';
import 'package:rebtal/feature/chalet/widget/owner_information_card.dart';
import 'package:rebtal/feature/chalet/widget/property_features_card.dart';
import 'package:rebtal/feature/chalet/widget/request_details_card.dart';
import 'package:rebtal/feature/chalet/widget/section_title.dart';
import 'package:rebtal/feature/chalet/widget/reviews_section.dart';
import 'package:animate_do/animate_do.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/chalet/widget/booking_dates_display.dart';

class ChaletDetailPage extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String docId;
  final String status;

  const ChaletDetailPage({
    super.key,
    required this.requestData,
    required this.docId,
    required this.status,
    this.bookingId,
    this.isReOffer = false,
  });

  final String? bookingId;
  final bool isReOffer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChaletDetailCubit()..initialize(requestData),
      child: BlocSelector<ChaletDetailCubit, ChaletDetailState, List<String>>(
        selector: (state) {
          if (state is ChaletDetailLoaded) {
            return state.images;
          }
          return <String>[];
        },
        builder: (context, images) {
          return BlocBuilder<AppCubit, AppState>(
            builder: (context, appState) {
              String role = 'guest';
              if (appState is AppAuthenticated) {
                role = context.read<AppCubit>().getCurrentRole();
              }

              final isDark = DynamicThemeManager.isDarkMode(context);
              // Force Airbnb styling (White/Black)
              final backgroundColor = isDark
                  ? const Color(0xFF121212)
                  : const Color(0xFFFFFFFF);
              final textColor = isDark ? Colors.white : const Color(0xFF222222);

              final hotelName = requestData['chaletName'] ?? 'Chalet Name';
              final location = requestData['location'] ?? 'Unknown Location';
              final price = requestData['price'];
              final description = requestData['description']?.toString() ?? '';

              // Helper to safely get int from multiple keys
              int getInt(List<String> keys) {
                for (final key in keys) {
                  final val = requestData[key];
                  if (val is num) return val.toInt();
                  if (val is String) return int.tryParse(val) ?? 0;
                }
                return 0;
              }

              final guests = getInt([
                'guests',
                'capacity',
                'guestCount',
                'maxGuests',
                'max_guests',
                'childrenCount',
              ]);
              final bedrooms = getInt([
                'bedrooms',
                'bedroomCount',
                'rooms',
                'roomCount',
              ]);

              // Use bedrooms count as fallback for beds if beds is 0
              int beds = getInt(['beds', 'bedCount', 'numBeds', 'num_beds']);
              if (beds == 0 && bedrooms > 0) beds = bedrooms;

              final bathrooms = getInt(['bathrooms', 'bathroomCount', 'baths']);

              // Area should check 'chaletArea' first (from ChaletModel)
              final areaVal =
                  requestData['chaletArea'] ??
                  requestData['area'] ??
                  requestData['size'] ??
                  requestData['totalArea'];

              final area =
                  (areaVal == null ||
                      areaVal.toString() == '0' ||
                      areaVal.toString() == '0.0')
                  ? null
                  : areaVal.toString();

              // Safe rating/reviews extraction
              final ratingVal =
                  (requestData['rating'] as num?)?.toDouble() ?? 0.0;
              final reviewsVal =
                  (requestData['reviews_count'] as num?)?.toInt() ??
                  (requestData['ratingCount'] as num?)?.toInt() ??
                  0;
              final formattedRating = ratingVal == 0
                  ? 'New'
                  : ratingVal.toString();

              return Scaffold(
                backgroundColor: backgroundColor,
                body: Stack(
                  children: [
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // 1. Image Header (Full width)
                        SliverToBoxAdapter(
                          child: ImageHeaderSection(
                            hotelName: hotelName,
                            location: location,
                            requestData: requestData,
                            docId: docId,
                          ),
                        ),

                        // 2. Main Content
                        SliverToBoxAdapter(
                          child: Container(
                            color: backgroundColor,
                            padding: const EdgeInsets.only(
                              left: 24,
                              right: 24,
                              top: 24,
                              bottom: 120, // Space for bottom bar
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // A. Title Section
                                FadeInUp(
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeOutQuart,
                                  child: RepaintBoundary(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hotelName,
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                            letterSpacing:
                                                -0.2, // Tight spacing
                                          ),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          location,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${area != null ? 'Area $area m² · ' : ''}${guests > 0 ? '$guests · ' : ''}$bedrooms bedroom · $beds beds",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.white70
                                                : const Color(0xFF717171),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // B. Stats Row
                                FadeInUp(
                                  duration: const Duration(milliseconds: 1000),
                                  delay: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutQuart,
                                  child: RepaintBoundary(
                                    child: _buildStatsRow(
                                      isDark,
                                      textColor,
                                      formattedRating,
                                      reviewsVal.toString(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                FadeIn(
                                  delay: const Duration(milliseconds: 400),
                                  child: Divider(
                                    height: 1,
                                    color: isDark
                                        ? Colors.white24
                                        : const Color(0xFFDDDDDD),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // C. Host Section
                                FadeInUp(
                                  duration: const Duration(milliseconds: 1000),
                                  delay: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutQuart,
                                  child: RepaintBoundary(
                                    child: OwnerInformationCard(
                                      requestData: requestData,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                FadeIn(
                                  delay: const Duration(milliseconds: 600),
                                  child: Divider(
                                    height: 1,
                                    color: isDark
                                        ? Colors.white24
                                        : const Color(0xFFDDDDDD),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // D. Highlights (Property Features)
                                FadeInUp(
                                  duration: const Duration(milliseconds: 1000),
                                  delay: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutQuart,
                                  child: RepaintBoundary(
                                    child: PropertyFeaturesCard(
                                      requestData: requestData,
                                      isDark: isDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                FadeIn(
                                  delay: const Duration(milliseconds: 800),
                                  child: Divider(
                                    height: 1,
                                    color: isDark
                                        ? Colors.white24
                                        : const Color(0xFFDDDDDD),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // F. Description
                                FadeInUp(
                                  duration: const Duration(milliseconds: 1000),
                                  delay: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutQuart,
                                  child: RepaintBoundary(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle(
                                          "About this place",
                                          textColor,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          description,
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            fontWeight: FontWeight.w400,
                                            color: isDark
                                                ? Colors.white70
                                                : const Color(0xFF717171),
                                          ),
                                          maxLines: 6,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildShowMoreButton(isDark, textColor),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                FadeIn(
                                  delay: const Duration(milliseconds: 1000),
                                  child: Divider(
                                    height: 1,
                                    color: isDark
                                        ? Colors.white24
                                        : const Color(0xFFDDDDDD),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // G. Gallery Strip
                                FadeInUp(
                                  duration: const Duration(milliseconds: 1000),
                                  delay: const Duration(milliseconds: 1000),
                                  curve: Curves.easeOutQuart,
                                  child: RepaintBoundary(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle(
                                          "Gallery",
                                          textColor,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildGalleryStrip(
                                          context,
                                          images,
                                          isDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                FadeIn(
                                  delay: const Duration(milliseconds: 1200),
                                  child: Divider(
                                    height: 1,
                                    color: isDark
                                        ? Colors.white24
                                        : const Color(0xFFDDDDDD),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // H. Amenities (Map)
                                FadeInUp(
                                  duration: const Duration(milliseconds: 1000),
                                  delay: const Duration(milliseconds: 1200),
                                  curve: Curves.easeOutQuart,
                                  child: RepaintBoundary(
                                    child: LocationMapCard(
                                      location: location,
                                      latitude: requestData['latitude'] != null
                                          ? (requestData['latitude'] as num)
                                                .toDouble()
                                          : (requestData['lat'] != null
                                                ? (requestData['lat'] as num)
                                                      .toDouble()
                                                : null),
                                      longitude:
                                          requestData['longitude'] != null
                                          ? (requestData['longitude'] as num)
                                                .toDouble()
                                          : (requestData['lon'] != null
                                                ? (requestData['lon'] as num)
                                                      .toDouble()
                                                : null),
                                      fallbackImage: images.isNotEmpty
                                          ? images.first
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                FadeIn(
                                  delay: const Duration(milliseconds: 1400),
                                  child: Divider(
                                    height: 1,
                                    color: isDark
                                        ? Colors.white24
                                        : const Color(0xFFDDDDDD),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Reviews
                                FadeInUp(
                                  duration: const Duration(milliseconds: 1000),
                                  delay: const Duration(milliseconds: 1400),
                                  curve: Curves.easeOutQuart,
                                  child: RepaintBoundary(
                                    child: ReviewsSection(
                                      chaletId: docId,
                                      isDark: isDark,
                                      requestData: requestData,
                                    ),
                                  ),
                                ),

                                // Booking Dates (Start/End)
                                if (requestData['availableFrom'] != null &&
                                    requestData['availableTo'] != null) ...[
                                  const SizedBox(height: 24),
                                  FadeIn(
                                    delay: const Duration(milliseconds: 1500),
                                    child: Divider(
                                      height: 1,
                                      color: isDark
                                          ? Colors.white24
                                          : const Color(0xFFDDDDDD),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  FadeInUp(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    delay: const Duration(milliseconds: 1500),
                                    curve: Curves.easeOutQuart,
                                    child: RepaintBoundary(
                                      child: BookingDatesDisplay(
                                        requestData: requestData,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ),
                                ],

                                // Admin Sections
                                if (role == 'admin' || role == 'owner') ...[
                                  FadeInUp(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    delay: const Duration(milliseconds: 1600),
                                    curve: Curves.easeOutQuart,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 24),
                                        Divider(
                                          height: 1,
                                          color: isDark
                                              ? Colors.white24
                                              : const Color(0xFFDDDDDD),
                                        ),
                                        const SizedBox(height: 24),
                                        _buildSectionTitle(
                                          'Availability',
                                          textColor,
                                        ),
                                        const SizedBox(height: 16),
                                        AvailabilityCard(
                                          requestData: requestData,
                                        ),
                                        if (role == 'admin') ...[
                                          const SizedBox(height: 24),
                                          _buildSectionTitle(
                                            'Request Details',
                                            textColor,
                                          ),
                                          const SizedBox(height: 16),
                                          RequestDetailsCard(
                                            docId: docId,
                                            requestData: requestData,
                                          ),
                                        ],
                                        const SizedBox(height: 24),
                                        ActionButtons(
                                          status: status,
                                          docId: docId,
                                          requestData: requestData,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 3. Fixed Bottom Bar
                    if (role == 'user' || role == 'guest')
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: FixedBottomBar(
                          price: price,
                          requestData: requestData,
                          isDark: isDark,
                          docId: docId,
                          bookingId: bookingId,
                          isReOffer: isReOffer,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGalleryStrip(
    BuildContext context,
    List<String> images,
    bool isDark,
  ) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              context.read<ChaletDetailCubit>().openFullScreen(
                context,
                images: images,
                start: index,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: AppImageHelper(path: images[index], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(
    bool isDark,
    Color textColor,
    String rating,
    String reviewsCount,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide.none, // Handled by external dividers
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(rating, "Rating", Icons.star, true, isDark, textColor),
          _buildVerticalDivider(isDark),
          _buildStatItem(
            "Guest\nfavorite",
            "",
            null,
            false,
            isDark,
            textColor,
            isBadge: true,
          ),
          _buildVerticalDivider(isDark),
          _buildStatItem(
            reviewsCount,
            "Reviews",
            null,
            false,
            isDark,
            textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String mainText,
    String subText,
    IconData? icon,
    bool showIcon,
    bool isDark,
    Color textColor, {
    bool isBadge = false,
  }) {
    if (isBadge) {
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
                    children: [
                      // Left Laurel Branch
                      SizedBox(
                        width: 20,
                        height: 40,
                        child: Stack(
                          children: [
                            _buildLaurelLeaf(
                              value,
                              bottom: 2,
                              left: 8,
                              rotate: -0.8,
                              size: 8,
                              textColor: textColor,
                            ),
                            _buildLaurelLeaf(
                              value,
                              bottom: 8,
                              left: 4,
                              rotate: -0.6,
                              size: 10,
                              textColor: textColor,
                            ),
                            _buildLaurelLeaf(
                              value,
                              bottom: 16,
                              left: 2,
                              rotate: -0.4,
                              size: 11,
                              textColor: textColor,
                            ),
                            _buildLaurelLeaf(
                              value,
                              bottom: 24,
                              left: 6,
                              rotate: -0.2,
                              size: 10,
                              textColor: textColor,
                            ),
                            _buildLaurelLeaf(
                              value,
                              bottom: 32,
                              left: 10,
                              rotate: 0,
                              size: 8,
                              textColor: textColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Guest",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "favourite",
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
                      // Right Laurel Branch
                      SizedBox(
                        width: 20,
                        height: 40,
                        child: Stack(
                          children: [
                            _buildLaurelLeaf(
                              value,
                              bottom: 2,
                              right: 8,
                              rotate: 0.8,
                              size: 8,
                              textColor: textColor,
                            ),
                            _buildLaurelLeaf(
                              value,
                              bottom: 8,
                              right: 4,
                              rotate: 0.6,
                              size: 10,
                              textColor: textColor,
                            ),
                            _buildLaurelLeaf(
                              value,
                              bottom: 16,
                              right: 2,
                              rotate: 0.4,
                              size: 11,
                              textColor: textColor,
                            ),
                            _buildLaurelLeaf(
                              value,
                              bottom: 24,
                              right: 6,
                              rotate: 0.2,
                              size: 10,
                              textColor: textColor,
                            ),
                            _buildLaurelLeaf(
                              value,
                              bottom: 32,
                              right: 10,
                              rotate: 0,
                              size: 8,
                              textColor: textColor,
                            ),
                          ],
                        ),
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
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mainText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (showIcon) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 14, color: textColor),
              ],
            ],
          ),
          if (subText.isNotEmpty)
            Text(
              subText,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
                decoration: TextDecoration.underline,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLaurelLeaf(
    double value, {
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double rotate,
    required double size,
    required Color textColor,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom != null ? bottom * value : null,
      child: Transform.rotate(
        angle: rotate,
        child: Opacity(
          opacity: value,
          child: Icon(
            Icons.spa_rounded,
            size: size,
            color: textColor.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 40,
      width: 1,
      color: isDark ? Colors.white24 : const Color(0xFFDDDDDD),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildShowMoreButton(bool isDark, Color textColor) {
    return Row(
      children: [
        Text(
          "Show more",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            color: textColor,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.arrow_forward_ios, size: 12, color: textColor),
      ],
    );
  }
}
