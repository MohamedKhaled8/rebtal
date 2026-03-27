import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/admin_repository.dart';

class GetAdminStreamUseCase {
  final AdminRepository repository;

  GetAdminStreamUseCase(this.repository);

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(String collectionName) {
    return repository.watchCollection(collectionName);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchChalets() {
    return repository.watchChalets();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookings() {
    return repository.watchBookings();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPaymentProofs() {
    return repository.watchPaymentProofs();
  }
}

class UpdatePaymentProofStatusUseCase {
  final AdminRepository repository;

  UpdatePaymentProofStatusUseCase(this.repository);

  Future<void> call(String docId, String newStatus) {
    return repository.updatePaymentProofStatus(docId, newStatus);
  }
}

class UpdateChaletStatusUseCase {
  final AdminRepository repository;

  UpdateChaletStatusUseCase(this.repository);

  Future<void> call(String docId, String newStatus) {
    return repository.updateChaletStatus(docId, newStatus);
  }
}

class ManageUserUseCase {
  final AdminRepository repository;

  ManageUserUseCase(this.repository);

  Future<void> updateUser(String collection, String docId, Map<String, dynamic> data) {
    return repository.updateUser(collection, docId, data);
  }

  Future<void> deleteUser(String collection, String docId) {
    return repository.deleteUser(collection, docId);
  }
}
