import 'package:flutter/material.dart';

class SearchFilters {
  final String query;
  final RangeValues? priceRange;
  final double? exactPrice;
  final int? minBedrooms;
  final int? minBathrooms;
  final int? minChildren;
  final bool dayUseOnly;
  final bool hasOffers;
  final List<String> features;
  final List<String> facilities;
  final String? location;
  final double? minArea;

  const SearchFilters({
    this.query = '',
    this.priceRange,
    this.exactPrice,
    this.minBedrooms,
    this.minBathrooms,
    this.minChildren,
    this.dayUseOnly = false,
    this.hasOffers = false,
    this.features = const [],
    this.facilities = const [],
    this.location,
    this.minArea,
  });

  SearchFilters copyWith({
    String? query,
    RangeValues? priceRange,
    double? exactPrice,
    int? minBedrooms,
    int? minBathrooms,
    int? minChildren,
    bool? dayUseOnly,
    bool? hasOffers,
    List<String>? features,
    List<String>? facilities,
    String? location,
    double? minArea,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      priceRange: priceRange ?? this.priceRange,
      exactPrice: exactPrice ?? this.exactPrice,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      minChildren: minChildren ?? this.minChildren,
      dayUseOnly: dayUseOnly ?? this.dayUseOnly,
      hasOffers: hasOffers ?? this.hasOffers,
      features: features ?? this.features,
      facilities: facilities ?? this.facilities,
      location: location ?? this.location,
      minArea: minArea ?? this.minArea,
    );
  }

  bool get isEmpty =>
      query.isEmpty &&
      priceRange == null &&
      exactPrice == null &&
      minBedrooms == null &&
      minBathrooms == null &&
      minChildren == null &&
      !dayUseOnly &&
      !hasOffers &&
      features.isEmpty &&
      facilities.isEmpty &&
      location == null &&
      minArea == null;
}

/// Shared search notifier for HomeScreen lists.
class HomeSearch {
  static final ValueNotifier<SearchFilters> filters =
      ValueNotifier<SearchFilters>(const SearchFilters());

  // Helper to get current query for backward compatibility if needed,
  // though we should migrate usages.
  static String get currentQuery => filters.value.query;

  static void updateQuery(String q) {
    filters.value = filters.value.copyWith(query: q);
  }

  static void clear() {
    filters.value = const SearchFilters();
  }
}
