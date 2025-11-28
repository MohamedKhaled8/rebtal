import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/function/user_manger.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/feature/admin/logic/cubit/admin_cubit.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:screen_go/functions/screen_type_value_func.dart';

class HeaderAdmin extends StatelessWidget {
  const HeaderAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final cubit = context.read<AdminCubit>();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 20 : 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
        borderRadius: isLargeScreen
            ? const BorderRadius.only(topLeft: Radius.circular(24))
            : null,
      ),
      child: Row(
        children: [
          if (!isLargeScreen)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.deepPurple),
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
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(width: 2.w),
          // search field
          Container(
            width: stv(
              context: context,
              mobile: 58.sp,
              tablet: 100.sp,
              desktop: 50.sp,
            ),
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.search, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: BlocBuilder<AdminCubit, AdminState>(
                    builder: (context, state) {
                      return TextField(
                        controller: cubit.searchController,
                        onChanged: cubit.updateSearch,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Search users, chalets, phone...',
                        ),
                        style: const TextStyle(fontSize: 14),
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
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: cubit.clearSearch,
                    );
                  },
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
