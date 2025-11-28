import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/onboarding/data/repository/onboarding_repository.dart';
import 'package:rebtal/feature/onboarding/logic/cubit/terms_state.dart';

/// Cubit for managing terms & conditions screen state
/// Handles scroll detection, checkbox enabling, and agreement tracking
class TermsCubit extends Cubit<TermsState> {
  final OnboardingRepository _repository;

  TermsCubit(this._repository) : super(const TermsInitial());

  // Tracks if user has scrolled to bottom
  bool _hasScrolledToBottom = false;

  // Tracks if user has agreed to terms
  bool _isAgreed = false;

  /// Gets whether user has scrolled to bottom
  bool get hasScrolledToBottom => _hasScrolledToBottom;

  /// Gets whether user has agreed to terms
  bool get isAgreed => _isAgreed;

  /// Checks scroll position and updates state
  /// Called on every scroll event
  void onScroll(ScrollController controller) {
    if (!controller.hasClients) return;

    // Calculate scroll progress (0.0 to 1.0)
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    final scrollProgress = maxScroll > 0 ? currentScroll / maxScroll : 0.0;

    // Emit scroll progress
    emit(TermsScrolling(scrollProgress));

    // Check if scrolled to bottom - must scroll to the very bottom
    // Use a small threshold (10 pixels) to account for floating point precision
    // User needs to scroll all the way to the very bottom to enable checkbox
    final distanceFromBottom = maxScroll - currentScroll;
    if (distanceFromBottom <= 10 && maxScroll > 0 && !_hasScrolledToBottom) {
      _hasScrolledToBottom = true;
      emit(const TermsScrolledToBottom());
    }
  }

  /// Toggles the agreement checkbox
  /// Only works if user has scrolled to bottom
  void toggleAgreement(bool value) {
    if (!_hasScrolledToBottom) return; // Prevent checking before scrolling

    _isAgreed = value;
    emit(TermsAgreed(value));
  }

  /// Completes the terms acceptance process
  /// Saves onboarding completion to cache and triggers navigation
  Future<void> completeTerms() async {
    if (!_isAgreed) return; // Can't complete without agreement

    // Save onboarding completion to persistent storage
    await _repository.setOnboardingCompleted();

    // Emit completion state to trigger navigation
    emit(const TermsCompleted());
  }

  /// Resets the terms state (useful for testing)
  void reset() {
    _hasScrolledToBottom = false;
    _isAgreed = false;
    emit(const TermsInitial());
  }
}
