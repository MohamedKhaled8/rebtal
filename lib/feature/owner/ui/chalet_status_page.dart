import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/owner/widget/owner_chalets_list.dart';

class ChaletStatusPage extends StatelessWidget {
  final String status;

  const ChaletStatusPage({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().getCurrentUser();
    final ownerId = currentUser?.uid;

    String title;
    String emptyTitle;
    String emptySubtitle;
    IconData emptyIcon;

    if (status == 'approved') {
      title = 'الشاليهات الموافق عليها';
      emptyTitle = 'لا توجد شاليهات موافق عليها';
      emptySubtitle = 'ستظهر الشاليهات الموافق عليها هنا';
      emptyIcon = Icons.check_circle_outline;
    } else {
      title = 'الشاليهات المرفوضة';
      emptyTitle = 'لا توجد شاليهات مرفوضة';
      emptySubtitle = 'ستظهر الشاليهات المرفوضة هنا';
      emptyIcon = Icons.cancel_outlined;
    }

    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: status == 'approved'
            ? const Color(0xFF3DDC84)
            : const Color(0xFFEF4444),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: OwnerChaletsList(
              status: status,
              ownerId: ownerId,
              emptyIcon: emptyIcon,
              emptyTitle: emptyTitle,
              emptySubtitle: emptySubtitle,
            ),
          ),
        ),
      ),
    );
  }
}
