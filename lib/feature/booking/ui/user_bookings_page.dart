import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';

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
    // AppCubit automatically loads user data on auth success,
    // but we can trigger a refresh if needed or rely on existing state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppCubit>().state;
      if (appState is AppAuthenticated) {
        // Data should already be loading/loaded by AppCubit's listener
        // But we can ensure it:
        // context.read<AppCubit>().bookingCubit.loadUserBookings(appState.user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access user via AppCubit state
    final appCubit = context.read<AppCubit>();

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
            : ColorManager.black,
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
                final state = appCubit.state;
                if (state is AppAuthenticated) {
                  // Trigger refresh via exposed cubit or method
                  appCubit.bookingCubit.loadUserBookings(state.user.uid);
                  SnackBarHelper.showSuccess(context, 'تم تحديث البيانات');
                }
              },
            ),
          ),
        ],
      ),
      // Use AppCubit for reactive state
      body: BlocBuilder<AppCubit, AppState>(
        buildWhen: (previous, current) {
          if (current is AppAuthenticated && previous is AppAuthenticated) {
            return current.bookings != previous.bookings ||
                current.isBookingsLoading != previous.isBookingsLoading;
          }
          return true;
        },
        builder: (context, state) {
          if (state is! AppAuthenticated) {
            // Not authenticated yet or error
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isBookingsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorManager.primaryColor,
              ),
            );
          }

          // Filter bookings (if needed, though AppCubit loads specific user bookings)
          final currentUid = state.user.uid;
          final userBookings =
              state.bookings; // AppCubit maintains filtered list usually?

          // However, BookingCubit might hold ALL bookings if not careful.
          // AppCubit calls loadUserBookings() which updates state.bookings with that specific list.
          // So state.bookings SHOULD be correct.
          // But to be safe and match previous logic:
          final myBookings = userBookings
              .where((b) => b.userId == currentUid)
              .toList();

          debugPrint(
            '🎨 UserBookingsPage Build: Total Bookings: ${state.bookings.length} -> Mine: ${myBookings.length}',
          );

          if (myBookings.isEmpty) {
            return const EmptyBookingsState();
          }

          // فصل الحجوزات حسب الحالة
          final pendingBookings =
              myBookings
                  .where((b) => b.status == BookingStatus.pending)
                  .toList()
                ..sort((a, b) {
                  final dateA = a.createdAt ?? a.updatedAt ?? DateTime.now();
                  final dateB = b.createdAt ?? b.updatedAt ?? DateTime.now();
                  return dateB.compareTo(dateA);
                });

          final approvedBookings =
              myBookings
                  .where(
                    (b) =>
                        b.status == BookingStatus.approved ||
                        b.status == BookingStatus.awaitingPayment ||
                        b.status == BookingStatus.paymentUnderReview ||
                        b.status == BookingStatus.confirmed ||
                        b.status == BookingStatus.completed ||
                        b.status == BookingStatus.reOffered ||
                        b.status == BookingStatus.pendingOwnerApproval,
                  )
                  .toList()
                ..sort((a, b) {
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
                  if (priorityA != priorityB) {
                    return priorityA.compareTo(priorityB);
                  }

                  final dateA = a.createdAt ?? a.updatedAt ?? DateTime.now();
                  final dateB = b.createdAt ?? b.updatedAt ?? DateTime.now();
                  return dateB.compareTo(dateA);
                });

          final rejectedBookings =
              myBookings
                  .where(
                    (b) =>
                        b.status == BookingStatus.rejected ||
                        b.status == BookingStatus.cancelled,
                  )
                  .toList()
                ..sort((a, b) {
                  final dateA = a.createdAt ?? a.updatedAt ?? DateTime.now();
                  final dateB = b.createdAt ?? b.updatedAt ?? DateTime.now();
                  return dateB.compareTo(dateA);
                });

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
