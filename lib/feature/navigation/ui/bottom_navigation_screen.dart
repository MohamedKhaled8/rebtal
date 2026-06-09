import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/home/ui/home_screen.dart';
import 'package:rebtal/feature/owner/ui/owner_chalets_page.dart';
import 'package:rebtal/feature/owner/ui/owner_bookings_page.dart';
import 'package:rebtal/feature/owner/ui/owner_cancellations_page.dart';
import 'package:rebtal/feature/owner/ui/booking_transfers_page.dart';
import 'package:rebtal/feature/admin/presentation/pages/dashboard.dart';

import 'package:rebtal/feature/profile/ui/profile_page.dart';
import 'package:rebtal/feature/booking/ui/user_bookings_page.dart';
import 'package:rebtal/feature/guest/ui/guest_sign_in_page.dart';

import 'package:rebtal/feature/chalet/ui/offers_page.dart';
import 'package:rebtal/feature/favorites/ui/favorites_page.dart';
import 'package:rebtal/feature/chalet/ui/day_use_page.dart';
import 'package:rebtal/feature/navigation/ui/bottom_nav_controller.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  String? _cachedRole;
  List<Widget>? _screens;

  @override
  void initState() {
    super.initState();
    bottomNavIndex.value = 0;
  }

  void _buildScreensForRole(String role) {
    if (role == _cachedRole && _screens != null) {
      return;
    }
    _cachedRole = role;

    if (role == 'admin') {
      _screens = const [
        HomeScreen(),
        FavoritesPage(),
        DayUsePage(),
        UserBookingsPage(),
        AdminDashboard(),
        ProfilePage(),
      ];
    } else if (role == 'owner') {
      _screens = const [
        OwnerChaletsPage(),
        OwnerBookingsPage(),
        BookingTransfersPage(),
        OwnerCancellationsPage(),
        ProfilePage(),
      ];
    } else if (role == 'guest') {
      _screens = const [
        HomeScreen(),
        OffersPage(),
        DayUsePage(),
        GuestSignInPage(),
      ];
    } else {
      _screens = const [
        HomeScreen(),
        OffersPage(),
        FavoritesPage(),
        DayUsePage(),
        UserBookingsPage(),
        ProfilePage(),
      ];
    }
  }

  List<NavItem> _buildNavItemsForRole(String role, String Function(String) t) {
    switch (role) {
      case 'admin':
        return [
          NavItem(icon: Icons.home, label: t('nav_home')),
          NavItem(icon: Icons.favorite, label: t('nav_favorites')),
          NavItem(icon: Icons.wb_sunny_rounded, label: t('nav_day_use')),
          NavItem(icon: Icons.confirmation_number, label: t('nav_bookings')),
          NavItem(icon: Icons.admin_panel_settings, label: t('nav_admin')),
          NavItem(icon: Icons.person, label: t('nav_profile')),
        ];
      case 'owner':
        return [
          NavItem(icon: Icons.villa, label: t('nav_chalets')),
          NavItem(icon: Icons.book_online, label: t('nav_bookings')),
          NavItem(icon: Icons.swap_horiz_rounded, label: t('nav_transfers')),
          NavItem(
            icon: Icons.cancel_presentation,
            label: t('nav_cancellations'),
          ),
          NavItem(icon: Icons.person, label: t('nav_profile')),
        ];
      case 'guest':
        return [
          NavItem(icon: Icons.home, label: t('nav_home')),
          NavItem(icon: Icons.local_offer, label: t('nav_offers')),
          NavItem(icon: Icons.wb_sunny_rounded, label: t('nav_day_use')),
          NavItem(icon: Icons.login_rounded, label: t('nav_sign_in')),
        ];
      default:
        return [
          NavItem(icon: Icons.home, label: t('nav_home')),
          NavItem(icon: Icons.local_offer, label: t('nav_offers')),
          NavItem(icon: Icons.favorite, label: t('nav_favorites')),
          NavItem(icon: Icons.wb_sunny_rounded, label: t('nav_day_use')),
          NavItem(icon: Icons.confirmation_number, label: t('nav_bookings')),
          NavItem(icon: Icons.person, label: t('nav_profile')),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    final authCubit = appCubit.authCubit;
    final isDark = DynamicThemeManager.isDarkMode(context);
    final shellBg = isDark
        ? ColorsManager.black
        : ColorsManager.chaletBackgroundLight;

    return BlocBuilder<AuthCubit, AuthState>(
      bloc: authCubit,
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is AuthSuccess && current is AuthSuccess) {
          return previous.user.uid != current.user.uid ||
              previous.user.role != current.user.role ||
              previous.uiRevision != current.uiRevision;
        }
        return true;
      },
      builder: (context, state) {
        final isGuest = state is AuthGuest;
        final currentUser = (state is AuthSuccess)
            ? state.user
            : authCubit.getCurrentUser();

        if (currentUser == null && !isGuest) {
          return Scaffold(
            backgroundColor: shellBg,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final role = authCubit.getCurrentRole();
        _buildScreensForRole(role);
        final screens = _screens!;
        final bottomNavItems = _buildNavItemsForRole(role, context.tr);

        return ValueListenableBuilder<int>(
          valueListenable: bottomNavIndex,
          builder: (context, currentIndex, _) {
            final maxIndex = screens.length - 1;
            final safeIndex = currentIndex.clamp(0, maxIndex);

            if (safeIndex != currentIndex) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (bottomNavIndex.value != safeIndex) {
                  bottomNavIndex.value = safeIndex;
                }
              });
            }

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                if (safeIndex != 0) {
                  bottomNavIndex.value = 0;
                } else {
                  SystemNavigator.pop();
                }
              },
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: shellBg,
                body: IndexedStack(
                  index: safeIndex,
                  sizing: StackFit.expand,
                  children: screens,
                ),
                bottomNavigationBar: _SimpleNavBar(
                  items: bottomNavItems,
                  currentIndex: safeIndex,
                  onTap: (i) => bottomNavIndex.value = i.clamp(0, maxIndex),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

class _SimpleNavBar extends StatelessWidget {
  const _SimpleNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _active = Color(0xFF2563EB);

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = DynamicThemeManager.isDarkMode(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final inactive = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.45);
    final inactiveBorder = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    final indicatorSurface = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    final barBg = isDark ? const Color(0xFF0B0F0D) : Colors.white;

    return Material(
      color: barBg,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: barBg,
          border: Border(top: BorderSide(color: inactiveBorder, width: 0.5)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Theme(
            data: theme.copyWith(
              splashColor: _active.withValues(alpha: 0.12),
              highlightColor: _active.withValues(alpha: 0.04),
              navigationBarTheme: NavigationBarThemeData(
                height: 64,
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: indicatorSurface,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 10,
                    height: 1.15,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _active : inactive,
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: selected ? _active : inactive,
                    size: 26,
                  );
                }),
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return _active.withValues(alpha: 0.1);
                  }
                  return Colors.transparent;
                }),
              ),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              onDestinationSelected: (i) {
                HapticFeedback.selectionClick();
                onTap(i);
              },
              destinations: [
                for (final item in items)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
