import 'package:flutter/material.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/booking_helper.dart';

class GuestInfoCard extends StatelessWidget {
  final Booking booking;
  final bool isDark;

  const GuestInfoCard({super.key, required this.booking, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Show phone/email with placeholder if missing
    final phone = booking.userPhone?.isNotEmpty == true
        ? booking.userPhone!
        : 'غير متوفر';
    final email = booking.userEmail?.isNotEmpty == true
        ? booking.userEmail!
        : 'غير متوفر';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? ColorManager.white.withOpacity(0.05)
            : ColorManager.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ColorManager.white10 : ColorManager.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuestHeader(name: booking.userName, isDark: isDark),

          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? ColorManager.white10 : ColorManager.grey200,
          ),
          const SizedBox(height: 16),

          // Dates Section
          Row(
            children: [
              Expanded(
                child: _DateColumn(
                  label: 'تاريخ الوصول',
                  date: booking.from,
                  icon: Icons.login_rounded,
                  color: ColorManager.green,
                  isDark: isDark,
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: isDark ? ColorManager.white10 : ColorManager.grey300,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _DateColumn(
                  label: 'تاريخ المغادرة',
                  date: booking.to,
                  icon: Icons.logout_rounded,
                  color: ColorManager.red,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? ColorManager.white10 : ColorManager.grey200,
          ),
          const SizedBox(height: 16),

          // Contact Info - Always show
          ContactRow(
            icon: Icons.phone_rounded,
            label: 'رقم الهاتف',
            value: phone,
            color: ColorManager.green,
            bgColor: ColorManager.green.withOpacity(0.1),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ContactRow(
            icon: Icons.email_rounded,
            label: 'البريد الإلكتروني',
            value: email,
            color: ColorManager.orange,
            bgColor: ColorManager.orange.withOpacity(0.1),
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
            color: ColorManager.chaletActionBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 18, color: ColorManager.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'معلومات الضيف',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? ColorManager.white70 : ColorManager.grey600,
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
                      ? ColorManager.white
                      : ColorManager.chaletTextPrimaryLight,
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
