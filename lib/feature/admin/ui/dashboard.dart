import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/function/user_manger.dart';
import 'package:rebtal/feature/admin/logic/cubit/admin_cubit.dart';
import 'package:rebtal/feature/admin/widget/desktop/desktop_sidebar_widget.dart';
import 'package:rebtal/feature/admin/widget/header/hearder.dart';
import 'package:rebtal/feature/admin/widget/mobile/mobile_drawer_widget.dart';

// small shared search notifier used by lists (no constructor changes to tabs)
class AdminSearch {
  static final ValueNotifier<String> q = ValueNotifier<String>('');
}

// Admin Dashboard
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return BlocProvider(
      create: (context) => AdminCubit(),
      child: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          final cubit = context.read<AdminCubit>();

          return Scaffold(
            key: cubit.scaffoldKey,
            backgroundColor: Colors.grey[50],
            // no AppBar — custom header is inside body so drawer can still open via the scaffold key
            drawer: isLargeScreen
                ? null
                : MobileDrawerWidget(
                    selectedIndex: cubit.selectedIndex,
                    tabTitles: UserManager.tabTitles,
                    tabIcons: UserManager.tabIcons,
                    onItemSelected: (i) => cubit.changeTab(i),
                  ),
            body: Row(
              children: [
                // Side navigation for larger screens
                if (isLargeScreen)
                  DesktopSidebarWidget(
                    selectedIndex: cubit.selectedIndex,
                    tabTitles: UserManager.tabTitles,
                    tabIcons: UserManager.tabIcons,
                    onItemSelected: (i) => cubit.changeTab(i),
                  ),
                // Main content
                Expanded(
                  child: SafeArea(
                    child: Column(
                      children: [
                        // custom header (replaces AppBar). On mobile shows menu icon that opens drawer.
                        HeaderAdmin(),
                        // content area
                        Expanded(
                          child: Container(
                            margin: isLargeScreen
                                ? const EdgeInsets.only(
                                    left: 0,
                                    top: 12,
                                    right: 12,
                                    bottom: 12,
                                  )
                                : const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: UserManager.tabs[cubit.selectedIndex],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String formatAvailabilityDate(dynamic dt) {
  if (dt == null) return 'Not specified';
  try {
    DateTime d;
    if (dt is Timestamp) {
      d = dt.toDate();
    } else if (dt is String && dt.isNotEmpty)
      // ignore: curly_braces_in_flow_control_structures
      d = DateTime.parse(dt);
    else if (dt is DateTime)
      // ignore: curly_braces_in_flow_control_structures
      d = dt;
    else
      // ignore: curly_braces_in_flow_control_structures
      return dt.toString();
    return '${d.day}/${d.month}/${d.year}';
  } catch (_) {
    return 'Invalid date';
  }
}
