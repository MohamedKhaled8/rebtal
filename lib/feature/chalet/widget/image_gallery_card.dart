import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/image_gallery_cubit.dart';

class ImageGalleryCard extends StatelessWidget {
  final List<String> images;
  final Map<String, dynamic> requestData;

  const ImageGalleryCard({
    super.key,
    required this.images,
    required this.requestData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocProvider(
      create: (context) => ImageGalleryCubit(images.length),
      child: BlocBuilder<ImageGalleryCubit, ImageGalleryState>(
        builder: (context, state) {
          final cubit = context.read<ImageGalleryCubit>();
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorManager.chaletCardDark,
                        ColorManager.chaletCardDark.withOpacity(0.8),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorManager.chaletCardLight,
                        ColorManager.chaletCardLight.withOpacity(0.95),
                      ],
                    ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? ColorManager.white.withOpacity(0.05)
                    : ColorManager.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.chaletGalleryPink.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: ColorManager.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorManager.chaletGalleryPink.withOpacity(0.2),
                            ColorManager.chaletGalleryPink.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ColorManager.chaletGalleryPink.withOpacity(
                            0.3,
                          ),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.collections_rounded,
                        color: ColorManager.chaletGalleryPink,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Photo Gallery',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? ColorManager.chaletTextPrimaryDark
                                  : ColorManager.chaletGalleryTextDark,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${images.length} photos',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? ColorManager.chaletTextSecondaryDark
                                  : ColorManager.chaletTextSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            ColorManager.chaletGalleryBlue,
                            Color(0xFF2563EB),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.chaletGalleryBlue.withOpacity(
                              0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: ColorManager.transparent,
                        child: InkWell(
                          onTap: () => cubit.openFullScreen(
                            context,
                            images: images,
                            start: 0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'View All',
                                  style: TextStyle(
                                    color: ColorManager.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: ColorManager.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    controller: cubit.scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: images.length.clamp(0, 8),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => cubit.openFullScreen(
                          context,
                          images: images,
                          start: index,
                        ),
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ColorManager.chaletGalleryPink.withOpacity(0.1),
                                ColorManager.chaletGalleryBlue.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: ColorManager.chaletGalleryPink
                                    .withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: AppImageHelper(
                                  path: images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      ColorManager.transparent,
                                      ColorManager.black.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                              // Border
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ColorManager.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // Index badge
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorManager.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: ColorManager.white.withOpacity(
                                        0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${index + 1}/${images.length}',
                                    style: const TextStyle(
                                      color: ColorManager.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              // Tap indicator
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ColorManager.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: ColorManager.black.withOpacity(
                                          0.2,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.zoom_in_rounded,
                                    color: ColorManager.chaletGalleryBlue,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
