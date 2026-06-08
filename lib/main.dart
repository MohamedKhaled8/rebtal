import 'package:flutter/material.dart';
import 'package:rebtal/core/Router/app_router.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/app_initializer.dart';
import 'package:rebtal/rebtal_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  await AppInitializer.initialize();

  runApp(
    BlocProvider<AppCubit>(
      create: (context) => getIt<AppCubit>(),
      child: RebtalApp(appRouter: AppRouter()),
    ),
  );
}
