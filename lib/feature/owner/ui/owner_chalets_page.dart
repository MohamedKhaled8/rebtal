import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/ui/owner_chalet_Add_screen.dart';
import 'package:rebtal/feature/owner/widget/owner_chalets_list.dart';

class OwnerChaletsPage extends StatefulWidget {
  const OwnerChaletsPage({super.key});

  @override
  State<OwnerChaletsPage> createState() => _OwnerChaletsPageState();
}

class _OwnerChaletsPageState extends State<OwnerChaletsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final appCubit = context.read<AppCubit>();
    final currentUser = appCubit.getCurrentUser();
    final ownerId = currentUser?.uid;

    final scaffoldBg = isDark ? Colors.black : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryBlue = const Color(0xFF2563EB); // Matches User Home Blue

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AppCubit>().fetchOwnerChalets();
        },
        color: primaryBlue,
        backgroundColor: cardColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. CLEAN TOP BAR (Matches User HomeTopBar)
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Profile & Welcome
                        Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryBlue.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: AppImageHelper(
                                  path:
                                      currentUser?.profileImageUrl ??
                                      'https://ui-avatars.com/api/?name=${currentUser?.name ?? 'Owner'}&background=2563EB&color=fff',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'أهلاً بك 👋',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                Text(
                                  currentUser?.name ?? 'المالك',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Right: Add Button (Mini) or Notification
                        // User requested removing notification, so we can keep clean or add a mini add button
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. SEARCH BAR (Matches User Home Style)
            SliverToBoxAdapter(
              child: FadeInDown(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.search_rounded,
                          color: primaryBlue,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ValueListenableBuilder<SearchFilters>(
                            valueListenable: HomeSearch.filters,
                            builder: (context, filters, _) {
                              return TextField(
                                onChanged: HomeSearch.updateQuery,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'ابحث في شاليهاتك...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(
                                    bottom: 4,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. STATS / FILTER CHIPS (Styled Cleanly)
            SliverToBoxAdapter(
              child: FadeIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BlocBuilder<AppCubit, AppState>(
                    builder: (context, state) {
                      final count = state is AppAuthenticated
                          ? state.ownerChalets.length
                          : 0;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _UserStyleChip(
                              label: 'الكل',
                              count: count,
                              isSelected: true,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _UserStyleChip(
                              label: 'نشط',
                              count: count,
                              isSelected: false, // Logic to be added
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _UserStyleChip(
                              label: 'قيد المراجعة',
                              count: 0,
                              isSelected: false,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // 4. SECTION TITLE (Matches User Home "AccentBarTitle")
            SliverToBoxAdapter(
              child: FadeInLeft(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'قائمة الشاليهات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 15)),

            // 5. LIST (Using existing list but animating entrance)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                  child: OwnerChaletsList(
                    status: 'approved',
                    ownerId: ownerId,
                    emptyIcon: Icons.holiday_village_outlined,
                    emptyTitle: 'لا توجد شاليهات',
                    emptySubtitle: 'ابدأ بإضافة شاليهك الأول',
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ), // Space for FAB
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ownerCubit = context.read<AppCubit>().ownerCubit;
          await Navigator.push<bool?>(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: ownerCubit,
                child: const OwnerChaletAddScreen(),
              ),
            ),
          );
        },
        backgroundColor: primaryBlue,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'إضافة شاليه',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _UserStyleChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final bool isDark;

  const _UserStyleChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryBlue
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected
              ? primaryBlue
              : (isDark ? Colors.white10 : Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (count > 0 || isSelected) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : (isDark ? Colors.black26 : Colors.grey.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black54),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
