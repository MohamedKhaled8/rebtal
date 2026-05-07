import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:rebtal/core/utils/helper/network_image_helper.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class AppImageHelper extends StatelessWidget {
  final String path;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Color? color;
  final Widget? placeholder;
  final Widget? errorWidget;

  /// Pass Firestore doc id (or similar) for network images so list/detail cards
  /// never reuse another chalet's decoded image for the same URL slot.
  final String? cacheScope;

  const AppImageHelper({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit = BoxFit.scaleDown,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.cacheScope,
  });

  @override
  Widget build(BuildContext context) {
    var path = this.path.trim();
    if (path.startsWith('//')) {
      path = 'https:$path';
    }
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
          placeholder: placeholder,
          errorWidget: errorWidget,
          cacheScope: cacheScope,
        );
      case ImageType.lottie:
        return Lottie.asset(path, height: height, width: width, fit: fit);
      case ImageType.asset:
        return Image.asset(
          path,
          height: height,
          width: width,
          fit: fit,
          color: color,
        );
      case ImageType.errorImage:
        // Avoid a missing asset (e.g. error_image.jpg); use an in-app placeholder.
        return SizedBox(
          height: height,
          width: width,
          child: ColoredBox(
            color: const Color(0xFFE8E8E8),
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: color ?? const Color(0xFF9E9E9E),
              ),
            ),
          ),
        );
    }
  }

  ImageType _getImageType(String path) {
    if (path.isEmpty) return ImageType.errorImage;

    final uri = Uri.tryParse(path);
    if (uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      return ImageType.network;
    }

    if (path.endsWith("svg")) {
      return ImageType.svg;
    }
    if (path.endsWith("json")) {
      return ImageType.lottie;
    }
    return ImageType.asset;
  }
}

enum ImageType { svg, network, lottie, asset, errorImage }

/// Collects image URLs from Firestore chalet documents (handles nulls, maps,
/// protocol-relative URLs, and common alternate field names).
List<String> collectChaletImageUrls(Map<String, dynamic> data) {
  final out = <String>[];
  final seen = <String>{};

  void addOne(String? raw) {
    if (raw == null) return;
    var s = raw.trim();
    if (s.isEmpty || s == 'null') return;
    if (s.startsWith('//')) s = 'https:$s';
    if (seen.add(s)) out.add(s);
  }

  void addDynamic(dynamic v) {
    if (v == null) return;
    if (v is Map) {
      final m = Map<String, dynamic>.from(v);
      addOne(
        (m['secure_url'] ??
                m['url'] ??
                m['imageUrl'] ??
                m['src'] ??
                m['thumbnail'])
            ?.toString(),
      );
      return;
    }
    addOne(v.toString());
  }

  final imgs = data['images'];
  if (imgs is String) {
    addDynamic(imgs);
  } else if (imgs is List) {
    for (final e in imgs) {
      addDynamic(e);
    }
  }
  addDynamic(data['image']);
  addDynamic(data['imageUrl']);
  addDynamic(data['thumbnail']);
  addDynamic(data['cover']);
  addDynamic(data['photo']);
  addDynamic(data['profileImage']);

  return out;
}

/// First usable cover URL for list cards and headers.
String resolveChaletCoverImageUrl(Map<String, dynamic> data) {
  final urls = collectChaletImageUrls(data);
  return urls.isEmpty ? '' : urls.first;
}
