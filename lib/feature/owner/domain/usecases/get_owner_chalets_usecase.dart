import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/feature/owner/domain/repository/base_owner_repository.dart';

class GetOwnerChaletsUseCase {
  final BaseOwnerRepository repository;

  GetOwnerChaletsUseCase(this.repository);

  // Returns List<dynamic> to preserve all Firestore fields
  Future<Either<Failure, List<dynamic>>> call(String ownerId) async {
    return await repository.getOwnerChalets(ownerId);
  }

  Stream<List<dynamic>> stream(String ownerId) {
    return repository.getOwnerChaletsStream(ownerId);
  }
}
