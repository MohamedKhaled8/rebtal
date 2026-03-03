import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/function/user_manger.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String docId;
  final String collection;

  const UserCard({
    super.key,
    required this.userData,
    required this.docId,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final name = userData['name'] ?? 'No Name';
    final email = userData['email'] ?? 'No Email';
    final phone = userData['phone'] ?? 'No Phone';
    final uid = userData['uid'] ?? docId;
    final role = userData['role'] ?? 'user';
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667EEA),
                        const Color(0xFF764BA2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: UserManager.roleColor(
                                role,
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: TextStyle(
                                color: UserManager.roleColor(role),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.phone_outlined, phone, isDark),
            const SizedBox(height: 12),
            _buildInfoRow(context, Icons.fingerprint, uid, isDark),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.edit_rounded,
                    label: 'تعديل',
                    color: const Color(0xFF667EEA),
                    onPressed: () {
                      UserManager.editUser(
                        ctx: context,
                        userData: userData,
                        collection: collection,
                        docId: docId,
                      );
                    },
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.delete_outline_rounded,
                    label: 'حذف',
                    color: Colors.red,
                    onPressed: () {
                      UserManager.deleteUser(
                        ctx: context,
                        collection: collection,
                        docId: docId,
                      );
                    },
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            if (userData['idCardUrl'] != null &&
                userData['idCardUrl'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildActionButton(
                context: context,
                icon: Icons.badge_outlined,
                label: 'عرض البطاقة الشخصية',
                color: const Color(0xFF10B981), // Green color
                onPressed: () {
                  _showIdCardDialog(
                    context,
                    userData['idCardUrl'],
                    name,
                    isDark,
                  );
                },
                isDark: isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showIdCardDialog(
    BuildContext context,
    String imageUrl,
    String userName,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'البطاقة الشخصية: $userName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String text,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2D2D44).withOpacity(0.5)
                : const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? const Color(0xFF667EEA) : const Color(0xFF667EEA),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[700],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
