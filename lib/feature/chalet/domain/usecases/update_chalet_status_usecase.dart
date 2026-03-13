import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/feature/chalet/domain/repository/base_chalet_repository.dart';

class UpdateChaletStatusUseCase {
  final BaseChaletRepository repository;

  UpdateChaletStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateChaletStatusParams params) {
    return repository.updateStatus(
      docId: params.docId,
      newStatus: params.newStatus,
    );
  }
}

class UpdateChaletStatusParams extends Equatable {
  final String docId;
  final String newStatus;

  const UpdateChaletStatusParams({
    required this.docId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [docId, newStatus];
}

