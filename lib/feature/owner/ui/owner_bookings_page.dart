import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/owner/widget/booking_card.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/owner/utils/owner_helper.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class OwnerBookingsPage extends StatelessWidget {
  const OwnerBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    // final authState = appCubit.state; // We check state in builder usually

    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.darkBackground121212
          : ColorsManager.profileBackgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header بسيط
          SliverAppBar(
            floating: true,
            pinned: false,
            elevation: 0,
            backgroundColor: isDark
                ? ColorsManager.transparent
                : ColorsManager.white,
            title: Text(
              context.tr('owner_my_bookings'),
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? ColorsManager.white : ColorsManager.black,
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
                          size: 80.sp,
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.sh),
                        Text(
                          context.tr('owner_no_bookings'),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? ColorsManager.white70
                                : ColorsManager.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: stv(
                    context: context,
                    mobile: 16.sw,
                    tablet: 24.sw,
                    desktop: 32.sw,
                  ),
                  vertical: 16.sh,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final b = bookings[index];
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

                        if (showTwoColumns && index % 2 == 0) {
                          final secondIndex = index + 1;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: 8.sw,
                                    bottom: 16.sh,
                                  ),
                                  child: BookingCard(
                                    booking: b,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                              if (secondIndex < bookings.length)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 8.sw,
                                      bottom: 16.sh,
                                    ),
                                    child: BookingCard(
                                      booking: bookings[secondIndex],
                                      isDark: isDark,
                                    ),
                                  ),
                                )
                              else
                                const Expanded(child: SizedBox()),
                            ],
                          );
                        }

                        // Skip the second card when in two-column mode
                        if (showTwoColumns && index % 2 == 1) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: 16.sh,
                            left: stv(
                              context: context,
                              mobile: 0.sw,
                              tablet: 8.sw,
                              desktop: 16.sw,
                            ),
                            right: stv(
                              context: context,
                              mobile: 0.sw,
                              tablet: 8.sw,
                              desktop: 16.sw,
                            ),
                          ),
                          child: BookingCard(booking: b, isDark: isDark),
                        );
                      },
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
