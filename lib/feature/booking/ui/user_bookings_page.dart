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
        context.read<BookingCubit>().loadBookings();
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
                context.read<BookingCubit>().loadBookings();
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
          final userBookings = state.bookings.where((b) {
            // تطبيع معرف المستخدم للمقارنة
            final normalizedUserId = b.userId.trim();
            final normalizedCurrentUid = currentUid.trim();

            // محاولة مطابقة مختلفة
            final isUserMatch =
                normalizedUserId == normalizedCurrentUid ||
                b.userId == currentUid ||
                b.userId.contains(currentUid) ||
                currentUid.contains(b.userId);

            return isUserMatch;
          }).toList();

          // فصل الحجوزات حسب الحالة
          final pendingBookings = userBookings
              .where((b) => b.status == BookingStatus.pending)
              .toList();
          final approvedBookings = userBookings
              .where((b) => b.status == BookingStatus.approved)
              .toList();
          final rejectedBookings = userBookings
              .where((b) => b.status == BookingStatus.rejected)
              .toList();

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
