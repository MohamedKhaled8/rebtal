// OwnerCard (used in Chalet cards) — improved avatar & layout
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';

class OwnerCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final dynamic profileImage;

  const OwnerCard({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  String? _avatarUrl() {
    if (profileImage == null) return null;
    if (profileImage is String && profileImage.isNotEmpty) {
      return profileImage as String;
    }
    if (profileImage is List) {
      for (final e in profileImage) {
        if (e is String && e.isNotEmpty) return e;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _avatarUrl();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (avatar == null)
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.deepPurple.withOpacity(0.14),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            ClipOval(
              child: SizedBox(
                width: 52,
                height: 52,
                child: AppImageHelper(path: avatar, fit: BoxFit.cover),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Owner',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
