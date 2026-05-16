import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/core/utils/services/email_service.dart';
import 'package:rebtal/core/utils/helper/booking_profile_fields.dart';

// ✅ إضافة هذه الدوال للـ BookingCubit

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(const BookingState(bookings: [], isLoading: false));

  StreamSubscription? _bookingsSubscription;
  String? _activeBookingsScope;

  // ✅ تحميل حجوزات المالك فقط
  Future<void> loadOwnerBookings(String ownerId) async {
    final scope = 'owner:$ownerId';
    if (_activeBookingsScope == scope && _bookingsSubscription != null) {
      return;
    }
    _activeBookingsScope = scope;

    await _bookingsSubscription?.cancel();
    final showLoading = state.bookings.isEmpty;
    emit(
      state.copyWith(
        isLoading: showLoading,
        bookings: showLoading ? [] : state.bookings,
      ),
    );

    final query = FirebaseFirestore.instance
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId);
    // .orderBy('createdAt', descending: true); // ⚠️ تم التعطيل مؤقتاً لإصلاح مشكلة الـ Index

    // ⚡️ محاولة تحديث الكاش من السيرفر مباشرة أولاً
    try {
      final serverSnapshot = await query.get(
        const GetOptions(source: Source.server),
      );
      await _processSnapshot(serverSnapshot);
    } catch (e) {}

    _bookingsSubscription = query.snapshots().listen(
      (snapshot) async {
        await _processSnapshot(snapshot);
      },
      onError: (e) {
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  // ✅ تحميل حجوزات المستخدم فقط
  Future<void> loadUserBookings(String userId) async {
    final scope = 'user:$userId';
    if (_activeBookingsScope == scope && _bookingsSubscription != null) {
      return;
    }
    _activeBookingsScope = scope;

    await _bookingsSubscription?.cancel();
    final showLoading = state.bookings.isEmpty;
    emit(
      state.copyWith(
        isLoading: showLoading,
        bookings: showLoading ? [] : state.bookings,
      ),
    );

    final query = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId);
    // .orderBy('createdAt', descending: true); // ⚠️ تم التعطيل مؤقتاً لإصلاح مشكلة الـ Index

    // ⚡️ محاولة تحديث الكاش من السيرفر مباشرة أولاً
    try {
      final serverSnapshot = await query.get(
        const GetOptions(source: Source.server),
      );
      await _processSnapshot(serverSnapshot);
    } catch (e) {}

    _bookingsSubscription = query.snapshots().listen(
      (snapshot) async {
        await _processSnapshot(snapshot);
      },
      onError: (e) {
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  Future<void> loadBookings() async {
    await _bookingsSubscription?.cancel();
    emit(state.copyWith(isLoading: true, bookings: []));

    final query = FirebaseFirestore.instance.collection('bookings')
    // .orderBy('createdAt', descending: true) // ⚠️ تم التعطيل مؤقتاً
    ;

    try {
      final serverSnapshot = await query.get(
        const GetOptions(source: Source.server),
      );
      await _processSnapshot(serverSnapshot);
    } catch (e) {}

    _bookingsSubscription = query.snapshots().listen(
      (snapshot) async {
        await _processSnapshot(snapshot);
      },
      onError: (e) {
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  Future<void> _processSnapshot(QuerySnapshot snapshot) async {
    if (snapshot.docs.isEmpty) {
      emit(state.copyWith(bookings: [], isLoading: false));
      return;
    }

    final bookings = await Future.wait(
      snapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;

        // جلب معلومات الشاليه
        String? chaletImage;
        String? chaletLocation;

        try {
          final chaletId = data['chaletId'] ?? '';
          if (chaletId.isNotEmpty) {
            final chaletDoc = await FirebaseFirestore.instance
                .collection('chalets')
                .doc(chaletId)
                .get();

            if (chaletDoc.exists) {
              final chaletData = chaletDoc.data();
              if (chaletData != null) {
                final images = (chaletData['images'] as List?)?.cast<dynamic>();
                chaletImage = images != null && images.isNotEmpty
                    ? images.first.toString()
                    : null;

                chaletLocation =
                    chaletData['location']?.toString() ??
                    chaletData['city']?.toString() ??
                    chaletData['address']?.toString() ??
                    'غير محدد';
              }
            }
          }
        } catch (e) {
          // Removed debugPrint
        }

        // جلب معلومات المستخدم (الاسم من الملف إذا لم يُخزَّن في الحجز)
        String? userPhone;
        String? userEmail;
        String resolvedUserName = (data['userName'] ?? '').toString().trim();

        try {
          final userId = data['userId'] ?? '';
          if (userId.isNotEmpty) {
            final userDoc = await fetchFirestoreProfileDoc(userId);
            if (userDoc != null && userDoc.exists) {
              final userData = userDoc.data();
              if (userData != null) {
                if (resolvedUserName.isEmpty) {
                  resolvedUserName = displayNameFromProfileMap(userData);
                }
                userPhone = phoneFromProfileMap(userData);
                final em = (userData['email']?.toString() ?? '').trim();
                userEmail = em.isEmpty ? null : em;
              }
            }
          }
        } catch (e) {
          debugPrint('Error fetching user details: $e');
        }

        // جلب معلومات المالك
        String? ownerPhone;
        String? ownerEmail;
        String resolvedOwnerName = (data['ownerName'] ?? '').toString().trim();

        try {
          final ownerId = data['ownerId'] ?? '';
          if (ownerId.isNotEmpty) {
            final ownerDoc = await fetchFirestoreProfileDoc(ownerId);
            if (ownerDoc != null && ownerDoc.exists) {
              final ownerData = ownerDoc.data();
              if (ownerData != null) {
                if (resolvedOwnerName.isEmpty) {
                  resolvedOwnerName = displayNameFromProfileMap(ownerData);
                }
                ownerPhone = phoneFromProfileMap(ownerData);
                final oem = (ownerData['email']?.toString() ?? '').trim();
                ownerEmail = oem.isEmpty ? null : oem;
              }
            }
          }
        } catch (e) {}

        // Parse payment rejection fields
        final paymentRejected = data['paymentRejected'] as bool? ?? false;
        DateTime? paymentRejectedAt;
        if (data['paymentRejectedAt'] != null) {
          paymentRejectedAt = _parseDateTime(data['paymentRejectedAt']);
        }

        return Booking(
          id: doc.id,
          chaletId: data['chaletId'] ?? '',
          chaletName: data['chaletName'] ?? '',
          ownerId: data['ownerId'] ?? '',
          ownerName: resolvedOwnerName,
          userId: data['userId'] ?? '',
          userName: resolvedUserName,
          from: _parseDateTime(data['from']),
          to: _parseDateTime(data['to']),
          status: _parseStatus(data['status']),
          chaletImage: chaletImage,
          chaletLocation: chaletLocation,
          userPhone: userPhone,
          userEmail: userEmail,
          ownerPhone: ownerPhone,
          ownerEmail: ownerEmail,
          amount: (data['amount'] as num?)?.toDouble(),
          updatedAt: _parseDateTime(data['updatedAt']),
          adminPaymentNotes: data['adminPaymentNotes'] as String?,
          paymentRejected: paymentRejected,
          paymentRejectedAt: paymentRejectedAt,
          originalTenantId: data['originalTenantId'] as String?,
          originalTenantName: data['originalTenantName'] as String?,
          originalTenantPhone: data['originalTenantPhone'] as String?,
          originalTenantEmail: data['originalTenantEmail'] as String?,
          transferredAt: data['transferredAt'] != null
              ? _parseDateTime(data['transferredAt'])
              : null,
          isDayUse: data['isDayUse'] as bool? ?? false,
        );
      }).toList(),
    );

    emit(state.copyWith(bookings: bookings, isLoading: false));
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }

  // ✅ إضافة حجز جديد
  void addBooking(Booking booking) {
    final currentBookings = List<Booking>.from(state.bookings);

    // ✅ التحقق من عدم وجود الحجز مسبقاً
    final existingIndex = currentBookings.indexWhere((b) => b.id == booking.id);
    if (existingIndex >= 0) {
      // ✅ استبدال الحجز الموجود
      currentBookings[existingIndex] = booking;
    } else {
      // ✅ إضافة حجز جديد
      currentBookings.insert(0, booking);
    }

    emit(state.copyWith(bookings: currentBookings));
  }

  // تحديث حالة الحجز محلياً وفي Firestore
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    // حفظ الحالة القديمة للتراجع في حالة الخطأ
    final previousBookings = List<Booking>.from(state.bookings);
    final index = previousBookings.indexWhere((b) => b.id == bookingId);

    if (index == -1) return;

    try {
      // ✅ تحديث تفاؤلي (Optimistic Update): نحدث الواجهة فوراً
      final currentBookings = List<Booking>.from(state.bookings);
      currentBookings[index] = currentBookings[index].copyWith(
        status: newStatus,
      );
      emit(state.copyWith(bookings: currentBookings));

      // تحديث في Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': describeEnum(newStatus),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // ✅ إرسال إشعار للمستخدم (OneSignal + In-App)
      final booking = currentBookings[index];

      // 1. In-App Notification (Firestore) + Push (OneSignal)
      if (newStatus == BookingStatus.approved) {
        await NotificationService().sendNotification(
          userId: booking.userId,
          titleKey: 'notifications_booking_approved_title',
          bodyKey: 'notifications_booking_approved_body',
          bodyParams: {'chaletName': booking.chaletName},
          type: NotificationType.bookingApproved,
          relatedId: booking.id,
          data: {'bookingId': booking.id, 'chaletId': booking.chaletId},
        );
      } else if (newStatus == BookingStatus.rejected) {
        await NotificationService().sendNotification(
          userId: booking.userId,
          titleKey: 'notifications_booking_rejected_title',
          bodyKey: 'notifications_booking_rejected_body',
          bodyParams: {'chaletName': booking.chaletName},
          type: NotificationType.bookingRejected,
          relatedId: booking.id,
          data: {'bookingId': booking.id, 'chaletId': booking.chaletId},
        );
      }
    } catch (e) {
      emit(state.copyWith(bookings: previousBookings));
      rethrow;
    }
  }

  // تحديث حالة الدفع للحجز
  Future<void> markBookingAsPaid({
    required String bookingId,
    required String transactionId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'isPaid': true,
            'paymentTransactionId': transactionId,
            'paidAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  // ✅ إلغاء الحجز
  void cancelBooking(String bookingId) async {
    try {
      // ✅ تحديث محلي
      updateBookingStatus(bookingId, BookingStatus.cancelled);

      // ✅ تحديث في Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': describeEnum(BookingStatus.cancelled),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // ✅ إرسال إشعار للمالك (اختياري)
      final booking = state.bookings.firstWhere(
        (b) => b.id == bookingId,
        orElse: () => Booking(
          id: '',
          chaletId: '',
          chaletName: '',
          ownerId: '',
          ownerName: '',
          userId: '',
          userName: '',
          from: DateTime.now(),
          to: DateTime.now(),
          status: BookingStatus.cancelled,
          updatedAt: DateTime.now(),
        ),
      );

      if (booking.id.isNotEmpty && booking.ownerId.isNotEmpty) {
        // 1. In-App + Push
        await NotificationService().sendNotification(
          userId: booking.ownerId,
          titleKey: 'notifications_booking_cancelled_title',
          bodyKey: 'notifications_booking_cancelled_body',
          bodyParams: {
            'userName': booking.userName,
            'chaletName': booking.chaletName,
          },
          type: NotificationType.general,
          relatedId: booking.id,
          data: {'bookingId': booking.id},
        );
      }
    } catch (e) {}
  }

  // ✅ حذف الحجز
  void removeBooking(String bookingId) {
    final currentBookings = state.bookings
        .where((b) => b.id != bookingId)
        .toList();
    emit(state.copyWith(bookings: currentBookings));
  }

  // ✅ الحصول على الحجوزات حسب المالك
  List<Booking> getOwnerBookings(String ownerId) {
    final normalizedOwnerId = _normalizeId(ownerId);

    return state.bookings.where((booking) {
      final bookingOwnerId = _normalizeId(booking.ownerId);
      return bookingOwnerId == normalizedOwnerId;
    }).toList();
  }

  // ✅ إلغاء الحجز مع الاسترداد
  Future<void> cancelBookingWithRefund(
    String bookingId,
    double refundAmount,
    String refundReason,
  ) async {
    try {
      // ✅ تحديث محلي
      updateBookingStatus(bookingId, BookingStatus.cancelled);

      // ✅ تحديث في Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': describeEnum(BookingStatus.cancelled),
            'refundAmount': refundAmount,
            'refundReason': refundReason,
            'cancelledAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // ✅ إرسال إيميل للمستخدم
      final booking = state.bookings.firstWhere(
        (b) => b.id == bookingId,
        orElse: () => Booking(
          id: '',
          chaletId: '',
          chaletName: '',
          ownerId: '',
          ownerName: '',
          userId: '',
          userName: '',
          from: DateTime.now(),
          to: DateTime.now(),
          status: BookingStatus.cancelled,
          updatedAt: DateTime.now(),
        ),
      );

      if (booking.id.isNotEmpty) {
        // إرسال الإيميل
        await EmailService().sendBookingCancellationEmail(
          booking: booking,
          refundAmount: refundAmount,
          policyMessage: refundReason,
        );

        // ✅ إرسال إشعار للمالك
        if (booking.ownerId.isNotEmpty) {
          // 1. In-App + Push
          await NotificationService().sendNotification(
            userId: booking.ownerId,
            titleKey: 'notifications_booking_cancelled_title',
            bodyKey: 'notifications_booking_cancelled_body',
            bodyParams: {
              'userName': booking.userName,
              'chaletName': booking.chaletName,
            },
            type: NotificationType.general,
            relatedId: booking.id,
            data: {'bookingId': booking.id},
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // ✅ الحصول على الحجوزات حسب المستخدم
  List<Booking> getUserBookings(String userId) {
    return state.bookings.where((booking) => booking.userId == userId).toList();
  }

  // ✅ دوال مساعدة
  String _normalizeId(String id) {
    if (id.contains(':')) return id.split(':').last.trim();
    return id.trim();
  }

  DateTime _parseDateTime(dynamic dateTime) {
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
      return DateTime.now();
    }
    return DateTime.now();
  }

  BookingStatus _parseStatus(dynamic status) {
    if (status == null) return BookingStatus.pending;

    try {
      final statusString = status.toString().toLowerCase();
      switch (statusString) {
        case 'pending':
          return BookingStatus.pending;
        case 'approved':
          return BookingStatus.approved;
        case 'rejected':
          return BookingStatus.rejected;
        case 'cancelled':
          return BookingStatus.cancelled;
        case 'awaitingpayment':
          return BookingStatus.awaitingPayment;
        case 'paymentunderreview':
          return BookingStatus.paymentUnderReview;
        case 'confirmed':
          return BookingStatus.confirmed;
        case 'completed':
          return BookingStatus.completed;
        case 'reoffered':
          return BookingStatus.reOffered;
        case 'pendingownerapproval':
          return BookingStatus.pendingOwnerApproval;
        default:
          return BookingStatus.pending;
      }
    } catch (e) {
      return BookingStatus.pending;
    }
  }

  // ==================== PAYMENT METHODS ====================

  /// Owner approves booking - move to awaitingPayment
  Future<void> ownerApproveBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, BookingStatus.awaitingPayment);

      // Send notification to user
      final booking = state.bookings.firstWhere((b) => b.id == bookingId);

      // 1. In-App + Push
      await NotificationService().sendNotification(
        userId: booking.userId,
        titleKey: 'notifications_booking_approved_title',
        bodyKey: 'notifications_booking_approved_body',
        bodyParams: {'chaletName': booking.chaletName},
        type: NotificationType.bookingApproved,
        relatedId: booking.id,
        data: {'bookingId': booking.id},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// User selects payment method
  Future<void> selectPaymentMethod(
    String bookingId,
    PaymentMethod paymentMethod,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'paymentMethod': paymentMethod.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local state
      final currentBookings = List<Booking>.from(state.bookings);
      final index = currentBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        currentBookings[index] = currentBookings[index].copyWith(
          paymentMethod: paymentMethod,
        );
        emit(state.copyWith(bookings: currentBookings));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Upload payment proof
  Future<void> uploadPaymentProof({
    required String bookingId,
    String? proofImageUrl,
    required String transactionNumber,
  }) async {
    try {
      final booking = state.bookings.firstWhere((b) => b.id == bookingId);

      // Create payment proof document
      await FirebaseFirestore.instance.collection('payment_proofs').add({
        'bookingId': bookingId,
        'userId': booking.userId,
        'userName': booking.userName,
        'imageUrl': proofImageUrl,
        'transactionNumber': transactionNumber,
        'uploadedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Update booking
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'paymentProofUrl': proofImageUrl,
            'paymentProofUploadedAt': FieldValue.serverTimestamp(),
            'status': BookingStatus.paymentUnderReview.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local state
      final currentBookings = List<Booking>.from(state.bookings);
      final index = currentBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        currentBookings[index] = currentBookings[index].copyWith(
          paymentProofUrl: proofImageUrl,
          paymentProofUploadedAt: DateTime.now(),
          status: BookingStatus.paymentUnderReview,
        );
        emit(state.copyWith(bookings: currentBookings));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Admin confirms payment
  Future<void> adminConfirmPayment(String bookingId, String? notes) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': BookingStatus.confirmed.name,
            'adminConfirmedPaymentAt': FieldValue.serverTimestamp(),
            'adminPaymentNotes': notes,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local state
      final currentBookings = List<Booking>.from(state.bookings);
      final index = currentBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        currentBookings[index] = currentBookings[index].copyWith(
          status: BookingStatus.confirmed,
          adminConfirmedPaymentAt: DateTime.now(),
          adminPaymentNotes: notes,
        );
        emit(state.copyWith(bookings: currentBookings));
      }

      // Retrieve the booking object to send email
      final booking = currentBookings[index];

      // Send confirmation email (Fire and forget, don't await blocking UI)
      EmailService().sendBookingConfirmationEmail(booking);

      // TODO: Send notification to user and owner
    } catch (e) {
      rethrow;
    }
  }

  /// Admin rejects payment
  Future<void> adminRejectPayment(String bookingId, String reason) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': BookingStatus.awaitingPayment.name,
            'adminPaymentNotes': reason,
            'paymentProofUrl': null,
            'paymentProofUploadedAt': null,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local state
      final currentBookings = List<Booking>.from(state.bookings);
      final index = currentBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        currentBookings[index] = currentBookings[index].copyWith(
          status: BookingStatus.awaitingPayment,
          adminPaymentNotes: reason,
          paymentProofUrl: null,
          paymentProofUploadedAt: null,
        );
        emit(state.copyWith(bookings: currentBookings));
      }

      // TODO: Send notification to user
    } catch (e) {
      rethrow;
    }
  }

  /// Confirm cash on arrival payment
  Future<void> confirmCashOnArrival(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': BookingStatus.confirmed.name,
            'adminConfirmedPaymentAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local state
      final currentBookings = List<Booking>.from(state.bookings);
      final index = currentBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        currentBookings[index] = currentBookings[index].copyWith(
          status: BookingStatus.confirmed,
          adminConfirmedPaymentAt: DateTime.now(),
        );
        emit(state.copyWith(bookings: currentBookings));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Complete booking after stay
  Future<void> completeBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': BookingStatus.completed.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local state
      final currentBookings = List<Booking>.from(state.bookings);
      final index = currentBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        currentBookings[index] = currentBookings[index].copyWith(
          status: BookingStatus.completed,
        );
        emit(state.copyWith(bookings: currentBookings));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Request refund
  Future<void> requestRefund({
    required String bookingId,
    required String reason,
    required double refundAmount,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': BookingStatus.cancelled.name,
            'refundReason': reason,
            'refundAmount': refundAmount,
            'refundedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local state
      final currentBookings = List<Booking>.from(state.bookings);
      final index = currentBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        currentBookings[index] = currentBookings[index].copyWith(
          status: BookingStatus.cancelled,
          refundReason: reason,
          refundAmount: refundAmount,
          refundedAt: DateTime.now(),
        );
        emit(state.copyWith(bookings: currentBookings));
      }

      // TODO: Send notification to admin
    } catch (e) {
      rethrow;
    }
  }

  // ✅ الموافقة النهائية على نقل الحجز (للمالك)
  Future<void> finalizeTransfer(String bookingId) async {
    try {
      // جلب بيانات الحجز
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) {
        return;
      }

      final bookingData = bookingDoc.data()!;
      final oldBooking = Booking.fromJson({
        ...bookingData,
        'id': bookingDoc.id,
      });

      // التأكد من وجود معلومات المستأجر الجديد
      final newTenantId = bookingData['pendingNewTenantId'] as String?;
      final newTenantName = bookingData['pendingNewTenantName'] as String?;
      final newTenantPhone = bookingData['pendingNewTenantPhone'] as String?;
      final newTenantEmail = bookingData['pendingNewTenantEmail'] as String?;

      if (newTenantId == null) {
        return;
      }

      // تنفيذ التحويل الفعلي
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': 'confirmed',
            'userId': newTenantId,
            'userName': newTenantName ?? 'Unknown',
            'userPhone': newTenantPhone,
            'userEmail': newTenantEmail,
            'originalTenantId': oldBooking.userId,
            // حفظ بيانات المستأجر الأصلي
            'originalTenantName': oldBooking.userName,
            'originalTenantPhone': oldBooking.userPhone,
            'originalTenantEmail': oldBooking.userEmail,
            'transferredAt': FieldValue.serverTimestamp(),
            'paymentStatus': 'paid',
            // حذف الحقول المؤقتة
            'pendingNewTenantId': FieldValue.delete(),
            'pendingNewTenantName': FieldValue.delete(),
            'pendingNewTenantPhone': FieldValue.delete(),
            'pendingNewTenantEmail': FieldValue.delete(),
            'pendingApprovalAt': FieldValue.delete(),
          });

      // إرسال إشعار للمستأجر الجديد
      try {
        await NotificationService().sendNotification(
          userId: newTenantId,
          titleKey: 'notifications_general_title',
          bodyKey: 'notifications_general_body',
          type: NotificationType.transferTicket,
          relatedId: bookingId,
          data: {'bookingId': bookingId, 'chaletName': oldBooking.chaletName},
        );
      } catch (e) {}

      // إرسال إيميل للمستأجر الجديد
      if (newTenantEmail != null && newTenantEmail.isNotEmpty) {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': [newTenantEmail],
          'message': {
            'subject': 'تأكيد حجز الشاليه: ${oldBooking.chaletName}',
            'html':
                '''
<h2>تم تأكيد حجزك!</h2>
<p>مرحباً ${newTenantName ?? 'عزيزي العميل'}،</p>
<p>تم نقل حجز الشاليه (<strong>${oldBooking.chaletName}</strong>) إليك بنجاح.</p>
<h3>تفاصيل الحجز:</h3>
<ul>
  <li><strong>من:</strong> ${_formatDate(oldBooking.from)}</li>
  <li><strong>إلى:</strong> ${_formatDate(oldBooking.to)}</li>
  <li><strong>المبلغ:</strong> ${oldBooking.amount} EGP</li>
</ul>
<p>نتمنى لك إقامة سعيدة!</p>
''',
          },
        });
      }
    } catch (e) {}
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

// ✅ تحديث BookingState إذا لزم الأمر
class BookingState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;

  const BookingState({
    required this.bookings,
    this.isLoading = false,
    this.error,
  });

  BookingState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
