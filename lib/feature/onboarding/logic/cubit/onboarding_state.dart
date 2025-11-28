import 'package:equatable/equatable.dart';

/// Base state class for onboarding flow
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state when onboarding screen is first loaded
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// State emitted when the current page changes
/// Contains the new page index
class OnboardingPageChanged extends OnboardingState {
  final int currentPage;

  const OnboardingPageChanged(this.currentPage);

  @override
  List<Object?> get props => [currentPage];
}

/// State emitted when onboarding is completed
/// Triggers navigation to terms screen
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}
