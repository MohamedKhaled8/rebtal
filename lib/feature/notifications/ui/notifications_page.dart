import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_state.dart';
import 'package:rebtal/feature/notifications/widget/notification_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<NotificationCubit>().listenToNotifications(
        authState.user.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final authState = context.read<AuthCubit>().state;
    String userId = '';
    if (authState is AuthSuccess) userId = authState.user.uid;

    return Scaffold(
      backgroundColor: isDark
          ? ColorManager.chaletBackgroundDark
          : ColorManager.chaletBackgroundLight,
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        backgroundColor: isDark
            ? ColorManager.chaletCardDark
            : ColorManager.chaletCardLight,
        foregroundColor: isDark
            ? ColorManager.chaletTextPrimaryDark
            : ColorManager.chaletTextPrimaryLight,
        elevation: 0,
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all_rounded),
                  tooltip: 'تحديد الكل كمقروء',
                  onPressed: () {
                    context.read<NotificationCubit>().markAllAsRead(userId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم تحديد جميع الإشعارات كمقروءة'),
                        backgroundColor: ColorManager.chaletActionGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearConfirmation(userId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('حذف الكل'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return _buildLoadingState();
          }

          if (state is NotificationError) {
            return _buildErrorState(state.message);
          }

          if (state is NotificationLoaded) {
            final notifications = _showUnreadOnly
                ? state.notifications.where((n) => !n.isRead).toList()
                : state.notifications;

            if (notifications.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                // Filter chips
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'الكل (${state.notifications.length})',
                        isSelected: !_showUnreadOnly,
                        onTap: () => setState(() => _showUnreadOnly = false),
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        label: 'غير المقروءة (${state.unreadCount})',
                        isSelected: _showUnreadOnly,
                        onTap: () => setState(() => _showUnreadOnly = true),
                      ),
                    ],
                  ),
                ),

                // Notifications list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _loadNotifications();
                    },
                    color: ColorManager.chaletAccent,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return NotificationCard(
                          notification: notification,
                          onTap: () {
                            // TODO: Navigate based on notification type
                          },
                          onDelete: () {
                            context
                                .read<NotificationCubit>()
                                .deleteNotification(notification.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('تم حذف الإشعار'),
                                backgroundColor: ColorManager.chaletActionRed,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          onMarkAsRead: () {
                            context.read<NotificationCubit>().markAsRead(
                              notification.id,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [ColorManager.chaletAccent, Color(0xFF17B85A)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark
                    ? ColorManager.chaletCardDark
                    : ColorManager.chaletCardLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ColorManager.chaletAccent
                : (isDark
                      ? ColorManager.white.withOpacity(0.1)
                      : ColorManager.black.withOpacity(0.1)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? ColorManager.white
                : (isDark
                      ? ColorManager.chaletTextPrimaryDark
                      : ColorManager.chaletTextPrimaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: ColorManager.chaletAccent),
    );
  }

  Widget _buildErrorState(String message) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: ColorManager.chaletActionRed.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? ColorManager.chaletTextPrimaryDark
                    : ColorManager.chaletTextPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? ColorManager.chaletTextSecondaryDark
                    : ColorManager.chaletTextSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.chaletAccent,
                foregroundColor: ColorManager.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorManager.chaletAccent.withOpacity(0.2),
                    ColorManager.chaletAccent.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 60,
                color: ColorManager.chaletAccent.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'لا توجد إشعارات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? ColorManager.chaletTextPrimaryDark
                    : ColorManager.chaletTextPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _showUnreadOnly
                  ? 'لا توجد إشعارات غير مقروءة'
                  : 'ستظهر هنا جميع إشعاراتك',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? ColorManager.chaletTextSecondaryDark
                    : ColorManager.chaletTextSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(String userId) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? ColorManager.chaletCardDark
            : ColorManager.chaletCardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'حذف جميع الإشعارات',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark
                ? ColorManager.chaletTextPrimaryDark
                : ColorManager.chaletTextPrimaryLight,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(
            color: isDark
                ? ColorManager.chaletTextSecondaryDark
                : ColorManager.chaletTextSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationCubit>().clearAll(userId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم حذف جميع الإشعارات'),
                  backgroundColor: ColorManager.chaletActionRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.chaletActionRed,
              foregroundColor: ColorManager.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
