import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/booking/logic/wizard_cubit/booking_wizard_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';

import 'package:flutter/material.dart';

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
    final price = basePriceInput;
    final discountEnabled = requestData['discountEnabled'] == true;
    final discountValue =
        double.tryParse(requestData['discountValue']?.toString() ?? '0') ?? 0;

    double basePrice;
    if (price is num) {
      basePrice = price.toDouble();
    } else {
      basePrice =
          double.tryParse(
            (price ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0;
    }

    if (discountEnabled && discountValue > 0) {
      final discountType = requestData['discountType'];
      if (discountType == 'percentage') {
        basePrice = basePrice * (1 - discountValue / 100);
      } else if (discountType == 'fixed') {
        basePrice = basePrice - discountValue;
      }
      if (basePrice < 0) basePrice = 0;
    }

    emit(state.copyWith(nightlyPrice: basePrice));
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

    final days = end.difference(start).inDays.clamp(0, 365);
    final nights = (days - 1).clamp(0, 364);

    // If it's Day Use, we charge for at least 1 day even if nights is 0
    final double total = state.isDayUse
        ? state.nightlyPrice * (days == 0 ? 1 : days)
        : state.nightlyPrice * nights;

    emit(
      state.copyWith(
        startDate: start,
        endDate: end,
        days: days,
        nights: nights,
        totalAmount: total,
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

      // Send Notification
      try {
        await NotificationService().sendNotification(
          userId: booking.ownerId,
          title: 'طلب حجز جديد 📩',
          body:
              'لديك طلب حجز جديد لشاليه ${booking.chaletName} من ${booking.userName}. يرجى المراجعة والموافقة.',
          type: NotificationType.bookingRequest,
          relatedId: booking.id,
          data: {'bookingId': booking.id, 'chaletId': booking.chaletId},
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
