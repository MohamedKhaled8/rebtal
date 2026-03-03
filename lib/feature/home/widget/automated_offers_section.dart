import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class AutomatedOffersSection extends StatelessWidget {
  const AutomatedOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chalets')
          .where('status', isEqualTo: 'approved')
          .where('discountEnabled', isEqualTo: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('home_exclusive_offers'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '${docs.length} ${context.tr('home_offers_available')}',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;

                  // Logic to calculate discount percentage
                  final price = (data['price'] as num?)?.toDouble() ?? 0.0;
                  final discountValue =
                      double.tryParse(data['discountValue'].toString()) ?? 0.0;
                  final discountType = data['discountType'] ?? 'amount';

                  double discountedPrice = price;
                  int percentage = 0;

                  if (discountType == 'percentage') {
                    percentage = discountValue.toInt();
                    discountedPrice = price - (price * (discountValue / 100));
                  } else {
                    if (price > 0) {
                      percentage = ((discountValue / price) * 100).round();
                    }
                    discountedPrice = price - discountValue;
                  }

                  final images = data['images'] as List<dynamic>?;
                  final imageUrl = (images != null && images.isNotEmpty)
                      ? images[0]
                      : data['profileImage'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChaletDetailPage(
                            requestData: data,
                            docId: docId,
                            status: 'approved',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16, bottom: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF111111) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Full Background Image
                            AppImageHelper(
                              path: imageUrl,
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),

                            // Gradient Overlay for Text Readability
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.2),
                                      Colors.black.withOpacity(0.8),
                                    ],
                                    stops: const [0.5, 0.7, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            // Discount Badge (Chic Glassmorphism Style)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_offer_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${context.tr('common_discount')} $percentage%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Text Info Overlay
                            Positioned(
                              bottom: 16,
                              right: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    data['chaletName'] ??
                                        context.tr('home_featured_chalet'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '${discountedPrice.round()} ${context.tr('booking_egp_currency')}',
                                        style: const TextStyle(
                                          color: Color(
                                            0xFF4ADE80,
                                          ), // Light green for visibility
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black45,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${price.round()} ${context.tr('booking_egp_currency')}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 13,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: Colors.white70,
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
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
