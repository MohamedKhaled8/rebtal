import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/home/ui/home_screen.dart';
import 'package:rebtal/feature/owner/ui/owner_chalets_page.dart';
import 'package:rebtal/feature/owner/ui/owner_bookings_page.dart';
import 'package:rebtal/feature/profile/ui/profile_page.dart';
import 'package:rebtal/feature/booking/ui/user_bookings_page.dart';
import 'package:rebtal/feature/favorites/ui/favorites_page.dart';
import 'package:rebtal/feature/navigation/ui/bottom_nav_controller.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final currentUser = (state is AuthSuccess)
            ? state.user
            : context.read<AuthCubit>().getCurrentUser();

        if (currentUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = currentUser.role.toLowerCase().trim();
        final List<Widget> screens;
        final List<NavItem> bottomNavItems;

        if (role == 'owner') {
          screens = const [
            OwnerChaletsPage(),
            OwnerBookingsPage(),
            ProfilePage(),
          ];
          bottomNavItems = const [
            NavItem(icon: Icons.villa, label: 'الشاليهات'),
            NavItem(icon: Icons.book_online, label: 'الحجوزات'),
            NavItem(icon: Icons.person, label: 'الملف'),
          ];
        } else {
          screens = const [
            HomeScreen(),
            FavoritesPage(),
            UserBookingsPage(),
            ProfilePage(),
          ];
          bottomNavItems = const [
            NavItem(icon: Icons.home, label: 'الرئيسية'),
            NavItem(icon: Icons.favorite, label: 'المفضلة'),
            NavItem(icon: Icons.confirmation_number, label: 'الحجوزات'),
            NavItem(icon: Icons.person, label: 'الملف'),
          ];
        }

        return ValueListenableBuilder<int>(
          valueListenable: bottomNavIndex,
          builder: (context, currentIndex, _) {
            final int maxIndex = screens.length - 1;
            final int safeIndex = currentIndex.clamp(0, maxIndex);
            if (safeIndex != currentIndex) {
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
                backgroundColor: const Color(0xFF001409),
                body: Stack(
                  children: [
                    screens[safeIndex],
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 10,
                      child: _FloatingNavBar(
                        items: bottomNavItems,
                        currentIndex: safeIndex,
                        onTap: (i) =>
                            bottomNavIndex.value = i.clamp(0, maxIndex),
                      ),
                    ),
                  ],
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

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E), // Dark Blue
            Color(0xFF16213E), // Darker Blue
            Color(0xFF0F3460), // Navy Blue
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      width: isActive ? 40 : 32,
                      height: isActive ? 40 : 32,
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFE94560), // Red
                                  Color(0xFFFF6B6B), // Light Red
                                ],
                              )
                            : null,
                        color: isActive ? null : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE94560,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: AnimatedScale(
                          scale: isActive ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOutCubic,
                          child: Icon(
                            item.icon,
                            color: isActive ? Colors.white : Colors.white70,
                            size: isActive ? 20 : 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedOpacity(
                      opacity: isActive ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          color: Color(0xFFE94560),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 3,
                        height: 1,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94560),
                          borderRadius: BorderRadius.circular(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
