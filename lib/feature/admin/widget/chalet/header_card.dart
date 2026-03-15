import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/extensions/responsive_nums.dart';
// import 'package:responsive_screen_master/responsive_screen_master.dart';

class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key, required this.requestData});
  final Map<String, dynamic> requestData;

  @override
  Widget build(BuildContext context) {
    final hotelName = requestData['chaletName'] ?? 'Hotel Name';
    final location = requestData['location'] ?? 'Unknown Location';

    final price = requestData['price'];
    final rating =
        ((requestData['rating'] ?? requestData['avgRating'])?.toString()) ??
        '0.0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotelName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 0.1,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey[600],
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Flexible(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (requestData['discountEnabled'] == true &&
                      requestData['discountValue'] != null) ...[
                    Text(
                      CurrencyFormatter.egp(
                        context,
                        (price is num)
                            ? price
                            : double.tryParse((price ?? '').toString()) ?? 0,
                        withSuffixPerNight: true,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _calculateDiscountedPrice(context, requestData),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ] else
                    Text(
                      CurrencyFormatter.egp(
                        context,
                        (price is num)
                            ? price
                            : double.tryParse((price ?? '').toString()) ?? 0,
                        withSuffixPerNight: true,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),

                  const SizedBox.shrink(),
                ],
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Rating and Quick Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 2.w),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5.w),
              if (requestData['hasWifi'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi, color: Colors.blue, size: 16),
                      SizedBox(width: 2.w),
                      const Text(
                        'Free WiFi',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(width: 5.w),
              if (requestData['hasBreakfast'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.free_breakfast,
                        color: Colors.orange,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      const Text(
                        'Breakfast',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateDiscountedPrice(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final basePrice = (data['price'] is num)
        ? data['price'].toDouble()
        : double.tryParse((data['price'] ?? '').toString()) ?? 0.0;
    final discountType = data['discountType'];
    final discountValue = double.tryParse(data['discountValue'] ?? '0') ?? 0.0;

    double finalPrice = basePrice;
    if (discountType == 'percentage' && discountValue > 0) {
      finalPrice = basePrice * (1 - discountValue / 100);
    } else if (discountType == 'fixed' && discountValue > 0) {
      finalPrice = basePrice - discountValue;
      if (finalPrice < 0) finalPrice = 0;
    }

    return CurrencyFormatter.egp(context, finalPrice, withSuffixPerNight: true);
  }
}
