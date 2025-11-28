import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'add_chalet_state.dart';

class AddChaletCubit extends Cubit<AddChaletState> {
  AddChaletCubit() : super(AddChaletInitial());

  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedImages.addAll(images.map((e) => File(e.path)));
        emit(AddChaletImagesUpdated(List.from(selectedImages)));
      }
    } catch (e) {
      emit(AddChaletFailure("Failed to pick images: $e"));
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      emit(AddChaletImagesUpdated(List.from(selectedImages)));
    }
  }

  Future<void> submitChalet({
    required String name,
    required String description,
    required double price,
    required String location,
    required List<String> features,
    required String ownerId,
  }) async {
    emit(AddChaletLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual API call here

      emit(AddChaletSuccess());
    } catch (e) {
      emit(AddChaletFailure("Failed to add chalet: $e"));
    }
  }
}
