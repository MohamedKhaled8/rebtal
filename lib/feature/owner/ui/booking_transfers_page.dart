import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/owner/widget/transfer_card.dart';

class BookingTransfersPage extends StatelessWidget {
  const BookingTransfersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorManager.darkBackground121212
          : ColorManager.profileBackgroundLight,
      appBar: AppBar(
        title: const Text(
          'انتقالات الحجوزات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? ColorManager.transparent : ColorManager.white,
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
                    size: 80,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'لا توجد انتقالات حتى الآن',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                return TransferCard(booking: transfers[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
