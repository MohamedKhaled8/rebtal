import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

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
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        debugPrint('❌ Image failed to load: $url');
        return errorWidget ??
            const Center(child: Icon(Icons.error, color: ColorManager.red));
      },
    );
  }
}
