import 'package:cloud_firestore/cloud_firestore.dart';

class ChaletModel {
  final String id;
  final String ownerId; // This is the key field for privacy
  final String ownerName;
  final String chaletName;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final String price;
  final int bedrooms;
  final int bathrooms;
  final bool hasWifi;
  final bool hasPool;
  final bool hasAirConditioning;
  final bool hasParking;
  final bool isAvailable;
  final String status; // pending, approved, rejected
  final List<String> images;
  final String? profileImage;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String email;
  final String phoneNumber;

  const ChaletModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.chaletName,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.hasWifi,
    required this.hasPool,
    required this.hasAirConditioning,
    required this.hasParking,
    required this.isAvailable,
    required this.status,
    required this.images,
    this.profileImage,
    this.availableFrom,
    this.availableTo,
    required this.createdAt,
    this.updatedAt,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'chaletName': chaletName,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'hasWifi': hasWifi,
      'hasPool': hasPool,
      'hasAirConditioning': hasAirConditioning,
      'hasParking': hasParking,
      'isAvailable': isAvailable,
      'status': status,
      'images': images,
      'profileImage': profileImage,
      'availableFrom': availableFrom?.toIso8601String(),
      'availableTo': availableTo?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  factory ChaletModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ChaletModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? map['merchantName'] ?? '',
      chaletName: map['chaletName'] ?? map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      price: map['price']?.toString() ?? '0',
      bedrooms: map['bedrooms'] ?? 1,
      bathrooms: map['bathrooms'] ?? 1,
      hasWifi: map['hasWifi'] ?? false,
      hasPool: map['hasPool'] ?? false,
      hasAirConditioning: map['hasAirConditioning'] ?? false,
      hasParking: map['hasParking'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      status: map['status'] ?? 'pending',
      images: List<String>.from(map['images'] ?? []),
      profileImage: map['profileImage'],
      availableFrom: map['availableFrom'] != null 
          ? DateTime.tryParse(map['availableFrom']) 
          : null,
      availableTo: map['availableTo'] != null 
          ? DateTime.tryParse(map['availableTo']) 
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp 
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt']) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp 
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt']))
          : null,
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? map['phone'] ?? '',
    );
  }

  ChaletModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? chaletName,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? price,
    int? bedrooms,
    int? bathrooms,
    bool? hasWifi,
    bool? hasPool,
    bool? hasAirConditioning,
    bool? hasParking,
    bool? isAvailable,
    String? status,
    List<String>? images,
    String? profileImage,
    DateTime? availableFrom,
    DateTime? availableTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? email,
    String? phoneNumber,
  }) {
    return ChaletModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      chaletName: chaletName ?? this.chaletName,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      price: price ?? this.price,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      hasWifi: hasWifi ?? this.hasWifi,
      hasPool: hasPool ?? this.hasPool,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasParking: hasParking ?? this.hasParking,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
      images: images ?? this.images,
      profileImage: profileImage ?? this.profileImage,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
