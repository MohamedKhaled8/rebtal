import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/auth_restriction_helper.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/ui/owner_chalet_Add_screen.dart';
import 'package:rebtal/feature/owner/widget/owner_chalets_list.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:rebtal/feature/navigation/ui/bottom_nav_controller.dart';

class OwnerChaletsPage extends StatefulWidget {
  const OwnerChaletsPage({super.key});

  @override
  State<OwnerChaletsPage> createState() => _OwnerChaletsPageState();
}

class _OwnerChaletsPageState extends State<OwnerChaletsPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  String _selectedStatus = '';
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350), // Snappy and instant
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.02), // subtle premium lift
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Listen to bottom navigation changes to replay animation on tab switch
    bottomNavIndex.addListener(_handleTabChange);

    // Play initial animation if this is the active tab
    if (bottomNavIndex.value == 0) {
      _animationController.forward();
    }
  }

  void _handleTabChange() {
    if (!mounted) return;
    if (bottomNavIndex.value == 0) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    bottomNavIndex.removeListener(_handleTabChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = DynamicThemeManager.isDarkMode(context);
    final appCubit = context.read<AppCubit>();
    final currentUser = appCubit.getCurrentUser();
    final ownerId = currentUser?.uid;

    final scaffoldBg = isDark ? Colors.black : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<AppCubit>().fetchOwnerChalets();
            },
            color: primaryBlue,
            backgroundColor: cardColor,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.sw, 10.sh, 20.sw, 10.sh),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 45.sp,
                                height: 45.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryBlue.withValues(alpha: 0.2),
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
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.sw,
                      vertical: 15.sh,
                    ),
                    child: Container(
                      height: 50.sp,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16.sp),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.withValues(alpha: 0.1),
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
                                  onChanged: HomeSearch.updateQueryDebounced,
                                  style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    fontSize: 14.sp,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        context.tr('owner_search_chalets'),
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                      fontSize: 14.sp,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.only(bottom: 4.sp),
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
                SliverToBoxAdapter(
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
                                label:
                                    '${context.tr('owner_all')} ($allCount)',
                                count: allCount,
                                isSelected: _selectedStatus.isEmpty,
                                isDark: isDark,
                                onTap: () =>
                                    setState(() => _selectedStatus = ''),
                              ),
                              SizedBox(width: 10.sw),
                              _UserStyleChip(
                                label:
                                    '${context.tr('booking_status_pending')} ($pendingCount)',
                                count: pendingCount,
                                isSelected: _selectedStatus == 'pending',
                                isDark: isDark,
                                color: Colors.orange,
                                onTap: () => setState(
                                  () => _selectedStatus = 'pending',
                                ),
                              ),
                              SizedBox(width: 10.sw),
                              _UserStyleChip(
                                label:
                                    '${context.tr('common_approved')} ($approvedCount)',
                                count: approvedCount,
                                isSelected: _selectedStatus == 'approved',
                                isDark: isDark,
                                color: Colors.green,
                                onTap: () => setState(
                                  () => _selectedStatus = 'approved',
                                ),
                              ),
                              SizedBox(width: 10.sw),
                              _UserStyleChip(
                                label:
                                    '${context.tr('common_rejected')} ($rejectedCount)',
                                count: rejectedCount,
                                isSelected: _selectedStatus == 'rejected',
                                isDark: isDark,
                                color: Colors.red,
                                onTap: () => setState(
                                  () => _selectedStatus = 'rejected',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 25.sp)),
                SliverToBoxAdapter(
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
                SliverToBoxAdapter(child: SizedBox(height: 15.sh)),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sp),
                  sliver: SliverToBoxAdapter(
                    child: OwnerChaletsList(
                      status: _selectedStatus,
                      ownerId: ownerId,
                      emptyIcon: Icons.holiday_village_outlined,
                      emptyTitle: context.tr('owner_no_chalets'),
                      emptySubtitle: context.tr('owner_start_add_first'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 100.sp)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!AuthRestrictionHelper.guardOwnerAddChalet(context)) return;

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

  Map<String, dynamic> _chaletToMapSimple(dynamic chalet) {
    if (chalet is Map<String, dynamic>) {
      return chalet;
    }

    try {
      final map = <String, dynamic>{};
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
    const primaryBlue = Color(0xFF2563EB);
    final chipColor = color ?? primaryBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sw, vertical: 8.sh),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white),
          borderRadius: BorderRadius.circular(30.sp),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (isDark
                    ? Colors.white10
                    : Colors.grey.withValues(alpha: 0.2)),
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
                      ? Colors.white.withValues(alpha: 0.2)
                      : (isDark
                          ? Colors.black26
                          : Colors.grey.withValues(alpha: 0.1)),
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
