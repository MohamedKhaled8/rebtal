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

        if (images.isEmpty) {
          return Container(
            height: 400,
            margin: const EdgeInsets.only(bottom: 16.31),
            decoration: BoxDecoration(color: ColorManager.chaletGrey200),
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
                  final currentIndex = data.currentIndex;
                  cubit.openFullScreen(
                    context,
                    images: images,
                    start: currentIndex,
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

              // Gradient Overlay - Ignore pointer to allow tap through
              Positioned.fill(
                child: IgnorePointer(
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
              ),

              // Back Button (Top Left) - Keep pointer events
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

              // Title and Location (Bottom Left) - Ignore pointer to allow tap through
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: IgnorePointer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotelName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: ColorManager.white,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: ColorManager.black.withOpacity(0.45),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: ColorManager.chaletGrey200,
                                height: 1.3,
                                shadows: [
                                  Shadow(
                                    color: ColorManager.black.withOpacity(0.45),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
