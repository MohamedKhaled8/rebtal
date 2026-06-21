import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class _OwnerImageCacheManager {
  static final BaseCacheManager instance = CacheManager(
    Config(
      'rebtalOwnerImageCache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 300,
    ),
  );
}

class OwnerInformationCard extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const OwnerInformationCard({super.key, required this.requestData});

  @override
  State<OwnerInformationCard> createState() => _OwnerInformationCardState();
}

class _OwnerInformationCardState extends State<OwnerInformationCard> {
  Future<DocumentSnapshot?>? _ownerFuture;
  String? _ownerFutureKey;

  static String _resolveOwnerId(Map<String, dynamic> data) {
    for (final key in ['ownerId', 'merchantId', 'userId']) {
      final v = data[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
  }

  void _ensureOwnerFuture() {
    final ownerId = _resolveOwnerId(widget.requestData);
    if (_ownerFutureKey == ownerId && _ownerFuture != null) return;
    _ownerFutureKey = ownerId;
    _ownerFuture = _getOwnerData(ownerId);
  }

  @override
  void initState() {
    super.initState();
    _ensureOwnerFuture();
  }

  @override
  void didUpdateWidget(covariant OwnerInformationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureOwnerFuture();
  }

  @override
  Widget build(BuildContext context) {
    final requestData = widget.requestData;
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
      future: _ownerFuture,
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
                    color: isDark ? Colors.white10 : Colors.grey[200],
                  ),
                  child: ClipOval(
                    child: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profileImageUrl,
                            cacheManager: _OwnerImageCacheManager.instance,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 120),
                            fadeOutDuration: Duration.zero,
                            placeholderFadeInDuration: Duration.zero,
                            errorWidget: (_, url, error) => Icon(
                              Icons.person,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                  ),
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
          final ref = FirebaseFirestore.instance.collection(col).doc(ownerId);
          try {
            final serverDoc = await ref.get(const GetOptions(source: Source.server));
            if (serverDoc.exists) return serverDoc;
          } catch (_) {}

          final cachedDoc = await ref.get(const GetOptions(source: Source.cache));
          if (cachedDoc.exists) return cachedDoc;
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
