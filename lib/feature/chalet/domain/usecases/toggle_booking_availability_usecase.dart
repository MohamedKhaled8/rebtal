import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/feature/chalet/domain/repository/base_chalet_repository.dart';

class ToggleBookingAvailabilityUseCase {
  final BaseChaletRepository repository;

  ToggleBookingAvailabilityUseCase(this.repository);

  Future<Either<Failure, String>> call(
    ToggleBookingAvailabilityParams params,
  ) {
    return repository.toggleBookingAvailability(
      docId: params.docId,
      currentAvailability: params.currentAvailability,
    );
  }
}

class ToggleBookingAvailabilityParams extends Equatable {
  final String docId;
  final String currentAvailability;

  const ToggleBookingAvailabilityParams({
    required this.docId,
    required this.currentAvailability,
  });

  @override
  List<Object?> get props => [docId, currentAvailability];
}

