import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/owner/domain/entities/chalet_entity.dart';

class ChaletModel extends ChaletEntity {
  const ChaletModel({
    required super.id,
    required super.chaletName,
    required super.location,
    required super.description,
    required super.ownerId,
    required super.ownerName,
    required super.price,
    required super.bedrooms,
    required super.bathrooms,
    required super.images,
    required super.amenities,
    super.latitude,
    super.longitude,
    required super.createdAt,
    required super.updatedAt,
    super.status = ChaletStatus.pending,
    super.bookingAvailability = BookingAvailability.available,
    super.isVisible = true,
    super.chaletArea,
    super.childrenCount,
    super.discountEnabled,
    super.discountType,
    super.discountValue,
    super.features,
  });

  factory ChaletModel.fromMap(Map<String, dynamic> map, String id) {
    return ChaletModel(
      id: id,
      chaletName: map['chaletName'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      bedrooms: map['bedrooms'] ?? 0,
      bathrooms: map['bathrooms'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      status: _parseChaletStatus(map['status']),
      bookingAvailability: _parseBookingAvailability(
        map['bookingAvailability'],
      ),
      isVisible: map['isVisible'] ?? true,
      chaletArea: map['chaletArea']?.toString(),
      childrenCount: map['childrenCount'],
      discountEnabled: map['discountEnabled'],
      discountType: map['discountType'],
      discountValue: map['discountValue'],
      features: map['features'] != null
          ? List<String>.from(map['features'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chaletName': chaletName,
      'location': location,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'images': images,
      'amenities': amenities,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status.name,
      'bookingAvailability': bookingAvailability.name,
      'isVisible': isVisible,
      'chaletArea': chaletArea,
      'childrenCount': childrenCount,
      'discountEnabled': discountEnabled,
      'discountType': discountType,
      'discountValue': discountValue,
      'features': features,
    };
  }

  ChaletModel copyWith({
    String? id,
    String? chaletName,
    String? location,
    String? description,
    String? ownerId,
    String? ownerName,
    double? price,
    int? bedrooms,
    int? bathrooms,
    List<String>? images,
    List<String>? amenities,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    ChaletStatus? status,
    BookingAvailability? bookingAvailability,
    bool? isVisible,
    String? chaletArea,
    int? childrenCount,
    bool? discountEnabled,
    String? discountType,
    String? discountValue,
    List<String>? features,
  }) {
    return ChaletModel(
      id: id ?? this.id,
      chaletName: chaletName ?? this.chaletName,
      location: location ?? this.location,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      price: price ?? this.price,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      bookingAvailability: bookingAvailability ?? this.bookingAvailability,
      isVisible: isVisible ?? this.isVisible,
      chaletArea: chaletArea ?? this.chaletArea,
      childrenCount: childrenCount ?? this.childrenCount,
      discountEnabled: discountEnabled ?? this.discountEnabled,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      features: features ?? this.features,
    );
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();

    try {
      if (dateTime is Timestamp) {
        return dateTime.toDate();
      } else if (dateTime is String) {
        return DateTime.parse(dateTime);
      } else if (dateTime is DateTime) {
        return dateTime;
      }
    } catch (e) {
      // print('Error parsing datetime: $e');
    }

    return DateTime.now();
  }

  static ChaletStatus _parseChaletStatus(dynamic status) {
    if (status == null) return ChaletStatus.pending;

    try {
      final statusString = status.toString().toLowerCase();
      switch (statusString) {
        case 'pending':
          return ChaletStatus.pending;
        case 'approved':
          return ChaletStatus.approved;
        case 'rejected':
          return ChaletStatus.rejected;
        case 'hidden':
          return ChaletStatus.hidden;
        default:
          return ChaletStatus.pending;
      }
    } catch (e) {
      return ChaletStatus.pending;
    }
  }

  static BookingAvailability _parseBookingAvailability(dynamic availability) {
    if (availability == null) return BookingAvailability.available;

    try {
      final availabilityString = availability.toString().toLowerCase();
      switch (availabilityString) {
        case 'available':
          return BookingAvailability.available;
        case 'unavailable':
          return BookingAvailability.unavailable;
        default:
          return BookingAvailability.available;
      }
    } catch (e) {
      return BookingAvailability.available;
    }
  }
}
