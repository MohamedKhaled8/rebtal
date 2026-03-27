import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class AdminPaymentsEmptyState extends StatelessWidget {
  final bool isDark;
  final bool hasFilters;

  const AdminPaymentsEmptyState({super.key, required this.isDark, this.hasFilters = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark ? ColorsManager.white.withOpacity(0.05) : ColorsManager.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.search_off : Icons.payment, 
              size: 80, 
              color: ColorsManager.grey400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            hasFilters ? 'لا توجد نتائج' : 'لا توجد طلبات دفع',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorsManager.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
