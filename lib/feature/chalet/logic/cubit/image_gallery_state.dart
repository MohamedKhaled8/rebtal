part of 'image_gallery_cubit.dart';

abstract class ImageGalleryState {}

class ImageGalleryInitial extends ImageGalleryState {}

class ImageGalleryUpdated extends ImageGalleryState {
  final int currentIndex;
  ImageGalleryUpdated(this.currentIndex);
}
