import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/owner/widget/owner_chalets_list.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class ChaletStatusPage extends StatelessWidget {
  final String status;

  const ChaletStatusPage({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppCubit>().authCubit.getCurrentUser();
    final ownerId = currentUser?.uid;

    String title;
    String emptyTitle;
    String emptySubtitle;
    IconData emptyIcon;

    if (status == 'approved') {
      title = context.tr('owner_approved_chalets');
      emptyTitle = context.tr('owner_no_approved_chalets');
      emptySubtitle = context.tr('owner_approved_chalets_hint');
      emptyIcon = Icons.check_circle_outline;
    } else {
      title = context.tr('owner_rejected_chalets');
      emptyTitle = context.tr('owner_no_rejected_chalets');
      emptySubtitle = context.tr('owner_rejected_chalets_hint');
      emptyIcon = Icons.cancel_outlined;
    }

    return Scaffold(
      backgroundColor: ColorsManager.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: ColorsManager.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: status == 'approved'
            ? ColorsManager.green3DDC84
            : ColorsManager.chaletUnavailableRed,
        foregroundColor: ColorsManager.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: stv(
                context: context,
                mobile: 12.sw,
                tablet: 16.sw,
                desktop: 20.sw,
              ),
              vertical: 8.sh,
            ),
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
