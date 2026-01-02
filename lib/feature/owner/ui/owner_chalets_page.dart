import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rebtal/feature/owner/widget/owner_chalets_list.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/owner/ui/owner_chalet_Add_screen.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';

class OwnerChaletsPage extends StatelessWidget {
  const OwnerChaletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    // We no longer create a local OwnerCubit.
    // We rely on AppCubit's aggregated OwnerCubit if needed,
    // but OwnerChaletsList actually uses a StreamBuilder internally.

    // Access auth info from AppCubit (Single Source of Truth)
    final appCubit = context.read<AppCubit>();
    final currentUser = appCubit.getCurrentUser();
    final ownerId = currentUser?.uid;

    return Scaffold(
      backgroundColor: isDark
          ? ColorManager.profileSurfaceDark
          : ColorManager.white,
      body: CustomScrollView(
        slivers: [
          // Responsive Header with Search and Add Button
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.25,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: ColorManager.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            ColorManager.profileSurfaceDark,
                            ColorManager.darkBlue1A1A2E,
                          ]
                        : [
                            ColorManager.darkBlue1A1A2E, // Dark Blue
                            ColorManager.darkBlue16213E, // Darker Blue
                            ColorManager.navyBlue0F3460, // Navy Blue
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // Top Row with Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'شاليهاتي',
                              style: TextStyle(
                                color: ColorManager.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Search Bar - Responsive
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDark
                                ? ColorManager.white.withOpacity(0.05)
                                : ColorManager.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: isDark
                                ? Border.all(
                                    color: ColorManager.white.withOpacity(0.1),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Icon(
                                Icons.search,
                                color: isDark
                                    ? ColorManager.white70
                                    : ColorManager.grey600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ValueListenableBuilder<SearchFilters>(
                                  valueListenable: HomeSearch.filters,
                                  builder: (context, filters, _) {
                                    return TextField(
                                      onChanged: (v) =>
                                          HomeSearch.updateQuery(v),
                                      style: TextStyle(
                                        color: isDark
                                            ? ColorManager.white
                                            : ColorManager
                                                  .chaletTextPrimaryLight,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'ابحث عن الشاليهات...',
                                        hintStyle: TextStyle(
                                          color: isDark
                                              ? ColorManager.white70
                                              : ColorManager.grey400,
                                          fontSize: 14,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Add Button - Responsive
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Use GLOBAL persistent OwnerCubit from AppCubit
                              // This ensures data persists if user backs out
                              final ownerCubit = context
                                  .read<AppCubit>()
                                  .ownerCubit;

                              await Navigator.push<bool?>(
                                context,
                                MaterialPageRoute(
                                  // Pass the persistent cubit by value
                                  builder: (context) => BlocProvider.value(
                                    value: ownerCubit,
                                    child: const OwnerChaletAddScreen(),
                                  ),
                                ),
                              );
                              // Refresh done by StreamBuilder automatically
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text(
                              'إضافة شاليه جديد',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.redE94560,
                              foregroundColor: ColorManager.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Chalets List
          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: () async {
                // Trigger any manual reload if needed
                context.read<AppCubit>().fetchOwnerChalets();
              },
              color: ColorManager.redE94560,
              backgroundColor: isDark
                  ? ColorManager.darkBlue1A1A2E
                  : ColorManager.white,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 8,
                  bottom: 100, // مسافة كبيرة للـ BottomNavBar
                ),
                child: OwnerChaletsList(
                  status: 'approved',
                  ownerId: ownerId,
                  emptyIcon: Icons.home_outlined,
                  emptyTitle: 'لا توجد شاليهات موافق عليها',
                  emptySubtitle: 'ستظهر الشاليهات الموافق عليها هنا',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
