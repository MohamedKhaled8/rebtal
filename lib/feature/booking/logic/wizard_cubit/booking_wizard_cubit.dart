import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/booking/logic/wizard_cubit/booking_wizard_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';

import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/services/chalet_pricing_service.dart';

class BookingWizardCubit extends Cubit<BookingWizardState> {
  final Map<String, dynamic> requestData;
  final dynamic basePriceInput;
  final String userId;
  final String userName;
  final String chaletId;
  final String chaletName;
  final String ownerIdInput;
  final String ownerNameInput;

  BookingWizardCubit({
    required this.requestData,
    required this.basePriceInput,
    required this.userId,
    required this.userName,
    required this.chaletId,
    required this.chaletName,
    required this.ownerIdInput,
    required this.ownerNameInput,
  }) : super(const BookingWizardState()) {
    _calculateInitialPrice();
    _fetchAdditionalData();
    _checkDayUse();
  }

  void _checkDayUse() {
    final isDayUse = requestData['dayUseEnabled'] == true;
    emit(state.copyWith(isDayUse: isDayUse));
  }

  void _calculateInitialPrice() {
    final data = Map<String, dynamic>.from(requestData);
    if (basePriceInput != null && data['price'] == null) {
      data['price'] = basePriceInput;
    }
    emit(state.copyWith(nightlyPrice: ChaletPricingService.basePrice(data)));
  }

  Future<void> _fetchAdditionalData() async {
    // Fetch User Data
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (!userDoc.exists) {
        userDoc = await FirebaseFirestore.instance
            .collection('Owners')
            .doc(userId)
            .get();
      }
      if (userDoc.exists) {
        final userData = userDoc.data();
        emit(
          state.copyWith(
            userPhone: userData?['phone'] ?? userData?['phoneNumber'],
            userEmail: userData?['email'],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    }

    // Fetch Owner Data
    try {
      // Resolve Owner ID/Name first if empty
      String resolvedId = ownerIdInput;
      String resolvedName = ownerNameInput;

      if (resolvedId.trim().isEmpty || resolvedName.trim().isEmpty) {
        final chaletDoc = await FirebaseFirestore.instance
            .collection('chalets')
            .doc(chaletId)
            .get();
        if (chaletDoc.exists) {
          final data = chaletDoc.data();
          resolvedId = resolvedId.trim().isEmpty
              ? (data?['ownerId'] ?? data?['merchantId'] ?? '') ?? resolvedId
              : resolvedId;
          resolvedName = resolvedName.trim().isEmpty
              ? (data?['merchantName'] ?? data?['ownerName'] ?? '') ??
                    resolvedName
              : resolvedName;
        }
      }

      // Encode normalized owner ID
      final normOwnerId = resolvedId.contains(':')
          ? resolvedId.split(':').last.trim()
          : resolvedId.trim();

      emit(
        state.copyWith(
          ownerIdResolved: normOwnerId,
          ownerNameResolved: resolvedName,
        ),
      );

      var ownerDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(normOwnerId)
          .get();
      if (!ownerDoc.exists) {
        ownerDoc = await FirebaseFirestore.instance
            .collection('Owners')
            .doc(normOwnerId)
            .get();
      }
      if (ownerDoc.exists) {
        final ownerData = ownerDoc.data();
        emit(
          state.copyWith(
            ownerPhone: ownerData?['phone'] ?? ownerData?['phoneNumber'],
            ownerEmail: ownerData?['email'],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching owner details: $e');
    }
  }

  void selectDates(DateTime start, DateTime end) {
    if (end.isBefore(start)) end = start;

    final data = Map<String, dynamic>.from(requestData);
    if (basePriceInput != null && data['price'] == null) {
      data['price'] = basePriceInput;
    }

    final spanDays = end.difference(start).inDays.clamp(0, 365);
    final nights = spanDays.clamp(0, 365);
    final inclusiveStayDays = spanDays + 1;

    final breakdown = ChaletPricingService.nightlyBreakdown(data, start, end);
    final total = ChaletPricingService.totalForRange(
      data,
      start,
      end,
      isDayUse: state.isDayUse,
    );
    final avgNightly = breakdown.isEmpty
        ? ChaletPricingService.basePrice(data)
        : ChaletPricingService.averageNightly(data, start, end);

    emit(
      state.copyWith(
        startDate: start,
        endDate: end,
        days: inclusiveStayDays,
        nights: state.isDayUse ? (spanDays == 0 ? 1 : spanDays) : nights,
        totalAmount: total,
        nightlyPrice: avgNightly,
        nightlyBreakdown: breakdown
            .map((e) => BookingNightLine(date: e.date, price: e.price))
            .toList(),
        errorMessage: null,
      ),
    );
  }

  void updateGuestCount(int count) {
    emit(state.copyWith(guestCount: count.clamp(0, 30)));
  }

  void toggleTerms(bool value) {
    emit(state.copyWith(termsAccepted: value));
  }

  void nextStep() {
    if (state.currentStep == 0) {
      if (!state.isDatesSelected) {
        emit(
          state.copyWith(errorMessage: 'يرجى اختيار تاريخ الوصول والمغادرة'),
        );
        return;
      }
    }

    if (state.currentStep < 1) {
      // Only 2 steps total (0, 1) currently
      emit(
        state.copyWith(currentStep: state.currentStep + 1, errorMessage: null),
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(
        state.copyWith(currentStep: state.currentStep - 1, errorMessage: null),
      );
    }
  }

  Future<Booking?> submitBooking() async {
    if (!state.termsAccepted) {
      emit(
        state.copyWith(errorMessage: 'يجب الموافقة على سياسات الحجز للإكمال'),
      );
      return null;
    }

    emit(
      state.copyWith(
        status: BookingWizardStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      final docRef = FirebaseFirestore.instance
          .collection('bookings')
          .doc(); // Auto-gen ID for doc, or use bookingId?
      // The original code used a generated UUID for the 'id' field, but let Firestore gen auth doc ID.
      // Actually it used: final docRef = ...doc(); final bookingWithId = booking.copyWith(id: docRef.id);

      final booking = Booking(
        id: docRef.id, // Using Firestore ID to match original logic
        chaletId: chaletId,
        chaletName: chaletName,
        ownerId: state.ownerIdResolved ?? ownerIdInput,
        ownerName: state.ownerNameResolved ?? ownerNameInput,
        userId: userId,
        userName: userName,
        from: state.startDate ?? DateTime.now(),
        to: state.endDate ?? DateTime.now().add(const Duration(days: 1)),
        status: BookingStatus.pending,
        amount: state.totalAmount,
        userPhone: state.userPhone,
        userEmail: state.userEmail,
        ownerPhone: state.ownerPhone,
        ownerEmail: state.ownerEmail,
        chaletLocation: requestData['location'] as String?,
        childrenCount: state.guestCount,
        isDayUse: state.isDayUse,
      );

      await docRef.set(booking.toMap());

      // Send Notification (مفاتيح ترجمة + بارامترات لتفادي {userName} ولغة المالك)
      try {
        await NotificationService().sendNotification(
          userId: booking.ownerId,
          titleKey: 'notifications_booking_request_title',
          bodyKey: 'notifications_booking_request_body',
          bodyParams: {
            'chaletName': booking.chaletName,
            'userName': booking.userName,
          },
          type: NotificationType.bookingRequest,
          relatedId: booking.id,
          data: {
            'bookingId': booking.id,
            'chaletId': booking.chaletId,
            'chaletName': booking.chaletName,
            'userName': booking.userName,
          },
        );
      } catch (e) {
        debugPrint('Notification error: $e');
      }

      emit(state.copyWith(status: BookingWizardStatus.success));
      return booking;
    } catch (e) {
      emit(
        state.copyWith(
          status: BookingWizardStatus.failure,
          errorMessage: 'حدث خطأ أثناء الحجز: $e',
        ),
      );
      return null;
    }
  }
}
