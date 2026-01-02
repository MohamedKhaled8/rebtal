import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';
import 'package:rebtal/feature/notifications/logic/notification_cubit.dart';
import 'package:rebtal/core/utils/model/user_model.dart';

extension AppCubitExtensions on BuildContext {
  /// Get the AppCubit instance
  AppCubit get appCubit => read<AppCubit>();

  /// Get the AuthCubit instance
  AuthCubit get authCubit => read<AppCubit>().authCubit;

  /// Get the BookingCubit instance
  BookingCubit get bookingCubit => read<AppCubit>().bookingCubit;

  /// Get the ThemeCubit instance
  ThemeCubit get themeCubit => read<AppCubit>().themeCubit;

  /// Get the NotificationCubit instance
  NotificationCubit get notificationCubit => read<AppCubit>().notificationCubit;

  /// Get the current user (convenience method)
  UserModel? get currentUser => read<AppCubit>().getCurrentUser();

  /// Get the current user role (convenience method)
  String get currentRole => read<AppCubit>().getCurrentRole();
}
