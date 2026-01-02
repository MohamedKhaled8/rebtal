import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/feature/admin/ui/full_screen_image_gallery.dart';

part 'chalet_detail_state.dart';

class ChaletDetailCubit extends Cubit<ChaletDetailState> {
  PageController? _pageController;
  Timer? _autoPlayTimer;

  ChaletDetailCubit() : super(ChaletDetailInitial());

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

    emit(ChaletDetailLoaded(images: images, bookedDates: initialDates));
    _startAutoPlay();

    // Fetch latest bookings
    final chaletId = requestData['id'] ?? requestData['chaletId'];
    if (chaletId != null) {
      _fetchBookedDates(chaletId.toString());
    }
  }

  Future<void> _fetchBookedDates(String chaletId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('chaletId', isEqualTo: chaletId)
          .where(
            'status',
            whereIn: [
              'approved',
              'confirmed',
              'completed',
              'awaitingPayment',
              'paymentUnderReview',
            ],
          )
          .get();

      final List<DateTime> bookedDates = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final from = (data['from'] as Timestamp?)?.toDate();
        final to = (data['to'] as Timestamp?)?.toDate();

        if (from != null && to != null) {
          // Add all dates in range
          DateTime current = from;
          while (current.isBefore(to) || current.isAtSameMomentAs(to)) {
            bookedDates.add(current);
            current = current.add(const Duration(days: 1));
          }
        }
      }

      bookedDates.sort();

      final currentState = state;
      if (currentState is ChaletDetailLoaded) {
        emit(currentState.copyWith(bookedDates: bookedDates));
      }
    } catch (e) {
      debugPrint('Error fetching booked dates: $e');
    }
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
    try {
      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });

      if (context.mounted) {
        if (newStatus == 'approved') {
          SnackBarHelper.showSuccess(context, 'Request $newStatus');
        } else {
          SnackBarHelper.showError(context, 'Request $newStatus');
        }
        Navigator.pop(context);
      }

      emit(ChaletDetailStatusUpdated(newStatus));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      emit(ChaletDetailError(e.toString()));
    }
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
    try {
      final currentAvailability =
          requestData['bookingAvailability'] ?? 'available';
      final newAvailability = currentAvailability == 'available'
          ? 'unavailable'
          : 'available';

      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'bookingAvailability': newAvailability,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        if (newAvailability == 'available') {
          SnackBarHelper.showSuccess(context, 'تم تشغيل الحجز بنجاح');
        } else {
          SnackBarHelper.showError(context, 'تم إيقاف الحجز بنجاح');
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'خطأ في تحديث حالة الحجز: $e');
      }
    }
  }

  @override
  Future<void> close() {
    _autoPlayTimer?.cancel();
    _pageController?.dispose();
    return super.close();
  }
}
