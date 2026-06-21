import 'package:rebtal/core/utils/constant/popular_destinations.dart';
import 'package:rebtal/core/utils/services/chalet_filter_service.dart';
import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';

class PopularDestinationsResolver {
  static List<PopularDestination> resolve(List<HomeChaletEntity> chalets) {
    if (chalets.isEmpty) return const [];

    final popularNames = PopularDestinations.namesAr.toSet();
    final usedDestinations = <String>{};

    for (final entity in chalets) {
      if (!ChaletFilterService.isEligibleForGeneralListing(entity.data)) {
        continue;
      }
      final features = entity.data['features'] as List<dynamic>?;
      if (features == null) continue;
      for (final feature in features) {
        final name = feature.toString();
        if (popularNames.contains(name)) {
          usedDestinations.add(name);
        }
      }
    }

    if (usedDestinations.isEmpty) return const [];

    return PopularDestinations.all
        .where((destination) => usedDestinations.contains(destination.nameAr))
        .toList(growable: false);
  }
}
