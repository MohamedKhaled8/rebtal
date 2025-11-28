import 'package:flutter/material.dart';
import 'package:rebtal/feature/home/widget/public_chalets_list.dart';
import 'package:rebtal/feature/home/widget/header_section.dart';
import 'package:rebtal/feature/home/widget/category_button.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:rebtal/core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  String? _selectedCategoryValue;

  late final List<Map<String, dynamic>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = [
      {'label': 'الكل', 'value': null, 'icon': Icons.grid_view},
      ...AppConstants.chaletCategories,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001409),
      body: CustomScrollView(
        slivers: [
          // 1. Immersive Header
          const SliverToBoxAdapter(child: HeaderSection()),

          // 2. Categories Bar
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 24),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return CategoryButton(
                    label: cat['label'],
                    icon: cat['icon'],
                    isSelected: _selectedCategoryIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                        _selectedCategoryValue = cat['value'];
                      });
                    },
                  );
                },
              ),
            ),
          ),

          // 3. Property Listings
          SliverToBoxAdapter(
            child: Column(
              children: [
                PublicChaletsList(
                  selectedCategory: _selectedCategoryValue,
                  emptyIcon: Icons.home_outlined,
                  emptyTitle: 'لا توجد شاليهات متاحة حالياً',
                  emptySubtitle: 'سيتم عرض الشاليهات هنا عند توفرها',
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 10.h),
          ), // Extra padding for FAB/Nav
        ],
      ),
    );
  }
}
