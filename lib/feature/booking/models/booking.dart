import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending, // قيد الانتظار (المالك لم يوافق بعد)
  approved, // تمت الموافقة من المالك
  awaitingPayment, // في انتظار الدفع من المستخدم
  paymentUnderReview, // الدفع قيد المراجعة من الأدمن
  confirmed, // مؤكد ومدفوع بالكامل
  completed, // اكتمل الحجز
  rejected, // مرفوض من المالك
  cancelled, // ملغي من المستخدم
}

enum PaymentStatus { pending, paid, failed, expired }

enum PaymentMethod {
  cashOnArrival, // دفع عند الوصول
  bankTransfer, // تحويل بنكي
  vodafoneCash, // فودافون كاش
  instaPay, // إنستاباي
}

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
  // Owner details
  final String? ownerPhone;
  final String? ownerEmail;
  // Payment fields
  final String? paymentProvider; // e.g., 'fawry'
  final PaymentStatus? paymentStatus;
  final String? paymentRef; // merchant/fawry ref
  final String? transactionId;
  final double? amount;
  final DateTime? paidAt;
  final DateTime? paymentExpiresAt;
  final DateTime? updatedAt;
  final DateTime? createdAt; // Added createdAt

  // New payment fields for Admin-intermediary system
  final PaymentMethod? paymentMethod;
  final String? paymentProofUrl;
  final DateTime? paymentProofUploadedAt;
  final DateTime? adminConfirmedPaymentAt;
  final String? adminPaymentNotes;
  final double? amountPaidToOwner;
  final DateTime? ownerPaidAt;
  final double? refundAmount;
  final DateTime? refundedAt;
  final String? refundReason;

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
    this.ownerPhone,
    this.ownerEmail,
    this.paymentProvider,
    this.paymentStatus,
    this.paymentRef,
    this.transactionId,
    this.amount,
    this.paidAt,
    this.paymentExpiresAt,
    this.updatedAt,
    this.createdAt,
    this.paymentMethod,
    this.paymentProofUrl,
    this.paymentProofUploadedAt,
    this.adminConfirmedPaymentAt,
    this.adminPaymentNotes,
    this.amountPaidToOwner,
    this.ownerPaidAt,
    this.refundAmount,
    this.refundedAt,
    this.refundReason,
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
    String? ownerPhone,
    String? ownerEmail,
    String? paymentProvider,
    PaymentStatus? paymentStatus,
    String? paymentRef,
    String? transactionId,
    double? amount,
    DateTime? paidAt,
    DateTime? paymentExpiresAt,
    DateTime? updatedAt,
    DateTime? createdAt,
    PaymentMethod? paymentMethod,
    String? paymentProofUrl,
    DateTime? paymentProofUploadedAt,
    DateTime? adminConfirmedPaymentAt,
    String? adminPaymentNotes,
    double? amountPaidToOwner,
    DateTime? ownerPaidAt,
    double? refundAmount,
    DateTime? refundedAt,
    String? refundReason,
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
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentRef: paymentRef ?? this.paymentRef,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      paidAt: paidAt ?? this.paidAt,
      paymentExpiresAt: paymentExpiresAt ?? this.paymentExpiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      paymentProofUploadedAt:
          paymentProofUploadedAt ?? this.paymentProofUploadedAt,
      adminConfirmedPaymentAt:
          adminConfirmedPaymentAt ?? this.adminConfirmedPaymentAt,
      adminPaymentNotes: adminPaymentNotes ?? this.adminPaymentNotes,
      amountPaidToOwner: amountPaidToOwner ?? this.amountPaidToOwner,
      ownerPaidAt: ownerPaidAt ?? this.ownerPaidAt,
      refundAmount: refundAmount ?? this.refundAmount,
      refundedAt: refundedAt ?? this.refundedAt,
      refundReason: refundReason ?? this.refundReason,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      chaletId: json['chaletId'] as String,
      chaletName: json['chaletName'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      from: _parseDate(json['from'])!,
      to: _parseDate(json['to'])!,
      status: _parseStatus(json['status'] as String?),
      chaletImage: json['chaletImage'] as String?,
      chaletLocation: json['chaletLocation'] as String?,
      userPhone: json['userPhone'] as String?,
      userEmail: json['userEmail'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      ownerEmail: json['ownerEmail'] as String?,
      paymentProvider: json['paymentProvider'] as String?,
      paymentStatus: json['paymentStatus'] != null
          ? _parsePaymentStatus(json['paymentStatus'] as String)
          : null,
      paymentRef: json['paymentRef'] as String?,
      transactionId: json['transactionId'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      paidAt: _parseDate(json['paidAt']),
      paymentExpiresAt: _parseDate(json['paymentExpiresAt']),
      updatedAt: _parseDate(json['updatedAt']),
      paymentMethod: json['paymentMethod'] != null
          ? _parsePaymentMethod(json['paymentMethod'] as String)
          : null,
      paymentProofUrl: json['paymentProofUrl'] as String?,
      paymentProofUploadedAt: _parseDate(json['paymentProofUploadedAt']),
      adminConfirmedPaymentAt: _parseDate(json['adminConfirmedPaymentAt']),
      adminPaymentNotes: json['adminPaymentNotes'] as String?,
      amountPaidToOwner: (json['amountPaidToOwner'] as num?)?.toDouble(),
      ownerPaidAt: _parseDate(json['ownerPaidAt']),
      refundAmount: (json['refundAmount'] as num?)?.toDouble(),
      refundedAt: _parseDate(json['refundedAt']),
      refundReason: json['refundReason'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  static BookingStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'approved':
        return BookingStatus.approved;
      case 'awaitingPayment':
        return BookingStatus.awaitingPayment;
      case 'paymentUnderReview':
        return BookingStatus.paymentUnderReview;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'rejected':
        return BookingStatus.rejected;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  static PaymentStatus? _parsePaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'expired':
        return PaymentStatus.expired;
      default:
        return null;
    }
  }

  static PaymentMethod? _parsePaymentMethod(String method) {
    switch (method) {
      case 'cashOnArrival':
        return PaymentMethod.cashOnArrival;
      case 'bankTransfer':
        return PaymentMethod.bankTransfer;
      case 'vodafoneCash':
        return PaymentMethod.vodafoneCash;
      case 'instaPay':
        return PaymentMethod.instaPay;
      default:
        return null;
    }
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
    'ownerPhone': ownerPhone,
    'ownerEmail': ownerEmail,
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
    'paymentMethod': paymentMethod != null
        ? describeEnum(paymentMethod!)
        : null,
    'paymentProofUrl': paymentProofUrl,
    'paymentProofUploadedAt': paymentProofUploadedAt?.toIso8601String(),
    'adminConfirmedPaymentAt': adminConfirmedPaymentAt?.toIso8601String(),
    'adminPaymentNotes': adminPaymentNotes,
    'amountPaidToOwner': amountPaidToOwner,
    'ownerPaidAt': ownerPaidAt?.toIso8601String(),
    'refundAmount': refundAmount,
    'refundedAt': refundedAt?.toIso8601String(),
    'refundReason': refundReason,
  };
}
