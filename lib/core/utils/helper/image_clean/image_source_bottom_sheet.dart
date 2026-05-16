import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  final bool isChaletPhoto;
  final bool isDark;

  const ImageSourceBottomSheet({
    super.key,
    required this.isChaletPhoto,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.darkBackground0A0E27.withOpacity(0.95)
            : ColorsManager.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorsManager.blue2563EB.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isChaletPhoto
                        ? Icons.collections_rounded
                        : Icons.account_circle_rounded,
                    color: ColorsManager.blue2563EB,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChaletPhoto
                            ? context.tr('owner_add_chalet_images')
                            : context.tr('profile_change_photo'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        context.tr('common_select_source'),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _ImageSourceOption(
              onTap: () => Navigator.pop(context, ImageSource.camera),
              icon: Icons.camera_enhance_rounded,
              title: context.tr('auth_camera'),
              subtitle: isChaletPhoto
                  ? context.tr('owner_capture_single_photo')
                  : context.tr('profile_capture_new_photo'),
              gradient: const LinearGradient(
                colors: [ColorsManager.blue2563EB, ColorsManager.purple764BA2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _ImageSourceOption(
              onTap: () => Navigator.pop(context, ImageSource.gallery),
              icon: Icons.photo_library_rounded,
              title: context.tr('auth_gallery'),
              subtitle: isChaletPhoto
                  ? context.tr('owner_select_multiple_photos')
                  : context.tr('profile_select_from_gallery'),
              gradient: const LinearGradient(
                colors: [
                  ColorsManager.purple764BA2,
                  ColorsManager.bookingsAccentPrimary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white12
                        : Colors.black.withOpacity(0.08),
                  ),
                ),
              ),
              child: Text(
                context.tr('common_cancel'),
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final bool isDark;

  const _ImageSourceOption({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: isDark ? ColorsManager.darkSurface1E1E1E : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
