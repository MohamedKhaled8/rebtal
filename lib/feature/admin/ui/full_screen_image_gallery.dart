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
            body: GestureDetector(
              onTap: () => cubit.toggleAppBar(),
              child: PageView.builder(
                controller: cubit.galleryController,
                itemCount: images.length,
                onPageChanged: (i) => cubit.changeImageIndex(i),
                itemBuilder: (context, i) => InteractiveViewer(
                  child: Center(
                    child: AppImageHelper(
                      height: double.infinity,
                      path: images[i],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
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
