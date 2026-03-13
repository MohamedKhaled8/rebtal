/// Central definition for popular destinations used across the app
class PopularDestinations {
  static const List<_PopularDestination> all = [
    _PopularDestination(
      key: 'north_coast',
      nameAr: 'الساحل الشمالي',
      imageUrl:
          'https://images.pexels.com/photos/1007657/pexels-photo-1007657.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    _PopularDestination(
      key: 'ain_sokhna',
      nameAr: 'العين السخنة',
      imageUrl:
          'https://images.pexels.com/photos/1450360/pexels-photo-1450360.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    _PopularDestination(
      key: 'sharm_sheikh',
      nameAr: 'شرم الشيخ',
      imageUrl:
          'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    _PopularDestination(
      key: 'hurghada',
      nameAr: 'الغردقة',
      imageUrl:
          'https://images.pexels.com/photos/261102/pexels-photo-261102.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    _PopularDestination(
      key: 'gouna',
      nameAr: 'الجونة',
      imageUrl:
          'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
  ];

  /// Arabic names list – used when we need only the label (e.g. for features)
  static List<String> get namesAr =>
      all.map((destination) => destination.nameAr).toList(growable: false);
}

class _PopularDestination {
  final String key;
  final String nameAr;
  final String imageUrl;

  const _PopularDestination({
    required this.key,
    required this.nameAr,
    required this.imageUrl,
  });
}

