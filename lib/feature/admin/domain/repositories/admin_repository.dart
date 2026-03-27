import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AdminRepository {
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(String collectionName);
  Stream<QuerySnapshot<Map<String, dynamic>>> watchChalets();
  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookings();
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPaymentProofs();

  Future<void> updateChaletStatus(String docId, String newStatus);
  Future<void> updatePaymentProofStatus(String docId, String newStatus);
  Future<void> updateUser(String collection, String docId, Map<String, dynamic> data);
  Future<void> deleteUser(String collection, String docId);
}
