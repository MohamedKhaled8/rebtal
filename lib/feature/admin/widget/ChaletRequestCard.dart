import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/widgets/rating_display_widget.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:rebtal/feature/home/widget/public_chalet/chalet_image_carousel.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

import 'package:rebtal/feature/admin/widget/chalet_management_controls.dart';
import 'package:rebtal/feature/admin/widget/chalet_action_buttons.dart';

class ChaletRequestCard extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String docId;
  final String status;

  const ChaletRequestCard({
    super.key,
    required this.requestData,
    required this.docId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final chaletName =
        requestData['chaletName'] ?? context.tr('home_chalet_no_name');
    final location =
        requestData['location'] ?? context.tr('home_location_unknown');
    final rawImages = collectChaletImageUrls(requestData);
    final images = rawImages.isEmpty ? const [''] : rawImages;
    final isDark = DynamicThemeManager.isDarkMode(context);

    final price = requestData['price']?.toString() ?? '0';
    final bedrooms = requestData['bedrooms']?.toString() ?? '0';
    final bathrooms = requestData['bathrooms']?.toString() ?? '0';
    final chaletArea = requestData['chaletArea']?.toString() ?? '';

    final isVisible = requestData['isVisible'] ?? true;
    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';

    return Container(
      margin: EdgeInsets.only(bottom: 20.sh),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0F0D) : Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChaletDetailPage(
                requestData: requestData,
                docId: docId,
                status: status,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack (matches user/owner view)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.sp),
                  ),
                  child: ChaletImageCarousel(docId: docId, images: images),
                ),
                Positioned(
                  top: 20,
                  left: 5,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingDisplayWidget(
                        chaletId: docId,
                        isDark: false,
                        isBadge: true,
                      ),
                      // Add visibility state badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.sp,
                          vertical: 4.sp,
                        ),
                        decoration: BoxDecoration(
                          color: isVisible
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Text(
                          isVisible
                              ? (context.tr('common_show').isEmpty
                                    ? 'مرئي'
                                    : context.tr('common_show'))
                              : (context.tr('common_hidden').isEmpty
                                    ? 'مخفي'
                                    : context.tr('common_hidden')),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(12.sw),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chaletName,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      horizintalSpace(2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          horizintalSpace(1),
                          Text(
                            context.tr('booking_egp_currency').isEmpty
                                ? 'ج.م'
                                : context.tr('booking_egp_currency'),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  verticalSpace(0.5),

                  // Location Row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      horizintalSpace(1),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(1.5),

                  // Stats Row
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bed_outlined,
                            size: 14.sp,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                          horizintalSpace(1),
                          Text(
                            '$bedrooms ${context.tr('common_beds_short').isEmpty ? 'سرير' : context.tr('common_beds_short')}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      horizintalSpace(4),
                      Row(
                        children: [
                          Icon(
                            Icons.bathtub_outlined,
                            size: 14.sp,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                          horizintalSpace(1),
                          Text(
                            '$bathrooms ${context.tr('common_baths_short').isEmpty ? 'حمام' : context.tr('common_baths_short')}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (chaletArea.isNotEmpty) ...[
                        horizintalSpace(4),
                        Row(
                          children: [
                            Icon(
                              Icons.square_foot_outlined,
                              size: 14.sp,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                            horizintalSpace(1),
                            Text(
                              '$chaletArea ${context.tr('common_m2').isEmpty ? 'م²' : context.tr('common_m2')}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  verticalSpace(2),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                  ),
                  verticalSpace(2),

                  // Management Controls
                  ChaletManagementControls(
                    docId: docId,
                    isVisible: isVisible,
                    bookingAvailability: bookingAvailability,
                  ),
                  verticalSpace(1.5),

                  // Action Buttons
                  ChaletActionButtons(docId: docId, requestData: requestData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
