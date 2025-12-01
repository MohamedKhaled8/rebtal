import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';

class RequestDetailsCard extends StatelessWidget {
  const RequestDetailsCard({
    super.key,
    required this.docId,
    required this.requestData,
  });

  final String docId;
  final Map<String, dynamic> requestData;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChaletDetailCubit>();
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Request Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.fingerprint,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Request ID: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                        fontSize: 15,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        docId,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Submitted: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                        fontSize: 15,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        cubit.formatDate(requestData['createdAt']),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.update,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Updated: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                        fontSize: 15,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        cubit.formatDate(
                          requestData['updatedAt'] ?? requestData['createdAt'],
                        ),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
