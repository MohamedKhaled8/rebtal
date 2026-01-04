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

        if (email.isEmpty) email = 'No email';
        if (phoneNumber.isEmpty) phoneNumber = 'No phone';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
              const SizedBox(height: 32),

              Row(
                children: [
                  GestureDetector(
                    onTap: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? () => _showFullScreenImage(context, profileImageUrl!)
                        : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child:
                            profileImageUrl != null &&
                                profileImageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: profileImageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[200]),
                                errorWidget: (context, url, error) =>
                                    _buildPlaceholderIcon(isDark),
                              )
                            : _buildPlaceholderIcon(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Owner Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? ColorManager.chaletTextPrimaryDark
                                : ColorManager.chaletTextPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          merchantName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Simple Contact List - No Container
              Column(
                children: [
                  OwnerInfoRow(
                    icon: Icons.email_outlined,
                    label: "Email",
                    value: email,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  OwnerInfoRow(
                    icon: Icons.phone_outlined,
                    label: "Phone",
                    value: phoneNumber,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderIcon(bool isDark) {
    return Container(
      color: isDark ? Colors.white10 : Colors.grey[100],
      child: Icon(
        Icons.person_rounded,
        size: 24,
        color: isDark ? Colors.white30 : Colors.grey[400],
      ),
    );
  }

  Future<DocumentSnapshot?> _getOwnerData(String ownerId) async {
    if (ownerId.isEmpty) return null;
    try {
      var doc = await FirebaseFirestore.instance
          .collection('Owners')
          .doc(ownerId)
          .get();
      if (doc.exists) return doc;
      doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(ownerId)
          .get();
      return doc.exists ? doc : null;
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
          color: isDark ? Colors.white38 : ColorManager.chaletActionBlue,
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
