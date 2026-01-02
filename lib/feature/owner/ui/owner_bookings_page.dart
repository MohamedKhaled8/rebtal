import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/ui/widgets/booking_card.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class OwnerBookingsPage extends StatefulWidget {
  const OwnerBookingsPage({super.key});

  @override
  State<OwnerBookingsPage> createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends State<OwnerBookingsPage> {
  @override
  void initState() {
    super.initState();
    // AppCubit manages booking loading via listeners
    // but explicit refresh can be triggered if needed.
  }

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

              // Filter bookings
              // We rely on the query to filter by ownerId.
              // Just filter by valid status to exclude temp/corrupt records if any.
              final bookings = all.where((b) {
                return b.status != null;
              }).toList();

              // Sort bookings: Pending/Action Required first, then by date (newest first)
              bookings.sort((a, b) {
                // Priority logic:
                // 1. Pending (requires approval)
                // 2. Payment Under Review (requires verification)
                // 3. Awaiting Payment
                // 4. Approved
                // 5. Others (Completed, Cancelled, Rejected)

                int getPriority(BookingStatus status) {
                  switch (status) {
                    case BookingStatus.pending:
                      return 0;
                    case BookingStatus.paymentUnderReview:
                      return 1;
                    case BookingStatus.awaitingPayment:
                      return 2;
                    case BookingStatus.approved:
                      return 3;
                    default:
                      return 4;
                  }
                }

                final priorityA = getPriority(a.status);
                final priorityB = getPriority(b.status);

                if (priorityA != priorityB) {
                  return priorityA.compareTo(priorityB);
                }

                // If same priority, sort by createdAt (newest first)
                // Fallback to ancient date if createdAt is null so they appear last
                final dateA = a.createdAt ?? DateTime(2000);
                final dateB = b.createdAt ?? DateTime(2000);
                // Reverse compare for descending order
                return dateB.compareTo(dateA);
              });

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
