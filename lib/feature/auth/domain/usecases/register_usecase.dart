import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/feature/auth/repository/base_auth_repository.dart';

class RegisterUseCase {
  final BaseAuthRepository authRepository;

  RegisterUseCase(this.authRepository);

  Future<Either<Failure, UserModel>> call({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    String? profileImageUrl,
  }) async {
    return await authRepository.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
      profileImageUrl: profileImageUrl,
    );
  }
}
