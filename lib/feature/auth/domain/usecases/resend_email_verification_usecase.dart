import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/failure.dart';
import 'package:rebtal/feature/auth/repository/base_auth_repository.dart';

class ResendEmailVerificationUseCase {
  final BaseAuthRepository _authRepository;

  ResendEmailVerificationUseCase(this._authRepository);

  Future<Either<Failure, void>> call() async {
    return await _authRepository.sendEmailVerification();
  }
}
