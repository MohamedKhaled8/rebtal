import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/widget/booking_card.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/owner/utils/owner_helper.dart';

class OwnerBookingsPage extends StatelessWidget {
  const OwnerBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    // final authState = appCubit.state; // We check state in builder usually

    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorManager.darkBackground121212
          : ColorManager.profileBackgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header بسيط
          SliverAppBar(
            floating: true,
            pinned: false,
            elevation: 0,
            backgroundColor: isDark
                ? ColorManager.transparent
                : ColorManager.white,
            title: const Text(
              'حجوزاتي',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? ColorManager.white : ColorManager.black,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  final state = appCubit.state;
                  if (state is AppAuthenticated) {
                    // Since AppCubit already listens to booking cubit changes,
                    // we just need to trigger the fetch in the underlying cubit.
                    // AppCubit doesn't expose `loadOwnerBookings` directly in facade yet,
                    // but we can access the cubit via getter.
                    appCubit.bookingCubit.loadOwnerBookings(state.user.uid);
                  }
                },
              ),
            ],
          ),

          // المحتوى
          BlocBuilder<AppCubit, AppState>(
            buildWhen: (previous, current) {
              if (current is AppAuthenticated && previous is AppAuthenticated) {
                return current.bookings != previous.bookings ||
                    current.isBookingsLoading != previous.isBookingsLoading;
              }
              return true;
            },
            builder: (context, state) {
              if (state is! AppAuthenticated) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.isBookingsLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final all = state.bookings;

              // Filter and sort bookings using helper
              final validBookings = OwnerHelper.filterValidBookings(all);
              final bookings = OwnerHelper.sortBookings(validBookings);

              if (bookings.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 80,
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد حجوزات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? ColorManager.white70
                                : ColorManager.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final b = bookings[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BookingCard(booking: b, isDark: isDark),
                    );
                  }, childCount: bookings.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
