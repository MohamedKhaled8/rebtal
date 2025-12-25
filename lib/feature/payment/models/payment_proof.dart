import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum PaymentProofStatus {
  pending, // قيد المراجعة
  approved, // تم التأكيد
  rejected, // مرفوض
}

class PaymentProof {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String? imageUrl;
  final String? transactionNumber;
  final DateTime uploadedAt;
  final PaymentProofStatus status;
  final String? adminNotes;
  final DateTime? reviewedAt;
  final String? reviewedBy; // Admin ID

  const PaymentProof({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    this.imageUrl,
    this.transactionNumber,
    required this.uploadedAt,
    this.status = PaymentProofStatus.pending,
    this.adminNotes,
    this.reviewedAt,
    this.reviewedBy,
  });

  PaymentProof copyWith({
    String? id,
    String? bookingId,
    String? userId,
    String? userName,
    String? imageUrl,
    String? transactionNumber,
    DateTime? uploadedAt,
    PaymentProofStatus? status,
    String? adminNotes,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return PaymentProof(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      imageUrl: imageUrl ?? this.imageUrl,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'bookingId': bookingId,
    'userId': userId,
    'userName': userName,
    'imageUrl': imageUrl,
    'transactionNumber': transactionNumber,
    'uploadedAt': uploadedAt.toIso8601String(),
    'status': describeEnum(status),
    'adminNotes': adminNotes,
    'reviewedAt': reviewedAt?.toIso8601String(),
    'reviewedBy': reviewedBy,
  };

  factory PaymentProof.fromMap(Map<String, dynamic> map) {
    return PaymentProof(
      id: map['id'] ?? '',
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      imageUrl: map['imageUrl'],
      transactionNumber: map['transactionNumber'],
      uploadedAt: _parseDate(map['uploadedAt']),
      status: _parseStatus(map['status']),
      adminNotes: map['adminNotes'],
      reviewedAt: map['reviewedAt'] != null
          ? _parseDate(map['reviewedAt'])
          : null,
      reviewedBy: map['reviewedBy'],
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  static PaymentProofStatus _parseStatus(dynamic status) {
    if (status == null) return PaymentProofStatus.pending;

    try {
      final statusString = status.toString().toLowerCase();
      switch (statusString) {
        case 'pending':
          return PaymentProofStatus.pending;
        case 'approved':
          return PaymentProofStatus.approved;
        case 'rejected':
          return PaymentProofStatus.rejected;
        default:
          return PaymentProofStatus.pending;
      }
    } catch (e) {
      return PaymentProofStatus.pending;
    }
  }
}
