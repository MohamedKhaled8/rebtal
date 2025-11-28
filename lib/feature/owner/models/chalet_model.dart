import 'package:cloud_firestore/cloud_firestore.dart';

enum ChaletStatus {
  pending,
  approved,
  rejected,
  hidden,
}

enum BookingAvailability {
  available,
  unavailable,
}

class ChaletModel {
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

  ChaletModel({
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
      bookingAvailability: _parseBookingAvailability(map['bookingAvailability']),
      isVisible: map['isVisible'] ?? true,
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
      print('Error parsing datetime: $e');
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
      print('Error parsing chalet status: $e');
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
      print('Error parsing booking availability: $e');
      return BookingAvailability.available;
    }
  }
}
