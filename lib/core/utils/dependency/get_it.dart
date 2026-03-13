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
import 'package:rebtal/feature/chalet/domain/repository/base_chalet_repository.dart';
import 'package:rebtal/feature/chalet/data/datasources/chalet_remote_data_source.dart';
import 'package:rebtal/feature/chalet/data/repository/chalet_repository_impl.dart';
import 'package:rebtal/feature/chalet/domain/usecases/get_chalet_booked_dates_usecase.dart';
import 'package:rebtal/feature/chalet/domain/usecases/toggle_booking_availability_usecase.dart';
import 'package:rebtal/feature/chalet/domain/usecases/update_chalet_status_usecase.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';
import 'package:rebtal/feature/home/domain/repositories/base_home_repository.dart';
import 'package:rebtal/feature/home/data/datasources/home_remote_data_source.dart';
import 'package:rebtal/feature/home/data/repositories/home_repository_impl.dart';
import 'package:rebtal/feature/home/domain/usecases/watch_public_chalets_usecase.dart';
import 'package:rebtal/feature/home/domain/usecases/watch_discounted_chalets_usecase.dart';

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

  // Register ChaletRepository
  getIt.registerLazySingleton<ChaletRemoteDataSource>(
    () => ChaletRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<BaseChaletRepository>(
    () => ChaletRepositoryImpl(remoteDataSource: getIt<ChaletRemoteDataSource>()),
  );

  // Register HomeRepository (Home Data Layer)
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<BaseHomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: getIt<HomeRemoteDataSource>()),
  );

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

  // Register Chalet UseCases
  getIt.registerLazySingleton<GetChaletBookedDatesUseCase>(
    () => GetChaletBookedDatesUseCase(getIt<BaseChaletRepository>()),
  );
  getIt.registerLazySingleton<UpdateChaletStatusUseCase>(
    () => UpdateChaletStatusUseCase(getIt<BaseChaletRepository>()),
  );
  getIt.registerLazySingleton<ToggleBookingAvailabilityUseCase>(
    () => ToggleBookingAvailabilityUseCase(getIt<BaseChaletRepository>()),
  );

  // Register Home UseCases (Home feature uses chalet repository)
  getIt.registerLazySingleton<WatchPublicChaletsUseCase>(
    () => WatchPublicChaletsUseCase(getIt<BaseHomeRepository>()),
  );
  getIt.registerLazySingleton<WatchDiscountedChaletsUseCase>(
    () => WatchDiscountedChaletsUseCase(getIt<BaseHomeRepository>()),
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

  getIt.registerLazySingleton<ChaletDetailCubit>(
    () => ChaletDetailCubit(
      getChaletBookedDatesUseCase: getIt<GetChaletBookedDatesUseCase>(),
      updateChaletStatusUseCase: getIt<UpdateChaletStatusUseCase>(),
      toggleBookingAvailabilityUseCase:
          getIt<ToggleBookingAvailabilityUseCase>(),
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
