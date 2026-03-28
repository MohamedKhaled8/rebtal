import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rebtal/core/utils/function/user_manger.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

String? _firstNonEmptyUrl(Map<String, dynamic> data, List<String> keys) {
  for (final k in keys) {
    final v = data[k];
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty && s != 'null') return s;
  }
  return null;
}

bool _isGoogleStaticMapUrl(String url) =>
    url.contains('maps.googleapis.com/maps/api/staticmap');

Map<String, String>? _httpHeadersForUrl(String url) {
  if (url.contains('googleapis.com')) {
    return const {
      'User-Agent':
          'Mozilla/5.0 (compatible; RebtalAdmin/1.0; +https://rebtal.app)',
    };
  }
  return null;
}

Future<void> _openUrlExternal(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

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
    final profileImageUrl = _firstNonEmptyUrl(userData, const [
      'profileImageUrl',
      'profileImage',
      'photoUrl',
      'avatar',
      'image',
    ]);
    final idCardUrl = _firstNonEmptyUrl(userData, const [
      'idCardUrl',
      'idCard',
      'nationalIdUrl',
      'identityDocumentUrl',
      'id_card_url',
      'idCardImageUrl',
    ]);
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
                      ? () => _showPhotosDialog(context, name, userData, isDark)
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
                  _showPhotosDialog(context, name, userData, isDark);
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
    Map<String, dynamic> data,
    bool isDark,
  ) {
    final profileUrl = _firstNonEmptyUrl(data, const [
      'profileImageUrl',
      'profileImage',
      'photoUrl',
      'avatar',
      'image',
    ]);
    final idUrl = _firstNonEmptyUrl(data, const [
      'idCardUrl',
      'idCard',
      'nationalIdUrl',
      'identityDocumentUrl',
      'id_card_url',
      'idCardImageUrl',
    ]);

    if ((profileUrl == null || profileUrl.isEmpty) &&
        (idUrl == null || idUrl.isEmpty)) {
      return;
    }

    final sameUrl = profileUrl != null &&
        idUrl != null &&
        profileUrl.trim() == idUrl.trim();

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
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (sameUrl) ...[
                          Text(
                            '${dialogContext.tr('admin_user_profile_photo')} · ${dialogContext.tr('admin_user_id_card')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dialogContext.tr('admin_user_same_url_warning'),
                            style: TextStyle(
                              color: Colors.amber.shade200,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _dialogImageBlock(dialogContext, profileUrl),
                        ] else ...[
                          if (profileUrl != null && profileUrl.isNotEmpty) ...[
                            Text(
                              dialogContext.tr('admin_user_profile_photo'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _dialogImageBlock(dialogContext, profileUrl),
                            const SizedBox(height: 28),
                          ],
                          if (idUrl != null && idUrl.isNotEmpty) ...[
                            Text(
                              dialogContext.tr('admin_user_id_card'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _dialogImageBlock(dialogContext, idUrl),
                          ],
                        ],
                      ],
                    ),
                  ),
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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(dialogContext).size.width * 0.65,
                    ),
                    child: Text(
                      dialogContext
                          .tr('admin_user_photos_title')
                          .replaceAll('{}', userName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
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

  Widget _dialogImageBlock(BuildContext context, String url) {
    if (_isGoogleStaticMapUrl(url)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.map_rounded, size: 48, color: Colors.amber.shade200),
          const SizedBox(height: 8),
          Text(
            context.tr('admin_user_image_link_invalid'),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _openUrlExternal(url),
            icon: const Icon(Icons.open_in_browser_rounded, size: 20),
            label: Text(context.tr('admin_user_open_in_browser')),
          ),
        ],
      );
    }

    final headers = _httpHeadersForUrl(url);
    final maxH = MediaQuery.sizeOf(context).height * 0.5;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: maxH.clamp(200.0, 520.0),
        child: InteractiveViewer(
          minScale: 0.6,
          maxScale: 5,
          child: CachedNetworkImage(
            imageUrl: url,
            httpHeaders: headers,
            width: double.infinity,
            height: maxH.clamp(200.0, 520.0),
            fit: BoxFit.contain,
            placeholder: (c, _) => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (c, failedUrl, err) {
              debugPrint('❌ Admin user image failed: $failedUrl ($err)');
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.broken_image_rounded,
                    size: 56,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('admin_user_image_link_invalid'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _openUrlExternal(failedUrl),
                    icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                    label: Text(context.tr('admin_user_open_in_browser')),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
