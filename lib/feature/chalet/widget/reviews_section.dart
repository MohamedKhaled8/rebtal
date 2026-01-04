import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:intl/intl.dart' as intl;

class ReviewsSection extends StatelessWidget {
  final String chaletId;
  final bool isDark;

  const ReviewsSection({
    super.key,
    required this.chaletId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
          const SizedBox(height: 32),
          Text(
            'Guest Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? ColorManager.chaletTextPrimaryDark
                  : ColorManager.chaletTextPrimaryLight,
            ),
          ),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chalet_ratings')
                .where('chaletId', isEqualTo: chaletId.trim())
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Could not load reviews',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[500],
                    fontSize: 14,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final allDocs = snapshot.data!.docs;
              final sortedDocs = allDocs.toList()
                ..sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final timeA = dataA['createdAt'] as Timestamp?;
                  final timeB = dataB['createdAt'] as Timestamp?;
                  if (timeA == null) return -1;
                  if (timeB == null) return 1;
                  return timeB.compareTo(timeA);
                });

              final reviews = sortedDocs.take(5).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Divider(
                    color: isDark ? Colors.white10 : Colors.grey[100],
                    height: 1,
                  ),
                ),
                itemBuilder: (context, index) {
                  final data = reviews[index].data() as Map<String, dynamic>;
                  return ReviewItem(data: data, isDark: isDark);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No reviews yet',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Be the first to share your experience!',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white38 : Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const ReviewItem({super.key, required this.data, required this.isDark});

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    // Use format: 1 / 1 / 2026 12:10 (or similar)
    return intl.DateFormat('d / M / yyyy   hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final userName = data['userName'] ?? 'User';
    final userImage = data['userImage'] ?? '';
    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final review = data['review'] ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final dateStr = _getTimeAgo(createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Info Header
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white10 : Colors.grey[200],
              ),
              child: ClipOval(
                child: userImage.isNotEmpty
                    ? AppImageHelper(path: userImage, fit: BoxFit.cover)
                    : Icon(
                        Icons.person,
                        size: 24,
                        color: isDark ? Colors.white38 : Colors.grey[400],
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Stars (Yellow)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              Icons.star_rounded,
              size: 16,
              color: index < rating.round()
                  ? const Color(0xFFEAB308) // Yellow
                  : isDark
                  ? Colors.white12
                  : Colors.grey[200],
            );
          }),
        ),

        const SizedBox(height: 12),

        // Review Text Bubble (Shape)
        if (review.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF3F4F6), // Light grey bubble
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              review,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
              ),
            ),
          ),
      ],
    );
  }
}
