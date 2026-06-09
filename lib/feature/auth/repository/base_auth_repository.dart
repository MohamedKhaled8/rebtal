import 'package:dartz/dartz.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/core/utils/model/user_model.dart';

abstract class BaseAuthRepository {
  Future<Either<Failure, UserModel>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    String? profileImageUrl,
    String? idCardUrl,
    String? deviceType,
  });

  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserModel>> saveUserToFirestore(UserModel userModel);

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, UserModel>> updateProfile({
    required String uid,
    required String name,
    required String phone,
    required String role,
    String? profileImageUrl,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, UserModel>> updateIdCard({
    required String uid,
    required String role,
    required String idCardUrl,
  });
}
