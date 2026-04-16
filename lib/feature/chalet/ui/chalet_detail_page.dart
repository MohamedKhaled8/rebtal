import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/feature/chalet/function/chalet_detail_functions.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';
import 'package:rebtal/feature/chalet/widget/action_buttons.dart';
import 'package:rebtal/feature/chalet/widget/availability_card.dart';
import 'package:rebtal/feature/chalet/widget/booking_dates_display.dart';
import 'package:rebtal/feature/chalet/widget/chalet_gallery_strip.dart';
import 'package:rebtal/feature/chalet/widget/chalet_section_title.dart';
import 'package:rebtal/feature/chalet/widget/chalet_stats_row.dart';
import 'package:rebtal/feature/chalet/widget/fixed_bottom_bar.dart';
import 'package:rebtal/feature/chalet/widget/image_header_section.dart';
import 'package:rebtal/feature/chalet/widget/location_map_card.dart';
import 'package:rebtal/feature/chalet/widget/owner_information_card.dart';
import 'package:rebtal/feature/chalet/widget/property_features_card.dart';
import 'package:rebtal/feature/chalet/widget/request_details_card.dart';
import 'package:rebtal/feature/chalet/widget/reviews_section.dart';
import 'package:rebtal/feature/chalet/widget/show_more_button.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// Prefer fresh data from [AppAuthenticated.ownerChalets] after edit; else snapshot passed in.
Map<String, dynamic> _resolveChaletDisplayData(
  AppState appState,
  String docId,
  Map<String, dynamic> fallback,
) {
  if (appState is AppAuthenticated) {
    for (final c in appState.ownerChalets) {
      if (c is Map && c['id']?.toString() == docId) {
        return Map<String, dynamic>.from(c);
      }
    }
  }
  return fallback;
}

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
      key: ValueKey<String>('chalet_detail_$docId'),
      create: (context) {
        final initial = _resolveChaletDisplayData(
          context.read<AppCubit>().state,
          docId,
          requestData,
        );
        return getIt<ChaletDetailCubit>()..initialize(initial, docId: docId);
      },
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (prev, next) {
          if (next is! AppAuthenticated) return false;
          if (prev is! AppAuthenticated) return true;
          return !identical(prev.ownerChalets, next.ownerChalets);
        },
        listener: (context, appState) {
          final d = _resolveChaletDisplayData(appState, docId, requestData);
          context.read<ChaletDetailCubit>().syncImagesFromMap(d);
        },
        child: BlocSelector<ChaletDetailCubit, ChaletDetailState, List<String>>(
          selector: (state) {
            if (state is ChaletDetailLoaded) {
              return state.images;
            }
            return <String>[];
          },
          builder: (context, images) {
            return BlocBuilder<AppCubit, AppState>(
              buildWhen: (prev, next) {
                if (prev.locale != next.locale) return true;
                if (prev is AppAuthenticated && next is AppAuthenticated) {
                  return !identical(prev.ownerChalets, next.ownerChalets);
                }
                return prev.runtimeType != next.runtimeType;
              },
              builder: (context, appState) {
                String role = 'guest';
                if (appState is AppAuthenticated) {
                  role = context.read<AppCubit>().getCurrentRole();
                }

                final displayData = _resolveChaletDisplayData(
                  appState,
                  docId,
                  requestData,
                );

                final isDark = DynamicThemeManager.isDarkMode(context);
                // Force Airbnb styling (White/Black)
                final backgroundColor = isDark
                    ? const Color(0xFF121212)
                    : const Color(0xFFFFFFFF);
                final textColor = isDark
                    ? Colors.white
                    : const Color(0xFF222222);

                final hotelName = displayData['chaletName'] ?? 'Chalet Name';
                final location = displayData['location'] ?? 'Unknown Location';
                final price = displayData['price'];
                final description =
                    displayData['description']?.toString() ?? '';

                final metrics = buildChaletDetailMetrics(displayData);
                final bathSuffix = metrics.bathrooms > 0
                    ? ' · ${metrics.bathrooms} ${context.tr(metrics.bathrooms == 1 ? 'common_baths_short' : 'common_baths')}'
                    : '';
                final specsLine =
                    "${metrics.area != null ? '${context.tr('chalet_detail_area')} ${metrics.area} ${context.tr('common_m2')} · ' : ''}${metrics.guests > 0 ? '${metrics.guests} · ' : ''}${metrics.bedrooms} ${context.tr(metrics.bedrooms == 1 ? 'chalet_detail_bedroom' : 'chalet_detail_bedrooms')} · ${metrics.beds} ${context.tr('chalet_detail_beds')}$bathSuffix";

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
                              requestData: displayData,
                              docId: docId,
                            ),
                          ),

                          // 2. Main Content
                          SliverToBoxAdapter(
                            child: Container(
                              color: backgroundColor,
                              padding: EdgeInsets.only(
                                left: stv(
                                  context: context,
                                  mobile: 24.sw,
                                  tablet: 32.sw,
                                  desktop: 40.sw,
                                ),
                                right: stv(
                                  context: context,
                                  mobile: 24.sw,
                                  tablet: 32.sw,
                                  desktop: 40.sw,
                                ),
                                top: otv(
                                  context: context,
                                  portrait: 24.sh,
                                  landscape: 12.sh,
                                ),
                                bottom: otv(
                                  context: context,
                                  portrait: 120.sh,
                                  landscape: 250.sh,
                                ), // Space for bottom bar
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // A. Title Section
                                  FadeInUp(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    curve: Curves.easeOutQuart,
                                    child: RepaintBoundary(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hotelName,
                                            style: TextStyle(
                                              fontSize: stv(
                                                context: context,
                                                mobile: 26.spScaled,
                                                tablet: 30.spScaled,
                                                desktop: 34.spScaled,
                                              ),
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                              letterSpacing:
                                                  -0.2, // Tight spacing
                                            ),
                                            maxLines: 2,
                                          ),
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 8.sh,
                                              landscape: 4.sh,
                                            ),
                                          ),
                                          Text(
                                            location,
                                            style: TextStyle(
                                              fontSize: stv(
                                                context: context,
                                                mobile: 16.spScaled,
                                                tablet: 18.spScaled,
                                                desktop: 20.spScaled,
                                              ),
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 4.sh,
                                              landscape: 2.sh,
                                            ),
                                          ),
                                          Text(
                                            specsLine,
                                            style: TextStyle(
                                              fontSize: stv(
                                                context: context,
                                                mobile: 14.spScaled,
                                                tablet: 16.spScaled,
                                                desktop: 18.spScaled,
                                              ),
                                              color: isDark
                                                  ? Colors.white70
                                                  : const Color(0xFF717171),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),

                                  // B. Stats Row
                                  FadeInUp(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    delay: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutQuart,
                                    child: RepaintBoundary(
                                      child: ChaletStatsRow(
                                        isDark: isDark,
                                        textColor: textColor,
                                        rating: metrics.formattedRating,
                                        reviewsCount: metrics.reviewsCount
                                            .toString(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),
                                  FadeIn(
                                    delay: const Duration(milliseconds: 400),
                                    child: Divider(
                                      height: 1,
                                      color: isDark
                                          ? Colors.white24
                                          : const Color(0xFFDDDDDD),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),

                                  // C. Host Section
                                  FadeInUp(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    delay: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutQuart,
                                    child: RepaintBoundary(
                                      child: OwnerInformationCard(
                                        requestData: displayData,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),
                                  FadeIn(
                                    delay: const Duration(milliseconds: 600),
                                    child: Divider(
                                      height: 1,
                                      color: isDark
                                          ? Colors.white24
                                          : const Color(0xFFDDDDDD),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),

                                  // D. Highlights (Property Features)
                                  FadeInUp(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    delay: const Duration(milliseconds: 600),
                                    curve: Curves.easeOutQuart,
                                    child: RepaintBoundary(
                                      child: PropertyFeaturesCard(
                                        requestData: displayData,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),
                                  FadeIn(
                                    delay: const Duration(milliseconds: 800),
                                    child: Divider(
                                      height: 1,
                                      color: isDark
                                          ? Colors.white24
                                          : const Color(0xFFDDDDDD),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),

                                  // F. Description
                                  FadeInUp(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    delay: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutQuart,
                                    child: RepaintBoundary(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ChaletSectionTitle(
                                            title: context.tr(
                                              'chalet_about_place',
                                            ),
                                            textColor: textColor,
                                          ),
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 12.sh,
                                              landscape: 6.sh,
                                            ),
                                          ),
                                          Text(
                                            description,
                                            style: TextStyle(
                                              fontSize: stv(
                                                context: context,
                                                mobile: 16.spScaled,
                                                tablet: 18.spScaled,
                                                desktop: 20.spScaled,
                                              ),
                                              height: 1.5,
                                              fontWeight: FontWeight.w400,
                                              color: isDark
                                                  ? Colors.white70
                                                  : const Color(0xFF717171),
                                            ),
                                            maxLines: 6,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 16.sh,
                                              landscape: 8.sh,
                                            ),
                                          ),
                                          ShowMoreButton(
                                            isDark: isDark,
                                            textColor: textColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),
                                  FadeIn(
                                    delay: const Duration(milliseconds: 1000),
                                    child: Divider(
                                      height: 1,
                                      color: isDark
                                          ? Colors.white24
                                          : const Color(0xFFDDDDDD),
                                    ),
                                  ),
                                  verticalSpace(5),

                                  // G. Gallery Strip
                                  FadeInUp(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    delay: const Duration(milliseconds: 1000),
                                    curve: Curves.easeOutQuart,
                                    child: RepaintBoundary(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ChaletSectionTitle(
                                            title: context.tr(
                                              'chalet_gallery_title',
                                            ),
                                            textColor: textColor,
                                          ),
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 16.sh,
                                              landscape: 8.sh,
                                            ),
                                          ),
                                          ChaletGalleryStrip(
                                            images: images,
                                            isDark: isDark,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),
                                  FadeIn(
                                    delay: const Duration(milliseconds: 1200),
                                    child: Divider(
                                      height: 1,
                                      color: isDark
                                          ? Colors.white24
                                          : const Color(0xFFDDDDDD),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),

                                  // H. Amenities (Map)
                                  FadeInUp(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    delay: const Duration(milliseconds: 1200),
                                    curve: Curves.easeOutQuart,
                                    child: RepaintBoundary(
                                      child: LocationMapCard(
                                        location: location,
                                        latitude:
                                            displayData['latitude'] != null
                                            ? (displayData['latitude'] as num)
                                                  .toDouble()
                                            : (displayData['lat'] != null
                                                  ? (displayData['lat'] as num)
                                                        .toDouble()
                                                  : null),
                                        longitude:
                                            displayData['longitude'] != null
                                            ? (displayData['longitude'] as num)
                                                  .toDouble()
                                            : (displayData['lon'] != null
                                                  ? (displayData['lon'] as num)
                                                        .toDouble()
                                                  : null),
                                        fallbackImage: images.isNotEmpty
                                            ? images.first
                                            : null,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: otv(
                                      context: context,
                                      portrait: 24.sh,
                                      landscape: 12.sh,
                                    ),
                                  ),

                                  // Reviews
                                  FadeInUp(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    delay: const Duration(milliseconds: 1400),
                                    curve: Curves.easeOutQuart,
                                    child: RepaintBoundary(
                                      child: ReviewsSection(
                                        chaletId: docId,
                                        isDark: isDark,
                                        requestData: displayData,
                                      ),
                                    ),
                                  ),

                                  // Booking Dates (Start/End)
                                  if (displayData['availableFrom'] != null &&
                                      displayData['availableTo'] != null) ...[
                                    SizedBox(
                                      height: otv(
                                        context: context,
                                        portrait: 24.sh,
                                        landscape: 12.sh,
                                      ),
                                    ),
                                    FadeIn(
                                      delay: const Duration(milliseconds: 1500),
                                      child: Divider(
                                        height: 1,
                                        color: isDark
                                            ? Colors.white24
                                            : const Color(0xFFDDDDDD),
                                      ),
                                    ),
                                    SizedBox(
                                      height: otv(
                                        context: context,
                                        portrait: 24.sh,
                                        landscape: 12.sh,
                                      ),
                                    ),
                                    FadeInUp(
                                      duration: const Duration(
                                        milliseconds: 1000,
                                      ),
                                      delay: const Duration(milliseconds: 1500),
                                      curve: Curves.easeOutQuart,
                                      child: RepaintBoundary(
                                        child: BookingDatesDisplay(
                                          requestData: displayData,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Admin Sections
                                  if (role == 'admin') ...[
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
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 24.sh,
                                              landscape: 12.sh,
                                            ),
                                          ),
                                          Divider(
                                            height: 1,
                                            color: isDark
                                                ? Colors.white24
                                                : const Color(0xFFDDDDDD),
                                          ),
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 24.sh,
                                              landscape: 12.sh,
                                            ),
                                          ),
                                          ChaletSectionTitle(
                                            title: 'Availability',
                                            textColor: textColor,
                                          ),
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 16.sh,
                                              landscape: 8.sh,
                                            ),
                                          ),
                                          AvailabilityCard(
                                            requestData: displayData,
                                          ),
                                          if (role == 'admin') ...[
                                            SizedBox(
                                              height: otv(
                                                context: context,
                                                portrait: 24.sh,
                                                landscape: 12.sh,
                                              ),
                                            ),
                                            ChaletSectionTitle(
                                              title: 'Request Details',
                                              textColor: textColor,
                                            ),
                                            SizedBox(
                                              height: otv(
                                                context: context,
                                                portrait: 16.sh,
                                                landscape: 8.sh,
                                              ),
                                            ),
                                            RequestDetailsCard(
                                              docId: docId,
                                              requestData: displayData,
                                            ),
                                          ],
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 24.sh,
                                              landscape: 12.sh,
                                            ),
                                          ),
                                          ActionButtons(
                                            status: status,
                                            docId: docId,
                                            requestData: displayData,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Owner Sections
                                  if (role == 'owner') ...[
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
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 24.sh,
                                              landscape: 12.sh,
                                            ),
                                          ),
                                          Divider(
                                            height: 1,
                                            color: isDark
                                                ? Colors.white24
                                                : const Color(0xFFDDDDDD),
                                          ),
                                          SizedBox(
                                            height: otv(
                                              context: context,
                                              portrait: 24.sh,
                                              landscape: 12.sh,
                                            ),
                                          ),
                                          ActionButtons(
                                            status: status,
                                            docId: docId,
                                            requestData: displayData,
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
                            requestData: displayData,
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
      ),
    );
  }
}
