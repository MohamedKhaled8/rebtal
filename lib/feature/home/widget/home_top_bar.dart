import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

import 'package:rebtal/feature/notifications/ui/notifications_page.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final appCubit = context.read<AppCubit>();
    final user = appCubit.getCurrentUser();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Profile Image & Greeting
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2563EB).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: AppImageHelper(
                    path:
                        user?.profileImageUrl ??
                        'https://ui-avatars.com/api/?name=${user?.name ?? 'User'}&background=2563EB&color=fff',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('home_welcome_back'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  Text(
                    user?.name ?? context.tr('home_new_user'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right Side: Notifications
          BlocSelector<AppCubit, AppState, int>(
            selector: (state) {
              if (state is AppAuthenticated) {
                return state.unreadNotifications;
              }
              return 0;
            },
            builder: (context, unreadCount) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.notifications_none_outlined,
                      size: 28,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
