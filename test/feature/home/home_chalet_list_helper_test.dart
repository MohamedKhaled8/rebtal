import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/logic/helpers/home_chalet_list_helper.dart';

void main() {
  group('HomeChaletListHelper', () {
    final entities = [
      HomeChaletEntity(
        id: 'old',
        data: {
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'price': 100,
        },
      ),
      HomeChaletEntity(
        id: 'new',
        data: {
          'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
          'price': 200,
        },
      ),
    ];

    test('sorts by createdAt descending', () {
      final sorted = HomeChaletListHelper.filterAndSort(
        entities,
        const SearchFilters(),
        null,
      );
      expect(sorted.first.id, 'new');
      expect(sorted.last.id, 'old');
    });

    test('visibleCount respects display limit when not filtering', () {
      expect(
        HomeChaletListHelper.visibleCount(entities, 1, false),
        1,
      );
      expect(
        HomeChaletListHelper.visibleCount(entities, 10, false),
        2,
      );
    });

    test('hasMore is false when filtering', () {
      expect(
        HomeChaletListHelper.hasMore(entities, 1, true),
        false,
      );
    });
  });
}
