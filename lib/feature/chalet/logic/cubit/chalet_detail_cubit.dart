import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/feature/admin/presentation/pages/full_screen_image_gallery.dart';
import 'package:rebtal/feature/chalet/domain/usecases/get_chalet_booked_dates_usecase.dart';
import 'package:rebtal/feature/chalet/domain/usecases/toggle_booking_availability_usecase.dart';
import 'package:rebtal/feature/chalet/domain/usecases/update_chalet_status_usecase.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/owner/utils/chalet_edit_review_helper.dart';

part 'chalet_detail_state.dart';

class ChaletDetailCubit extends Cubit<ChaletDetailState> {
  final GetChaletBookedDatesUseCase getChaletBookedDatesUseCase;
  final UpdateChaletStatusUseCase updateChaletStatusUseCase;
  final ToggleBookingAvailabilityUseCase toggleBookingAvailabilityUseCase;

  PageController? _pageController;
  Timer? _autoPlayTimer;
  static const bool _enableAutoPlay = false;

  ChaletDetailCubit({
    required this.getChaletBookedDatesUseCase,
    required this.updateChaletStatusUseCase,
    required this.toggleBookingAvailabilityUseCase,
  }) : super(ChaletDetailInitial());

  PageController get pageController {
    _pageController ??= PageController();
    return _pageController!;
  }

  List<DateTime>? _parseBookedDatesField(Map<String, dynamic> data) {
    final bookingDates = data['bookedDates'];
    if (bookingDates == null || bookingDates is! List) return null;
    return bookingDates.map((e) {
      if (e is Timestamp) return e.toDate();
      if (e is String) return DateTime.tryParse(e) ?? DateTime.now();
      return DateTime.now();
    }).toList();
  }

  Future<void> initialize(
    Map<String, dynamic> requestData, {
    String? docId,
    String viewerRole = 'guest',
  }) async {
    // Paint immediately from the snapshot (no grey "empty" header while server
    // round-trips). Server merge may refine URLs/order afterward.
    if (!isClosed) {
      final bootData = _viewerDisplayData(requestData, viewerRole);
      emit(
        ChaletDetailLoaded(
          images: collectChaletImageUrls(bootData),
          bookedDates: _parseBookedDatesField(bootData),
        ),
      );
      _startAutoPlay();
    }

    // Prefer loading the latest chalet data by Firestore docId.
    Map<String, dynamic> effectiveData = requestData;
    if (docId != null && docId.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('chalets')
            .doc(docId)
            .get(const GetOptions(source: Source.serverAndCache));
        final data = snap.data();
        if (data != null) {
          effectiveData = {...requestData, ...data, 'id': docId};
        }
      } catch (e) {
        // Best-effort: fall back to requestData if Firestore fails/offline.
      }
    }

    effectiveData = _viewerDisplayData(effectiveData, viewerRole);
    final images = collectChaletImageUrls(effectiveData);
    final initialDates = _parseBookedDatesField(effectiveData);

    if (isClosed) return;

    emit(ChaletDetailLoaded(images: images, bookedDates: initialDates));
    _startAutoPlay();

    final c = _pageController;
    if (c != null && c.hasClients && images.isNotEmpty) {
      try {
        c.jumpToPage(0);
      } catch (_) {}
    }

    // Fetch latest bookings
    final chaletId = docId ?? effectiveData['id'] ?? effectiveData['chaletId'];
    if (chaletId != null) {
      _fetchBookedDates(chaletId.toString());
    }
  }

  /// When owner list is patched after edit, keep gallery in sync with Firestore fields.
  void syncImagesFromMap(
    Map<String, dynamic> data, {
    String viewerRole = 'guest',
  }) {
    if (isClosed) return;
    final next = _extractImagesFromRequestData(data, viewerRole);
    final s = state;
    if (s is! ChaletDetailLoaded) return;
    if (listEquals(s.images, next)) return;
    final idx = next.isEmpty
        ? 0
        : s.currentImageIndex.clamp(0, next.length - 1);
    emit(s.copyWith(images: next, currentImageIndex: idx));
    final c = _pageController;
    if (c != null && c.hasClients && next.isNotEmpty) {
      Future.microtask(() {
        if (isClosed) return;
        try {
          c.jumpToPage(idx);
        } catch (_) {}
      });
    }
  }

  Future<void> _fetchBookedDates(String chaletId) async {
    final Either<Failure, List<DateTime>> result =
        await getChaletBookedDatesUseCase(chaletId);

    result.fold(
      (failure) => debugPrint('Error fetching booked dates: $failure'),
      (bookedDates) {
        if (isClosed) return;
        final currentState = state;
        if (currentState is ChaletDetailLoaded) {
          emit(currentState.copyWith(bookedDates: bookedDates));
        }
      },
    );
  }

  Map<String, dynamic> _viewerDisplayData(
    Map<String, dynamic> root,
    String viewerRole,
  ) {
    if (viewerRole == 'admin') {
      return ChaletEditReviewHelper.previewDataForAdmin(root);
    }
    if (viewerRole == 'owner') {
      return ChaletEditReviewHelper.dataForOwnerEditForm(root);
    }
    return Map<String, dynamic>.from(root);
  }

  List<String> _extractImagesFromRequestData(
    Map<String, dynamic> data,
    String viewerRole,
  ) {
    return collectChaletImageUrls(_viewerDisplayData(data, viewerRole));
  }

  void _startAutoPlay() {
    if (!_enableAutoPlay) {
      _autoPlayTimer?.cancel();
      return;
    }
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (isClosed) return;
      final currentState = state;
      if (currentState is ChaletDetailLoaded) {
        final controller = _pageController;
        if (controller?.hasClients == true && currentState.images.length > 1) {
          int nextIndex = currentState.currentImageIndex + 1;
          if (nextIndex >= currentState.images.length) {
            nextIndex = 0;
          }
          try {
            controller?.animateToPage(
              nextIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          } catch (_) {
            // Ignore controller lifecycle races during route pops.
          }
        }
      }
    });
  }

  void onPageChanged(int index) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is ChaletDetailLoaded) {
      emit(currentState.copyWith(currentImageIndex: index));
    }
  }

  void navigateToImage(int index) {
    if (isClosed) return;
    final controller = _pageController;
    if (controller?.hasClients != true) return;
    try {
      controller?.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (_) {
      // Ignore if controller is disposed mid-flight.
    }
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
    return collectChaletImageUrls(requestData);
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
    final controller = _pageController;
    _pageController = null;
    try {
      controller?.dispose();
    } catch (_) {
      // Ignore double-dispose races during widget finalization.
    }
    return super.close();
  }
}
