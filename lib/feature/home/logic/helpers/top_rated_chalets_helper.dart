import 'package:rebtal/feature/home/domain/entities/home_chalet_entity.dart';

class TopRatedChaletsHelper {
  static List<HomeChaletEntity> sortByRating(List<HomeChaletEntity> source) {
    final sorted = List<HomeChaletEntity>.from(source);
    sorted.sort((a, b) {
      final ratingA = _readRating(a);
      final ratingB = _readRating(b);
      return ratingB.compareTo(ratingA);
    });
    return sorted;
  }

  static List<HomeChaletEntity> topRatedSection(List<HomeChaletEntity> source) {
    return sortByRating(source).take(10).toList(growable: false);
  }

  static List<HomeChaletEntity> topRatedPreview(
    List<HomeChaletEntity> source, {
    int limit = 3,
  }) {
    return sortByRating(source).take(limit).toList(growable: false);
  }

  static double _readRating(HomeChaletEntity entity) {
    final value = entity.data['averageRating'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
