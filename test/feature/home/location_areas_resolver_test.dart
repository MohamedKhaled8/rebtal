import 'package:flutter_test/flutter_test.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';
import 'package:rebtal/feature/home/logic/helpers/location_areas_resolver.dart';

void main() {
  group('LocationAreasResolver', () {
    test('builds city hierarchy from location strings', () {
      final result = LocationAreasResolver.resolve(const [
        HomeChaletEntity(
          id: '1',
          data: {
            'location': 'القاهرة - المعادي',
            'images': ['https://example.com/a.jpg'],
          },
        ),
      ]);

      expect(result, isNotEmpty);
      expect(result.first.cityName, 'القاهرة');
      expect(result.first.areas, contains('المعادي'));
    });
  });
}
