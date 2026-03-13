import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OwnerInformationCard extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const OwnerInformationCard({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final ownerId = requestData['ownerId'] ?? requestData['id'] ?? '';
    final isDark = DynamicThemeManager.isDarkMode(context);

    String initialMerchantName =
        requestData['merchantName'] ??
        requestData['ownerName'] ??
        'Not provided';
    if (initialMerchantName == 'غير محدد') initialMerchantName = 'Not provided';

    String initialEmail =
        requestData['email'] ??
        requestData['ownerEmail'] ??
        requestData['userEmail'] ??
        '';

    String initialPhone =
        requestData['phoneNumber'] ??
        requestData['ownerPhone'] ??
        requestData['userPhone'] ??
        requestData['phone'] ??
        '';

    String? initialProfileImage =
        requestData['profileImage'] ?? requestData['profileImageUrl'];

    return FutureBuilder<DocumentSnapshot?>(
      future: _getOwnerData(ownerId),
      builder: (context, snapshot) {
        String merchantName = initialMerchantName;
        String email = initialEmail;
        String phoneNumber = initialPhone;
        String? profileImageUrl = initialProfileImage;

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final fetchedName =
              data['name'] ?? data['userName'] ?? data['merchantName'];
          if (fetchedName != null && fetchedName.toString().isNotEmpty) {
            if (merchantName == 'Not provided' || merchantName.isEmpty) {
              merchantName = fetchedName;
            }
          }

          if (phoneNumber.isEmpty ||
              phoneNumber == 'No phone' ||
              phoneNumber == 'غير متوفر') {
            phoneNumber = data['phoneNumber'] ?? data['phone'] ?? '';
          }
          if (profileImageUrl == null || profileImageUrl.isEmpty) {
            profileImageUrl = data['profileImageUrl'] ?? data['image'];
          }
        }

        Map<String, dynamic> ownerData = {};
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          ownerData = snapshot.data!.data() as Map<String, dynamic>;
        }

        if (email.isEmpty) email = 'No email';
        if (phoneNumber.isEmpty) phoneNumber = 'No phone';

        // Calculate hosting duration
        String hostingDuration = context.tr('chalet_detail_new_host');
        Timestamp? createdTimestamp;

        // Helper to safely parse timestamp
        Timestamp? parseTimestamp(dynamic val) {
          if (val is Timestamp) return val;
          if (val is String && val.isNotEmpty) {
            try {
              // Try standard parsing
              return Timestamp.fromDate(DateTime.parse(val));
            } catch (_) {}
          }
          return null;
        }

        createdTimestamp =
            parseTimestamp(ownerData['createdAt']) ??
            parseTimestamp(ownerData['memberSince']) ??
            parseTimestamp(requestData['createdAt']);

        if (createdTimestamp != null) {
          final createdDate = createdTimestamp.toDate();
          final now = DateTime.now();
          final difference = now.difference(createdDate);
          final days = difference.inDays;

          if (days > 365) {
            final years = (days / 365).floor();
            hostingDuration = '$years ${context.tr(years == 1 ? 'chalet_detail_year_hosting' : 'chalet_detail_years_hosting')}';
          } else if (days > 30) {
            final months = (days / 30).floor();
            hostingDuration =
                '$months ${context.tr(months == 1 ? 'chalet_detail_month_hosting' : 'chalet_detail_months_hosting')}';
          } else {
            hostingDuration = '$days ${context.tr(days == 1 ? 'chalet_detail_day_hosting' : 'chalet_detail_days_hosting')}';
          }
        }

        return Padding(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              GestureDetector(
                onTap: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? () => _showFullScreenImage(context, profileImageUrl!)
                    : null,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(profileImageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: isDark ? Colors.white10 : Colors.grey[200],
                  ),
                  child: profileImageUrl == null || profileImageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          color: isDark ? Colors.white54 : Colors.grey,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.tr('chalet_detail_hosted_by')} $merchantName',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${context.tr('chalet_detail_superhost')} · $hostingDuration',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF717171),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<DocumentSnapshot?> _getOwnerData(String ownerId) async {
    if (ownerId.isEmpty) return null;
    try {
      final collections = [
        'Owners',
        'Users',
        'Admin',
        'Admins',
        'owners',
        'users',
        'admins',
      ];
      for (final col in collections) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection(col)
              .doc(ownerId)
              .get();
          if (doc.exists) return doc;
        } catch (_) {}
      }
      return null;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(imageUrl: imageUrl),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const OwnerInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          // Colored icons in light mode
          color: isDark ? Colors.white38 : ColorsManager.chaletActionBlue,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500, // Slightly bolder
              color: isDark ? Colors.white70 : Colors.grey[800], // Darker text
            ),
          ),
        ),
      ],
    );
  }
}
