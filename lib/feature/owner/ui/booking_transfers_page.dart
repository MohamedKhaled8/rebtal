import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/owner/widget/transfer_card.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class BookingTransfersPage extends StatelessWidget {
  const BookingTransfersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.darkBackground121212
          : ColorsManager.profileBackgroundLight,
      appBar: AppBar(
        title: Text(
          context.tr('owner_booking_transfers'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark
            ? ColorsManager.transparent
            : ColorsManager.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final appCubit = context.read<AppCubit>();
          final state = appCubit.state;
          if (state is AppAuthenticated) {
            await appCubit.bookingCubit.loadOwnerBookings(state.user.uid);
          }
        },
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            if (state is! AppAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter bookings that have been transferred
            final transfers =
                state.bookings
                    .where(
                      (b) =>
                          b.originalTenantId != null &&
                          b.originalTenantId!.isNotEmpty,
                    )
                    .toList()
                  ..sort(
                    (a, b) => (b.transferredAt ?? DateTime.now()).compareTo(
                      a.transferredAt ?? DateTime.now(),
                    ),
                  );

            if (transfers.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 80.sp,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  SizedBox(height: 16.sh),
                  Center(
                    child: Text(
                      context.tr('owner_no_transfers'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
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
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: stv(
                        context: context,
                        mobile: 16.sw,
                        tablet: 24.sw,
                        desktop: 32.sw,
                      ),
                      vertical: 16.sh,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: (transfers.length / 2).ceil(),
                    itemBuilder: (context, i) {
                      final firstIndex = i * 2;
                      final secondIndex = firstIndex + 1;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: 8.sw,
                                bottom: 16.sh,
                              ),
                              child: TransferCard(
                                booking: transfers[firstIndex],
                              ),
                            ),
                          ),
                          if (secondIndex < transfers.length)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 8.sw,
                                  bottom: 16.sh,
                                ),
                                child: TransferCard(
                                  booking: transfers[secondIndex],
                                ),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: stv(
                      context: context,
                      mobile: 16.sw,
                      tablet: 24.sw,
                      desktop: 32.sw,
                    ),
                    vertical: 16.sh,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: transfers.length,
                  itemBuilder: (context, index) {
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
                      child: TransferCard(booking: transfers[index]),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
