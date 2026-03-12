import 'package:flutter/material.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/booking_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class GuestInfoCard extends StatelessWidget {
  final Booking booking;
  final bool isDark;

  const GuestInfoCard({super.key, required this.booking, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Show phone/email with placeholder if missing
    final phone = booking.userPhone?.isNotEmpty == true
        ? booking.userPhone!
        : context.tr('common_unavailable');
    final email = booking.userEmail?.isNotEmpty == true
        ? booking.userEmail!
        : context.tr('common_unavailable');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.white.withOpacity(0.05)
            : ColorsManager.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ColorsManager.white10 : ColorsManager.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuestHeader(name: booking.userName, isDark: isDark),

          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? ColorsManager.white10 : ColorsManager.grey200,
          ),
          const SizedBox(height: 16),

          // Dates Section
          Row(
            children: [
              Expanded(
                child: _DateColumn(
                  label: context.tr('booking_arrival'),
                  date: booking.from,
                  icon: Icons.login_rounded,
                  color: ColorsManager.green,
                  isDark: isDark,
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: isDark ? ColorsManager.white10 : ColorsManager.grey300,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _DateColumn(
                  label: context.tr('booking_departure'),
                  date: booking.to,
                  icon: Icons.logout_rounded,
                  color: ColorsManager.red,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? ColorsManager.white10 : ColorsManager.grey200,
          ),
          const SizedBox(height: 16),

          // Contact Info - Always show
          ContactRow(
            icon: Icons.phone_rounded,
            label: context.tr('common_phone'),
            value: phone,
            color: ColorsManager.green,
            bgColor: ColorsManager.green.withOpacity(0.1),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ContactRow(
            icon: Icons.email_rounded,
            label: context.tr('common_email'),
            value: email,
            color: ColorsManager.orange,
            bgColor: ColorsManager.orange.withOpacity(0.1),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  final String name;
  final bool isDark;
  const _GuestHeader({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: ColorsManager.chaletActionBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 18, color: ColorsManager.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('admin_guest_info'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ColorsManager.white
                      : ColorsManager.chaletTextPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final bool isDark;

  const ContactRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final DateTime date;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _DateColumn({
    required this.label,
    required this.date,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          BookingHelper.formatDate(date),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
