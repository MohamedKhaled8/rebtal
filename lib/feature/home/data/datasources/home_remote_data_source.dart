import 'package:cloud_firestore/cloud_firestore.dart';

abstract class HomeRemoteDataSource {
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPublicChalets();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDiscountedChalets();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  HomeRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
}

