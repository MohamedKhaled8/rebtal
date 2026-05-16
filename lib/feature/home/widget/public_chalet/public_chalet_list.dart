import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/services/chalet_filter_service.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/widgets/shimmers.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/feature/home/domain/usecases/watch_public_chalets_usecase.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalet_card.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// Public chalets: primary [ListView] (no shrinkWrap); Firestore stream بدون orderBy على createdAt.
class PublicChaletsList extends StatefulWidget {
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;
  final String? selectedCategory;

  /// When true, list is embedded in a parent [CustomScrollView] (no nested scroll).
  final bool shrinkWrap;

  const PublicChaletsList({
    super.key,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
    this.selectedCategory,
    this.shrinkWrap = false,
  });

  @override
  State<PublicChaletsList> createState() => _PublicChaletsListState();
}

class _PublicChaletsListState extends State<PublicChaletsList> {
  int _displayLimit = 10;
  final int _increment = 10;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _streamDocs = [];

  static List<QueryDocumentSnapshot<Map<String, dynamic>>>? _cachedDocs;

  bool _waitingFirst = true;
  Object? _streamError;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = getIt<WatchPublicChaletsUseCase>()().listen(
      (snap) {
        if (!mounted) return;
        setState(() {
          _waitingFirst = false;
          _streamError = null;
          _streamDocs = snap.docs;
          _cachedDocs = snap.docs;
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _waitingFirst = false;
          _streamError = e;
        });
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _loadMore() {
    setState(() => _displayLimit += _increment);
  }

  ScrollPhysics get _listPhysics => widget.shrinkWrap
      ? const NeverScrollableScrollPhysics()
      : const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  bool _showTwoColumns(BuildContext context) {
    return otv(
      context: context,
      portrait: stv(
        context: context,
        mobile: false,
        tablet: true,
        desktop: true,
      ),
      landscape: true,
    );
  }

  Widget _buildListFromDocs(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    bool isDark,
  ) {
    return ValueListenableBuilder<SearchFilters>(
      valueListenable: HomeSearch.filters,
      builder: (context, filters, _) {
        final filtered = docs.where((doc) {
          final data = doc.data();
          if (widget.selectedCategory != null) {
            final features = data['features'] as List<dynamic>?;
            if (features == null ||
                !features.contains(widget.selectedCategory)) {
              return false;
            }
          }
          final singleList = [data];
          final result = ChaletFilterService.filterChalets(singleList, filters);
          return result.isNotEmpty;
        }).toList();
        filtered.sort((a, b) {
          final aData = a.data();
          final bData = b.data();
          final aTime = aData['createdAt'];
          final bTime = bData['createdAt'];
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0;
        });
        if (filtered.isEmpty) {
          return ListView(
            shrinkWrap: widget.shrinkWrap,
            physics: _listPhysics,
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
                          widget.emptyIcon ?? Icons.search_off_rounded,
                          size: 60.spScaled,
                          color: isDark ? Colors.white24 : Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 20.sh),
                      Text(
                        widget.emptyTitle ?? context.tr('home_no_results'),
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

        final isFiltering = !filters.isEmpty;
        final int countToShow = isFiltering
            ? filtered.length
            : (_displayLimit > filtered.length
                  ? filtered.length
                  : _displayLimit);
        final bool hasMore = !isFiltering && filtered.length > _displayLimit;
        final showTwoColumns = _showTwoColumns(context);

        if (showTwoColumns) {
          final rowCount = (countToShow / 2).ceil();
          final extra = (hasMore ? 1 : 0) + 1;
          final itemCount = rowCount + extra;

          return ListView.builder(
            shrinkWrap: widget.shrinkWrap,
            physics: _listPhysics,
            padding: EdgeInsets.only(bottom: 20.sh),
            itemCount: itemCount,
            itemBuilder: (context, i) {
              if (i < rowCount) {
                final firstIndex = i * 2;
                final secondIndex = firstIndex + 1;
                return RepaintBoundary(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PublicChaletCard(
                          key: ValueKey(filtered[firstIndex].id),
                          chaletData: filtered[firstIndex].data(),
                          docId: filtered[firstIndex].id,
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
                      if (secondIndex < countToShow)
                        Expanded(
                          child: PublicChaletCard(
                            key: ValueKey(filtered[secondIndex].id),
                            chaletData: filtered[secondIndex].data(),
                            docId: filtered[secondIndex].id,
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
                  ),
                );
              }
              if (hasMore && i == rowCount) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.sw,
                    vertical: 10.sh,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadMore,
                      icon: Icon(
                        Icons.expand_more,
                        color: Colors.white,
                        size: 24.spScaled,
                      ),
                      label: Text(
                        '${context.tr('home_show_more')} (${filtered.length - countToShow} ${context.tr('common_chalet')})',
                        style: TextStyle(
                          fontSize: 16.spScaled,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.sh),
                        backgroundColor: ColorsManager.chaletAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                );
              }
              return SizedBox(height: 60.sh);
            },
          );
        }

        final itemCount = countToShow + (hasMore ? 1 : 0) + 1;

        return ListView.builder(
          shrinkWrap: widget.shrinkWrap,
          physics: _listPhysics,
          padding: EdgeInsets.only(bottom: 20.sh),
          itemCount: itemCount,
          itemBuilder: (context, i) {
            if (i < countToShow) {
              final doc = filtered[i];
              final data = doc.data();
              return RepaintBoundary(
                child: PublicChaletCard(
                  key: ValueKey(doc.id),
                  chaletData: data,
                  docId: doc.id,
                ),
              );
            }
            if (hasMore && i == countToShow) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.sw,
                  vertical: 10.sh,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loadMore,
                    icon: Icon(
                      Icons.expand_more,
                      color: Colors.white,
                      size: 24.spScaled,
                    ),
                    label: Text(
                      '${context.tr('home_show_more')} (${filtered.length - countToShow} ${context.tr('common_chalet')})',
                      style: TextStyle(
                        fontSize: 16.spScaled,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.sh),
                      backgroundColor: ColorsManager.chaletAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.sp),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              );
            }
            return SizedBox(height: 60.sh);
          },
        );
      },
    );
  }

  Widget _buildLoadingList(BuildContext context) {
    final showTwoColumns = _showTwoColumns(context);
    if (showTwoColumns) {
      return ListView.builder(
        shrinkWrap: widget.shrinkWrap,
        physics: _listPhysics,
        padding: EdgeInsets.symmetric(vertical: 16.sh),
        itemCount: 2,
        itemBuilder: (context, i) => Row(
          children: [
            Expanded(
              child: PublicChaletCardShimmer(
                margin: EdgeInsets.only(
                  bottom: 16.sh,
                  left: 16.sw,
                  right: 8.sw,
                ),
              ),
            ),
            Expanded(
              child: PublicChaletCardShimmer(
                margin: EdgeInsets.only(
                  bottom: 16.sh,
                  left: 8.sw,
                  right: 16.sw,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: _listPhysics,
      padding: EdgeInsets.symmetric(vertical: 16.sh),
      itemCount: 3,
      itemBuilder: (context, i) => const PublicChaletCardShimmer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    if (_waitingFirst && (_cachedDocs == null || _cachedDocs!.isEmpty)) {
      return _buildLoadingList(context);
    }

    if (_waitingFirst && _cachedDocs != null && _cachedDocs!.isNotEmpty) {
      return _buildListFromDocs(context, _cachedDocs!, isDark);
    }

    if (_streamError != null) {
      return ListView(
        shrinkWrap: widget.shrinkWrap,
        physics: _listPhysics,
        children: [
          SizedBox(
            height: 280.sh,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.spScaled,
                  color: ColorsManager.chaletUnavailableRed,
                ),
                SizedBox(height: 16.sh),
                Text(
                  context.tr('home_load_error'),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return _buildListFromDocs(context, _streamDocs, isDark);
  }
}
