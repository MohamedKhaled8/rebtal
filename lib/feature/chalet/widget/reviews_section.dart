import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

import 'package:rebtal/feature/chalet/ui/chalet_reviews_page.dart';

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
    final rating = (requestData['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewsCount =
        (requestData['reviews_count'] as num?)?.toInt() ??
        (requestData['ratingCount'] as num?)?.toInt() ??
        0;

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: stv(
                context: context,
                mobile: 24.sw,
                tablet: 32.sw,
                desktop: 40.sw,
              ),
            ),
            child: Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
          ),
          SizedBox(
            height: otv(context: context, portrait: 48.sh, landscape: 24.sh),
          ),
          // Header: ★ 4.83 · 78 reviews
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: stv(
                context: context,
                mobile: 24.sw,
                tablet: 32.sw,
                desktop: 40.sw,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  size: stv(
                    context: context,
                    mobile: 20.spScaled,
                    tablet: 22.spScaled,
                    desktop: 24.spScaled,
                  ),
                  color: isDark ? Colors.white : Colors.black,
                ),
                SizedBox(
                  width: stv(
                    context: context,
                    mobile: 8.sw,
                    tablet: 10.sw,
                    desktop: 12.sw,
                  ),
                ),
                Text(
                  '$rating · $reviewsCount ${context.tr('chalet_detail_reviews')}',
                  style: TextStyle(
                    fontSize: stv(
                      context: context,
                      mobile: 20.spScaled,
                      tablet: 22.spScaled,
                      desktop: 24.spScaled,
                    ),
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? ColorsManager.chaletTextPrimaryDark
                        : ColorsManager.chaletTextPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: otv(context: context, portrait: 40.sh, landscape: 20.sh),
          ),
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
                  child: _buildEmptyState(context),
                );
              }

              final docs = snapshot.data!.docs.toList();
              // Sort client-side
              docs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aTime = aData['createdAt'] as Timestamp?;
                final bTime = bData['createdAt'] as Timestamp?;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(docs.length * 2 - 1, (index) {
                    if (index.isOdd) {
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
                    final doc = docs[docIndex];
                    final data = doc.data() as Map<String, dynamic>;

                    final reviewText =
                        data['review'] ?? data['comment'] ?? data['text'] ?? '';
                    final userImg =
                        data['userImage'] ??
                        data['profileImageUrl'] ??
                        data['user_image'] ??
                        data['profileImage'] ??
                        '';
                    final userName =
                        data['userName'] ?? data['user_name'] ?? 'Guest';
                    final userId = data['userId'] ?? data['user_id'] ?? '';

                    // Date formatting
                    String dateStr = context.tr('booking_today');
                    final createdAt = data['createdAt'];
                    if (createdAt is Timestamp) {
                      final date = createdAt.toDate();
                      final diff = DateTime.now().difference(date);
                      if (diff.inDays > 30) {
                        dateStr = "${(diff.inDays / 30).floor()} ${context.tr('time_months_ago')}";
                      } else if (diff.inDays == 1) {
                        dateStr = context.tr('time_yesterday');
                      } else if (diff.inDays > 1 && diff.inDays <= 7) {
                        dateStr = "${diff.inDays} ${context.tr('time_days_ago')}";
                      } else if (diff.inDays > 7) {
                        dateStr = "${(diff.inDays / 7).floor()} ${context.tr('time_weeks_ago')}";
                      } else {
                        dateStr = context.tr('booking_today');
                      }
                    }

                    return SizedBox(
                      width: 270,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 14, // Slightly smaller
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ExpandableText(
                            text: reviewText,
                            isDark: isDark,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ReviewAvatar(
                                userId: userId,
                                initialImage: userImg,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF222222),
                                      ),
                                    ),
                                    Text(
                                      "Manzala, Egypt",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey[600],
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
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: 24), // Increased from 16
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChaletReviewsPage(
                        chaletId: chaletId,
                        chaletName: requestData['chaletName'] ?? 'Chalet',
                        isDark: isDark,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? Colors.white : Colors.black87,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                ),
                child: Text(
                  context
                      .tr('chalet_detail_show_all_reviews')
                      .replaceAll('{}', '$reviewsCount'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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

  Widget _buildEmptyState(BuildContext context) {
    return Text(
      context.tr('chalet_detail_no_reviews'),
      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
    );
  }
}

class ReviewAvatar extends StatelessWidget {
  final String userId;
  final String initialImage;
  final bool isDark;

  const ReviewAvatar({
    super.key,
    required this.userId,
    required this.initialImage,
    required this.isDark,
  });

  Future<String?> _fetchUserImage() async {
    if (userId.isEmpty) return null;

    final collections = [
      'Users',
      'Owners',
      'Admin',
      'Admins',
      'users',
      'owners',
      'admins',
    ];
    for (final col in collections) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(col)
            .doc(userId)
            .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return data['profileImageUrl'] ??
              data['profileImage'] ??
              data['userImage'];
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (initialImage.isNotEmpty) {
      return _buildAvatar(initialImage);
    }

    if (userId.isEmpty) {
      return _buildPlaceholder();
    }

    return FutureBuilder<String?>(
      future: _fetchUserImage(),
      builder: (context, snapshot) {
        final imgUrl = snapshot.data;
        if (imgUrl != null && imgUrl.isNotEmpty) {
          return _buildAvatar(imgUrl);
        }
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white12 : Colors.grey[200],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white10 : Colors.grey[200],
      ),
      child: const Icon(Icons.person, color: Colors.grey, size: 24),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final bool isDark;
  final int maxLines;

  const ExpandableText({
    super.key,
    required this.text,
    required this.isDark,
    this.maxLines = 4,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textSpan = TextSpan(
      text: widget.text,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: widget.isDark ? Colors.white70 : const Color(0xFF222222),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final bool isLong = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: isExpanded ? null : widget.maxLines,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: textSpan.style,
            ),
            if (isLong)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Builder(
                    builder: (ctx) => Text(
                      isExpanded
                          ? ctx.tr('chalet_detail_show_less')
                          : ctx.tr('chalet_detail_show_more'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
