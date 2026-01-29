import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class ReviewsSection extends StatelessWidget {
  final String chaletId;
  final bool isDark;
  final Map<String, dynamic> requestData; // Added

  const ReviewsSection({
    super.key,
    required this.chaletId,
    required this.isDark,
    required this.requestData, // Added
  });

  @override
  Widget build(BuildContext context) {
    // Get real rating and count with safe casting
    final rating = (requestData['rating'] as num?)?.toDouble() ?? 4.83;
    final reviewsCount =
        (requestData['reviews_count'] as num?)?.toInt() ??
        (requestData['ratingCount'] as num?)?.toInt() ??
        78;

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
          ),
          const SizedBox(height: 32),

          // Header: ★ 4.83 · 78 reviews
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  size: 22,
                  color: isDark ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  '$rating · $reviewsCount reviews',
                  style: TextStyle(
                    fontSize: 22, // Bigger font
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? ColorManager.chaletTextPrimaryDark
                        : ColorManager.chaletTextPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Horizontal Review List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chalet_ratings')
                .where('chaletId', isEqualTo: chaletId.trim())
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildEmptyState(),
                );
              }

              final docs = snapshot.data!.docs;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(docs.length * 2 - 1, (index) {
                    if (index.isOdd) {
                      // Separator with minimal width
                      return Container(
                        width: 8,
                        height: 140,
                        alignment: Alignment.center,
                        child: Container(
                          width: 1,
                          color: isDark ? Colors.white24 : Colors.blueGrey[100],
                        ),
                      );
                    }

                    final docIndex = index ~/ 2;
                    final data = docs[docIndex].data() as Map<String, dynamic>;
                    final reviewText =
                        data['review'] ?? data['comment'] ?? data['text'] ?? '';
                    final userImg =
                        data['userImage'] ??
                        data['user_image'] ??
                        data['profileImage'] ??
                        '';
                    final userName =
                        data['userName'] ?? data['user_name'] ?? 'Guest';

                    return SizedBox(
                      width: 270, // Compacter width
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Stars + Date
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 15,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "3 weeks ago",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 2. Review Text
                          Text(
                            reviewText,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF222222),
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          if (reviewText.length > 100)
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Show more",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),

                          const SizedBox(height: 15),

                          // 3. User Info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.grey[200],
                                backgroundImage:
                                    (userImg != null && userImg.isNotEmpty)
                                    ? NetworkImage(userImg)
                                    : null,
                                child: (userImg == null || userImg.isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF222222),
                                    ),
                                  ),
                                  Text(
                                    "Cairo, Egypt",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: 16), // Reduced from 32
          // "Show all reviews" Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: isDark
                      ? Colors.white10
                      : const Color(0xFFF7F7F7), // Very light grey
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  // Remove minimumSize if needed to make it compact? No, standard height 48 is good.
                ),
                child: Text(
                  "Show all $reviewsCount reviews",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // ... keep existing empty state logic or simplified
    return Text("No reviews yet");
  }
}
