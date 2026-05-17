import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/feature/home/logic/helpers/location_areas_resolver.dart';

class LocationCityChip extends StatelessWidget {
  const LocationCityChip({
    super.key,
    required this.city,
    required this.isDark,
    required this.isSelected,
  });

  final LocationCityArea city;
  final bool isDark;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          HomeSearch.filters.value =
              HomeSearch.filters.value.copyWith(location: '', query: '');
        } else {
          HomeSearch.filters.value = HomeSearch.filters.value.copyWith(
            location: city.cityName,
            query: '',
          );
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
                      : (isDark ? Colors.white12 : Colors.black12),
                  width: 2,
                ),
              ),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: city.thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: city.thumbnailUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 140,
                        fadeInDuration: Duration.zero,
                        placeholder: (context, url) => Container(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.location_on,
                          color: isDark ? Colors.white38 : Colors.black26,
                        ),
                      )
                    : Icon(
                        Icons.location_on,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              city.cityName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
