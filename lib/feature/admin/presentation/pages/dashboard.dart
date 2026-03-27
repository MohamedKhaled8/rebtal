import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/function/user_manger.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_cubit.dart';
import 'package:rebtal/feature/admin/presentation/cubit/admin_state.dart';
import 'package:rebtal/feature/admin/data/datasources/admin_remote_data_source.dart';
import 'package:rebtal/feature/admin/data/repositories/admin_repository_impl.dart';
import 'package:rebtal/feature/admin/domain/usecases/admin_usecases.dart';
import 'package:rebtal/feature/admin/widget/desktop/desktop_sidebar_widget.dart';
import 'package:rebtal/feature/admin/widget/header/hearder.dart';
import 'package:rebtal/feature/admin/widget/mobile/mobile_drawer_widget.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';

// small shared search notifier used by lists
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
      create: (context) {
        final dataSource = AdminRemoteDataSourceImpl(FirebaseFirestore.instance);
        final repository = AdminRepositoryImpl(dataSource);
        
        return AdminCubit(
          getAdminStreamUseCase: GetAdminStreamUseCase(repository),
          updateChaletStatusUseCase: UpdateChaletStatusUseCase(repository),
          updatePaymentProofStatusUseCase: UpdatePaymentProofStatusUseCase(repository),
          manageUserUseCase: ManageUserUseCase(repository),
        )..startListeningToAll();
      },
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          final isDark =
              (appState.themeMode == ThemeMode.dark) ||
              (appState.themeMode == ThemeMode.system &&
                  MediaQuery.of(context).platformBrightness == Brightness.dark);

          return BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              final cubit = context.read<AdminCubit>();

              return Scaffold(
                key: cubit.scaffoldKey,
                backgroundColor: isDark
                    ? const Color(0xFF0F0F1E)
                    : Colors.grey[50],
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
                    if (isLargeScreen)
                      DesktopSidebarWidget(
                        selectedIndex: cubit.selectedIndex,
                        tabTitles: UserManager.tabTitles,
                        tabIcons: UserManager.tabIcons,
                        onItemSelected: (i) => cubit.changeTab(i),
                      ),
                    Expanded(
                      child: SafeArea(
                        child: Column(
                          children: [
                            HeaderAdmin(),
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
                                  color: isDark
                                      ? const Color(0xFF1A1A2E)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDark ? 0.3 : 0.02,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: UserManager.tabs[cubit.selectedIndex],
                                ),
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
    } else if (dt is String && dt.isNotEmpty) {
      d = DateTime.parse(dt);
    } else if (dt is DateTime) {
      d = dt;
    } else {
      return dt.toString();
    }
    return '${d.day}/${d.month}/${d.year}';
  } catch (_) {
    return 'Invalid date';
  }
}
