import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:rebtal/feature/admin/presentation/pages/dashboard.dart';

import '../../domain/usecases/admin_usecases.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final GetAdminStreamUseCase getAdminStreamUseCase;
  final UpdateChaletStatusUseCase updateChaletStatusUseCase;
  final UpdatePaymentProofStatusUseCase updatePaymentProofStatusUseCase;
  final ManageUserUseCase manageUserUseCase;

  AdminCubit({
    required this.getAdminStreamUseCase,
    required this.updateChaletStatusUseCase,
    required this.updatePaymentProofStatusUseCase,
    required this.manageUserUseCase,
  }) : super(AdminInitial());

  final TextEditingController searchController = TextEditingController();
  int selectedIndex = 0;
  int currentIndex = 0;
  final PageController pageController = PageController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String currentQuery = '';

  // Galleries
  bool showAppBar = true;
  int currentImageIndex = 0;
  PageController? galleryController;

  // Stream Subscriptions
  StreamSubscription? _usersSub;
  StreamSubscription? _ownersSub;
  StreamSubscription? _adminsSub;
  StreamSubscription? _chaletsSub;
  StreamSubscription? _bookingsSub;
  StreamSubscription? _paymentsSub;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _users = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _owners = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _admins = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _chalets = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _bookings = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _payments = [];

  void startListeningToAll() {
    emit(AdminLoading());

    _usersSub ??= getAdminStreamUseCase
        .watchCollection('Users')
        .listen(
          (snapshot) {
            _users = snapshot.docs;
            _emitDataLoaded();
          },
          onError: (e) {
            emit(AdminError('Error fetching Users: $e'));
          },
        );

    _ownersSub ??= getAdminStreamUseCase
        .watchCollection('Owners')
        .listen(
          (snapshot) {
            _owners = snapshot.docs;
            _emitDataLoaded();
          },
          onError: (e) {
            emit(AdminError('Error fetching Owners: $e'));
          },
        );

    _adminsSub ??= getAdminStreamUseCase
        .watchCollection('Admin')
        .listen(
          (snapshot) {
            _admins = snapshot.docs;
            _emitDataLoaded();
          },
          onError: (e) {
            emit(AdminError('Error fetching Admin: $e'));
          },
        );

    _chaletsSub ??= getAdminStreamUseCase.watchChalets().listen(
      (snapshot) {
        _chalets = snapshot.docs;
        _emitDataLoaded();
      },
      onError: (e) {
        emit(AdminError('Error fetching chalets: $e'));
      },
    );

    _bookingsSub ??= getAdminStreamUseCase.watchBookings().listen(
      (snapshot) {
        _bookings = snapshot.docs;
        _emitDataLoaded();
      },
      onError: (e) {
        emit(AdminError('Error fetching bookings: $e'));
      },
    );

    _paymentsSub ??= getAdminStreamUseCase.watchPaymentProofs().listen(
      (snapshot) {
        _payments = snapshot.docs;
        _emitDataLoaded();
      },
      onError: (e) {
        emit(AdminError('Error fetching payments: $e'));
      },
    );
  }

  void _emitDataLoaded() {
    emit(
      AdminDataLoaded(
        users: _users,
        owners: _owners,
        admins: _admins,
        chalets: _chalets,
        bookings: _bookings,
        paymentProofs: _payments,
      ),
    );
  }

  void initGallery(int initialIndex) {
    currentImageIndex = initialIndex;
    galleryController = PageController(initialPage: initialIndex);
  }

  void toggleAppBar() {
    showAppBar = !showAppBar;
  }

  void changeImageIndex(int index) {
    currentImageIndex = index;
  }

  void updateSearch(String value) {
    currentQuery = value.trim();
    AdminSearch.q.value = currentQuery;
    // Do not emit here: transient states replaced [AdminDataLoaded] and cleared all admin lists.
  }

  void changeTab(int index) {
    selectedIndex = index;
    _emitDataLoaded();
  }

  void clearSearch() {
    searchController.clear();
    currentQuery = '';
    AdminSearch.q.value = '';
  }

  /// Approve uploaded payment proof and confirm the booking (blocks dates on calendar).
  Future<void> approvePaymentProof({
    required String proofDocId,
    required String bookingId,
  }) async {
    final bookingRef = FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId);
    final bookingSnap = await bookingRef.get();
    final before = bookingSnap.data();
    final guestUserId = before?['userId']?.toString();
    final chaletName = before?['chaletName']?.toString() ?? '';
    final chaletId = before?['chaletId']?.toString() ?? '';
    final isDayUse =
        before?['isDayUse'] == true ||
        before?['bookingType']?.toString() == 'day_use';

    await updatePaymentProofStatusUseCase(proofDocId, 'approved');
    await bookingRef.update({
      'status': 'confirmed',
      'adminConfirmedPaymentAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Day-use should become unavailable ONLY after admin confirms payment.
    // Keep the unavailability scoped to the day-use flow so it doesn't affect
    // normal multi-day booking availability.
    if (isDayUse && chaletId.isNotEmpty) {
      final now = DateTime.now();
      final todayKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await FirebaseFirestore.instance.collection('chalets').doc(chaletId).set({
        'dayUseBookingAvailability': 'unavailable',
        'dayUseBookedAt': todayKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (guestUserId != null && guestUserId.isNotEmpty) {
      await NotificationService().sendNotification(
        userId: guestUserId,
        titleKey: 'notifications_payment_confirmed_title',
        bodyKey: 'notifications_payment_confirmed_body',
        bodyParams: {'chaletName': chaletName},
        type: NotificationType.paymentConfirmed,
        relatedId: bookingId,
        data: {'bookingId': bookingId, 'chaletName': chaletName},
      );
    }
  }

  /// Reject payment proof and send booking back to awaiting payment.
  Future<void> rejectPaymentProof({
    required String proofDocId,
    required String bookingId,
    String? reason,
  }) async {
    // Read booking to allow day-use availability reset.
    final bookingRef = FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId);
    final bookingSnap = await bookingRef.get();
    final data = bookingSnap.data();
    final chaletId = data?['chaletId']?.toString() ?? '';
    final isDayUse =
        data?['isDayUse'] == true ||
        data?['bookingType']?.toString() == 'day_use';

    await updatePaymentProofStatusUseCase(proofDocId, 'rejected');
    await bookingRef.update({
      'status': 'awaitingPayment',
      'paymentProofUrl': null,
      'paymentProofUploadedAt': null,
      if (reason != null && reason.isNotEmpty) 'adminPaymentNotes': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // If payment proof is rejected, keep day-use available (no blocking).
    if (isDayUse && chaletId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('chalets').doc(chaletId).set({
        'dayUseBookingAvailability': 'available',
        'dayUseBookedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateStatus(
    BuildContext context, {
    required String docId,
    required String newStatus,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('chalets')
          .doc(docId);
      final chaletDoc = await docRef.get();

      await updateChaletStatusUseCase(docId, newStatus);

      // Notification logic
      if (chaletDoc.exists) {
        final chaletData = chaletDoc.data() as Map<String, dynamic>;
        String? ownerId =
            (chaletData['ownerId'] ??
                    chaletData['merchantId'] ??
                    chaletData['userId'])
                ?.toString();
        final chaletName = chaletData['chaletName'] ?? 'شاليهك';

        if (ownerId != null && ownerId.isNotEmpty) {
          if (ownerId.contains(':')) ownerId = ownerId.split(':').last.trim();

          NotificationType type = NotificationType.general;
          String title = 'تحديث حالة الشاليه';
          String body = 'تمت مراجعة شاليهك $chaletName من قبل الإدارة.';

          if (newStatus == 'approved') {
            type = NotificationType.chaletApproved;
            title = 'تهانينا! تمت الموافقة 🎉';
            body =
                'تمت الموافقة على شاليهك $chaletName من قبل الإدارة وهو الآن متاح للمستخدمين.';
          } else if (newStatus == 'rejected') {
            type = NotificationType.chaletRejected;
            title = 'تم رفض الشاليه ❌';
            body =
                'عذراً، تم رفض طلبك لإضافة شاليه $chaletName. يرجى مراجعة التفاصيل والتعديل.';
          }

          await NotificationService().sendNotification(
            userId: ownerId,
            title: title,
            body: body,
            type: type,
            relatedId: docId,
            data: {'chaletId': docId},
          );
        }
      }

      if (context.mounted) {
        SnackBarHelper.showSuccess(context, 'Request $newStatus');
        Navigator.pop(context);
      }
      _emitDataLoaded();
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'Error: $e');
      }
      emit(AdminError(e.toString()));
    }
  }

  Future<void> updateUser(
    BuildContext context,
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await manageUserUseCase.updateUser(collection, docId, data);
      if (context.mounted) {
        SnackBarHelper.showSuccess(context, 'تم تحديث بيانات المستخدم بنجاح');
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'خطأ: $e');
      }
    }
  }

  Future<void> deleteUserLocal(
    BuildContext context,
    String collection,
    String docId,
  ) async {
    try {
      await manageUserUseCase.deleteUser(collection, docId);
      if (context.mounted) {
        SnackBarHelper.showSuccess(context, 'تم حذف المستخدم بنجاح');
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'خطأ: $e');
      }
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
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return 'Invalid date';
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

  Future<void> toggleChaletVisibility(
    String docId,
    bool currentVisibility,
  ) async {
    try {
      final newVisibility = !currentVisibility;
      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'isVisible': newVisibility,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(AdminError('common_error: $e'));
      rethrow;
    }
  }

  Future<void> toggleChaletBookingAvailability(
    String docId,
    String currentAvailability,
  ) async {
    try {
      final newAvailability = currentAvailability == 'available'
          ? 'unavailable'
          : 'available';
      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'bookingAvailability': newAvailability,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(AdminError('common_error: $e'));
      rethrow;
    }
  }

  Future<void> deleteChalet(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chalets')
          .doc(docId)
          .delete();
    } catch (e) {
      emit(AdminError('common_error: $e'));
      rethrow;
    }
  }

  @override
  Future<void> close() {
    searchController.dispose();
    pageController.dispose();
    galleryController?.dispose();
    _usersSub?.cancel();
    _ownersSub?.cancel();
    _adminsSub?.cancel();
    _chaletsSub?.cancel();
    _bookingsSub?.cancel();
    _paymentsSub?.cancel();
    return super.close();
  }
}
