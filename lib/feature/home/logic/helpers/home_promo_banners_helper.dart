import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class HomePromoBannerItem {
  const HomePromoBannerItem({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String tag;
  final String imageUrl;
}

class HomePromoBannersHelper {
  static List<HomePromoBannerItem> resolveBanners(BuildContext context) {
    return [
      HomePromoBannerItem(
        title: context.tr('home_banner_title_1'),
        subtitle: context.tr('home_banner_subtitle_1'),
        tag: context.tr('home_banner_tag_1'),
        imageUrl:
            'https://images.unsplash.com/photo-1540518614846-7eded433c457?q=80&w=600&auto=format&fit=crop',
      ),
      HomePromoBannerItem(
        title: context.tr('home_banner_title_2'),
        subtitle: context.tr('home_banner_subtitle_2'),
        tag: context.tr('home_banner_tag_2'),
        imageUrl:
            'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?q=80&w=600&auto=format&fit=crop',
      ),
      HomePromoBannerItem(
        title: context.tr('home_banner_title_3'),
        subtitle: context.tr('home_banner_subtitle_3'),
        tag: context.tr('home_banner_tag_3'),
        imageUrl:
            'https://images.unsplash.com/photo-1510074377623-8cf13fb86c08?q=80&w=600&auto=format&fit=crop',
      ),
    ];
  }
}
