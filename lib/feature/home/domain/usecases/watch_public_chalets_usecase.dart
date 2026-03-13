import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/home/domain/repositories/base_home_repository.dart';

class WatchPublicChaletsUseCase {
  final BaseHomeRepository repository;

  WatchPublicChaletsUseCase(this.repository);

  Stream<QuerySnapshot<Map<String, dynamic>>> call() {
    return repository.watchPublicChalets();
  }
}

