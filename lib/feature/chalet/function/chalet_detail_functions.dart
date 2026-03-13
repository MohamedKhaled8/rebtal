class ChaletDetailMetrics {
  final int guests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final String? area;
  final double ratingValue;
  final int reviewsCount;
  final String formattedRating;

  const ChaletDetailMetrics({
    required this.guests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.area,
    required this.ratingValue,
    required this.reviewsCount,
    required this.formattedRating,
  });
}

int getIntFromRequestData(
  Map<String, dynamic> requestData,
  List<String> keys,
) {
  for (final key in keys) {
    final val = requestData[key];
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
  }
  return 0;
}

ChaletDetailMetrics buildChaletDetailMetrics(
  Map<String, dynamic> requestData,
) {
  final guests = getIntFromRequestData(requestData, [
    'guests',
    'capacity',
    'guestCount',
    'maxGuests',
    'max_guests',
    'childrenCount',
  ]);

  final bedrooms = getIntFromRequestData(requestData, [
    'bedrooms',
    'bedroomCount',
    'rooms',
    'roomCount',
  ]);

  int beds = getIntFromRequestData(
    requestData,
    ['beds', 'bedCount', 'numBeds', 'num_beds'],
  );
  if (beds == 0 && bedrooms > 0) beds = bedrooms;

  final bathrooms = getIntFromRequestData(
    requestData,
    ['bathrooms', 'bathroomCount', 'baths'],
  );

  final areaVal = requestData['chaletArea'] ??
      requestData['area'] ??
      requestData['size'] ??
      requestData['totalArea'];

  final area = (areaVal == null ||
          areaVal.toString() == '0' ||
          areaVal.toString() == '0.0')
      ? null
      : areaVal.toString();

  final ratingValue =
      (requestData['rating'] as num?)?.toDouble() ?? 0.0;

  final reviewsCount =
      (requestData['reviews_count'] as num?)?.toInt() ??
      (requestData['ratingCount'] as num?)?.toInt() ??
      0;

  final formattedRating =
      ratingValue == 0 ? 'New' : ratingValue.toString();

  return ChaletDetailMetrics(
    guests: guests,
    bedrooms: bedrooms,
    beds: beds,
    bathrooms: bathrooms,
    area: area,
    ratingValue: ratingValue,
    reviewsCount: reviewsCount,
    formattedRating: formattedRating,
  );
}


