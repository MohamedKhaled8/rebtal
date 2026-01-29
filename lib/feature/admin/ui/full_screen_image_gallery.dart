import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/admin/logic/cubit/admin_cubit.dart';

class FullScreenImageGallery extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit()..initGallery(initialIndex),
      child: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          final cubit = context.read<AdminCubit>();

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: cubit.showAppBar
                ? AppBar(
                    backgroundColor: Colors.black54,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      '${cubit.currentImageIndex + 1} / ${images.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    centerTitle: true,
                  )
                : null,
            body: PageView.builder(
              controller: cubit.galleryController,
              itemCount: images.length,
              onPageChanged: (i) => cubit.changeImageIndex(i),
              physics: const PageScrollPhysics(),
              itemBuilder: (context, i) {
                return _ZoomableImage(
                  imageUrl: images[i],
                  onTap: () => cubit.toggleAppBar(),
                  pageController: cubit.galleryController,
                );
              },
            ),
            bottomNavigationBar: cubit.showAppBar && images.length > 1
                ? Container(
                    height: 72,
                    color: Colors.black54,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images
                          .asMap()
                          .entries
                          .map(
                            (e) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cubit.currentImageIndex == e.key
                                    ? ColorManager.white
                                    : Colors.white54,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

// Zoomable Image Widget with better zoom support
class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final PageController? pageController;

  const _ZoomableImage({
    required this.imageUrl,
    required this.onTap,
    this.pageController,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _transformationController =
      TransformationController();
  // Store the tap details for precise zoom
  TapDownDetails? _doubleTapDetails;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final wasZoomed = _isZoomed;
    final isNowZoomed = scale > 1.05; // Slightly tolerant

    if (wasZoomed != isNowZoomed) {
      if (mounted) {
        setState(() => _isZoomed = isNowZoomed);
      }
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isZoomed) {
          _resetZoom();
        } else {
          widget.onTap();
        }
      },
      onDoubleTapDown: (details) {
        _doubleTapDetails = details;
      },
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 5.0,
        panEnabled: _isZoomed, // Allow panning only when zoomed
        scaleEnabled: true,
        child: Center(
          child: AppImageHelper(
            height: double.infinity,
            width: double.infinity,
            path: widget.imageUrl,
            fit: BoxFit.contain, // Ensure full image is visible
          ),
        ),
      ),
    );
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _handleDoubleTap() {
    if (_isZoomed) {
      _resetZoom();
    } else {
      final position = _doubleTapDetails?.localPosition;
      if (position != null) {
        final double scale = 2.5;
        final x = -position.dx * (scale - 1);
        final y = -position.dy * (scale - 1);

        final zoomed = Matrix4.identity()
          ..translate(x, y)
          ..scale(scale);

        _transformationController.value = zoomed;
      } else {
        // Fallback center zoom
        _transformationController.value = Matrix4.identity()..scale(2.5);
      }
    }
  }
}
