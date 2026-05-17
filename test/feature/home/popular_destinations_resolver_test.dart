import 'package:flutter_test/flutter_test.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/logic/helpers/popular_destinations_resolver.dart';

void main() {
  group('PopularDestinationsResolver', () {
    test('returns empty when no matching features', () {
      final result = PopularDestinationsResolver.resolve(const [
        HomeChaletEntity(
          id: '1',
          data: {'features': ['غير معروف']},
        ),
      ]);
      expect(result, isEmpty);
    });

    test('returns destinations used in chalet features', () {
      final result = PopularDestinationsResolver.resolve(const [
        HomeChaletEntity(
          id: '1',
          data: {'features': ['الساحل الشمالي']},
        ),
      ]);
      expect(result, isNotEmpty);
      expect(result.first.nameAr, 'الساحل الشمالي');
    });
  });
}
