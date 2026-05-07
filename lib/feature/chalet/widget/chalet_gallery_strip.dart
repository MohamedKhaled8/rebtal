import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class ChaletGalleryStrip extends StatelessWidget {
  final List<String> images;
  final bool isDark;
  final String cacheScope;

  const ChaletGalleryStrip({
    super.key,
    required this.images,
    required this.isDark,
    required this.cacheScope,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: otv(
        context: context,
        portrait: stv(
          context: context,
          mobile: 130.sh,
          tablet: 100.sh,
          desktop: 80.sh,
        ),
        landscape: stv(
          context: context,
          mobile: 300.sh,
          tablet: 265.sh,
          desktop: 270.sh,
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: images.length,
        separatorBuilder: (_, __) => SizedBox(
          width: stv(
            context: context,
            mobile: 10.sw,
            tablet: 16.sw,
            desktop: 20.sw,
          ),
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              context.read<ChaletDetailCubit>().openFullScreen(
                    context,
                    images: images,
                    start: index,
                  );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                stv(
                  context: context,
                  mobile: 12.sp,
                  tablet: 16.sp,
                  desktop: 20.sp,
                ),
              ),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: AppImageHelper(
                  path: images[index],
                  fit: BoxFit.cover,
                  cacheScope: cacheScope,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

