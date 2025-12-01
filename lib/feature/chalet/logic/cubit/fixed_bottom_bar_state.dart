part of 'fixed_bottom_bar_cubit.dart';

abstract class FixedBottomBarState {}

class FixedBottomBarInitial extends FixedBottomBarState {}

class FixedBottomBarLoaded extends FixedBottomBarState {
  final String displayPrice;
  final String? originalPrice;
  final bool isBookingAvailable;

  FixedBottomBarLoaded({
    required this.displayPrice,
    this.originalPrice,
    required this.isBookingAvailable,
  });
}

class FixedBottomBarError extends FixedBottomBarState {
  final String message;
  FixedBottomBarError(this.message);
}
