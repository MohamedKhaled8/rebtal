import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/ui/home_screen.dart';
import 'package:rebtal/feature/owner/ui/owner_chalets_page.dart';
import 'package:rebtal/feature/owner/ui/owner_bookings_page.dart';
import 'package:rebtal/feature/owner/ui/owner_cancellations_page.dart';
import 'package:rebtal/feature/owner/ui/booking_transfers_page.dart';
import 'package:rebtal/feature/admin/ui/dashboard.dart';

import 'package:rebtal/feature/profile/ui/profile_page.dart';
import 'package:rebtal/feature/booking/ui/user_bookings_page.dart';

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
  List<NavItem>? _navItems;

  @override
  void initState() {
    super.initState();
    bottomNavIndex.value = 0;
  }

  void _buildScreensForRole(String role) {
    if (role == _cachedRole && _screens != null) return;
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
      _navItems = const [
        NavItem(icon: Icons.home, label: 'الرئيسية'),
        NavItem(icon: Icons.favorite, label: 'المفضلة'),
        NavItem(icon: Icons.wb_sunny_rounded, label: 'داي يوز'),
        NavItem(icon: Icons.confirmation_number, label: 'الحجوزات'),
        NavItem(icon: Icons.admin_panel_settings, label: 'الإدارة'),
        NavItem(icon: Icons.person, label: 'الملف'),
      ];
    } else if (role == 'owner') {
      _screens = const [
        OwnerChaletsPage(),
        OwnerBookingsPage(),
        BookingTransfersPage(),
        OwnerCancellationsPage(),
        ProfilePage(),
      ];
      _navItems = const [
        NavItem(icon: Icons.villa, label: 'الشاليهات'),
        NavItem(icon: Icons.book_online, label: 'الحجوزات'),
        NavItem(icon: Icons.swap_horiz_rounded, label: 'انتقالات'),
        NavItem(icon: Icons.cancel_presentation, label: 'الإلغاءات'),
        NavItem(icon: Icons.person, label: 'الملف'),
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
      _navItems = const [
        NavItem(icon: Icons.home, label: 'الرئيسية'),
        NavItem(icon: Icons.local_offer, label: 'عروض'),
        NavItem(icon: Icons.favorite, label: 'المفضلة'),
        NavItem(icon: Icons.wb_sunny_rounded, label: 'داي يوز'),
        NavItem(icon: Icons.confirmation_number, label: 'الحجوزات'),
        NavItem(icon: Icons.person, label: 'الملف'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    final authCubit = appCubit.authCubit;

    return BlocBuilder(
      bloc: authCubit,
      builder: (context, state) {
        final currentUser = (state is AuthSuccess)
            ? state.user
            : authCubit.getCurrentUser();

        if (currentUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = authCubit.getCurrentRole();
        _buildScreensForRole(role);
        final screens = _screens!;
        final bottomNavItems = _navItems!;

        return ValueListenableBuilder<int>(
          valueListenable: bottomNavIndex,
          builder: (context, currentIndex, _) {
            final int maxIndex = screens.length - 1;
            // Ensure index is valid for the current screen list
            final int safeIndex = currentIndex.clamp(0, maxIndex);

            // If the current index is out of bounds (e.g. switching from User->Owner while on index 4),
            // safeIndex will be 2. We should update the notifier.
            if (safeIndex != currentIndex) {
              // Schedule the update to avoid build conflicts
              WidgetsBinding.instance.addPostFrameCallback((_) {
                bottomNavIndex.value = safeIndex;
              });
            }

            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                if (didPop) return;
                if (currentIndex != 0) {
                  bottomNavIndex.value = 0;
                } else {
                  SystemNavigator.pop();
                }
              },
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: IndexedStack(index: safeIndex, children: screens),
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

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 65 + bottomPadding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0F0D) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: isActive
                          ? const Color(0xFF2563EB)
                          : isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.5),
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF2563EB)
                            : isDark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5),
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
