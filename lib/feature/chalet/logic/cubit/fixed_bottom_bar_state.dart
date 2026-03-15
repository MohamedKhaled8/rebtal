part of 'fixed_bottom_bar_cubit.dart';

abstract class FixedBottomBarState {}

class FixedBottomBarInitial extends FixedBottomBarState {}

class FixedBottomBarLoaded extends FixedBottomBarState {
  final double displayPriceValue;
  final double? originalPriceValue;
  final bool isBookingAvailable;

  FixedBottomBarLoaded({
    required this.displayPriceValue,
    this.originalPriceValue,
    required this.isBookingAvailable,
    this.hasContactedOriginalTenant = false,
    this.booking,
    this.isOriginalOfferOwner = false,
  });

  final bool hasContactedOriginalTenant;
  final Booking? booking;
  final bool isOriginalOfferOwner;
}

class FixedBottomBarError extends FixedBottomBarState {
  final String message;
  FixedBottomBarError(this.message);
}
