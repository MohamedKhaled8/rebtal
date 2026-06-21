import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/services/chalet_filter_service.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';

class HomeChaletListHelper {
  static const int defaultDisplayLimit = 10;
  static const int loadMoreIncrement = 10;

  static List<HomeChaletEntity> filterAndSort(
    List<HomeChaletEntity> source,
    SearchFilters filters,
    String? selectedCategory,
  ) {
    final filtered = source.where((entity) {
      if (!ChaletFilterService.isEligibleForGeneralListing(entity.data)) {
        return false;
      }
      if (selectedCategory != null) {
        final features = entity.data['features'] as List<dynamic>?;
        if (features == null || !features.contains(selectedCategory)) {
          return false;
        }
      }
      final result =
          ChaletFilterService.filterChalets([entity.data], filters);
      return result.isNotEmpty;
    }).toList();

    filtered.sort((a, b) {
      final aTime = a.data['createdAt'];
      final bTime = b.data['createdAt'];
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }
      return 0;
    });

    return filtered;
  }

  static int visibleCount(
    List<HomeChaletEntity> filtered,
    int displayLimit,
    bool isFiltering,
  ) {
    if (isFiltering) return filtered.length;
    return displayLimit > filtered.length ? filtered.length : displayLimit;
  }

  static bool hasMore(
    List<HomeChaletEntity> filtered,
    int displayLimit,
    bool isFiltering,
  ) {
    return !isFiltering && filtered.length >= displayLimit;
  }
}
