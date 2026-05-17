import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';

class HomeBlocScope extends StatelessWidget {
  const HomeBlocScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>.value(
      value: getIt<HomeCubit>()..ensureWatching(),
      child: child,
    );
  }
}
