import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';

class AdvancedSearchFormState extends Equatable {
  const AdvancedSearchFormState({
    this.query = '',
    this.location = '',
    this.exactPriceText = '',
    this.priceRange = const RangeValues(0, 10000),
    this.minBedrooms,
    this.minBathrooms,
    this.minChildren,
    this.dayUseOnly = false,
    this.hasOffers = false,
    this.selectedFacilities = const [],
    this.minArea = 0,
  });

  final String query;
  final String location;
  final String exactPriceText;
  final RangeValues priceRange;
  final int? minBedrooms;
  final int? minBathrooms;
  final int? minChildren;
  final bool dayUseOnly;
  final bool hasOffers;
  final List<String> selectedFacilities;
  final double minArea;

  factory AdvancedSearchFormState.fromFilters(SearchFilters filters) {
    return AdvancedSearchFormState(
      query: filters.query,
      location: filters.location ?? '',
      exactPriceText: filters.exactPrice != null
          ? filters.exactPrice!.toStringAsFixed(0)
          : '',
      priceRange: filters.priceRange ?? const RangeValues(0, 10000),
      minBedrooms: filters.minBedrooms,
      minBathrooms: filters.minBathrooms,
      minChildren: filters.minChildren,
      dayUseOnly: filters.dayUseOnly,
      hasOffers: filters.hasOffers,
      selectedFacilities: List<String>.from(filters.facilities),
      minArea: filters.minArea ?? 0,
    );
  }

  SearchFilters toSearchFilters() {
    final exactPriceTextTrimmed = exactPriceText.trim();
    final exactPrice = exactPriceTextTrimmed.isEmpty
        ? null
        : double.tryParse(exactPriceTextTrimmed);

    final activePriceRange =
        (priceRange.start > 0 || priceRange.end < 10000) ? priceRange : null;

    return SearchFilters(
      query: query.trim(),
      location: location.trim().isEmpty ? null : location.trim(),
      priceRange: activePriceRange,
      exactPrice: exactPrice,
      minBedrooms: minBedrooms,
      minBathrooms: minBathrooms,
      minChildren: minChildren,
      dayUseOnly: dayUseOnly,
      hasOffers: hasOffers,
      features: const [],
      facilities: selectedFacilities,
      minArea: minArea > 0 ? minArea : null,
    );
  }

  AdvancedSearchFormState copyWith({
    String? query,
    String? location,
    String? exactPriceText,
    RangeValues? priceRange,
    int? minBedrooms,
    int? minBathrooms,
    int? minChildren,
    bool? dayUseOnly,
    bool? hasOffers,
    List<String>? selectedFacilities,
    double? minArea,
    bool clearMinBedrooms = false,
    bool clearMinBathrooms = false,
    bool clearMinChildren = false,
  }) {
    return AdvancedSearchFormState(
      query: query ?? this.query,
      location: location ?? this.location,
      exactPriceText: exactPriceText ?? this.exactPriceText,
      priceRange: priceRange ?? this.priceRange,
      minBedrooms: clearMinBedrooms ? null : (minBedrooms ?? this.minBedrooms),
      minBathrooms:
          clearMinBathrooms ? null : (minBathrooms ?? this.minBathrooms),
      minChildren: clearMinChildren ? null : (minChildren ?? this.minChildren),
      dayUseOnly: dayUseOnly ?? this.dayUseOnly,
      hasOffers: hasOffers ?? this.hasOffers,
      selectedFacilities: selectedFacilities ?? this.selectedFacilities,
      minArea: minArea ?? this.minArea,
    );
  }

  @override
  List<Object?> get props => [
        query,
        location,
        exactPriceText,
        priceRange,
        minBedrooms,
        minBathrooms,
        minChildren,
        dayUseOnly,
        hasOffers,
        selectedFacilities,
        minArea,
      ];
}
