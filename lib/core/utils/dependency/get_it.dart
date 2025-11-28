import 'package:get_it/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/feature/onboarding/data/repository/onboarding_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Register CacheHelper
  getIt.registerLazySingleton<CacheHelper>(() => CacheHelper());

  // Register OnboardingRepository
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepository(getIt<CacheHelper>()),
  );
}
