import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rebtal/core/utils/helper/image_clean/helper_image_actions.dart';
import 'package:rebtal/core/utils/helper/image_clean/image_models.dart';

void main() {
  group('ChaletDraftValidator', () {
    const validator = ChaletDraftValidator();

    test('returns upload error when no images', () {
      const data = ChaletDraftSnapshot(
        uploadedImages: [],
        selectedLocation: 'Cairo',
        isAvailable: true,
        hasWifi: false,
        hasPool: false,
        hasAirConditioning: false,
        hasParking: false,
        hasGarden: false,
        hasBBQ: false,
        hasBeachView: false,
        hasHousekeeping: false,
        hasPetsAllowed: false,
        hasGym: false,
        hasKitchen: false,
        hasTV: false,
        status: 'pending',
        phoneNumber: '01000000000',
        email: 'a@b.com',
        chaletName: 'name',
        description: 'desc',
        merchantName: 'merchant',
        price: '10',
        chaletArea: '100',
        bedrooms: 2,
        bathrooms: 1,
        availableFrom: null,
        availableTo: null,
        childrenCount: 0,
        discountEnabled: false,
        discountType: null,
        discountValue: null,
        features: [],
      );

      expect(validator.validate(data), 'owner_upload_chalet_images');
    });

    test('returns null when required fields are valid', () {
      final data = ChaletDraftSnapshot(
        uploadedImages: [File('fake.jpg')],
        selectedLocation: 'Cairo',
        isAvailable: true,
        hasWifi: true,
        hasPool: false,
        hasAirConditioning: false,
        hasParking: false,
        hasGarden: false,
        hasBBQ: false,
        hasBeachView: false,
        hasHousekeeping: false,
        hasPetsAllowed: false,
        hasGym: false,
        hasKitchen: false,
        hasTV: false,
        status: 'pending',
        phoneNumber: '01000000000',
        email: 'a@b.com',
        chaletName: 'name',
        description: 'desc',
        merchantName: 'merchant',
        price: '10',
        chaletArea: '100',
        bedrooms: 2,
        bathrooms: 1,
        availableFrom: null,
        availableTo: null,
        childrenCount: 0,
        discountEnabled: false,
        discountType: null,
        discountValue: null,
        features: const [],
      );

      expect(validator.validate(data), isNull);
    });
  });

  group('ChaletAmenitiesExtractor', () {
    const extractor = ChaletAmenitiesExtractor();

    test('returns only enabled amenities', () {
      const data = ChaletDraftSnapshot(
        uploadedImages: [],
        selectedLocation: '',
        isAvailable: true,
        hasWifi: true,
        hasPool: false,
        hasAirConditioning: true,
        hasParking: false,
        hasGarden: false,
        hasBBQ: false,
        hasBeachView: false,
        hasHousekeeping: false,
        hasPetsAllowed: false,
        hasGym: false,
        hasKitchen: true,
        hasTV: false,
        status: 'pending',
        phoneNumber: null,
        email: null,
        chaletName: null,
        description: null,
        merchantName: null,
        price: '',
        chaletArea: null,
        bedrooms: null,
        bathrooms: null,
        availableFrom: null,
        availableTo: null,
        childrenCount: null,
        discountEnabled: false,
        discountType: null,
        discountValue: null,
        features: [],
      );

      expect(
        extractor.extract(data),
        ['hasWifi', 'hasAirConditioning', 'hasKitchen'],
      );
    });
  });
}
