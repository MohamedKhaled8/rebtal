import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';

// ✅ إضافة هذه الدوال للـ BookingCubit

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(const BookingState(bookings: [], isLoading: true)) {
    loadBookings(); // ✅ تحميل الحجوزات عند إنشاء الكيوبت
  }

  StreamSubscription? _bookingsSubscription;

  // ✅ تحميل الحجوزات والاستماع للتغييرات
  Future<void> loadBookings() async {
    await _bookingsSubscription?.cancel();
    emit(state.copyWith(isLoading: true)); // ✅ بدء التحميل

    _bookingsSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
            final bookings = await Future.wait(
              snapshot.docs.map((doc) async {
                final data = doc.data();

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
                        final images = (chaletData['images'] as List?)
                            ?.cast<dynamic>();
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
                    final userDoc = await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userId)
                        .get();

                    if (userDoc.exists) {
                      final userData = userDoc.data();
                      if (userData != null) {
                        userPhone = (userData['phone']?.toString() ?? '')
                            .trim();
                        userEmail = (userData['email']?.toString() ?? '')
                            .trim();
                      }
                    }
                  }
                } catch (e) {
                  debugPrint('Error fetching user details: $e');
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
                  updatedAt: _parseDateTime(data['updatedAt']),
                );
              }).toList(),
            );

            emit(
              state.copyWith(bookings: bookings, isLoading: false),
            ); // ✅ تحديث البيانات
          },
          onError: (e) {
            debugPrint('Error loading bookings: $e');
            emit(state.copyWith(isLoading: false)); // ✅ انتهاء التحميل مع خطأ
          },
        );
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
    try {
      // تحديث في Firestore أولاً
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': describeEnum(newStatus),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // إذا نجح التحديث في Firestore، نحدث محلياً
      final currentBookings = List<Booking>.from(state.bookings);
      final index = currentBookings.indexWhere((b) => b.id == bookingId);

      if (index >= 0) {
        currentBookings[index].status = newStatus;
        emit(state.copyWith(bookings: currentBookings));

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
      }
    } catch (e) {
      debugPrint('Error updating booking status: $e');
      // إعادة تحميل الحجوزات في حالة الخطأ
      await loadBookings();
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
        default:
          return BookingStatus.pending;
      }
    } catch (e) {
      debugPrint('Error parsing status: $e');
      return BookingStatus.pending;
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
