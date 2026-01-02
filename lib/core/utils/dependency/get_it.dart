import 'package:get_it/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/feature/onboarding/data/repository/onboarding_repository.dart';
import 'package:rebtal/feature/auth/repository/base_auth_repository.dart';
import 'package:rebtal/feature/auth/repository/auth_repository.dart';
import 'package:rebtal/feature/auth/domain/usecases/login_usecase.dart';
import 'package:rebtal/feature/auth/domain/usecases/register_usecase.dart';
import 'package:rebtal/feature/auth/domain/usecases/resend_email_verification_usecase.dart';
import 'package:rebtal/feature/auth/domain/usecases/save_user_usecase.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_cubit.dart';
import 'package:rebtal/feature/owner/logic/cubit/owner_cubit.dart';
import 'package:rebtal/feature/owner/domain/repository/base_owner_repository.dart';
import 'package:rebtal/feature/owner/data/repository/owner_repository_impl.dart';
import 'package:rebtal/feature/owner/domain/usecases/add_chalet_usecase.dart';
import 'package:rebtal/feature/owner/domain/usecases/get_owner_chalets_usecase.dart';

final GetIt getIt = GetIt.instance;

/// Composition Root - Where all dependencies are wired together
///
/// This is the ONLY place where:
/// - Dependencies are created
/// - Dependencies are injected
/// - Object graph is composed
///
/// Following Clean Architecture and Dependency Inversion Principle:
/// - High-level modules (AppCubit) depend on abstractions
/// - Low-level modules (Feature Cubits) are injected
/// - Dependencies point inward (toward business logic)
Future<void> setupGetIt() async {
  // ============================================================
  // INFRASTRUCTURE LAYER
  // ============================================================

  // Register CacheHelper
  getIt.registerLazySingleton<CacheHelper>(() => CacheHelper());

  // ============================================================
  // DATA LAYER
  // ============================================================

  // Register OnboardingRepository
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepository(getIt<CacheHelper>()),
  );

  // Register AuthRepository
  getIt.registerLazySingleton<BaseAuthRepository>(() => AuthRepository());

  // Register OwnerRepository
  getIt.registerLazySingleton<BaseOwnerRepository>(() => OwnerRepositoryImpl());

  // ============================================================
  // DOMAIN LAYER (Use Cases)
  // ============================================================

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

  // Register Owner UseCases
  getIt.registerLazySingleton<AddChaletUseCase>(
    () => AddChaletUseCase(getIt<BaseOwnerRepository>()),
  );
  getIt.registerLazySingleton<GetOwnerChaletsUseCase>(
    () => GetOwnerChaletsUseCase(getIt<BaseOwnerRepository>()),
  );

  // ============================================================
  // PRESENTATION LAYER (Feature Cubits)
  // ============================================================

  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(getIt<BaseAuthRepository>()),
  );

  getIt.registerLazySingleton<BookingCubit>(() => BookingCubit());

  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  getIt.registerLazySingleton<NotificationCubit>(() => NotificationCubit());

  getIt.registerLazySingleton<OwnerCubit>(
    () => OwnerCubit(
      addChaletUseCase: getIt<AddChaletUseCase>(),
      getOwnerChaletsUseCase: getIt<GetOwnerChaletsUseCase>(),
    ),
  );

  // ============================================================
  // APPLICATION LAYER (App Coordinator)
  // ============================================================

  getIt.registerLazySingleton<AppCubit>(
    () => AppCubit(
      authCubit: getIt<AuthCubit>(),
      bookingCubit: getIt<BookingCubit>(),
      themeCubit: getIt<ThemeCubit>(),
      notificationCubit: getIt<NotificationCubit>(),
      ownerCubit: getIt<OwnerCubit>(),
    ),
  );
}
