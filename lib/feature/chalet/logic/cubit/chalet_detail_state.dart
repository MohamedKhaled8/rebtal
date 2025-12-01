part of 'chalet_detail_cubit.dart';

@immutable
sealed class ChaletDetailState {}

final class ChaletDetailInitial extends ChaletDetailState {}

final class ChaletDetailLoading extends ChaletDetailState {}

final class ChaletDetailStatusUpdated extends ChaletDetailState {
  final String status;
  ChaletDetailStatusUpdated(this.status);
}

final class ChaletDetailError extends ChaletDetailState {
  final String message;
  ChaletDetailError(this.message);
}

final class ChaletDetailImageIndexChanged extends ChaletDetailState {
  final int index;
  ChaletDetailImageIndexChanged(this.index);
}
