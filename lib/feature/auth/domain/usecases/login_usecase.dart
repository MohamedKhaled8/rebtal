import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/feature/auth/repository/base_auth_repository.dart';

class LoginUseCase {
  final BaseAuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<Either<Failure, UserModel>> call({
    required String email,
    required String password,
  }) async {
    return await authRepository.login(email: email, password: password);
  }
}
