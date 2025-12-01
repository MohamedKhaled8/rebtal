import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/notifications/logic/notification_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_state.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is! NotificationLoaded || state.unreadCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: ColorManager.chaletActionRed,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorManager.white, width: 2),
          ),
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          child: Text(
            state.unreadCount > 99 ? '99+' : '${state.unreadCount}',
            style: const TextStyle(
              color: ColorManager.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
