import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class BookingDatesDisplay extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final bool isDark;

  const BookingDatesDisplay({
    super.key,
    required this.requestData,
    required this.isDark,
  });

  int _calculateDays(dynamic from, dynamic to) {
    try {
      DateTime fromDate;
      DateTime toDate;

      if (from is Timestamp) {
        fromDate = from.toDate();
      } else if (from is String) {
        fromDate = DateTime.parse(from);
      } else if (from is DateTime) {
        fromDate = from;
      } else {
        return 0;
      }

      if (to is Timestamp) {
        toDate = to.toDate();
      } else if (to is String) {
        toDate = DateTime.parse(to);
      } else if (to is DateTime) {
        toDate = to;
      } else {
        return 0;
      }

      return toDate.difference(fromDate).inDays;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final from = requestData['availableFrom'];
    final to = requestData['availableTo'];

    if (from == null || to == null) {
      return const SizedBox.shrink();
    }

    final cubit = context.read<ChaletDetailCubit>();
    final fromDate = cubit.formatDate(from);
    final toDate = cubit.formatDate(to);
    final days = _calculateDays(from, to);

    final textColor = isDark ? Colors.white : const Color(0xFF222222);
    final subColor = isDark ? Colors.white70 : const Color(0xFF717171);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('chalet_detail_booking_period'),
              style: TextStyle(
                fontSize: stv(context: context, mobile: 20.spScaled, tablet: 24.spScaled, desktop: 28.spScaled),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (days > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: stv(context: context, mobile: 10.sw, tablet: 12.sw, desktop: 14.sw),
                  vertical: stv(context: context, mobile: 4.sh, tablet: 5.sh, desktop: 6.sh),
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$days ${context.tr('chalet_detail_nights')}',
                  style: TextStyle(
                    fontSize: stv(context: context, mobile: 11.spScaled, tablet: 13.spScaled, desktop: 15.spScaled),
                    fontWeight: FontWeight.w600,
                    color: subColor,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: otv(context: context, portrait: 24.sh, landscape: 12.sh)),
        Row(
          children: [
            Expanded(
              child: _DateItem(
                label: context.tr('chalet_detail_check_in'),
                date: fromDate,
                icon: Icons.calendar_today_outlined,
                isDark: isDark,
                textColor: textColor,
                subColor: subColor,
              ),
            ),
            Container(
              height: otv(context: context, portrait: 40.sh, landscape: 24.sh),
              width: 1,
              color: isDark ? Colors.white24 : Colors.grey[300],
            ),
            Expanded(
              child: _DateItem(
                label: context.tr('chalet_detail_check_out'),
                date: toDate,
                icon: Icons.calendar_month_outlined,
                isDark: isDark,
                textColor: textColor,
                subColor: subColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateItem extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;
  final bool isDark;
  final Color textColor;
  final Color subColor;

  const _DateItem({
    required this.label,
    required this.date,
    required this.icon,
    required this.isDark,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: stv(context: context, mobile: 12.sw, tablet: 16.sw, desktop: 20.sw),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: stv(context: context, mobile: 18.spScaled, tablet: 20.spScaled, desktop: 22.spScaled),
                color: textColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: stv(context: context, mobile: 13.spScaled, tablet: 15.spScaled, desktop: 17.spScaled),
                  fontWeight: FontWeight.w400,
                  color: subColor,
                ),
              ),
            ],
          ),
          SizedBox(height: otv(context: context, portrait: 8.sh, landscape: 4.sh)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              date,
              style: TextStyle(
                fontSize: stv(context: context, mobile: 15.spScaled, tablet: 17.spScaled, desktop: 19.spScaled),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
