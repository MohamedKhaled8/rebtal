import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/admin/logic/cubit/admin_cubit.dart';

class AvailabilityCard extends StatelessWidget {
  const AvailabilityCard({super.key, required this.requestData});

  final Map<String, dynamic> requestData;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    final isAvailable = requestData['isAvailable'] == true;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Availability',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAvailable
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAvailable
                    ? const Color(0xFF10B981).withOpacity(0.2)
                    : const Color(0xFFEF4444).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isAvailable
                            ? const Color(0xFF10B981).withOpacity(0.2)
                            : const Color(0xFFEF4444).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isAvailable ? Icons.check_rounded : Icons.close_rounded,
                    color: isAvailable
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAvailable ? 'Available Now' : 'Currently Unavailable',
                      style: TextStyle(
                        color: isAvailable
                            ? const Color(0xFF065F46)
                            : const Color(0xFF991B1B),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (!isAvailable)
                      Text(
                        'Check back later',
                        style: TextStyle(
                          color: const Color(0xFFEF4444).withOpacity(0.8),
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
          Row(
            children: [
              Expanded(
                child: _buildDateBox(
                  label: 'From',
                  date:
                      cubit.formatAvailabilityDate(
                        requestData['availableFrom'],
                      ) ??
                      '--',
                  icon: Icons.login_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateBox(
                  label: 'To',
                  date:
                      cubit.formatAvailabilityDate(
                        requestData['availableTo'],
                      ) ??
                      '--',
                  icon: Icons.logout_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox({
    required String label,
    required String date,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
