import 'package:equatable/equatable.dart';

enum ChaletStatus { pending, approved, rejected, hidden }

enum BookingAvailability { available, unavailable }

class ChaletEntity extends Equatable {
  final String id;
  final String chaletName;
  final String location;
  final String description;
  final String ownerId;
  final String ownerName;
  final double price;
  final int bedrooms;
  final int bathrooms;
  final List<String> images;
  final List<String> amenities;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChaletStatus status;
  final BookingAvailability bookingAvailability;
  final bool isVisible;

  final String? chaletArea;
  final int? childrenCount;
  final bool? discountEnabled;
  final String? discountType;
  final String? discountValue;
  final List<String>? features;

  const ChaletEntity({
    required this.id,
    required this.chaletName,
    required this.location,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.images,
    required this.amenities,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.status = ChaletStatus.pending,
    this.bookingAvailability = BookingAvailability.available,
    this.isVisible = true,
    this.chaletArea,
    this.childrenCount,
    this.discountEnabled,
    this.discountType,
    this.discountValue,
    this.features,
  });

  @override
  List<Object?> get props => [
    id,
    chaletName,
    location,
    description,
    ownerId,
    ownerName,
    price,
    bedrooms,
    bathrooms,
    images,
    amenities,
    latitude,
    longitude,
    createdAt,
    updatedAt,
    status,
    bookingAvailability,
    isVisible,
    chaletArea,
    childrenCount,
    discountEnabled,
    discountType,
    discountValue,
    features,
  ];
}
