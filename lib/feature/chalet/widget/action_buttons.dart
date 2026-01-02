import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/chalet/logic/cubit/action_buttons_cubit.dart';
import 'package:rebtal/feature/chalet/widget/admin_buttons.dart';
import 'package:rebtal/feature/chalet/widget/owner_buttons.dart';
import 'package:rebtal/feature/chalet/widget/user_buttons.dart';

class ActionButtons extends StatelessWidget {
  final String status;
  final String docId;
  final Map<String, dynamic> requestData;

  const ActionButtons({
    super.key,
    required this.status,
    required this.docId,
    required this.requestData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActionButtonsCubit(),
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          if (appState is AppAuthenticated) {
            // ✅ Use getCurrentRole() to respect view mode switching
            final role = context.read<AppCubit>().getCurrentRole();

            if (role == 'admin') {
              return AdminButtons(status: status, docId: docId);
            } else if (role == 'user') {
              return UserButtons(requestData: requestData, docId: docId);
            } else if (role == 'owner') {
              return OwnerButtons(requestData: requestData, docId: docId);
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
