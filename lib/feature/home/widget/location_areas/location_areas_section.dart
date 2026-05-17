import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';
import 'package:rebtal/feature/home/logic/helpers/location_areas_resolver.dart';
import 'package:rebtal/feature/home/widget/location_areas/location_area_chip.dart';
import 'package:rebtal/feature/home/widget/location_areas/location_city_chip.dart';

class LocationAreasSection extends StatelessWidget {
  const LocationAreasSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeCubit, HomeState, List<LocationCityArea>>(
      selector: (state) => LocationAreasResolver.resolve(state.approvedChalets),
      builder: (context, cities) {
        if (cities.isEmpty) return const SizedBox.shrink();

        final isDark = DynamicThemeManager.isDarkMode(context);

        return ValueListenableBuilder<SearchFilters>(
          valueListenable: HomeSearch.filters,
          builder: (context, filters, _) {
            final selectedCity = filters.location;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('home_explore_destinations'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (selectedCity != null && selectedCity.isNotEmpty)
                        GestureDetector(
                          onTap: HomeSearch.clear,
                          child: Text(
                            context.tr('home_show_all'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 115,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      return LocationCityChip(
                        city: city,
                        isDark: isDark,
                        isSelected: selectedCity == city.cityName,
                      );
                    },
                  ),
                ),
                if (selectedCity != null && selectedCity.isNotEmpty)
                  LocationAreasSubList(
                    cities: cities,
                    selectedCity: selectedCity,
                    filters: filters,
                    isDark: isDark,
                  ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }
}

class LocationAreasSubList extends StatelessWidget {
  const LocationAreasSubList({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.filters,
    required this.isDark,
  });

  final List<LocationCityArea> cities;
  final String selectedCity;
  final SearchFilters filters;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final city = cities.firstWhere(
      (item) => item.cityName == selectedCity,
      orElse: () => const LocationCityArea(
        cityName: '',
        thumbnailUrl: '',
        areas: [],
      ),
    );

    if (city.areas.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: city.areas.length,
          itemBuilder: (context, index) {
            final areaName = city.areas[index];
            return LocationAreaChip(
              areaName: areaName,
              isDark: isDark,
              isSelected: filters.query == areaName,
            );
          },
        ),
      ),
    );
  }
}
