import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/config/space.dart';
// import 'package:screen_go/extensions/responsive_nums.dart';

class OwnerInformationCard extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const OwnerInformationCard({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    // Extract data with null safety
    final merchantName = requestData['merchantName'] ?? 'Not provided';
    final email = requestData['email'] ?? 'No email';
    final phoneNumber = requestData['phoneNumber'] ?? 'No phone';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              horizintalSpace(4),
              const Text(
                'Owner Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          verticalSpace(2),
          OwnerInfoRow(icon: Icons.person, label: "Name", value: merchantName),
          const SizedBox(height: 12),
          OwnerInfoRow(
            icon: Icons.email_outlined,
            label: "Email",
            value: email,
          ),
          const SizedBox(height: 12),
          OwnerInfoRow(
            icon: Icons.phone_outlined,
            label: "Phone",
            value: phoneNumber,
          ),
        ],
      ),
    );
  }
}

class OwnerInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const OwnerInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 18),
        horizintalSpace(4),
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 16),
          ),
        ),
      ],
    );
  }
}
