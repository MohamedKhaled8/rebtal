import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/failure.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/feature/auth/repository/base_auth_repository.dart';

class SaveUserUseCase {
  final BaseAuthRepository _authRepository;

  SaveUserUseCase(this._authRepository);

  Future<Either<Failure, UserModel>> call(UserModel userModel) async {
    return await _authRepository.saveUserToFirestore(userModel);
  }
}
