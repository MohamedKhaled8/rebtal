import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';
import 'package:rebtal/feature/chalet/widget/date_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityCard extends StatelessWidget {
  const AvailabilityCard({super.key, required this.requestData});

  final Map<String, dynamic> requestData;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChaletDetailCubit, ChaletDetailState>(
      builder: (context, state) {
        final cubit = context.read<ChaletDetailCubit>();

        // Priority: State (fetched) > RequestData > Null
        List<dynamic>? bookedDates = requestData['bookedDates'];
        if (state is ChaletDetailLoaded && state.bookedDates != null) {
          bookedDates = state.bookedDates;
        }

        // Check availability from multiple sources with fallback
        final bookingAvailability = requestData['bookingAvailability'];
        final isAvailableFromBooking =
            bookingAvailability == 'available' || bookingAvailability == null;
        final isAvailableFromFlag = requestData['isAvailable'] == true;
        final isAvailable =
            isAvailableFromFlag ||
            (requestData['isAvailable'] == null && isAvailableFromBooking);

        final isDark = DynamicThemeManager.isDarkMode(context);

        // Debug: Print data to verify (uncomment if needed)
        // print('📋 AvailabilityCard - Data received:');
        // print('   - All keys: ${requestData.keys.toList()}');
        // print('   - isAvailable: $isAvailable');
        // print('   - bookingAvailability: $bookingAvailability');
        // print('   - bookedDates: $bookedDates');
        // print('   - availableFrom: ${requestData['availableFrom']}');
        // print('   - availableTo: ${requestData['availableTo']}');

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? ColorManager.chaletCardDark
                : ColorManager.chaletCardLight,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorManager.chaletAvailableGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: ColorManager.chaletAvailableGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Availability',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? ColorManager.chaletTextPrimaryDark
                          : ColorManager.chaletTextPrimaryLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  DateBox(
                    label: 'From',
                    date: cubit.formatDate(requestData['availableFrom']),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  DateBox(
                    label: 'To',
                    date: cubit.formatDate(requestData['availableTo']),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? (isDark
                            ? ColorManager.chaletAvailableDarkGreen.withOpacity(
                                0.3,
                              )
                            : ColorManager.chaletAvailableLightGreen)
                      : (isDark
                            ? ColorManager.chaletUnavailableDarkRed.withOpacity(
                                0.3,
                              )
                            : ColorManager.chaletUnavailableLightRed),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAvailable
                        ? ColorManager.chaletAvailableGreen.withOpacity(0.2)
                        : ColorManager.chaletUnavailableRed.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorManager.chaletCardDark
                            : ColorManager.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isAvailable
                                ? ColorManager.chaletAvailableGreen.withOpacity(
                                    0.2,
                                  )
                                : ColorManager.chaletUnavailableRed.withOpacity(
                                    0.2,
                                  ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isAvailable ? Icons.check_rounded : Icons.close_rounded,
                        color: isAvailable
                            ? ColorManager.chaletAvailableGreen
                            : ColorManager.chaletUnavailableRed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAvailable
                              ? 'Available Now'
                              : 'Currently Unavailable',
                          style: TextStyle(
                            color: isAvailable
                                ? ColorManager.chaletAvailableGreen
                                : ColorManager.chaletUnavailableRed,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        if (!isAvailable)
                          Text(
                            'Check back later',
                            style: TextStyle(
                              color: ColorManager.chaletUnavailableRed
                                  .withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _BookedDatesList(
                bookedDates: bookedDates,
                isDark: isDark,
                cubit: cubit,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookedDatesList extends StatelessWidget {
  final dynamic bookedDates;
  final bool isDark;
  final ChaletDetailCubit cubit;

  const _BookedDatesList({
    required this.bookedDates,
    required this.isDark,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    if (bookedDates == null ||
        (bookedDates is List && (bookedDates as List).isEmpty)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available,
                size: 16,
                color: ColorManager.chaletAvailableGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Booked Dates',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? ColorManager.chaletTextPrimaryDark
                      : ColorManager.chaletTextPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? ColorManager.chaletIconBackgroundDark
                  : ColorManager.greyF9FAFB,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? ColorManager.white10
                    : ColorManager.chaletGrey100,
              ),
            ),
            child: Text(
              'No dates booked yet - Available for booking',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? ColorManager.chaletGrey400
                    : ColorManager.chaletGrey600,
              ),
            ),
          ),
        ],
      );
    }

    final List<dynamic> dates = bookedDates as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event_busy,
              size: 16,
              color: ColorManager.chaletUnavailableRed,
            ),
            const SizedBox(width: 8),
            Text(
              'Booked Dates',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? ColorManager.chaletTextPrimaryDark
                    : ColorManager.chaletTextPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dates.take(5).map((date) {
            String formattedDate = '';
            if (date is Timestamp) {
              formattedDate = cubit.formatDate(date);
            } else if (date is String) {
              formattedDate = date;
            } else if (date is DateTime) {
              formattedDate = cubit.formatDate(date);
            } else {
              formattedDate = date.toString();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ColorManager.chaletUnavailableRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColorManager.chaletUnavailableRed.withOpacity(0.3),
                ),
              ),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.chaletUnavailableRed,
                ),
              ),
            );
          }).toList(),
        ),
        if (dates.length > 5) ...[
          const SizedBox(height: 8),
          Text(
            '+ ${dates.length - 5} more dates',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark
                  ? ColorManager.chaletGrey400
                  : ColorManager.chaletGrey600,
            ),
          ),
        ],
      ],
    );
  }
}
