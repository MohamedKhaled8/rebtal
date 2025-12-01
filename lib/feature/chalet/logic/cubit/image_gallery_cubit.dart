import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';

part 'image_gallery_state.dart';

class ImageGalleryCubit extends Cubit<ImageGalleryState> {
  final ScrollController scrollController = ScrollController();
  Timer? _autoScrollTimer;
  int _currentIndex = 0;
  final int _totalImages;

  ImageGalleryCubit(this._totalImages) : super(ImageGalleryInitial()) {
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (scrollController.hasClients && _totalImages > 1) {
        _currentIndex = (_currentIndex + 1) % _totalImages.clamp(0, 5);

        final double targetOffset = _currentIndex * 132.0;

        scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        emit(ImageGalleryUpdated(_currentIndex));
      }
    });
  }

  void openFullScreen(
    BuildContext context, {
    required List<String> images,
    required int start,
  }) {
    context.read<ChaletDetailCubit>().openFullScreen(
      context,
      images: images,
      start: start,
    );
  }

  @override
  Future<void> close() {
    _autoScrollTimer?.cancel();
    scrollController.dispose();
    return super.close();
  }
}
