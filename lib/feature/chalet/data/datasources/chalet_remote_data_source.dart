import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChaletRemoteDataSource {
  Future<QuerySnapshot<Map<String, dynamic>>> getChaletBookings(
    String chaletId,
  );

  Future<void> updateChaletStatus({
    required String docId,
    required String newStatus,
  });

  Future<String> toggleBookingAvailability({
    required String docId,
    required String currentAvailability,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> watchApprovedVisibleChalets();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDiscountedChalets();
}

class ChaletRemoteDataSourceImpl implements ChaletRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChaletRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getChaletBookings(
    String chaletId,
  ) {
    return _firestore
        .collection('bookings')
        .where('chaletId', isEqualTo: chaletId)
        .where(
          'status',
          whereIn: const [
            'approved',
            'confirmed',
            'completed',
            'awaitingPayment',
            'paymentUnderReview',
          ],
        )
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
          toFirestore: (data, _) => data,
        )
        .get();
  }

  @override
  Future<void> updateChaletStatus({
    required String docId,
    required String newStatus,
  }) {
    return _firestore.collection('chalets').doc(docId).update({
      'status': newStatus,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<String> toggleBookingAvailability({
    required String docId,
    required String currentAvailability,
  }) async {
    final normalized =
        (currentAvailability.isEmpty ? 'available' : currentAvailability)
            .toLowerCase();
    final newAvailability =
        normalized == 'available' ? 'unavailable' : 'available';

    await _firestore.collection('chalets').doc(docId).update({
      'bookingAvailability': newAvailability,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return newAvailability;
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchApprovedVisibleChalets() {
    return _firestore
        .collection('chalets')
        .where('status', isEqualTo: 'approved')
        .where('isVisible', isEqualTo: true)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
          toFirestore: (data, _) => data,
        )
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchDiscountedChalets() {
    return _firestore
        .collection('chalets')
        .where('status', isEqualTo: 'approved')
        .where('discountEnabled', isEqualTo: true)
        .limit(10)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
          toFirestore: (data, _) => data,
        )
        .snapshots();
  }
}

