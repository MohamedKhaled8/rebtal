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
  String _norm(String id) {
    if (id.contains(':')) return id.split(':').last.trim();
    return id.trim();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthSuccess) {
        context.read<BookingCubit>().loadBookings();
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
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            title: const Text(
              'حجوزاتي',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<BookingCubit>().loadBookings();
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
              final ownerUidTrim = ownerUid.trim();

              // Since we are now filtering at the source (Firestore),
              // we might not need strict client-side filtering,
              // but keeping it for safety is fine.
              final bookings = all.where((b) {
                final normalizedBookingOwnerId = _norm(b.ownerId);
                final isValidStatus =
                    b.status == BookingStatus.pending ||
                    b.status == BookingStatus.approved ||
                    b.status == BookingStatus.cancelled;
                // If the query works correctly, normalizedBookingOwnerId should match.
                // But let's keep the check.
                return normalizedBookingOwnerId == ownerUidTrim &&
                    isValidStatus;
              }).toList();

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
