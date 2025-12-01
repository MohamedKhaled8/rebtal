part of 'action_buttons_cubit.dart';

abstract class ActionButtonsState {}

class ActionButtonsInitial extends ActionButtonsState {}

class ActionButtonsLoading extends ActionButtonsState {}

class ActionButtonsSuccess extends ActionButtonsState {
  final String message;
  ActionButtonsSuccess(this.message);
}

class ActionButtonsError extends ActionButtonsState {
  final String message;
  ActionButtonsError(this.message);
}
