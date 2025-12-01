// Chalet Request Card
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

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
    final isVisible = requestData['isVisible'] ?? true;
    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';
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
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(15.sp),
          boxShadow: [
            BoxShadow(
              color: ColorManager.black.withOpacity(0.1),
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
                      color: ColorManager.kPrimaryGradient.colors.first,
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
                            color: ColorManager.black,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$$price / Night',
                        style: TextStyle(
                          color: ColorManager.kPrimaryGradient.colors.first,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  verticalSpace(.5),

                  // Location
                  Text(
                    location,
                    style: TextStyle(
                      color: ColorManager.gray,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  verticalSpace(2),

                  // Property Details
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bed, size: 18.sp, color: Colors.grey),
                          horizintalSpace(1),
                          Text('$bedrooms Beds'),
                        ],
                      ),
                      horizintalSpace(5),
                      Row(
                        children: [
                          Icon(
                            Icons.bathtub_outlined,
                            size: 18.sp,
                            color: Colors.grey,
                          ),
                          horizintalSpace(1),
                          Text('$bathrooms Baths'),
                        ],
                      ),
                      horizintalSpace(5),
                      Row(
                        children: [
                          Icon(
                            Icons.price_change_outlined,
                            size: 18.sp,
                            color: Colors.grey,
                          ),

                          Text('$price price'),
                        ],
                      ),
                    ],
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
                          label: isVisible ? 'مخفي' : 'إظهار',
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
                              ? 'إيقاف الحجز'
                              : 'تشغيل الحجز',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newVisibility
                  ? 'تم إظهار الشاليه بنجاح'
                  : 'تم إخفاء الشاليه بنجاح',
            ),
            backgroundColor: newVisibility ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث حالة الشاليه: $e'),
            backgroundColor: Colors.red,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newAvailability == 'available'
                  ? 'تم تشغيل الحجز بنجاح'
                  : 'تم إيقاف الحجز بنجاح',
            ),
            backgroundColor: newAvailability == 'available'
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث حالة الحجز: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
