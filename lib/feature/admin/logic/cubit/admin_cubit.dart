import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/feature/admin/ui/dashboard.dart';
import 'package:rebtal/feature/admin/ui/full_screen_image_gallery.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(AdminInitial());

  final TextEditingController searchController = TextEditingController();
  int selectedIndex = 0;
  int currentIndex = 0;
  final PageController pageController = PageController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String currentQuery = '';
  // ------------------------------------
  // ✅ Full Screen Gallery logic
  // ------------------------------------
  bool showAppBar = true;
  int currentImageIndex = 0;
  PageController? galleryController;

  void initGallery(int initialIndex) {
    currentImageIndex = initialIndex;
    galleryController = PageController(initialPage: initialIndex);
    emit(AdminCurrentIndex(currentImageIndex));
  }

  void toggleAppBar() {
    showAppBar = !showAppBar;
    emit(AdminCurrentIndex(currentImageIndex));
  }

  void changeImageIndex(int index) {
    currentImageIndex = index;
    emit(AdminCurrentIndex(index));
  }

  /// --------------------------
  /// Search & Tabs
  /// --------------------------
  void updateSearch(String value) {
    currentQuery = value.trim();
    AdminSearch.q.value = currentQuery;
    emit(AdminSearchChanged(currentQuery));
  }

  void changeTab(int index) {
    selectedIndex = index;
    emit(AdminTabChanged(index));
  }

  void changeImage(int index) {
    currentIndex = index;
    emit(AdminCurrentIndex(currentIndex));
  }

  void clearSearch() {
    searchController.clear();
    currentQuery = '';
    AdminSearch.q.value = '';
    emit(AdminSearchChanged(currentQuery));
  }

  /// --------------------------
  /// Chalet Detail Logic
  /// --------------------------
  Future<void> updateStatus(
    BuildContext context, {
    required String docId,
    required String newStatus,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request $newStatus'),
            backgroundColor: newStatus == 'approved'
                ? Colors.green
                : Colors.red,
          ),
        );
        Navigator.pop(context);
      }

      emit(AdminStatusUpdated(newStatus));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      emit(AdminError(e.toString()));
    }
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

  /// --------------------------
  /// Chalet Detail Logic
  /// --------------------------
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

  @override
  Future<void> close() {
    searchController.dispose();
    pageController.dispose();
    galleryController?.dispose();
    return super.close();
  }
}
