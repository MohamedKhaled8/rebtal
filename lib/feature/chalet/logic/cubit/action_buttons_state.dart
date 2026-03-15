part of 'action_buttons_cubit.dart';

abstract class ActionButtonsState {
  final String? bookingAvailability;
  const ActionButtonsState({this.bookingAvailability});
}

class ActionButtonsInitial extends ActionButtonsState {
  const ActionButtonsInitial({String? bookingAvailability})
    : super(bookingAvailability: bookingAvailability);
}

class ActionButtonsLoading extends ActionButtonsState {
  const ActionButtonsLoading({String? bookingAvailability})
    : super(bookingAvailability: bookingAvailability);
}

class ActionButtonsSuccess extends ActionButtonsState {
  final String message;
  final String? newStatus;
  const ActionButtonsSuccess(
    this.message, {
    this.newStatus,
    String? bookingAvailability,
  }) : super(bookingAvailability: bookingAvailability);
}

class ActionButtonsError extends ActionButtonsState {
  final String message;
  const ActionButtonsError(this.message, {String? bookingAvailability})
    : super(bookingAvailability: bookingAvailability);
}
