part of 'add_chalet_cubit.dart';

abstract class AddChaletState {}

class AddChaletInitial extends AddChaletState {}

class AddChaletLoading extends AddChaletState {}

class AddChaletSuccess extends AddChaletState {}

class AddChaletFailure extends AddChaletState {
  final String error;
  AddChaletFailure(this.error);
}

class AddChaletImagesUpdated extends AddChaletState {
  final List<File> images;
  AddChaletImagesUpdated(this.images);
}
