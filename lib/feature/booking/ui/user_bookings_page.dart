import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/feature/booking/widgets/booking_card_compact.dart';

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
      backgroundColor: isDark ? ColorManager.black : ColorManager.white,
      appBar: AppBar(
        title: const Text(
          'حجوزاتي',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: isDark ? ColorManager.transparent : ColorManager.white,
        foregroundColor: isDark ? ColorManager.white : ColorManager.black,
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
                color: isDark ? ColorManager.black : ColorManager.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: isDark ? Colors.white : Colors.black87,
                  unselectedLabelColor: isDark ? Colors.white54 : Colors.grey.shade600,
                  indicatorColor: const Color(0xFF2563EB),
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: 'الحالية (${current.length})'),
                    Tab(text: 'قيد الانتظار (${pending.length})'),
                    Tab(text: 'السابقة (${previous.length})'),
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
              color: isDark ? ColorManager.white : ColorManager.black,
              size: 22,
            ),
            onPressed: () {
              final state = appCubit.state;
              if (state is AppAuthenticated) {
                appCubit.bookingCubit.loadUserBookings(state.user.uid);
                SnackBarHelper.showSuccess(context, 'تم تحديث البيانات');
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
              child: CircularProgressIndicator(color: ColorManager.primaryColor),
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
    filtered.sort((a, b) {
      final da = a.from;
      final db = b.from;
      return da.compareTo(db);
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
          'لا توجد حجوزات',
          style: TextStyle(
            fontSize: 16,
            color: DynamicThemeManager.isDarkMode(context)
                ? Colors.white54
                : Colors.grey.shade600,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: bookings.length,
      itemBuilder: (context, index) => BookingCardCompact(
        booking: bookings[index],
      ),
    );
  }
}
