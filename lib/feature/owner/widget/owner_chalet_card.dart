import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class OwnerChaletCard extends StatelessWidget {
  final Map<String, dynamic> chaletData;
  final String docId;

  const OwnerChaletCard({
    super.key,
    required this.chaletData,
    required this.docId,
  });

  List<String> _collectChaletImages(Map<String, dynamic> data) {
    final List<dynamic>? imgs = data['images'] as List<dynamic>?;
    final List<String> result = [];

    final String? profile = data['profileImage']?.toString();
    if (profile != null && profile.isNotEmpty) {
      result.add(profile);
    }

    if (imgs != null) {
      for (final e in imgs) {
        if (e == null) continue;
        final s = e.toString();
        if (s.isNotEmpty && s != profile) {
          result.add(s);
        }
        if (result.length >= 5) break;
      }
    }

    if (result.isEmpty) {
      result.add('https://via.placeholder.com/400x300?text=No+Image');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final chaletName = chaletData['chaletName'] ?? 'شاليه بدون اسم';
    final location = chaletData['location'] ?? 'الموقع غير محدد';
    final price = chaletData['price'];
    final images = _collectChaletImages(chaletData);
    final status = chaletData['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: AppImageHelper(path: images.first, fit: BoxFit.cover),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        chaletName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'approved'
                            ? ColorManager.green.withOpacity(0.1)
                            : status == 'rejected'
                            ? ColorManager.red.withOpacity(0.1)
                            : ColorManager.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status == 'approved'
                            ? 'موافق عليه'
                            : status == 'rejected'
                            ? 'مرفوض'
                            : 'قيد المراجعة',
                        style: TextStyle(
                          color: status == 'approved'
                              ? ColorManager.green
                              : status == 'rejected'
                              ? ColorManager.red
                              : ColorManager.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: ColorManager.grey600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: ColorManager.grey600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Features
                if (chaletData['features'] != null &&
                    (chaletData['features'] as List).isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (chaletData['features'] as List)
                        .take(3)
                        .map(
                          (feature) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorManager.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              feature.toString(),
                              style: TextStyle(
                                color: ColorManager.purple,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                // Children Count
                if (chaletData['childrenCount'] != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.child_care_rounded,
                        size: 14,
                        color: ColorManager.grey600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Children: ${chaletData['childrenCount']}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (chaletData['discountEnabled'] == true &&
                            chaletData['discountValue'] != null) ...[
                          Text(
                            CurrencyFormatter.egp(
                              (price is num)
                                  ? price
                                  : double.tryParse(
                                          (price ?? '').toString().replaceAll(
                                            RegExp('[^0-9.]'),
                                            '',
                                          ),
                                        ) ??
                                        0,
                              withSuffixPerNight: false,
                            ),
                            style: TextStyle(
                              color: ColorManager.grey400,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _calculateDiscountedPrice(chaletData),
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else
                          Text(
                            CurrencyFormatter.egp(
                              (price is num)
                                  ? price
                                  : double.tryParse(
                                          (price ?? '').toString().replaceAll(
                                            RegExp('[^0-9.]'),
                                            '',
                                          ),
                                        ) ??
                                        0,
                              withSuffixPerNight: false,
                            ),
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChaletDetailPage(
                              requestData: chaletData,
                              docId: docId,
                              status: status,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.purple,
                        foregroundColor: ColorManager.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('التفاصيل'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDiscountedPrice(Map<String, dynamic> data) {
    final basePrice = (data['price'] is num)
        ? data['price'].toDouble()
        : double.tryParse(
                (data['price'] ?? '').toString().replaceAll(
                  RegExp('[^0-9.]'),
                  '',
                ),
              ) ??
              0.0;
    final discountType = data['discountType'];
    final discountValue = double.tryParse(data['discountValue'] ?? '0') ?? 0.0;

    double finalPrice = basePrice;
    if (discountType == 'percentage' && discountValue > 0) {
      finalPrice = basePrice * (1 - discountValue / 100);
    } else if (discountType == 'fixed' && discountValue > 0) {
      finalPrice = basePrice - discountValue;
      if (finalPrice < 0) finalPrice = 0;
    }

    return CurrencyFormatter.egp(finalPrice, withSuffixPerNight: false);
  }
}
