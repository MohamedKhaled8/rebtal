import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';

import 'package:rebtal/feature/booking/widgets/bookings_list.dart';
import 'package:rebtal/feature/booking/widgets/empty_bookings_state.dart';

class UserBookingsPage extends StatefulWidget {
  const UserBookingsPage({super.key});

  @override
  State<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthSuccess) {
        context.read<BookingCubit>().loadUserBookings(authState.user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    String currentUid = '';
    if (authState is AuthSuccess) currentUid = authState.user.uid;

    return Scaffold(
      backgroundColor: DynamicThemeManager.isDarkMode(context)
          ? ColorManager.black
          : ColorManager.white,
      appBar: AppBar(
        title: const Text(
          'حجوزاتي',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: DynamicThemeManager.isDarkMode(context)
            ? ColorManager.transparent
            : ColorManager.white,
        foregroundColor: DynamicThemeManager.isDarkMode(context)
            ? ColorManager.white
            : ColorManager.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DynamicThemeManager.isDarkMode(context)
                      ? ColorManager.black.withOpacity(0.06)
                      : ColorManager.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: DynamicThemeManager.isDarkMode(context)
                      ? ColorManager.white
                      : ColorManager.black,
                  size: 20,
                ),
              ),
              onPressed: () {
                if (currentUid.isNotEmpty) {
                  context.read<BookingCubit>().loadUserBookings(currentUid);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم تحديث البيانات'),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // تصفية جميع الحجوزات للمستخدم الحالي
          // Since we are filtering at source, we can just use state.bookings
          // But keeping client-side filter for safety is okay.
          debugPrint(
            '🎨 UserBookingsPage Build: Total Bookings in State: ${state.bookings.length}',
          );

          final userBookings = state.bookings.where((b) {
            // تطبيع معرف المستخدم للمقارنة
            final normalizedUserId = b.userId.trim();
            final normalizedCurrentUid = currentUid.trim();

            // مطابقة دقيقة فقط
            final isMatch = normalizedUserId == normalizedCurrentUid;
            if (!isMatch) {
              debugPrint(
                '❌ Filter Mismatch: Booking ${b.id} has UserID "$normalizedUserId" vs Current "$normalizedCurrentUid"',
              );
            }
            return isMatch;
          }).toList();

          debugPrint('✅ Final Bookings for UI: ${userBookings.length}');

          // فصل الحجوزات حسب الحالة
          final pendingBookings =
              userBookings
                  .where((b) => b.status == BookingStatus.pending)
                  .toList()
                ..sort((a, b) {
                  // Fallback chain: createdAt -> updatedAt -> Now (assumed new)
                  final dateA = a.createdAt ?? a.updatedAt ?? DateTime.now();
                  final dateB = b.createdAt ?? b.updatedAt ?? DateTime.now();
                  return dateB.compareTo(dateA);
                });

          // Approved bookings now encompass the entire active lifecycle after approval
          final approvedBookings =
              userBookings
                  .where(
                    (b) =>
                        b.status == BookingStatus.approved ||
                        b.status == BookingStatus.awaitingPayment ||
                        b.status == BookingStatus.paymentUnderReview ||
                        b.status == BookingStatus.confirmed ||
                        b.status == BookingStatus.completed,
                  )
                  .toList()
                ..sort((a, b) {
                  // Prioritize payment under review and approved
                  int getPriority(BookingStatus status) {
                    switch (status) {
                      case BookingStatus.paymentUnderReview:
                        return 0;
                      case BookingStatus.awaitingPayment:
                        return 1;
                      case BookingStatus.approved:
                        return 2;
                      case BookingStatus.confirmed:
                        return 3;
                      case BookingStatus.completed:
                        return 4;
                      default:
                        return 5;
                    }
                  }

                  final priorityA = getPriority(a.status);
                  final priorityB = getPriority(b.status);
                  if (priorityA != priorityB)
                    return priorityA.compareTo(priorityB);

                  // Fallback chain: createdAt -> updatedAt -> Now
                  final dateA = a.createdAt ?? a.updatedAt ?? DateTime.now();
                  final dateB = b.createdAt ?? b.updatedAt ?? DateTime.now();
                  return dateB.compareTo(dateA);
                });

          final rejectedBookings =
              userBookings
                  .where(
                    (b) =>
                        b.status == BookingStatus.rejected ||
                        b.status == BookingStatus.cancelled,
                  )
                  .toList()
                ..sort((a, b) {
                  // Fallback chain: createdAt -> updatedAt -> Now
                  final dateA = a.createdAt ?? a.updatedAt ?? DateTime.now();
                  final dateB = b.createdAt ?? b.updatedAt ?? DateTime.now();
                  return dateB.compareTo(dateA);
                });

          if (userBookings.isEmpty) {
            return const EmptyBookingsState();
          }

          return BookingsList(
            pendingBookings: pendingBookings,
            approvedBookings: approvedBookings,
            rejectedBookings: rejectedBookings,
          );
        },
      ),
    );
  }
}
