import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/feature/chalet/widget/reviews_section.dart'; // To reuse ReviewAvatar
import 'package:responsive_screen_master/responsive_screen_master.dart';

class ChaletReviewsPage extends StatelessWidget {
  final String chaletId;
  final String chaletName;
  final bool isDark;

  const ChaletReviewsPage({
    super.key,
    required this.chaletId,
    required this.chaletName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF222222);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Reviews for $chaletName",
          style: TextStyle(
            color: textColor,
            fontSize: stv(context: context, mobile: 18.spScaled, tablet: 22.spScaled, desktop: 26.spScaled),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: stv(context: context, mobile: 20.spScaled, tablet: 24.spScaled, desktop: 28.spScaled)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chalet_ratings')
            .where('chaletId', isEqualTo: chaletId.trim())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Error loading reviews: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: stv(context: context, mobile: 64.spScaled, tablet: 80.spScaled, desktop: 96.spScaled),
                    color: isDark ? Colors.white24 : Colors.grey[300],
                  ),
                  SizedBox(height: otv(context: context, portrait: 16.sh, landscape: 8.sh)),
                  Text(
                    "No reviews found yet",
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey[600],
                      fontSize: stv(context: context, mobile: 16.spScaled, tablet: 18.spScaled, desktop: 20.spScaled),
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort client-side to ensure even reviews without createdAt are shown first or last
          final docs = snapshot.data!.docs.toList();
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['createdAt'] as Timestamp?;
            final bTime = bData['createdAt'] as Timestamp?;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          return ListView.separated(
            padding: EdgeInsets.all(stv(context: context, mobile: 24.sw, tablet: 32.sw, desktop: 40.sw)),
            itemCount: docs.length,
            separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: otv(context: context, portrait: 24.sh, landscape: 12.sh)),
              child: Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
            ),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return FullReviewItem(data: data, isDark: isDark);
            },
          );
        },
      ),
    );
  }
}

class FullReviewItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const FullReviewItem({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final reviewText = data['review'] ?? data['comment'] ?? data['text'] ?? '';
    final userImg = data['userImage'] ?? data['profileImageUrl'] ?? '';
    final userName = data['userName'] ?? data['user_name'] ?? 'Guest';
    final userId = data['userId'] ?? data['user_id'] ?? '';

    String dateStr = "Recent";
    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      final date = createdAt.toDate();
      dateStr = "${date.day}/${date.month}/${date.year}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ReviewAvatar(userId: userId, initialImage: userImg, isDark: isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: stv(context: context, mobile: 16.spScaled, tablet: 18.spScaled, desktop: 20.spScaled),
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF222222),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: stv(context: context, mobile: 13.spScaled, tablet: 15.spScaled, desktop: 17.spScaled),
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, size: stv(context: context, mobile: 14.spScaled, tablet: 16.spScaled, desktop: 18.spScaled), color: Colors.amber),
                SizedBox(width: stv(context: context, mobile: 4.sw, tablet: 6.sw, desktop: 8.sw)),
                Text(
                  (data['rating'] as num?)?.toStringAsFixed(1) ?? '5.0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: otv(context: context, portrait: 16.sh, landscape: 8.sh)),
        ExpandableText(text: reviewText, isDark: isDark, maxLines: 5),
      ],
    );
  }
}
