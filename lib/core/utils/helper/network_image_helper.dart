import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class _SharedImageCacheManager {
  static final BaseCacheManager instance = CacheManager(
    Config(
      'rebtalSharedImageCache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 500,
    ),
  );
}

class NetworkImageHelper extends StatelessWidget {
  final String imageUrl;
  final double width;
  final BoxFit fit;
  final double height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageHelper({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.height = 200.0,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: _SharedImageCacheManager.instance,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      useOldImageOnUrlChange: true,
      filterQuality: FilterQuality.low,
      placeholder: (context, url) =>
          placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        debugPrint('❌ Image failed to load: $url');
        return errorWidget ??
            const Center(child: Icon(Icons.error, color: ColorsManager.red));
      },
    );
  }
}
