import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class LocationAreasSection extends StatelessWidget {
  const LocationAreasSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chalets')
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        // 1. Dynamic Extraction from Database
        final allDocs = snapshot.data!.docs;
        final Map<String, Set<String>> activeHierarchy = {};
        final Map<String, String> cityThumbnails = {};

        for (var doc in allDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final rawLoc = (data['location'] ?? '').toString().trim();
          if (rawLoc.isEmpty) continue;

          String mainCity;
          String? subArea;

          // Support for "City - Area" or "City / Area" formats
          if (rawLoc.contains('-')) {
            final parts = rawLoc.split('-');
            mainCity = parts[0].trim();
            subArea = parts[1].trim();
          } else if (rawLoc.contains('/')) {
            final parts = rawLoc.split('/');
            mainCity = parts[0].trim();
            subArea = parts[1].trim();
          } else {
            mainCity = rawLoc;
          }

          // Build hierarchy
          if (!activeHierarchy.containsKey(mainCity)) {
            activeHierarchy[mainCity] = {};
            // Use this chalet's image as the city's representational image
            final images = data['images'] as List<dynamic>?;
            if (images != null && images.isNotEmpty) {
              cityThumbnails[mainCity] = images[0].toString();
            }
          }
          if (subArea != null) {
            activeHierarchy[mainCity]!.add(subArea);
          }
        }

        if (activeHierarchy.isEmpty) return const SizedBox.shrink();

        final sortedCities = activeHierarchy.keys.toList()..sort();

        return ValueListenableBuilder<SearchFilters>(
          valueListenable: HomeSearch.filters,
          builder: (context, filters, _) {
            final String? selectedCity = filters.location;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'استكشف الوجهات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (selectedCity != null && selectedCity.isNotEmpty)
                        GestureDetector(
                          onTap: () => HomeSearch.clear(),
                          child: const Text(
                            'عرض الكل',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Tier 1: Truly Dynamic City Stories
                SizedBox(
                  height: 115,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedCities.length,
                    itemBuilder: (context, index) {
                      final cityName = sortedCities[index];
                      final isSelected = selectedCity == cityName;
                      final imageUrl = cityThumbnails[cityName] ?? '';

                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            HomeSearch.filters.value = HomeSearch.filters.value
                                .copyWith(location: '', query: '');
                          } else {
                            HomeSearch.filters.value = HomeSearch.filters.value
                                .copyWith(location: cityName, query: '');
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 85,
                          margin: const EdgeInsets.only(right: 15),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : (isDark
                                              ? Colors.white12
                                              : Colors.black12),
                                    width: 2,
                                  ),
                                ),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: imageUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.black.withOpacity(0.05),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF2563EB,
                                              ).withOpacity(0.4),
                                              blurRadius: 15,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: imageUrl.isEmpty
                                      ? Icon(
                                          Icons.location_on,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black26,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cityName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Tier 2: Dynamic Areas from Database
                if (selectedCity != null &&
                    selectedCity.isNotEmpty &&
                    activeHierarchy.containsKey(selectedCity) &&
                    activeHierarchy[selectedCity]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: activeHierarchy[selectedCity]!.length,
                        itemBuilder: (context, index) {
                          final areaName = activeHierarchy[selectedCity]!
                              .elementAt(index);
                          final isAreaSelected = filters.query == areaName;

                          return GestureDetector(
                            onTap: () {
                              HomeSearch.filters.value = HomeSearch
                                  .filters
                                  .value
                                  .copyWith(
                                    query: isAreaSelected ? '' : areaName,
                                  );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isAreaSelected
                                    ? const Color(0xFF2563EB)
                                    : (isDark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.black.withOpacity(0.03)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                areaName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isAreaSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isAreaSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white60
                                            : Colors.black54),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
