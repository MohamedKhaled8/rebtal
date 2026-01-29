import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class BookingCategoriesBar extends StatefulWidget {
  final Function(String?) onCategorySelected;
  final String? selectedCategory;

  const BookingCategoriesBar({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  State<BookingCategoriesBar> createState() => _BookingCategoriesBarState();
}

class _BookingCategoriesBarState extends State<BookingCategoriesBar> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'الكل', 'icon': Icons.apps, 'value': null},
    {'name': 'شواطئ', 'icon': Icons.beach_access, 'value': 'beach'},
    {'name': 'مزارع', 'icon': Icons.agriculture, 'value': 'farm'},
    {'name': 'مسابح', 'icon': Icons.pool, 'value': 'pool'},
    {'name': 'فيلات', 'icon': Icons.villa, 'value': 'villa'},
    {'name': 'شقق', 'icon': Icons.apartment, 'value': 'apartment'},
    {'name': 'ريفي', 'icon': Icons.landscape, 'value': 'nature'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = widget.selectedCategory == category['value'];

          return GestureDetector(
            onTap: () => widget.onCategorySelected(category['value']),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : (isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.withOpacity(0.1)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      category['icon'],
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black54),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
