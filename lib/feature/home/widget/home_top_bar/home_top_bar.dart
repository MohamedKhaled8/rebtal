import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/home/widget/home_top_bar/waving_hand_icon.dart';
import 'package:rebtal/feature/notifications/ui/notifications_page.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final fallbackAvatar = (String? name) =>
        'https://ui-avatars.com/api/?name=${name ?? 'User'}&background=2563EB&color=fff';

    return Container(
      padding: EdgeInsets.fromLTRB(
        stv(context: context, mobile: 20.sw, tablet: 28.sw, desktop: 36.sw),
        otv(context: context, portrait: 10.sh, landscape: 5.sh),
        stv(context: context, mobile: 20.sw, tablet: 28.sw, desktop: 36.sw),
        otv(context: context, portrait: 10.sh, landscape: 5.sh),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Profile Image & Greeting
          BlocSelector<AppCubit, AppState, ({String? name, String? imageUrl})>(
            selector: (state) {
              if (state is AppAuthenticated) {
                return (
                  name: state.user.name,
                  imageUrl: state.user.profileImageUrl,
                );
              }
              return (name: null, imageUrl: null);
            },
            builder: (context, userData) {
              final avatarUrl =
                  userData.imageUrl ?? fallbackAvatar(userData.name);
              return Row(
                children: [
                  Container(
                    width: stv(
                      context: context,
                      mobile: 45.sw,
                      tablet: 55.sw,
                      desktop: 65.sw,
                    ),
                    height: stv(
                      context: context,
                      mobile: 45.sw,
                      tablet: 55.sw,
                      desktop: 65.sw,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2563EB).withOpacity(0.2),
                        width: 2.sw,
                      ),
                    ),
                    child: ClipOval(
                      child: AppImageHelper(
                        key: ValueKey(avatarUrl),
                        path: avatarUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: stv(
                      context: context,
                      mobile: 12.sw,
                      tablet: 16.sw,
                      desktop: 20.sw,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            context.tr('home_welcome_back'),
                            style: TextStyle(
                              fontSize: otv(
                                context: context,
                                portrait: stv(
                                  context: context,
                                  mobile: 12.spScaled,
                                  tablet: 14.spScaled,
                                  desktop: 16.spScaled,
                                ),
                                landscape: stv(
                                  context: context,
                                  mobile: 14.spScaled,
                                  tablet: 16.spScaled,
                                  desktop: 18.spScaled,
                                ),
                              ),
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4.sw),
                          const WavingHandIcon(),
                        ],
                      ),
                      Text(
                        userData.name ?? context.tr('home_new_user'),
                        style: TextStyle(
                          fontSize: stv(
                            context: context,
                            mobile: 16.spScaled,
                            tablet: 20.spScaled,
                            desktop: 24.spScaled,
                          ),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
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
                      size: stv(
                        context: context,
                        mobile: 28.sw,
                        tablet: 32.sw,
                        desktop: 36.sw,
                      ),
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: stv(
                        context: context,
                        mobile: 8.sw,
                        tablet: 10.sw,
                        desktop: 12.sw,
                      ),
                      top: stv(
                        context: context,
                        mobile: 8.sw,
                        tablet: 10.sw,
                        desktop: 12.sw,
                      ),
                      child: IgnorePointer(
                        child: Container(
                          padding: EdgeInsets.all(
                            stv(
                              context: context,
                              mobile: 4.sw,
                              tablet: 6.sw,
                              desktop: 8.sw,
                            ),
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: stv(
                              context: context,
                              mobile: 16.sw,
                              tablet: 20.sw,
                              desktop: 24.sw,
                            ),
                            minHeight: stv(
                              context: context,
                              mobile: 16.sw,
                              tablet: 20.sw,
                              desktop: 24.sw,
                            ),
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: stv(
                                context: context,
                                mobile: 10.spScaled,
                                tablet: 12.spScaled,
                                desktop: 14.spScaled,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
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

