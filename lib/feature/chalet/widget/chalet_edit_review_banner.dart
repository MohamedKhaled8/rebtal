import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/owner/utils/chalet_edit_review_helper.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class ChaletEditReviewBanner extends StatelessWidget {
  final Map<String, dynamic> rootData;

  const ChaletEditReviewBanner({super.key, required this.rootData});

  String _fieldLabel(BuildContext context, String key) {
    final trKey = 'admin_edit_field_$key';
    final translated = context.tr(trKey);
    if (translated.isNotEmpty && translated != trKey) return translated;
    return key;
  }

  @override
  Widget build(BuildContext context) {
    if (!ChaletEditReviewHelper.isEditReviewPending(rootData)) {
      return const SizedBox.shrink();
    }

    final isDark = DynamicThemeManager.isDarkMode(context);
    final changes = ChaletEditReviewHelper.listPendingFieldChanges(rootData);
    final ownerName =
        rootData['merchantName']?.toString() ??
        rootData['ownerName']?.toString() ??
        '';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.sh),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1B4B).withValues(alpha: 0.85)
            : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(
          color: isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5),
                size: 24.sp,
              ),
              SizedBox(width: 8.sw),
              Expanded(
                child: Text(
                  context.tr('admin_edit_review_title'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF312E81),
                  ),
                ),
              ),
            ],
          ),
          if (ownerName.isNotEmpty) ...[
            SizedBox(height: 6.sh),
            Text(
              '${context.tr('admin_chalet_edit_owner_hint')} $ownerName',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.white70 : const Color(0xFF4338CA),
              ),
            ),
          ],
          SizedBox(height: 12.sh),
          Text(
            context.tr('admin_edit_review_subtitle'),
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : const Color(0xFF4338CA),
            ),
          ),
          SizedBox(height: 12.sh),
          if (changes.isEmpty)
            Text(
              context.tr('admin_edit_review_no_diff'),
              style: TextStyle(
                fontSize: 13.sp,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            )
          else
            ...changes.map((c) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.sh),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fieldLabel(context, c.fieldKey),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                      ),
                    ),
                    SizedBox(height: 4.sh),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ValueChip(
                            label: context.tr('admin_edit_before'),
                            value: c.before,
                            isDark: isDark,
                            tone: _ChipTone.old,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.sw),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16.sp,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: _ValueChip(
                            label: context.tr('admin_edit_after'),
                            value: c.after,
                            isDark: isDark,
                            tone: _ChipTone.newValue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          if (changes.any((c) => c.fieldKey == 'images')) ...[
            SizedBox(height: 8.sh),
            Text(
              context.tr('admin_edit_new_images_preview'),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF4338CA),
              ),
            ),
            SizedBox(height: 8.sh),
            SizedBox(
              height: 72.sh,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ChaletEditReviewHelper.pendingNewImageUrls(rootData)
                    .length,
                separatorBuilder: (_, __) => SizedBox(width: 8.sw),
                itemBuilder: (context, index) {
                  final url = ChaletEditReviewHelper.pendingNewImageUrls(
                    rootData,
                  )[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.sp),
                    child: AppImageHelper(
                      path: url,
                      width: 72.sw,
                      height: 72.sh,
                      fit: BoxFit.cover,
                      cacheScope: rootData['id']?.toString() ?? 'edit',
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _ChipTone { old, newValue }

class _ValueChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final _ChipTone tone;

  const _ValueChip({
    required this.label,
    required this.value,
    required this.isDark,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final bg = tone == _ChipTone.newValue
        ? (isDark
              ? const Color(0xFF064E3B).withValues(alpha: 0.5)
              : const Color(0xFFD1FAE5))
        : (isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 2.sh),
          Text(
            value,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
