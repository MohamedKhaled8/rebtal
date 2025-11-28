import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:rebtal/core/utils/constant/image_assets_manger.dart';
import 'package:rebtal/core/utils/helper/network_image_helper.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class AppImageHelper extends StatelessWidget {
  final String path;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Color? color;

  const AppImageHelper({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit = BoxFit.scaleDown,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final imageType = _getImageType(path);

    switch (imageType) {
      case ImageType.svg:
        return SvgPicture.asset(
          path,
          height: height,
          width: width,
          fit: fit,
          // ignore: deprecated_member_use
          color: color,
        );
      case ImageType.network:
        return NetworkImageHelper(
          imageUrl: path,
          height: height ?? 200.0,
          width: width ?? double.infinity,
          fit: fit,
        );
      case ImageType.lottie:
        return Lottie.asset(
          path,
          height: height,
          width: width,
          fit: fit,
        );
      case ImageType.asset:
        return Image.asset(
          path,
          height: height,
          width: width,
          fit: fit,
          color: color,
        );
      case ImageType.errorImage:
        return Image.asset(
          ImageAssetsManger.errorImage,
          height: height,
          width: width,
          fit: fit,
          color: color,
        );
      }
  }

  ImageType _getImageType(String path) {
    if (path.isNotEmpty) {
      if (path.endsWith("svg")) {
        return ImageType.svg;
      } else if (path.startsWith("http")) {
        return ImageType.network;
      } else if (path.endsWith("json")) {
        return ImageType.lottie;
      } else {
        return ImageType.asset;
      }
    } else {
      return ImageType.errorImage;
    }
  }
}

enum ImageType {
  svg,
  network,
  lottie,
  asset,
  errorImage,
}
