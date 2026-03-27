import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(String collectionName) {
    return remoteDataSource.watchCollection(collectionName);
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchChalets() {
    return remoteDataSource.watchChalets();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookings() {
    return remoteDataSource.watchBookings();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPaymentProofs() {
    return remoteDataSource.watchPaymentProofs();
  }

  @override
  Future<void> updateChaletStatus(String docId, String newStatus) {
    return remoteDataSource.updateChaletStatus(docId, newStatus);
  }

  @override
  Future<void> updatePaymentProofStatus(String docId, String newStatus) {
    return remoteDataSource.updatePaymentProofStatus(docId, newStatus);
  }

  @override
  Future<void> updateUser(String collection, String docId, Map<String, dynamic> data) {
    return remoteDataSource.updateUser(collection, docId, data);
  }

  @override
  Future<void> deleteUser(String collection, String docId) {
    return remoteDataSource.deleteUser(collection, docId);
  }
}
