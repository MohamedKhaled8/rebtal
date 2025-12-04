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

  Booking copyWith({
    String? id,
    String? chaletId,
    String? chaletName,
    String? ownerId,
    String? ownerName,
    String? userId,
    String? userName,
    DateTime? from,
    DateTime? to,
    BookingStatus? status,
    String? chaletImage,
    String? chaletLocation,
    String? userPhone,
    String? userEmail,
    String? paymentProvider,
    PaymentStatus? paymentStatus,
    String? paymentRef,
    String? transactionId,
    double? amount,
    DateTime? paidAt,
    DateTime? paymentExpiresAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      chaletId: chaletId ?? this.chaletId,
      chaletName: chaletName ?? this.chaletName,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      from: from ?? this.from,
      to: to ?? this.to,
      status: status ?? this.status,
      chaletImage: chaletImage ?? this.chaletImage,
      chaletLocation: chaletLocation ?? this.chaletLocation,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentRef: paymentRef ?? this.paymentRef,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      paidAt: paidAt ?? this.paidAt,
      paymentExpiresAt: paymentExpiresAt ?? this.paymentExpiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
