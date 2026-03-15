import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/ui/owner_chalet_Add_screen.dart';
import 'package:rebtal/feature/owner/widget/owner_chalets_list.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class OwnerChaletsPage extends StatefulWidget {
  const OwnerChaletsPage({super.key});

  @override
  State<OwnerChaletsPage> createState() => _OwnerChaletsPageState();
}

class _OwnerChaletsPageState extends State<OwnerChaletsPage> {
  String _selectedStatus = '';

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
                  padding: EdgeInsets.fromLTRB(20.sw, 10.sh, 20.sw, 10.sh),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Profile & Welcome
                        Row(
                          children: [
                            Container(
                              width: 45.sp,
                              height: 45.sp,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryBlue.withOpacity(0.2),
                                  width: 2.sp,
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
                            SizedBox(width: 12.sw),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${context.tr('owner_welcome')} 👋',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                Text(
                                  currentUser?.name ??
                                      context.tr('owner_default_name'),
                                  style: TextStyle(
                                    fontSize: 16.sp,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.sw,
                    vertical: 15.sh,
                  ),
                  child: Container(
                    height: 50.sp,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16.sp),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 16.sw),
                        Icon(
                          Icons.search_rounded,
                          color: primaryBlue,
                          size: 22.sp,
                        ),
                        SizedBox(width: 12.sw),
                        Expanded(
                          child: ValueListenableBuilder<SearchFilters>(
                            valueListenable: HomeSearch.filters,
                            builder: (context, filters, _) {
                              return TextField(
                                onChanged: HomeSearch.updateQuery,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 14.sp,
                                ),
                                decoration: InputDecoration(
                                  hintText: context.tr('owner_search_chalets'),
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                    fontSize: 14.sp,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(bottom: 4.sp),
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

            // 3. STATS / FILTER CHIPS - REMOVED as per user request
            // Instead showing a single summary chip
            SliverToBoxAdapter(
              child: FadeIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sw),
                  child: BlocBuilder<AppCubit, AppState>(
                    builder: (context, state) {
                      final allCount = state is AppAuthenticated
                          ? state.ownerChalets.length
                          : 0;
                      final pendingCount = state is AppAuthenticated
                          ? state.ownerChalets.where((c) {
                              final map = _chaletToMapSimple(c);
                              return map['status'] == 'pending';
                            }).length
                          : 0;
                      final approvedCount = state is AppAuthenticated
                          ? state.ownerChalets.where((c) {
                              final map = _chaletToMapSimple(c);
                              return map['status'] == 'approved';
                            }).length
                          : 0;
                      final rejectedCount = state is AppAuthenticated
                          ? state.ownerChalets.where((c) {
                              final map = _chaletToMapSimple(c);
                              return map['status'] == 'rejected';
                            }).length
                          : 0;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _UserStyleChip(
                              label: '${context.tr('owner_all')} ($allCount)',
                              count: allCount,
                              isSelected: _selectedStatus.isEmpty,
                              isDark: isDark,
                              onTap: () => setState(() => _selectedStatus = ''),
                            ),
                            SizedBox(width: 10.sw),
                            _UserStyleChip(
                              label:
                                  '${context.tr('booking_status_pending')} ($pendingCount)',
                              count: pendingCount,
                              isSelected: _selectedStatus == 'pending',
                              isDark: isDark,
                              color: Colors.orange,
                              onTap: () => setState(() => _selectedStatus = 'pending'),
                            ),
                            SizedBox(width: 10.sw),
                            _UserStyleChip(
                              label:
                                  '${context.tr('common_approved')} ($approvedCount)',
                              count: approvedCount,
                              isSelected: _selectedStatus == 'approved',
                              isDark: isDark,
                              color: Colors.green,
                              onTap: () => setState(() => _selectedStatus = 'approved'),
                            ),
                            SizedBox(width: 10.sw),
                            _UserStyleChip(
                              label:
                                  '${context.tr('common_rejected')} ($rejectedCount)',
                              count: rejectedCount,
                              isSelected: _selectedStatus == 'rejected',
                              isDark: isDark,
                              color: Colors.red,
                              onTap: () => setState(() => _selectedStatus = 'rejected'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 25.sp)),

            // 4. SECTION TITLE (Matches User Home "AccentBarTitle")
            SliverToBoxAdapter(
              child: FadeInLeft(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sw),
                  child: Row(
                    children: [
                      Container(
                        width: 4.sp,
                        height: 24.sp,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(4.sp),
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Text(
                        context.tr('nav_chalets'),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 15.sh)),

            // 5. LIST (Using existing list but animating entrance)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp),
              sliver: SliverToBoxAdapter(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                  child: OwnerChaletsList(
                    status: _selectedStatus, // Filter chalets based on selected status
                    ownerId: ownerId,
                    emptyIcon: Icons.holiday_village_outlined,
                    emptyTitle: context.tr('owner_no_chalets'),
                    emptySubtitle: context.tr('owner_start_add_first'),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: 100.sp),
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
        icon: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
        label: Text(
          context.tr('owner_add_chalet'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  /// Convert chalet to Map<String, dynamic> for status checking
  Map<String, dynamic> _chaletToMapSimple(dynamic chalet) {
    if (chalet is Map<String, dynamic>) {
      return chalet;
    }

    // Try to access properties directly
    try {
      final map = <String, dynamic>{};
      // Get status field using reflection-like access
      final status = (chalet as dynamic).status;
      if (status != null) {
        map['status'] = status is String
            ? status
            : status.toString().split('.').last;
      } else {
        map['status'] = 'pending';
      }
      return map;
    } catch (e) {
      return {'status': 'pending'};
    }
  }
}

class _UserStyleChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final bool isDark;
  final Color? color;
  final VoidCallback? onTap;

  const _UserStyleChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.isDark,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF2563EB);
    final chipColor = color ?? primaryBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sw, vertical: 8.sh),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(30.sp),
          border: Border.all(
            color: isSelected
                ? chipColor
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
              fontSize: 14.sp,
            ),
          ),
          if (count > 0 || isSelected) ...[
            SizedBox(width: 8.sp),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : (isDark ? Colors.black26 : Colors.grey.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(10.sp),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black54),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}
