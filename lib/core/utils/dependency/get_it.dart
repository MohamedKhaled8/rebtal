import 'package:get_it/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/feature/onboarding/data/repository/onboarding_repository.dart';
import 'package:rebtal/feature/auth/repository/base_auth_repository.dart';
import 'package:rebtal/feature/auth/repository/auth_repository.dart';
import 'package:rebtal/feature/auth/domain/usecases/login_usecase.dart';
import 'package:rebtal/feature/auth/domain/usecases/register_usecase.dart';
import 'package:rebtal/feature/auth/domain/usecases/resend_email_verification_usecase.dart';
import 'package:rebtal/feature/auth/domain/usecases/save_user_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Register CacheHelper
  getIt.registerLazySingleton<CacheHelper>(() => CacheHelper());

  // Register OnboardingRepository
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepository(getIt<CacheHelper>()),
  );

  // Register AuthRepository
  getIt.registerLazySingleton<BaseAuthRepository>(() => AuthRepository());

  // Register UseCases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<BaseAuthRepository>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<BaseAuthRepository>()),
  );
  getIt.registerLazySingleton<ResendEmailVerificationUseCase>(
    () => ResendEmailVerificationUseCase(getIt<BaseAuthRepository>()),
  );
  getIt.registerLazySingleton<SaveUserUseCase>(
    () => SaveUserUseCase(getIt<BaseAuthRepository>()),
  );
}
