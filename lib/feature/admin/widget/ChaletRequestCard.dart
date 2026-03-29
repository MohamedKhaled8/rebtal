// Chalet Request Card
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

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
    final chaletName = requestData['chaletName'] ?? 'Unnamed Chalet';
    final location = requestData['location'] ?? 'Unknown Location';
    final price = requestData['price']?.toString() ?? 'N/A';
    final bedrooms = requestData['bedrooms']?.toString() ?? 'N/A';
    final bathrooms = requestData['bathrooms']?.toString() ?? 'N/A';
    final chaletArea = requestData['chaletArea']?.toString() ?? '';
    final childrenCount = requestData['childrenCount']?.toString() ?? '';
    final isVisible = requestData['isVisible'] ?? true;
    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';

    // Owner information
    final ownerId = requestData['ownerId'] ?? '';
    final ownerName = requestData['ownerName'] ?? 'غير محدد';

    // Debug: Print data to verify
    print('📋 ChaletRequestCard - Data received:');
    print('   - ownerId: $ownerId');
    print('   - ownerName: $ownerName');
    print('   - bookingAvailability: $bookingAvailability');
    print('   - status: ${requestData['status']}');

    // final city = requestData['city'] ?? 'Unknown City';
    final image =
        (requestData['images'] is List && requestData['images'].isNotEmpty)
        ? requestData['images'][0]
        : (requestData['profileImage']);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChaletDetailPage(
            requestData: requestData,
            docId: docId,
            status: status,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 20.sp),
        padding: EdgeInsets.only(left: 5.sp, right: 5.sp),
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(15.sp),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== Image Section ======
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.sp),
                  child: AppImageHelper(path: image, fit: BoxFit.cover),
                ),

                // City Tag
                Positioned(
                  top: 2.h,
                  left: 2.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.kPrimaryGradient.colors.first,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 16,
                        ),
                        horizintalSpace(3),
                        Text(
                          location,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ====== Content Section ======
            Padding(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Name + Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chaletName,
                          style: TextStyle(
                            color: ColorsManager.black,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (requestData['discountEnabled'] == true &&
                          requestData['discountValue'] != null) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$$price',
                              style: TextStyle(
                                color: ColorsManager.gray,
                                fontSize: 13.sp,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: ColorsManager.red,
                              ),
                            ),
                            Text(
                              (() {
                                final p =
                                    double.tryParse(price.toString()) ?? 0;
                                final val =
                                    double.tryParse(
                                      requestData['discountValue'].toString(),
                                    ) ??
                                    0;
                                double finalPrice = p;
                                if (requestData['discountType'] ==
                                    'percentage') {
                                  finalPrice = p - (p * (val / 100));
                                } else {
                                  finalPrice = p - val;
                                }
                                return '\$${finalPrice.toStringAsFixed(0)} / ${context.tr('chalet_night')}';
                              })(),
                              style: TextStyle(
                                color:
                                    ColorsManager.kPrimaryGradient.colors.first,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          '\$$price / ${context.tr('chalet_night')}',
                          style: TextStyle(
                            color: ColorsManager.kPrimaryGradient.colors.first,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),

                  verticalSpace(.5),

                  // Location
                  Text(
                    location,
                    style: TextStyle(
                      color: ColorsManager.gray,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  verticalSpace(2),

                  // Owner Information
                  // Owner Information section removed as requested
                  if (ownerName.isNotEmpty && ownerName != 'غير محدد')
                    verticalSpace(2),

                  // Property Details
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bed, size: 18.sp, color: Colors.grey),
                            horizintalSpace(1),
                            Text(
                              '$bedrooms ${context.tr('common_beds_short')}',
                            ),
                          ],
                        ),
                        horizintalSpace(3),
                        Row(
                          children: [
                            Icon(
                              Icons.bathtub_outlined,
                              size: 18.sp,
                              color: Colors.grey,
                            ),
                            horizintalSpace(1),
                            Text(
                              '$bathrooms ${context.tr('common_baths_short')}',
                            ),
                          ],
                        ),
                        if (childrenCount.isNotEmpty) ...[
                          horizintalSpace(3),
                          Row(
                            children: [
                              Icon(
                                Icons.child_care_rounded,
                                size: 18.sp,
                                color: Colors.grey,
                              ),
                              horizintalSpace(1),
                              Text(
                                '$childrenCount ${context.tr('booking_children')}',
                              ),
                            ],
                          ),
                        ],
                        if (chaletArea.isNotEmpty) ...[
                          horizintalSpace(3),
                          Row(
                            children: [
                              Icon(
                                Icons.square_foot_rounded,
                                size: 18.sp,
                                color: Colors.grey,
                              ),
                              horizintalSpace(1),
                              Text(
                                '$chaletArea ${context.tr('common_m2')}',
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  verticalSpace(2),

                  // Management Controls
                  Row(
                    children: [
                      // Visibility Toggle
                      Expanded(
                        child: _buildToggleButton(
                          context,
                          icon: isVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          label: isVisible
                              ? context.tr('common_hidden')
                              : context.tr('common_show'),
                          color: isVisible ? Colors.orange : Colors.green,
                          onPressed: () => _toggleVisibility(context),
                        ),
                      ),
                      horizintalSpace(2),

                      // Booking Availability Toggle
                      Expanded(
                        child: _buildToggleButton(
                          context,
                          icon: bookingAvailability == 'available'
                              ? Icons.lock_outline
                              : Icons.lock_open,
                          label: bookingAvailability == 'available'
                              ? context.tr('owner_stop_booking')
                              : context.tr('owner_start_booking'),
                          color: bookingAvailability == 'available'
                              ? Colors.red
                              : Colors.green,
                          onPressed: () => _toggleBookingAvailability(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16.sp, color: color),
                horizintalSpace(1),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleVisibility(BuildContext context) async {
    try {
      final newVisibility = !(requestData['isVisible'] ?? true);

      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'isVisible': newVisibility,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        if (newVisibility) {
          SnackBarHelper.showSuccess(
            context,
            context.tr('admin_show_chalet_success'),
          );
        } else {
          SnackBarHelper.showWarning(
            context,
            context.tr('admin_hide_chalet_success'),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(
          context,
          '${context.tr('common_error')}: $e',
        );
      }
    }
  }

  void _toggleBookingAvailability(BuildContext context) async {
    try {
      final currentAvailability =
          requestData['bookingAvailability'] ?? 'available';
      final newAvailability = currentAvailability == 'available'
          ? 'unavailable'
          : 'available';

      await FirebaseFirestore.instance.collection('chalets').doc(docId).update({
        'bookingAvailability': newAvailability,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        if (newAvailability == 'available') {
          SnackBarHelper.showSuccess(
            context,
            context.tr('admin_booking_started_success'),
          );
        } else {
          SnackBarHelper.showSuccess(
            context,
            context.tr('admin_booking_stopped_success'),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(
          context,
          '${context.tr('common_error')}: $e',
        );
      }
    }
  }
}
