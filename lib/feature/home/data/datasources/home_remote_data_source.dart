import 'package:cloud_firestore/cloud_firestore.dart';

/// Public listing uses a simple compound `where` — no extra index for [createdAt].
abstract class HomeRemoteDataSource {
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPublicChalets();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDiscountedChalets();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchApprovedChalets();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPublicChalets() {
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

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchApprovedChalets() {
    return _firestore
        .collection('chalets')
        .where('status', isEqualTo: 'approved')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
          toFirestore: (data, _) => data,
        )
        .snapshots();
  }
}
