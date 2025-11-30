import 'package:flutter/material.dart';

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
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Owner Information',
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
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              children: [
                OwnerInfoRow(
                  icon: Icons.account_circle_outlined,
                  label: "Name",
                  value: merchantName,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                ),
                OwnerInfoRow(
                  icon: Icons.email_outlined,
                  label: "Email",
                  value: email,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                ),
                OwnerInfoRow(
                  icon: Icons.phone_outlined,
                  label: "Phone",
                  value: phoneNumber,
                ),
              ],
            ),
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
        Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
        const SizedBox(width: 12),
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
