import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/ui/widgets/booking_card.dart';

class OwnerBookingsPage extends StatefulWidget {
  const OwnerBookingsPage({super.key});

  @override
  State<OwnerBookingsPage> createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends State<OwnerBookingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthSuccess) {
        context.read<BookingCubit>().loadOwnerBookings(authState.user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    String ownerUid = '';
    if (authState is AuthSuccess) ownerUid = authState.user.uid;

    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header بسيط
          SliverAppBar(
            floating: true,
            pinned: false,
            elevation: 0,
            backgroundColor: isDark ? Colors.transparent : Colors.white,
            title: const Text(
              'حجوزاتي',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (ownerUid.isNotEmpty) {
                    context.read<BookingCubit>().loadOwnerBookings(ownerUid);
                  }
                },
              ),
            ],
          ),

          // المحتوى
          BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              if (state.isLoading) {
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
                                ? Colors.white70
                                : Colors.grey.shade700,
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
