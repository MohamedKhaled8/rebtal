import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';

class LocationCityArea {
  const LocationCityArea({
    required this.cityName,
    required this.thumbnailUrl,
    required this.areas,
  });

  final String cityName;
  final String thumbnailUrl;
  final List<String> areas;
}

class LocationAreasResolver {
  static List<LocationCityArea> resolve(List<HomeChaletEntity> chalets) {
    if (chalets.isEmpty) return const [];

    final Map<String, Set<String>> activeHierarchy = {};
    final Map<String, String> cityThumbnails = {};

    for (final entity in chalets) {
      final rawLoc = (entity.data['location'] ?? '').toString().trim();
      if (rawLoc.isEmpty) continue;

      String mainCity;
      String? subArea;

      if (rawLoc.contains('-')) {
        final parts = rawLoc.split('-');
        mainCity = parts[0].trim();
        subArea = parts.length > 1 ? parts[1].trim() : null;
      } else if (rawLoc.contains('/')) {
        final parts = rawLoc.split('/');
        mainCity = parts[0].trim();
        subArea = parts.length > 1 ? parts[1].trim() : null;
      } else {
        mainCity = rawLoc;
      }

      activeHierarchy.putIfAbsent(mainCity, () => {});
      if (!cityThumbnails.containsKey(mainCity)) {
        final images = entity.data['images'] as List<dynamic>?;
        if (images != null && images.isNotEmpty) {
          cityThumbnails[mainCity] = images[0].toString();
        }
      }
      if (subArea != null && subArea.isNotEmpty) {
        activeHierarchy[mainCity]!.add(subArea);
      }
    }

    if (activeHierarchy.isEmpty) return const [];

    final sortedCities = activeHierarchy.keys.toList()..sort();

    return sortedCities
        .map(
          (city) => LocationCityArea(
            cityName: city,
            thumbnailUrl: cityThumbnails[city] ?? '',
            areas: activeHierarchy[city]!.toList()..sort(),
          ),
        )
        .toList(growable: false);
  }
}
