import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/home/domain/repositories/base_home_repository.dart';

class WatchDiscountedChaletsUseCase {
  final BaseHomeRepository repository;

  WatchDiscountedChaletsUseCase(this.repository);

  Stream<QuerySnapshot<Map<String, dynamic>>> call() {
    return repository.watchDiscountedChalets();
  }
}

