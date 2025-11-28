import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class NetworkImageHelper extends StatelessWidget {
  final String imageUrl;
  final double width;
  final BoxFit fit;
  final double height;

  const NetworkImageHelper({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.height = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          const Center(child: Icon(Icons.error, color: ColorManager.red)),
    );
  }
}
