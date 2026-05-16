import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/feature/booking/widgets/booking_card_compact.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class UserBookingsPage extends StatefulWidget {
  const UserBookingsPage({super.key});

  @override
  State<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? ColorsManager.black : ColorsManager.white,
      appBar: AppBar(
        title: Text(
          context.tr('booking_my_bookings'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: stv(context: context, mobile: 20.spScaled, tablet: 24.spScaled, desktop: 28.spScaled)),
        ),
        centerTitle: true,
        backgroundColor: isDark
            ? ColorsManager.transparent
            : ColorsManager.white,
        foregroundColor: isDark ? ColorsManager.white : ColorsManager.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: BlocBuilder<AppCubit, AppState>(
            buildWhen: (prev, curr) =>
                curr is AppAuthenticated &&
                (prev is! AppAuthenticated ||
                    prev.bookings != curr.bookings ||
                    prev.isBookingsLoading != curr.isBookingsLoading),
            builder: (context, state) {
              if (state is! AppAuthenticated) return const SizedBox.shrink();
              final myBookings = state.bookings
                  .where((b) => b.userId == state.user.uid)
                  .toList();
              final current = _filterCurrent(myBookings);
              final pending = _filterPending(myBookings);
              final previous = _filterPrevious(myBookings);
              return Container(
                color: isDark ? ColorsManager.black : ColorsManager.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: isDark ? Colors.white : Colors.black87,
                  unselectedLabelColor: isDark
                      ? Colors.white54
                      : Colors.grey.shade600,
                  indicatorColor: const Color(0xFF2563EB),
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      text:
                          '${context.tr('booking_current')} (${current.length})',
                    ),
                    Tab(
                      text:
                          '${context.tr('booking_pending')} (${pending.length})',
                    ),
                    Tab(
                      text:
                          '${context.tr('booking_previous')} (${previous.length})',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? ColorsManager.white : ColorsManager.black,
              size: stv(context: context, mobile: 22.spScaled, tablet: 26.spScaled, desktop: 30.spScaled),
            ),
            onPressed: () {
              final state = appCubit.state;
              if (state is AppAuthenticated) {
                appCubit.bookingCubit.loadUserBookings(state.user.uid);
                SnackBarHelper.showSuccess(
                  context,
                  context.tr('booking_data_updated'),
                );
              }
            },
          ),
        ],
      ),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isBookingsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorsManager.primaryColor,
              ),
            );
          }

          final myBookings = state.bookings
              .where((b) => b.userId == state.user.uid)
              .toList();
          final current = _filterCurrent(myBookings);
          final pending = _filterPending(myBookings);
          final previous = _filterPrevious(myBookings);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(context, current),
              _buildList(context, pending),
              _buildList(context, previous),
            ],
          );
        },
      ),
    );
  }

  List<Booking> _filterCurrent(List<Booking> list) {
    final filtered = list
        .where(
          (b) =>
              b.status == BookingStatus.approved ||
              b.status == BookingStatus.awaitingPayment ||
              b.status == BookingStatus.paymentUnderReview ||
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.completed,
        )
        .toList();
    // Newest activity first (last booked / approved / status change).
    filtered.sort((a, b) {
      final ta = a.updatedAt ?? a.createdAt ?? a.from;
      final tb = b.updatedAt ?? b.createdAt ?? b.from;
      return tb.compareTo(ta);
    });
    return filtered;
  }

  List<Booking> _filterPending(List<Booking> list) {
    final filtered = list
        .where(
          (b) =>
              b.status == BookingStatus.pending ||
              b.status == BookingStatus.reOffered ||
              b.status == BookingStatus.pendingOwnerApproval,
        )
        .toList();
    filtered.sort((a, b) {
      final da = a.createdAt ?? a.updatedAt ?? DateTime.now();
      final db = b.createdAt ?? b.updatedAt ?? DateTime.now();
      return db.compareTo(da);
    });
    return filtered;
  }

  List<Booking> _filterPrevious(List<Booking> list) {
    final filtered = list
        .where(
          (b) =>
              b.status == BookingStatus.rejected ||
              b.status == BookingStatus.cancelled,
        )
        .toList();
    filtered.sort((a, b) {
      final da = a.updatedAt ?? a.createdAt ?? DateTime.now();
      final db = b.updatedAt ?? b.createdAt ?? DateTime.now();
      return db.compareTo(da);
    });
    return filtered;
  }

  Widget _buildList(BuildContext context, List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          context.tr('booking_no_bookings'),
          style: TextStyle(
            fontSize: stv(
              context: context,
              mobile: 16.spScaled,
              tablet: 18.spScaled,
              desktop: 20.spScaled,
            ),
            color: DynamicThemeManager.isDarkMode(context)
                ? Colors.white54
                : Colors.grey.shade600,
          ),
        ),
      );
    }

    return Builder(
      builder: (context) {
        final bool showTwoColumns = otv(
          context: context,
          portrait: stv(
            context: context,
            mobile: false,
            tablet: true,
            desktop: true,
          ),
          landscape: true,
        );

        if (showTwoColumns) {
          final int rowCount = (bookings.length / 2).ceil();
          return ListView.builder(
            padding: EdgeInsets.only(
              top: otv(context: context, portrait: 16.sh, landscape: 8.sh),
              bottom: otv(context: context, portrait: 100.sh, landscape: 50.sh),
            ),
            itemCount: rowCount,
            itemBuilder: (context, index) {
              final firstIndex = index * 2;
              final secondIndex = firstIndex + 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BookingCardCompact(
                      booking: bookings[firstIndex],
                      margin: _getBookingCardMargin(context, isLeft: true),
                    ),
                  ),
                  if (secondIndex < bookings.length)
                    Expanded(
                      child: BookingCardCompact(
                        booking: bookings[secondIndex],
                        margin: _getBookingCardMargin(context, isLeft: false),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox.shrink()),
                ],
              );
            },
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(
            top: otv(context: context, portrait: 8.sh, landscape: 4.sh),
            bottom: otv(context: context, portrait: 100.sh, landscape: 50.sh),
          ),
          itemCount: bookings.length,
          itemBuilder: (context, index) => BookingCardCompact(
            booking: bookings[index],
            margin: _getBookingCardMargin(context),
          ),
        );
      },
    );
  }

  EdgeInsetsGeometry _getBookingCardMargin(BuildContext context, {bool? isLeft}) {
    return EdgeInsets.only(
      bottom: otv(context: context, portrait: 24.sh, landscape: 12.sh),
      left:
          isLeft == null
              ? stv(context: context, mobile: 16.sw, tablet: 24.sw, desktop: 32.sw)
              : (isLeft == true
                  ? stv(context: context, mobile: 16.sw, tablet: 24.sw, desktop: 32.sw)
                  : stv(context: context, mobile: 12.sw, tablet: 16.sw, desktop: 20.sw)),
      right:
          isLeft == null
              ? stv(context: context, mobile: 16.sw, tablet: 24.sw, desktop: 32.sw)
              : (isLeft == true
                  ? stv(context: context, mobile: 12.sw, tablet: 16.sw, desktop: 20.sw)
                  : stv(context: context, mobile: 16.sw, tablet: 24.sw, desktop: 32.sw)),
    );
  }
}
