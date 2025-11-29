import 'package:flutter/material.dart';
import 'package:rebtal/feature/booking/models/booking.dart';

class GuestInfoCard extends StatelessWidget {
  final Booking booking;
  final bool isDark;

  const GuestInfoCard({super.key, required this.booking, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final hasPhone = booking.userPhone?.isNotEmpty ?? false;
    final hasEmail = booking.userEmail?.isNotEmpty ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Avatar and Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 18, color: Colors.white),
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
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (hasPhone || hasEmail) ...[
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
            const SizedBox(height: 16),
          ],

          // Phone
          if (hasPhone)
            _buildContactRow(
              icon: Icons.phone_rounded,
              label: 'رقم الهاتف',
              value: booking.userPhone!,
              color: Colors.green,
              bgColor: Colors.green.withOpacity(0.1),
            ),

          if (hasPhone && hasEmail) const SizedBox(height: 12),

          // Email
          if (hasEmail)
            _buildContactRow(
              icon: Icons.email_rounded,
              label: 'البريد الإلكتروني',
              value: booking.userEmail!,
              color: Colors.orange,
              bgColor: Colors.orange.withOpacity(0.1),
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
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
