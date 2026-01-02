import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OwnerInformationCard extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const OwnerInformationCard({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final ownerId = requestData['ownerId'] ?? requestData['id'] ?? '';
    final isDark = DynamicThemeManager.isDarkMode(context);

    // Initial fallback values from requestData
    // We use these while loading or if fetch fails
    String initialMerchantName =
        requestData['merchantName'] ??
        requestData['ownerName'] ??
        'Not provided';

    // Clean up initial name if it's generic
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

        // Override with fetched data if available
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Try to get a better name if we don't have one
          final fetchedName =
              data['name'] ?? data['userName'] ?? data['merchantName'];
          if (fetchedName != null && fetchedName.toString().isNotEmpty) {
            // Only override if current is generic or empty, OR if we trust the doc more
            if (merchantName == 'Not provided' || merchantName.isEmpty) {
              merchantName = fetchedName;
            }
          }

          // Always try to fill missing contact info
          if (email.isEmpty || email == 'No email' || email == 'غير متوفر') {
            email = data['email'] ?? '';
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

        // Final Display Check
        if (email.isEmpty) email = 'No email';
        if (phoneNumber.isEmpty) phoneNumber = 'No phone';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? ColorManager.chaletCardDark
                : ColorManager.chaletCardLight,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        border: Border.all(
                          color: ColorManager.chaletActionBlue.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.chaletActionBlue.withOpacity(
                              0.15,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child:
                            profileImageUrl != null &&
                                profileImageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: profileImageUrl,
                                fit: BoxFit.cover,
                                width: 48,
                                height: 48,
                                placeholder: (context, url) => Container(
                                  color: isDark
                                      ? ColorManager.chaletIconBackgroundDark
                                      : ColorManager.chaletGrey50,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildPlaceholderIcon(isDark),
                              )
                            : _buildPlaceholderIcon(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Owner Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? ColorManager.chaletTextPrimaryDark
                            : ColorManager.chaletTextPrimaryLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? ColorManager.chaletIconBackgroundDark
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? ColorManager.white10
                        : ColorManager.chaletGrey100,
                  ),
                ),
                child: Column(
                  children: [
                    OwnerInfoRow(
                      icon: Icons.account_circle_outlined,
                      label: "Name",
                      value: merchantName,
                      isDark: isDark,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        height: 1,
                        color: isDark
                            ? ColorManager.white10
                            : ColorManager.chaletGrey200,
                      ),
                    ),
                    OwnerInfoRow(
                      icon: Icons.email_outlined,
                      label: "Email",
                      value: email,
                      isDark: isDark,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        height: 1,
                        color: isDark
                            ? ColorManager.white10
                            : ColorManager.chaletGrey200,
                      ),
                    ),
                    OwnerInfoRow(
                      icon: Icons.phone_outlined,
                      label: "Phone",
                      value: phoneNumber,
                      isDark: isDark,
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

  Widget _buildPlaceholderIcon(bool isDark) {
    return Container(
      color: isDark
          ? ColorManager.chaletIconBackgroundDark
          : ColorManager.greyF9FAFB,
      child: Icon(
        Icons.person_rounded,
        size: 24,
        color: ColorManager.indigo6366F1.withOpacity(0.5),
      ),
    );
  }

  Future<DocumentSnapshot?> _getOwnerData(String ownerId) async {
    if (ownerId.isEmpty) return null;

    try {
      // Try Owners collection first with timeout
      var doc = await FirebaseFirestore.instance
          .collection('Owners')
          .doc(ownerId)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              return FirebaseFirestore.instance
                  .collection('Owners')
                  .doc(ownerId)
                  .get(const GetOptions(source: Source.cache));
            },
          );

      if (doc.exists) return doc;

      // Try Users collection
      doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(ownerId)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              return FirebaseFirestore.instance
                  .collection('Users')
                  .doc(ownerId)
                  .get(const GetOptions(source: Source.cache));
            },
          );

      return doc.exists ? doc : null;
    } catch (e) {
      debugPrint('Error fetching owner data: $e');
      return null;
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: ColorManager.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: ColorManager.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: ColorManager.white),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: ColorManager.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: ColorManager.white,
                    size: 24,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
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
        Icon(icon, color: ColorManager.chaletGrey400, size: 20),
        const SizedBox(width: 12),
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: ColorManager.chaletGrey500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark
                  ? ColorManager.chaletTextPrimaryDark
                  : ColorManager.chaletGrey800,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
