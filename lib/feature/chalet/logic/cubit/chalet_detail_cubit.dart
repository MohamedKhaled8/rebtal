import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/feature/admin/presentation/pages/full_screen_image_gallery.dart';
import 'package:rebtal/feature/chalet/domain/usecases/get_chalet_booked_dates_usecase.dart';
import 'package:rebtal/feature/chalet/domain/usecases/toggle_booking_availability_usecase.dart';
import 'package:rebtal/feature/chalet/domain/usecases/update_chalet_status_usecase.dart';

part 'chalet_detail_state.dart';

class ChaletDetailCubit extends Cubit<ChaletDetailState> {
  final GetChaletBookedDatesUseCase getChaletBookedDatesUseCase;
  final UpdateChaletStatusUseCase updateChaletStatusUseCase;
  final ToggleBookingAvailabilityUseCase toggleBookingAvailabilityUseCase;

  PageController? _pageController;
  Timer? _autoPlayTimer;

  ChaletDetailCubit({
    required this.getChaletBookedDatesUseCase,
    required this.updateChaletStatusUseCase,
    required this.toggleBookingAvailabilityUseCase,
  }) : super(ChaletDetailInitial());

  PageController get pageController {
    _pageController ??= PageController();
    return _pageController!;
  }

  void initialize(Map<String, dynamic> requestData) {
    final images = _extractImagesFromRequestData(requestData);
    final bookingDates = requestData['bookedDates'];
    List<DateTime>? initialDates;

    if (bookingDates != null && bookingDates is List) {
      initialDates = bookingDates.map((e) {
        if (e is Timestamp) return e.toDate();
        if (e is String) return DateTime.tryParse(e) ?? DateTime.now();
        return DateTime.now();
      }).toList();
    }

    if (isClosed) return;

    emit(ChaletDetailLoaded(images: images, bookedDates: initialDates));
    _startAutoPlay();

    // Fetch latest bookings
    final chaletId = requestData['id'] ?? requestData['chaletId'];
    if (chaletId != null) {
      _fetchBookedDates(chaletId.toString());
    }
  }

  Future<void> _fetchBookedDates(String chaletId) async {
    final Either<Failure, List<DateTime>> result =
        await getChaletBookedDatesUseCase(chaletId);

    result.fold(
      (failure) => debugPrint('Error fetching booked dates: $failure'),
      (bookedDates) {
        final currentState = state;
        if (currentState is ChaletDetailLoaded) {
          emit(currentState.copyWith(bookedDates: bookedDates));
        }
      },
    );
  }

  List<String> _extractImagesFromRequestData(Map<String, dynamic> data) {
    final List<String> images = [];

    if (data['images'] != null && data['images'] is List) {
      images.addAll((data['images'] as List).map((e) => e.toString()));
    }
    if (data['image'] != null) {
      images.add(data['image'].toString());
    }
    if (data['imageUrl'] != null) {
      images.add(data['imageUrl'].toString());
    }

    return images;
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final currentState = state;
      if (currentState is ChaletDetailLoaded) {
        if (_pageController?.hasClients == true &&
            currentState.images.length > 1) {
          int nextIndex = currentState.currentImageIndex + 1;
          if (nextIndex >= currentState.images.length) {
            nextIndex = 0;
          }
          _pageController?.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void onPageChanged(int index) {
    final currentState = state;
    if (currentState is ChaletDetailLoaded) {
      emit(currentState.copyWith(currentImageIndex: index));
    }
  }

  void navigateToImage(int index) {
    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void toggleDescription() {
    final currentState = state;
    if (currentState is ChaletDetailLoaded) {
      emit(
        currentState.copyWith(
          isDescriptionExpanded: !currentState.isDescriptionExpanded,
        ),
      );
    }
  }

  Future<void> updateStatus(
    BuildContext context, {
    required String docId,
    required String newStatus,
  }) async {
    emit(ChaletDetailLoading());

    final result = await updateChaletStatusUseCase(
      UpdateChaletStatusParams(docId: docId, newStatus: newStatus),
    );

    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
        }
        emit(ChaletDetailError(failure.message));
      },
      (_) {
        if (context.mounted) {
          if (newStatus == 'approved') {
            SnackBarHelper.showSuccess(context, 'Request $newStatus');
          } else {
            SnackBarHelper.showError(context, 'Request $newStatus');
          }
          Navigator.pop(context);
        }
        emit(ChaletDetailStatusUpdated(newStatus));
      },
    );
  }

  List<String> extractImages(Map<String, dynamic> requestData) {
    final List<String> result = [];
    final dynamic imagesField = requestData['images'];
    final dynamic profileField = requestData['profileImage'];

    if (imagesField is List) {
      result.addAll(imagesField.whereType<String>().where((s) => s.isNotEmpty));
    } else if (imagesField is String && imagesField.isNotEmpty) {
      result.add(imagesField);
    }

    if (profileField is String && profileField.isNotEmpty) {
      if (!result.contains(profileField)) result.insert(0, profileField);
    } else if (profileField is List) {
      result.addAll(
        profileField.whereType<String>().where((s) => s.isNotEmpty),
      );
    }
    return result;
  }

  void openFullScreen(
    BuildContext context, {
    required List<String> images,
    required int start,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FullScreenImageGallery(images: images, initialIndex: start),
      ),
    );
  }

  String formatDate(dynamic dt) {
    if (dt == null) return 'Unknown';
    try {
      DateTime d;
      if (dt is Timestamp) {
        d = dt.toDate();
      } else if (dt is String && dt.isNotEmpty) {
        d = DateTime.parse(dt);
      } else if (dt is DateTime) {
        d = dt;
      } else {
        return dt.toString();
      }
      final String dd = d.day.toString().padLeft(2, '0');
      final String mm = d.month.toString().padLeft(2, '0');
      final String yyyy = d.year.toString();
      // Return date only (no time)
      return '$dd/$mm/$yyyy';
    } catch (_) {
      return 'Invalid date';
    }
  }

  String? formatAvailabilityDate(dynamic date) {
    if (date == null) return 'Not specified';
    // Ensure availability shows date only
    return formatDate(date);
  }

  Future<void> toggleBookingAvailability(
    BuildContext context, {
    required String docId,
    required Map<String, dynamic> requestData,
  }) async {
    final currentAvailability =
        (requestData['bookingAvailability'] ?? 'available').toString();

    final result = await toggleBookingAvailabilityUseCase(
      ToggleBookingAvailabilityParams(
        docId: docId,
        currentAvailability: currentAvailability,
      ),
    );

    result.fold(
      (failure) {
        if (context.mounted) {
          SnackBarHelper.showError(
            context,
            'خطأ في تحديث حالة الحجز: ${failure.message}',
          );
        }
      },
      (newAvailability) {
        if (context.mounted) {
          if (newAvailability == 'available') {
            SnackBarHelper.showSuccess(context, 'تم تشغيل الحجز بنجاح');
          } else {
            SnackBarHelper.showError(context, 'تم إيقاف الحجز بنجاح');
          }
        }
      },
    );
  }

  @override
  Future<void> close() {
    _autoPlayTimer?.cancel();
    _pageController?.dispose();
    return super.close();
  }
}
