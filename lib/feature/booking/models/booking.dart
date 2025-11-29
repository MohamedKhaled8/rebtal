import 'package:flutter/foundation.dart';

enum BookingStatus { pending, approved, rejected, cancelled }

enum PaymentStatus { pending, paid, failed, expired }

class Booking {
  final String id;
  final String chaletId;
  final String chaletName;
  final String ownerId;
  final String ownerName;
  final String userId;
  final String userName;
  final DateTime from;
  final DateTime to;
  BookingStatus status;
  // Chalet details
  final String? chaletImage;
  final String? chaletLocation;
  // User details
  final String? userPhone;
  final String? userEmail;
  // Payment fields (Fawry)
  final String? paymentProvider; // e.g., 'fawry'
  final PaymentStatus? paymentStatus;
  final String? paymentRef; // merchant/fawry ref
  final String? transactionId;
  final double? amount;
  final DateTime? paidAt;
  final DateTime? paymentExpiresAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.chaletId,
    required this.chaletName,
    required this.ownerId,
    required this.ownerName,
    required this.userId,
    required this.userName,
    required this.from,
    required this.to,
    this.status = BookingStatus.pending,
    this.chaletImage,
    this.chaletLocation,
    this.userPhone,
    this.userEmail,
    this.paymentProvider,
    this.paymentStatus,
    this.paymentRef,
    this.transactionId,
    this.amount,
    this.paidAt,
    this.paymentExpiresAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'chaletId': chaletId,
    'chaletName': chaletName,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'userId': userId,
    'userName': userName,
    'from': from.toIso8601String(),
    'to': to.toIso8601String(),
    'status': describeEnum(status),
    'chaletImage': chaletImage,
    'chaletLocation': chaletLocation,
    'userPhone': userPhone,
    'userEmail': userEmail,
    'paymentProvider': paymentProvider,
    'paymentStatus': paymentStatus != null
        ? describeEnum(paymentStatus!)
        : null,
    'paymentRef': paymentRef,
    'transactionId': transactionId,
    'amount': amount,
    'paidAt': paidAt?.toIso8601String(),
    'paymentExpiresAt': paymentExpiresAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
