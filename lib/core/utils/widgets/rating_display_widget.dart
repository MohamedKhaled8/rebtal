import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class RatingDisplayWidget extends StatelessWidget {
  final String chaletId;
  final bool isDark;
  final bool
  isBadge; // If true, shows as a badge (for overlay). If false, shows as stars row.

  const RatingDisplayWidget({
    super.key,
    required this.chaletId,
    required this.isDark,
    this.isBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chalet_ratings')
          .where('chaletId', isEqualTo: chaletId)
          .snapshots(),
      builder: (context, snapshot) {
        double rating = 0.0;
        int count = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;
          count = docs.length;
          final total = docs.fold(0.0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            return sum + ((data['rating'] as num?)?.toDouble() ?? 0.0);
          });
          rating = total / count;
        }

        // If no rating and isBadge, hide it
        if (count == 0 && isBadge) {
          return const SizedBox.shrink();
        }

        if (isBadge) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ColorsManager.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ColorsManager.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: ColorsManager.yellowEAB308,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: ColorsManager.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        // Star Row Display
        return Row(
          children: [
            ...List.generate(5, (index) {
              IconData icon = Icons.star_border_rounded;
              Color color = isDark
                  ? ColorsManager.white.withOpacity(0.2)
                  : ColorsManager.chaletGrey400;

              if (index < rating.floor()) {
                icon = Icons.star_rounded;
                color = ColorsManager.yellowEAB308;
              } else if (index < rating && (rating - index) >= 0.5) {
                icon = Icons.star_half_rounded;
                color = ColorsManager.yellowEAB308;
              }
              return Icon(icon, size: 18, color: color);
            }),
            const SizedBox(width: 8),
            Text(
              '${rating.toStringAsFixed(1)} ($count تقييم)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? ColorsManager.white.withOpacity(0.7)
                    : ColorsManager.chaletGrey600,
              ),
            ),
          ],
        );
      },
    );
  }
}
