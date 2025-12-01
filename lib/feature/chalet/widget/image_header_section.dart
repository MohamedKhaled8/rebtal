import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';

class ImageHeaderSection extends StatelessWidget {
  final String hotelName;
  final String location;

  const ImageHeaderSection({
    super.key,
    required this.hotelName,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ChaletDetailCubit,
      ChaletDetailState,
      ({List<String> images, int currentIndex})
    >(
      selector: (state) {
        if (state is ChaletDetailLoaded) {
          return (images: state.images, currentIndex: state.currentImageIndex);
        }
        return (images: <String>[], currentIndex: 0);
      },
      builder: (context, data) {
        final images = data.images;
        final currentImageIndex = data.currentIndex;

        if (images.isEmpty) {
          return Container(
            height: 400,
            margin: const EdgeInsets.only(bottom: 16.31),
            decoration: BoxDecoration(color: Colors.grey[200]),
          );
        }

        final cubit = context.read<ChaletDetailCubit>();

        return Container(
          height: 400,
          margin: const EdgeInsets.only(bottom: 16.31),
          decoration: const BoxDecoration(color: ColorManager.black),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main Image with PageView
              GestureDetector(
                onTap: () {
                  cubit.openFullScreen(
                    context,
                    images: images,
                    start: currentImageIndex,
                  );
                },
                child: PageView.builder(
                  controller: cubit.pageController,
                  itemCount: images.length,
                  onPageChanged: cubit.onPageChanged,
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: 'chalet_image_$index',
                      child: AppImageHelper(
                        path: images[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorManager.black.withOpacity(0.2),
                        ColorManager.transparent,
                        ColorManager.black.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Back Button (Top Left)
              Positioned(
                top: 50,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorManager.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorManager.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: ColorManager.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ),

              // Thumbnails (Bottom Right)
              if (images.length > 1)
                Positioned(
                  right: 20,
                  bottom: 100,
                  child: SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: images.length > 4 ? 4 : images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = currentImageIndex == index;
                        return GestureDetector(
                          onTap: () => cubit.navigateToImage(index),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: ColorManager.white, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: ColorManager.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AppImageHelper(
                                path: images[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Title and Location (Bottom Left)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotelName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: ColorManager.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: ColorManager.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE0E0E0),
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
