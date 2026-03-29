import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/image_gallery_cubit.dart';
import 'package:responsive_screen_master/extensions/responsive_nums.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

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
          return Padding(
            padding:  EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
  verticalSpace(
                                  5
                                ),
                // Minimal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('chalet_gallery_title'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? ColorsManager.chaletTextPrimaryDark
                            : ColorsManager.chaletTextPrimaryLight,
                      ),
                    ),
                    Text(
                      '${images.length} ${context.tr('common_photos')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Clean Image List
                SizedBox(
                  height: 120, // Slightly smaller
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
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            // Simple subtle shadow if needed, or none
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                AppImageHelper(
                                  path: images[index],
                                  fit: BoxFit.cover,
                                ),
                                // Minimal gradient for text visibility if needed, or remove
                              ],
                            ),
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
