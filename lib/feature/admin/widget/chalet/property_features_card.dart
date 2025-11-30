import 'package:flutter/material.dart';

class PropertyFeaturesCard extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const PropertyFeaturesCard({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final bedrooms = requestData['bedrooms']?.toString() ?? 'N/A';
    final bathrooms = requestData['bathrooms']?.toString() ?? 'N/A';
    final chaletArea = requestData['chaletArea']?.toString();
    final childrenCount = requestData['childrenCount']?.toString();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Property Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              FeatureItem(
                icon: Icons.bed_rounded,
                color: const Color(0xFF3B82F6),
                value: bedrooms,
                label: 'Bedrooms',
              ),
              FeatureItem(
                icon: Icons.bathtub_rounded,
                color: const Color(0xFF8B5CF6),
                value: bathrooms,
                label: 'Bathrooms',
              ),
              if (chaletArea != null && chaletArea.isNotEmpty)
                FeatureItem(
                  icon: Icons.square_foot_rounded,
                  color: const Color(0xFFF59E0B),
                  value: '$chaletArea m²',
                  label: 'Area',
                ),
              if (childrenCount != null)
                FeatureItem(
                  icon: Icons.child_care_rounded,
                  color: const Color(0xFFEC4899),
                  value: childrenCount,
                  label: 'Children',
                ),
            ],
          ),

          // Features Section
          if (requestData['features'] != null &&
              (requestData['features'] as List).isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 24),
            const Text(
              'Additional Features',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: (requestData['features'] as List)
                  .map(
                    (feature) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            feature.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
