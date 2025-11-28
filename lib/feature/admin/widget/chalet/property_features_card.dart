import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/config/space.dart';
// import 'package:screen_go/extensions/responsive_nums.dart';

class PropertyFeaturesCard extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const PropertyFeaturesCard({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final bedrooms = requestData['bedrooms']?.toString() ?? 'N/A';
    final bathrooms = requestData['bathrooms']?.toString() ?? 'N/A';
    final price = requestData['price']?.toString() ?? 'N/A';
    final chaletArea = requestData['chaletArea']?.toString();
    final childrenCount = requestData['childrenCount']?.toString();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Features',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          verticalSpace(3),
          Row(
            children: [
              Expanded(
                child: FeatureItem(
                  icon: Icons.bed_outlined,
                  color: const Color(0xFF3B82F6),
                  value: bedrooms,
                  label: 'Bedrooms',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FeatureItem(
                  icon: Icons.bathtub_outlined,
                  color: const Color(0xFF8B5CF6),
                  value: bathrooms,
                  label: 'Bathrooms',
                ),
              ),
              const SizedBox(width: 12),
              if (childrenCount != null)
                Expanded(
                  child: FeatureItem(
                    icon: Icons.child_care_rounded,
                    color: const Color(0xFFEC4899),
                    value: childrenCount,
                    label: 'Children',
                  ),
                )
              else
                Expanded(
                  child: FeatureItem(
                    icon: Icons.attach_money,
                    color: const Color(0xFF10B981),
                    value: price,
                    label: 'Per Night',
                  ),
                ),
            ],
          ),
          if (chaletArea != null && chaletArea.isNotEmpty) ...[
            verticalSpace(2),
            Row(
              children: [
                Expanded(
                  child: FeatureItem(
                    icon: Icons.square_foot_rounded,
                    color: const Color(0xFFF59E0B),
                    value: '$chaletArea m²',
                    label: 'Area',
                  ),
                ),
                const Spacer(), // Balance the row if needed
              ],
            ),
          ],
          // Features Section
          if (requestData['features'] != null &&
              (requestData['features'] as List).isNotEmpty) ...[
            verticalSpace(3),
            const Divider(),
            verticalSpace(3),
            Text(
              'Features',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            verticalSpace(2),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (requestData['features'] as List)
                  .map(
                    (feature) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            feature.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          verticalSpace(2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
