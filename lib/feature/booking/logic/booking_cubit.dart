import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';

// ✅ إضافة هذه الدوال للـ BookingCubit

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(const BookingState(bookings: [], isLoading: false));

  StreamSubscription? _bookingsSubscription;

  // ✅ تحميل حجوزات المالك فقط
  Future<void> loadOwnerBookings(String ownerId) async {
    await _bookingsSubscription?.cancel();
    emit(state.copyWith(isLoading: true, bookings: []));

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
    } catch (e) {
      debugPrint(
        '⚠️ Could not fetch from server (offline?), falling back to stream: $e',
      );
    }

    _bookingsSubscription = query.snapshots().listen(
      (snapshot) async {
        await _processSnapshot(snapshot);
      },
      onError: (e) {
        debugPrint('Error loading owner bookings: $e');
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  // ✅ تحميل حجوزات المستخدم فقط
  Future<void> loadUserBookings(String userId) async {
    await _bookingsSubscription?.cancel();
    emit(state.copyWith(isLoading: true, bookings: []));

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
    } catch (e) {
      debugPrint(
        '⚠️ Could not fetch from server (offline?), falling back to stream: $e',
      );
    }

    _bookingsSubscription = query.snapshots().listen(
      (snapshot) async {
        await _processSnapshot(snapshot);
      },
      onError: (e) {
        debugPrint('Error loading user bookings: $e');
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  // ✅ تحميل كل الحجوزات (للأدمن أو الاستخدام العام)
  Future<void> loadBookings() async {
    await _bookingsSubscription?.cancel();
    emit(state.copyWith(isLoading: true, bookings: []));

    final query = FirebaseFirestore.instance.collection('bookings')
    // .orderBy('createdAt', descending: true) // ⚠️ تم التعطيل مؤقتاً
    ;

    // ⚡️ محاولة تحديث الكاش من السيرفر مباشرة أولاً
    try {
      final serverSnapshot = await query.get(
        const GetOptions(source: Source.server),
      );
      await _processSnapshot(serverSnapshot);
    } catch (e) {
      debugPrint(
        '⚠️ Could not fetch from server (offline?), falling back to stream: $e',
      );
    }

    _bookingsSubscription = query.snapshots().listen(
      (snapshot) async {
        await _processSnapshot(snapshot);
      },
      onError: (e) {
        debugPrint('Error loading all bookings: $e');
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  // معالجة البيانات المشتركة
  Future<void> _processSnapshot(QuerySnapshot snapshot) async {
    debugPrint(
      '🔎 _processSnapshot called. Docs found: ${snapshot.docs.length}',
    );

    if (snapshot.docs.isEmpty) {
      debugPrint('📭 Snapshot is empty. Emitting empty list.');
      emit(state.copyWith(bookings: [], isLoading: false));
      return;
    }

    final bookings = await Future.wait(
      snapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint(
          '📄 Processing Doc: ${doc.id} | UserID: ${data['userId']} | OwnerID: ${data['ownerId']}',
        );

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
          debugPrint('Error fetching chalet details: $e');
        }

        // جلب معلومات المستخدم
        String? userPhone;
        String? userEmail;

        try {
          final userId = data['userId'] ?? '';
          if (userId.isNotEmpty) {
            // Try Users collection first
            var userDoc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(userId)
                .get();

            // If not found, try Owners collection
            if (!userDoc.exists) {
              userDoc = await FirebaseFirestore.instance
                  .collection('Owners')
                  .doc(userId)
                  .get();
            }

            if (userDoc.exists) {
              final userData = userDoc.data();
              if (userData != null) {
                userPhone = (userData['phone']?.toString() ?? '').trim();
                userEmail = (userData['email']?.toString() ?? '').trim();
              }
            }
          }
        } catch (e) {
          debugPrint('Error fetching user details: $e');
        }

        // جلب معلومات المالك
        String? ownerPhone;
        String? ownerEmail;

        try {
          final ownerId = data['ownerId'] ?? '';
          if (ownerId.isNotEmpty) {
            // Try Users collection first
            var ownerDoc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(ownerId)
                .get();

            // If not found, try Owners collection
            if (!ownerDoc.exists) {
              ownerDoc = await FirebaseFirestore.instance
                  .collection('Owners')
                  .doc(ownerId)
                  .get();
            }

            if (ownerDoc.exists) {
              final ownerData = ownerDoc.data();
              if (ownerData != null) {
                ownerPhone = (ownerData['phone']?.toString() ?? '').trim();
                ownerEmail = (ownerData['email']?.toString() ?? '').trim();
              }
            }
          }
        } catch (e) {
          debugPrint('Error fetching owner details: $e');
        }

        return Booking(
          id: doc.id,
          chaletId: data['chaletId'] ?? '',
          chaletName: data['chaletName'] ?? '',
          ownerId: data['ownerId'] ?? '',
          ownerName: data['ownerName'] ?? '',
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? '',
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
        );
      }).toList(),
    );

    debugPrint(
      '✅ Finished processing bookings. Total count: ${bookings.length}',
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

      // ✅ إرسال إشعار للمستخدم
      final booking = currentBookings[index];
      NotificationType notificationType = NotificationType.general;
      String title = 'تحديث حالة الحجز';
      String body = 'تم تحديث حالة حجزك في ${booking.chaletName}';

      if (newStatus == BookingStatus.approved) {
        notificationType = NotificationType.bookingApproved;
        title = 'تمت الموافقة على الحجز! 🎉';
        body =
            'وافق المالك على طلب حجزك في ${booking.chaletName}. استعد لرحلتك!';
      } else if (newStatus == BookingStatus.rejected) {
        notificationType = NotificationType.bookingRejected;
        title = 'تم رفض الحجز ❌';
        body = 'عذراً، تم رفض طلب حجزك في ${booking.chaletName}.';
      }

      await NotificationService().sendNotification(
        userId: booking.userId,
        title: title,
        body: body,
        type: notificationType,
        relatedId: booking.id,
        data: {'bookingId': booking.id, 'chaletId': booking.chaletId},
      );
    } catch (e) {
      debugPrint('Error updating booking status: $e');

      // ❌ تراجع عن التحديث في حالة الخطأ
      emit(state.copyWith(bookings: previousBookings));

      // إعادة تحميل الحجوزات للتأكد من التزامن
      // await loadBookings();
      rethrow; // إعادة رمي الخطأ ليتم معالجته في واجهة المستخدم
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

      debugPrint('✅ Booking $bookingId marked as paid');
    } catch (e) {
      debugPrint('❌ Error marking booking as paid: $e');
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
        await NotificationService().sendNotification(
          userId: booking.ownerId,
          title: 'تم إلغاء حجز ⚠️',
          body: 'قام ${booking.userName} بإلغاء حجزه في ${booking.chaletName}.',
          type: NotificationType.general,
          relatedId: booking.id,
          data: {'bookingId': booking.id},
        );
      }
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
    }
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
      debugPrint('Error parsing datetime: $e');
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
        default:
          return BookingStatus.pending;
      }
    } catch (e) {
      debugPrint('Error parsing status: $e');
      return BookingStatus.pending;
    }
  }

  // ==================== PAYMENT METHODS ====================

  /// Owner approves booking - move to awaitingPayment
  Future<void> ownerApproveBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, BookingStatus.awaitingPayment);

      // Send notification to user
      // final booking = state.bookings.firstWhere((b) => b.id == bookingId);
      // TODO: Send FCM notification to user using booking details
      debugPrint('✅ Booking approved, awaiting payment: $bookingId');
    } catch (e) {
      debugPrint('❌ Error approving booking: $e');
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

      debugPrint('✅ Payment method selected: ${paymentMethod.name}');
    } catch (e) {
      debugPrint('❌ Error selecting payment method: $e');
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

      // TODO: Send notification to admin
      debugPrint('✅ Payment proof uploaded: $bookingId');
    } catch (e) {
      debugPrint('❌ Error uploading payment proof: $e');
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

      // TODO: Send notification to user and owner
      debugPrint('✅ Payment confirmed by admin: $bookingId');
    } catch (e) {
      debugPrint('❌ Error confirming payment: $e');
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
      debugPrint('✅ Payment rejected by admin: $bookingId');
    } catch (e) {
      debugPrint('❌ Error rejecting payment: $e');
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

      debugPrint('✅ Cash on arrival confirmed: $bookingId');
    } catch (e) {
      debugPrint('❌ Error confirming cash on arrival: $e');
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

      debugPrint('✅ Booking completed: $bookingId');
    } catch (e) {
      debugPrint('❌ Error completing booking: $e');
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
      debugPrint('✅ Refund requested: $bookingId');
    } catch (e) {
      debugPrint('❌ Error requesting refund: $e');
      rethrow;
    }
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
