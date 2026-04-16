import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class AdminPaymentsHeader extends StatelessWidget {
  final bool isDark;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const AdminPaymentsHeader({
    super.key,
    required this.isDark,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(isDark ? 0.2 : 0.05),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorsManager.chaletAccent,
                      ColorsManager.chaletAccent.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.chaletAccent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: ColorsManager.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('admin_payments'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? ColorsManager.white
                            : ColorsManager.chaletTextPrimaryLight,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('admin_payments_review'),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? ColorsManager.white70
                            : ColorsManager.grey600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.black.withOpacity(isDark ? 0.15 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              style: TextStyle(
                color: isDark
                    ? ColorsManager.white
                    : ColorsManager.chaletTextPrimaryLight,
                fontSize: 16,
                height: 1.4,
              ),
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: context.tr('admin_search_payment'),
                hintStyle: TextStyle(
                  color: isDark ? ColorsManager.white70 : ColorsManager.grey700,
                  fontSize: 15,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search_rounded,
                    size: 24,
                    color: isDark
                        ? ColorsManager.white70
                        : ColorsManager.grey600,
                  ),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Material(
                          color: ColorsManager.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: onClearSearch,
                            borderRadius: BorderRadius.circular(8),
                            child: Icon(
                              Icons.clear_rounded,
                              size: 20,
                              color: isDark
                                  ? ColorsManager.white70
                                  : ColorsManager.grey600,
                            ),
                          ),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? ColorsManager.darkGrey252540
                    : ColorsManager.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: isDark
                        ? ColorsManager.white.withOpacity(0.1)
                        : ColorsManager.grey200,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: isDark
                        ? ColorsManager.white.withOpacity(0.1)
                        : ColorsManager.grey200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: ColorsManager.chaletAccent,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  context.tr('admin_all'),
                  'all',
                  Icons.dashboard_outlined,
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  context,
                  context.tr('admin_pending_review'),
                  'pending',
                  Icons.access_time_rounded,
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  context,
                  context.tr('booking_status_confirmed'),
                  'approved',
                  Icons.check_circle_outline_rounded,
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  context,
                  context.tr('booking_status_rejected'),
                  'rejected',
                  Icons.cancel_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = selectedFilter == value;
    final activeColor = ColorsManager.chaletAccent;

    return ChoiceChip(
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected
            ? ColorsManager.white
            : (isDark ? ColorsManager.white70 : ColorsManager.grey600),
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (value == 'all') {
          onFilterChanged('all');
        } else if (isSelected) {
          onFilterChanged('all');
        } else {
          onFilterChanged(value);
        }
      },
      backgroundColor: isDark
          ? ColorsManager.darkBlue1A1A2E
          : ColorsManager.white,
      selectedColor: activeColor,
      labelStyle: TextStyle(
        color: isSelected
            ? ColorsManager.white
            : (isDark
                  ? ColorsManager.white70
                  : ColorsManager.chaletTextPrimaryLight),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      side: BorderSide(
        color: isSelected
            ? ColorsManager.transparent
            : (isDark ? ColorsManager.white10 : ColorsManager.grey300),
      ),
    );
  }
}
