import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';

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
              "Booking Period",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (days > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$days Nights',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: subColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _DateItem(
                label: "Check-in",
                date: fromDate,
                icon: Icons.calendar_today_outlined,
                isDark: isDark,
                textColor: textColor,
                subColor: subColor,
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: isDark ? Colors.white24 : Colors.grey[300],
            ),
            Expanded(
              child: _DateItem(
                label: "Check-out",
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: subColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
