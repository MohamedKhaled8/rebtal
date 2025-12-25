part of 'action_buttons_cubit.dart';

abstract class ActionButtonsState {}

class ActionButtonsInitial extends ActionButtonsState {}

class ActionButtonsLoading extends ActionButtonsState {}

class ActionButtonsSuccess extends ActionButtonsState {
  final String message;
  final String? newStatus;
  ActionButtonsSuccess(this.message, {this.newStatus});
}

class ActionButtonsError extends ActionButtonsState {
  final String message;
  ActionButtonsError(this.message);
}
