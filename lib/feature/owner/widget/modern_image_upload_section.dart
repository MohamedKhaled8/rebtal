import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class ModernImageUploadSection extends StatelessWidget {
  final List<File> images;
  final List<String> networkImageUrls;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<int>? onRemoveNetwork;

  const ModernImageUploadSection({
    super.key,
    required this.images,
    this.networkImageUrls = const [],
    required this.onAdd,
    required this.onRemove,
    this.onRemoveNetwork,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ColorsManager.grey800.withOpacity(0.3)
              : ColorsManager.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? ColorsManager.black.withOpacity(0.3)
                : ColorsManager.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ColorsManager.purple764BA2,
                      ColorsManager.blue2563EB,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: ColorsManager.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('owner_chalet_photos'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? ColorsManager.white
                            : ColorsManager.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('owner_add_3_photos_hint'),
                      style: TextStyle(
                        color: isDark
                            ? ColorsManager.grey400
                            : ColorsManager.grey600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (images.isNotEmpty || networkImageUrls.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorsManager.mainBlue.withOpacity(0.2),
                        ColorsManager.cyan06B6D4.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ColorsManager.mainBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: ColorsManager.mainBlue,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${networkImageUrls.length + images.length}',
                        style: const TextStyle(
                          color: ColorsManager.mainBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Images Grid (existing URLs + new files)
          if (images.isNotEmpty || networkImageUrls.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: networkImageUrls.length + images.length,
              itemBuilder: (context, index) {
                final n = networkImageUrls.length;
                if (index < n) {
                  return _NetworkImageCard(
                    url: networkImageUrls[index],
                    index: index,
                    onRemove: onRemoveNetwork != null
                        ? () => onRemoveNetwork!(index)
                        : null,
                    isDark: isDark,
                    isFirst: index == 0,
                  );
                }
                final fi = index - n;
                return _ImageCard(
                  image: images[fi],
                  index: fi,
                  onRemove: () => onRemove(fi),
                  isDark: isDark,
                  isFirst: index == 0,
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Add Button
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
                    : ColorsManager.grey50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? ColorsManager.blue2563EB.withOpacity(0.3)
                      : ColorsManager.blue2563EB.withOpacity(0.2),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorsManager.blue2563EB.withOpacity(0.2),
                          ColorsManager.purple764BA2.withOpacity(0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      color: ColorsManager.blue2563EB,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (images.isEmpty && networkImageUrls.isEmpty)
                        ? context.tr('owner_add_first_photo')
                        : context.tr('owner_add_more_photos'),
                    style: TextStyle(
                      color: isDark ? ColorsManager.white : ColorsManager.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('owner_tap_to_select'),
                    style: TextStyle(
                      color: isDark
                          ? ColorsManager.grey400
                          : ColorsManager.grey600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkImageCard extends StatelessWidget {
  final String url;
  final int index;
  final VoidCallback? onRemove;
  final bool isDark;
  final bool isFirst;

  const _NetworkImageCard({
    required this.url,
    required this.index,
    required this.onRemove,
    required this.isDark,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFirst
                  ? ColorsManager.blue2563EB
                  : (isDark ? ColorsManager.grey800 : ColorsManager.grey300),
              width: isFirst ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isFirst
                    ? ColorsManager.blue2563EB.withOpacity(0.3)
                    : ColorsManager.black.withOpacity(0.1),
                blurRadius: isFirst ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => Container(
                color: isDark
                    ? ColorsManager.grey800
                    : ColorsManager.grey200,
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: ColorsManager.grey700,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
        if (isFirst)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    ColorsManager.blue2563EB,
                    ColorsManager.purple764BA2,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.black.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: ColorsManager.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('owner_image_cover'),
                    style: const TextStyle(
                      color: ColorsManager.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (onRemove != null)
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ColorsManager.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: ColorsManager.white,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  final File image;
  final int index;
  final VoidCallback onRemove;
  final bool isDark;
  final bool isFirst;

  const _ImageCard({
    required this.image,
    required this.index,
    required this.onRemove,
    required this.isDark,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image Container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFirst
                  ? ColorsManager.blue2563EB
                  : (isDark ? ColorsManager.grey800 : ColorsManager.grey300),
              width: isFirst ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isFirst
                    ? ColorsManager.blue2563EB.withOpacity(0.3)
                    : ColorsManager.black.withOpacity(0.1),
                blurRadius: isFirst ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

        // Cover Badge (for first image)
        if (isFirst)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    ColorsManager.blue2563EB,
                    ColorsManager.purple764BA2,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.black.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: ColorsManager.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('owner_image_cover'),
                    style: const TextStyle(
                      color: ColorsManager.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Remove Button
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ColorsManager.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.black.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: ColorsManager.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
