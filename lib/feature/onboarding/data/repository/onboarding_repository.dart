import 'package:rebtal/core/utils/helper/cash_helper.dart';

/// Repository for managing onboarding-related data persistence
/// Uses SharedPreferences through CacheHelper to store onboarding completion status
class OnboardingRepository {
  final CacheHelper _cacheHelper;

  // Cache key for storing onboarding completion status
  static const String _onboardingCompletedKey = 'onboardingCompleted';

  OnboardingRepository(this._cacheHelper);

  /// Checks if the user has completed the onboarding flow
  /// Returns true if onboarding was completed, false otherwise
  Future<bool> isOnboardingCompleted() async {
    final result = _cacheHelper.getData(key: _onboardingCompletedKey);
    return result == true;
  }

  /// Marks the onboarding flow as completed
  /// This should be called after the user agrees to terms and conditions
  Future<bool> setOnboardingCompleted() async {
    return await _cacheHelper.saveData(
      key: _onboardingCompletedKey,
      value: true,
    );
  }

  /// Resets the onboarding status (useful for testing or user logout)
  /// Returns true if successfully reset
  Future<bool> resetOnboarding() async {
    return await _cacheHelper.removeData(key: _onboardingCompletedKey);
  }
}
