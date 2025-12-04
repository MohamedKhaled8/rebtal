import 'package:flutter/material.dart';

import '../utils/home_search_notifier.dart';
import '../utils/number_parser.dart';
import '../utils/text_normalizer.dart';

/// Service for filtering chalets based on search criteria
/// Implements the complete search logic with AND/OR rules
class ChaletFilterService {
  /// Filters a list of chalets based on search filters
  ///
  /// Returns chalets that match ALL active filters (AND logic)
  /// Within multi-select filters (features, facilities), uses OR logic
  static List<Map<String, dynamic>> filterChalets(
    List<Map<String, dynamic>> chalets,
    SearchFilters filters,
  ) {
    print('🔧 ChaletFilterService: Filtering ${chalets.length} chalets');
    print('   Active filter count: ${countActiveFilters(filters)}');

    return chalets.where((chalet) {
      final queryMatch = matchesQuery(chalet, filters.query);
      final priceRangeMatch = matchesPriceRange(chalet, filters.priceRange);
      final bedroomsMatch = matchesBedrooms(chalet, filters.minBedrooms);
      final bathroomsMatch = matchesBathrooms(chalet, filters.minBathrooms);
      final areaMatch = matchesArea(chalet, filters.minArea);
      final featuresMatch = matchesFeatures(chalet, filters.features);
      final facilitiesMatch = matchesFacilities(chalet, filters.facilities);

      final allMatch =
          queryMatch &&
          priceRangeMatch &&
          bedroomsMatch &&
          bathroomsMatch &&
          areaMatch &&
          featuresMatch &&
          facilitiesMatch;

      // Debug failed matches
      if (!allMatch && chalets.length <= 5) {
        print('   ❌ ${chalet['chaletName']} filtered out:');
        if (!queryMatch) print('      - Query mismatch');
        if (!priceRangeMatch) print('      - Price range mismatch');
        if (!bedroomsMatch) print('      - Bedrooms mismatch');
        if (!bathroomsMatch) print('      - Bathrooms mismatch');
        if (!areaMatch) print('      - Area mismatch');
        if (!featuresMatch) print('      - Features mismatch');
        if (!facilitiesMatch) print('      - Facilities mismatch');
      }

      return allMatch;
    }).toList();
  }

  /// Checks if query filter is active
  static bool isQueryActive(String query) {
    return query.trim().isNotEmpty;
  }

  /// Checks if price range filter is active
  static bool isPriceRangeActive(RangeValues? priceRange) {
    return priceRange != null &&
        (priceRange.start > 0 || priceRange.end < 10000);
  }

  /// Checks if bedrooms filter is active
  static bool isBedroomsActive(int? minBedrooms) {
    return minBedrooms != null && minBedrooms > 0;
  }

  /// Checks if bathrooms filter is active
  static bool isBathroomsActive(int? minBathrooms) {
    return minBathrooms != null && minBathrooms > 0;
  }

  /// Checks if area filter is active
  static bool isAreaActive(double? minArea) {
    return minArea != null && minArea > 0;
  }

  /// Checks if features filter is active
  static bool isFeaturesActive(List<String> features) {
    return features.isNotEmpty;
  }

  /// Checks if facilities filter is active
  static bool isFacilitiesActive(List<String> facilities) {
    return facilities.isNotEmpty;
  }

  /// Matches chalet against query (name, location, description)
  static bool matchesQuery(Map<String, dynamic> chalet, String query) {
    if (!isQueryActive(query)) return true;

    final normalizedQuery = TextNormalizer.normalize(query);

    final candidates = [
      chalet['chaletName']?.toString(),
      chalet['location']?.toString(),
      chalet['description']?.toString(),
    ];

    for (final candidate in candidates) {
      if (candidate != null) {
        final normalizedCandidate = TextNormalizer.normalize(candidate);
        if (normalizedCandidate.contains(normalizedQuery)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Matches chalet against price range filter
  static bool matchesPriceRange(
    Map<String, dynamic> chalet,
    RangeValues? priceRange,
  ) {
    if (!isPriceRangeActive(priceRange)) {
      print('💰 Price range NOT active (null or 0-100000)');
      return true;
    }

    final rawPrice = chalet['price'];
    print('💰 === PRICE DEBUG ===');
    print('   Chalet: ${chalet['chaletName']}');
    print('   Raw price value: $rawPrice');
    print('   Raw price type: ${rawPrice.runtimeType}');

    final chaletPrice = NumberParser.parseDouble(chalet['price']);
    print('   Parsed price: $chaletPrice');
    print('   Range start: ${priceRange!.start}');
    print('   Range end: ${priceRange.end}');
    print(
      '   Check: $chaletPrice >= ${priceRange.start} = ${chaletPrice >= priceRange.start}',
    );
    print(
      '   Check: $chaletPrice <= ${priceRange.end} = ${chaletPrice <= priceRange.end}',
    );

    final result =
        chaletPrice >= priceRange.start && chaletPrice <= priceRange.end;
    print('   Final result: $result');
    print('💰 === END PRICE DEBUG ===');

    return result;
  }

  /// Matches chalet against bedrooms filter
  static bool matchesBedrooms(Map<String, dynamic> chalet, int? minBedrooms) {
    if (!isBedroomsActive(minBedrooms)) return true;

    final chaletBedrooms = NumberParser.parseInt(chalet['bedrooms']);

    return chaletBedrooms >= minBedrooms!;
  }

  /// Matches chalet against bathrooms filter
  static bool matchesBathrooms(Map<String, dynamic> chalet, int? minBathrooms) {
    if (!isBathroomsActive(minBathrooms)) return true;

    final chaletBathrooms = NumberParser.parseInt(chalet['bathrooms']);

    return chaletBathrooms >= minBathrooms!;
  }

  /// Matches chalet against area filter
  static bool matchesArea(Map<String, dynamic> chalet, double? minArea) {
    if (!isAreaActive(minArea)) return true;

    final chaletArea = NumberParser.parseDouble(chalet['chaletArea']);

    return chaletArea >= minArea!;
  }

  /// Matches chalet against features filter (OR logic)
  /// Returns true if chalet has AT LEAST ONE selected feature
  static bool matchesFeatures(
    Map<String, dynamic> chalet,
    List<String> features,
  ) {
    if (!isFeaturesActive(features)) return true;

    final chaletFeatures =
        (chalet['features'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // OR logic: match if chalet has ANY selected feature
    for (final feature in features) {
      if (chaletFeatures.contains(feature)) {
        return true;
      }
    }

    return false;
  }

  /// Matches chalet against facilities filter (OR logic)
  /// Returns true if chalet has AT LEAST ONE selected facility
  static bool matchesFacilities(
    Map<String, dynamic> chalet,
    List<String> facilities,
  ) {
    if (!isFacilitiesActive(facilities)) return true;

    // OR logic: match if chalet has ANY selected facility
    for (final facility in facilities) {
      // Check direct boolean field
      if (chalet[facility] == true) {
        return true;
      }

      // Check amenities list
      final amenities = chalet['amenities'] as List<dynamic>?;
      if (amenities != null && amenities.contains(facility)) {
        return true;
      }
    }

    return false;
  }

  /// Counts active filters
  static int countActiveFilters(SearchFilters filters) {
    int count = 0;

    if (isQueryActive(filters.query)) count++;
    if (isPriceRangeActive(filters.priceRange)) count++;
    if (isBedroomsActive(filters.minBedrooms)) count++;
    if (isBathroomsActive(filters.minBathrooms)) count++;
    if (isAreaActive(filters.minArea)) count++;
    if (isFeaturesActive(filters.features)) count++;
    if (isFacilitiesActive(filters.facilities)) count++;

    return count;
  }
}
