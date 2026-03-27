import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AdminRemoteDataSource {
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(String collectionName);
  Stream<QuerySnapshot<Map<String, dynamic>>> watchChalets();
  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookings();
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPaymentProofs();
  Future<void> updateChaletStatus(String docId, String newStatus);
  Future<void> updatePaymentProofStatus(String docId, String newStatus);
  Future<void> updateUser(String collection, String docId, Map<String, dynamic> data);
  Future<void> deleteUser(String collection, String docId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl(this.firestore);

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(String collectionName) {
    return firestore.collection(collectionName).snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchChalets() {
    return firestore.collection('chalets').snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookings() {
    return firestore.collection('bookings').snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPaymentProofs() {
    return firestore.collection('payment_proofs').orderBy('uploadedAt', descending: true).snapshots();
  }

  @override
  Future<void> updateChaletStatus(String docId, String newStatus) async {
    await firestore.collection('chalets').doc(docId).update({
      'status': newStatus,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> updatePaymentProofStatus(String docId, String newStatus) async {
    await firestore.collection('payment_proofs').doc(docId).update({
      'status': newStatus,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> updateUser(String collection, String docId, Map<String, dynamic> data) async {
    await firestore.collection(collection).doc(docId).update(data);
  }

  @override
  Future<void> deleteUser(String collection, String docId) async {
    await firestore.collection(collection).doc(docId).delete();
  }
}
