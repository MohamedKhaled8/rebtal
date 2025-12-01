import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_state.dart';

class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        // Start listening to notifications if user is logged in
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthSuccess) {
          context.read<NotificationCubit>().listenToNotifications(
            authState.user.uid,
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Notification Icon
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  size: 24,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.notificationsPage);
                },
              ),
            ),

            // Badge
            if (state is NotificationLoaded && state.unreadCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ColorManager.chaletActionRed,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF001409) : Colors.white,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    state.unreadCount > 9 ? '9+' : '${state.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
