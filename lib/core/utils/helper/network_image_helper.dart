import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

  /// e.g. Firestore `docId` — keeps CachedNetworkImage identity unique per chalet
  /// so the same URL on two listings cannot briefly show the wrong bitmap.
  final String? cacheScope;

  const NetworkImageHelper({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.height = 200.0,
    this.placeholder,
    this.errorWidget,
    this.cacheScope,
  });

  @override
  Widget build(BuildContext context) {
    final scope = cacheScope ?? '';
    return CachedNetworkImage(
      key: ValueKey('$scope|$imageUrl'),
      imageUrl: imageUrl,
      cacheManager: _SharedImageCacheManager.instance,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      // In fast-scrolling lists and live-updating streams, keeping the old image
      // can cause incorrect images to appear for other list items.
      useOldImageOnUrlChange: false,
      filterQuality: FilterQuality.low,
      placeholder: (context, url) =>
          placeholder ??
          const ColoredBox(color: Colors.transparent),
      errorWidget: (context, url, error) {
        if (kDebugMode) {
          debugPrint('❌ Image failed to load: $url | error=$error');
        }
        return errorWidget ??
            const Center(child: Icon(Icons.error, color: ColorsManager.red));
      },
    );
  }
}
