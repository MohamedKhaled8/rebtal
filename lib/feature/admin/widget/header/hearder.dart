import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/function/user_manger.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/feature/admin/logic/cubit/admin_cubit.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:screen_go/functions/screen_type_value_func.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';

class HeaderAdmin extends StatelessWidget {
  const HeaderAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final cubit = context.read<AdminCubit>();

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark =
            themeState.themeMode == ThemeMode.dark ||
            (themeState.themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 20 : 12,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                blurRadius: 8,
              ),
            ],
            borderRadius: isLargeScreen
                ? const BorderRadius.only(topLeft: Radius.circular(24))
                : null,
          ),
          child: Row(
            children: [
              if (!isLargeScreen)
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: isDark ? Colors.white : Colors.deepPurple,
                  ),
                  onPressed: () => context
                      .read<AdminCubit>()
                      .scaffoldKey
                      .currentState
                      ?.openDrawer(),
                )
              else
                horizintalSpace(1),
              Text(
                UserManager.tabTitles[context.read<AdminCubit>().selectedIndex],
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.deepPurple,
                ),
              ),
              SizedBox(width: 2.w),
              // search field
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252540) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.grey.withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(
                        Icons.search,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BlocBuilder<AdminCubit, AdminState>(
                          builder: (context, state) {
                            return TextField(
                              controller: cubit.searchController,
                              onChanged: cubit.updateSearch,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Search users, chalets, phone...',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey[500],
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                      BlocBuilder<AdminCubit, AdminState>(
                        builder: (context, state) {
                          if (cubit.searchController.text.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 18,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            onPressed: cubit.clearSearch,
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
