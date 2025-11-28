import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/onboarding/data/models/onboarding_model.dart';
import 'package:rebtal/feature/onboarding/logic/cubit/onboarding_state.dart';

/// Cubit for managing onboarding flow state
/// Handles page navigation, current page tracking, and completion
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingInitial());

  // Current page index (0-2 for 3 pages)
  int _currentPage = 0;

  // Total number of onboarding pages
  final int totalPages = OnboardingContent.pages.length;

  /// Gets the current page index
  int get currentPage => _currentPage;

  /// Checks if we're on the last page
  bool get isLastPage => _currentPage == totalPages - 1;

  /// Updates the current page index
  /// Called when user swipes or taps next
  void onPageChanged(int page) {
    _currentPage = page;
    emit(OnboardingPageChanged(page));
  }

  /// Navigates to the next page
  /// If on last page, completes onboarding
  void nextPage() {
    if (_currentPage < totalPages - 1) {
      _currentPage++;
      emit(OnboardingPageChanged(_currentPage));
    } else {
      completeOnboarding();
    }
  }

  /// Skips onboarding and navigates to terms
  void skipOnboarding() {
    completeOnboarding();
  }

  /// Marks onboarding as completed
  /// Emits state that triggers navigation to terms screen
  void completeOnboarding() {
    emit(const OnboardingCompleted());
  }

  /// Resets to first page (useful for testing)
  void reset() {
    _currentPage = 0;
    emit(const OnboardingInitial());
  }
}
