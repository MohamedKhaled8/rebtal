import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/feature/chalet/domain/repository/base_chalet_repository.dart';

class GetChaletBookedDatesUseCase {
  final BaseChaletRepository repository;

  GetChaletBookedDatesUseCase(this.repository);

  Future<Either<Failure, List<DateTime>>> call(String chaletId) {
    return repository.getBookedDates(chaletId);
  }
}

