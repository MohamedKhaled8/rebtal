import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/services/chalet_filter_service.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/owner/widget/owner_chalet_card.dart';
import 'package:rebtal/feature/owner/data/model/chalet_model.dart';
import 'package:rebtal/feature/owner/domain/entities/chalet_entity.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class OwnerChaletsList extends StatelessWidget {
  final String status;
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;
  final String? ownerId;

  const OwnerChaletsList({
    super.key,
    required this.status,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
    this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) {
        if (current is AppAuthenticated && previous is AppAuthenticated) {
          // Do not use deep list equality: `!=` can miss updates when references
          // differ but maps still compare equal momentarily; always rebuild on
          // new list identity, loading flag, or locale.
          return !identical(current.ownerChalets, previous.ownerChalets) ||
              current.isOwnerChaletsLoading != previous.isOwnerChaletsLoading ||
              current.locale != previous.locale;
        }
        return true;
      },
      builder: (context, state) {
        if (state is! AppAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<dynamic> allChalets = state.ownerChalets;

        // Block loading overlay only on real cold fetch — keep cached rows visible while reconnecting.
        if (state.isOwnerChaletsLoading && allChalets.isEmpty) {
          return _OwnerChaletsLoadingSkeleton(isDark: isDark);
        }
        final docs = allChalets.where((chalet) {
          // Convert ChaletEntity/ChaletModel to Map
          final Map<String, dynamic> map = _chaletToMap(chalet);

          final docStatus = map['status'];
          if (status.isNotEmpty && docStatus != status) return false;
          return true;
        }).toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  emptyIcon ?? Icons.home_outlined,
                  size: 72,
                  color: isDark ? ColorsManager.white70 : ColorsManager.grey400,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyTitle ?? context.tr('home_no_chalets'),
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark
                        ? ColorsManager.white70
                        : ColorsManager.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (emptySubtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    emptySubtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? ColorsManager.white70
                          : ColorsManager.grey700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        }

        return ValueListenableBuilder<SearchFilters>(
          valueListenable: HomeSearch.filters,
          builder: (context, filters, _) {
            final filtered = docs.where((chalet) {
              final Map<String, dynamic> data = _chaletToMap(chalet);

              final result = ChaletFilterService.filterChalets([data], filters);
              return result.isNotEmpty;
            }).toList();

            return Builder(
              builder: (context) {
                final bool showTwoColumns = otv(
                  context: context,
                  portrait: stv(
                    context: context,
                    mobile: false,
                    tablet: true,
                    desktop: true,
                  ),
                  landscape: true,
                );

                if (showTwoColumns) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 16.sh),
                    itemCount: (filtered.length / 2).ceil(),
                    itemBuilder: (context, i) {
                      final firstIndex = i * 2;
                      final secondIndex = firstIndex + 1;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: OwnerChaletCard(
                              key: ValueKey(
                                _chaletToMap(filtered[firstIndex])['id'] ?? '',
                              ),
                              chaletData: _chaletToMap(filtered[firstIndex]),
                              docId:
                                  _chaletToMap(filtered[firstIndex])['id'] ??
                                  '',
                              margin: EdgeInsets.only(
                                bottom: otv(
                                  context: context,
                                  portrait: 24.sh,
                                  landscape: 12.sh,
                                ),
                                left: stv(
                                  context: context,
                                  mobile: 16.sw,
                                  tablet: 24.sw,
                                  desktop: 32.sw,
                                ),
                                right: stv(
                                  context: context,
                                  mobile: 16.sw,
                                  tablet: 20.sw,
                                  desktop: 24.sw,
                                ),
                              ),
                            ),
                          ),
                          if (secondIndex < filtered.length)
                            Expanded(
                              child: OwnerChaletCard(
                                key: ValueKey(
                                  _chaletToMap(filtered[secondIndex])['id'] ??
                                      '',
                                ),
                                chaletData: _chaletToMap(
                                  filtered[secondIndex],
                                ),
                                docId:
                                    _chaletToMap(
                                      filtered[secondIndex],
                                    )['id'] ??
                                    '',
                                margin: EdgeInsets.only(
                                  bottom: otv(
                                    context: context,
                                    portrait: 24.sh,
                                    landscape: 12.sh,
                                  ),
                                  left: stv(
                                    context: context,
                                    mobile: 16.sw,
                                    tablet: 20.sw,
                                    desktop: 24.sw,
                                  ),
                                  right: stv(
                                    context: context,
                                    mobile: 16.sw,
                                    tablet: 24.sw,
                                    desktop: 32.sw,
                                  ),
                                ),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      );
                    },
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 16.sh),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final chalet = filtered[i];
                    final Map<String, dynamic> data = _chaletToMap(chalet);

                    final String id = data['id'] ?? '';

                    return OwnerChaletCard(
                      key: ValueKey(id),
                      chaletData: data,
                      docId: id,
                      margin: EdgeInsets.only(
                        bottom: 16.sh,
                        left: stv(
                          context: context,
                          mobile: 0.sw,
                          tablet: 8.sw,
                          desktop: 16.sw,
                        ),
                        right: stv(
                          context: context,
                          mobile: 0.sw,
                          tablet: 8.sw,
                          desktop: 16.sw,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// Converts owner listing entities/models into maps for filtering and cards.
  Map<String, dynamic> _chaletToMap(dynamic chalet) {
    if (chalet is Map<String, dynamic>) {
      return chalet;
    }

    if (chalet is ChaletModel) {
      final map = chalet.toMap();
      map['id'] = chalet.id; // Ensure ID is included

      // Try to get original Firestore data if available
      // Note: This assumes the original data might be stored somewhere
      // For now, we'll add fallback values based on ownerName
      if (!map.containsKey('merchantName') && chalet.ownerName.isNotEmpty) {
        map['merchantName'] = chalet.ownerName;
      }

      // Set isAvailable based on bookingAvailability if not present
      if (!map.containsKey('isAvailable')) {
        map['isAvailable'] =
            chalet.bookingAvailability == BookingAvailability.available;
      }

      return map;
    }

    if (chalet is ChaletEntity) {
      // Convert ChaletEntity to Map manually
      final map = {
        'id': chalet.id,
        'chaletName': chalet.chaletName,
        'location': chalet.location,
        'description': chalet.description,
        'ownerId': chalet.ownerId,
        'ownerName': chalet.ownerName,
        'price': chalet.price,
        'bedrooms': chalet.bedrooms,
        'bathrooms': chalet.bathrooms,
        'images': chalet.images,
        'amenities': chalet.amenities,
        'latitude': chalet.latitude,
        'longitude': chalet.longitude,
        'createdAt': chalet.createdAt,
        'updatedAt': chalet.updatedAt,
        'status': chalet.status.name,
        'bookingAvailability': chalet.bookingAvailability.name,
        'isVisible': chalet.isVisible,
      };

      // Add fallback values for missing fields
      if (!map.containsKey('merchantName') && chalet.ownerName.isNotEmpty) {
        map['merchantName'] = chalet.ownerName;
      }

      // Set isAvailable based on bookingAvailability
      map['isAvailable'] =
          chalet.bookingAvailability == BookingAvailability.available;

      return map;
    }

    // Fallback: try to call toMap() if available
    try {
      return (chalet as dynamic).toMap() as Map<String, dynamic>;
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}

/// Lightweight placeholders while Firestore loads — avoids N× animate_do per card.
class _OwnerChaletsLoadingSkeleton extends StatelessWidget {
  const _OwnerChaletsLoadingSkeleton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final baseColor =
        isDark ? const Color(0xFF2A2A2E) : Colors.grey.shade300;
    final highlightColor =
        isDark ? const Color(0xFF3D3D44) : Colors.grey.shade100;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.sh),
      child: Column(
        children: List.generate(5, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: 14.sh),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.sp),
              child: Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                period: const Duration(milliseconds: 1200),
                child: Container(
                  height: 128.sh,
                  width: width,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

