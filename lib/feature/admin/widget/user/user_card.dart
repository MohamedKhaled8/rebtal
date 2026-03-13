import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rebtal/core/utils/function/user_manger.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
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
    final profileImageUrl = userData['profileImageUrl']?.toString();
    final idCardUrl = userData['idCardUrl']?.toString();
    final isDark = DynamicThemeManager.isDarkMode(context);
    final hasPhotos = (profileImageUrl != null && profileImageUrl.isNotEmpty) ||
        (idCardUrl != null && idCardUrl.isNotEmpty);

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
                GestureDetector(
                  onTap: hasPhotos
                      ? () => _showPhotosDialog(context, name, profileImageUrl, idCardUrl, isDark)
                      : null,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: (profileImageUrl == null || profileImageUrl.isEmpty)
                          ? LinearGradient(
                              colors: [
                                const Color(0xFF667EEA),
                                const Color(0xFF764BA2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                          ? isDark ? Colors.white10 : Colors.grey[200]
                          : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: profileImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          )
                        : Center(
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
                    label: context.tr('admin_user_edit'),
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
                    label: context.tr('admin_user_delete'),
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
            if (hasPhotos) ...[
              const SizedBox(height: 12),
              _buildActionButton(
                context: context,
                icon: Icons.photo_library_rounded,
                label: context.tr('admin_user_view_photos'),
                color: const Color(0xFF10B981),
                onPressed: () {
                  _showPhotosDialog(
                    context,
                    name,
                    profileImageUrl,
                    idCardUrl,
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

  void _showPhotosDialog(
    BuildContext context,
    String userName,
    String? profileImageUrl,
    String? idCardUrl,
    bool isDark,
  ) {
    final photos = <String>[];
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      photos.add(profileImageUrl);
    }
    if (idCardUrl != null && idCardUrl.isNotEmpty) {
      photos.add(idCardUrl);
    }
    if (photos.isEmpty) return;

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, __, ___) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: photos.length,
                  itemBuilder: (_, index) {
                    final url = photos[index];
                    return Center(
                      child: InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 4,
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.contain,
                          placeholder: (c, _) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (c, _, __) => const Icon(
                            Icons.broken_image_rounded,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 16,
                  child: Text(
                    dialogContext
                        .tr('admin_user_photos_title')
                        .replaceAll('{}', userName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
