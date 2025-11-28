import 'package:equatable/equatable.dart';

/// Base state class for terms & conditions screen
abstract class TermsState extends Equatable {
  const TermsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when terms screen is first loaded
/// Checkbox is disabled, user hasn't scrolled to bottom
class TermsInitial extends TermsState {
  const TermsInitial();
}

/// State emitted when user scrolls through the terms
/// Contains scroll progress percentage (0.0 to 1.0)
class TermsScrolling extends TermsState {
  final double scrollProgress;

  const TermsScrolling(this.scrollProgress);

  @override
  List<Object?> get props => [scrollProgress];
}

/// State emitted when user has scrolled to the bottom
/// Triggers checkbox enable animation
class TermsScrolledToBottom extends TermsState {
  const TermsScrolledToBottom();
}

/// State emitted when user checks the agreement checkbox
class TermsAgreed extends TermsState {
  final bool isAgreed;

  const TermsAgreed(this.isAgreed);

  @override
  List<Object?> get props => [isAgreed];
}

/// State emitted when user completes terms acceptance
/// Triggers navigation to home/welcome screen
class TermsCompleted extends TermsState {
  const TermsCompleted();
}
