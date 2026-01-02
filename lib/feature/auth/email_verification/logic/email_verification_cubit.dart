import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/auth/domain/usecases/resend_email_verification_usecase.dart';
import 'package:rebtal/feature/auth/domain/usecases/save_user_usecase.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';

part 'email_verification_state.dart';

class EmailVerificationCubit extends Cubit<EmailVerificationState> {
  EmailVerificationCubit({
    required this.userModel,
    required ResendEmailVerificationUseCase resendUseCase,
    required SaveUserUseCase saveUserUseCase,
  }) : _resendUseCase = resendUseCase,
       _saveUserUseCase = saveUserUseCase,
       super(EmailVerificationInitial()) {
    _startVerificationCheck();
    _startResendTimer();
  }

  final UserModel userModel;
  String get email => userModel.email;
  final ResendEmailVerificationUseCase _resendUseCase;
  final SaveUserUseCase _saveUserUseCase;
  Timer? _timer;
  Timer? _resendTimer;

  void _startVerificationCheck() {
    emit(EmailVerificationChecking());
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          debugPrint('⚠️ No current user found');
          return;
        }

        await currentUser.reload();
        final user = FirebaseAuth.instance.currentUser;

        debugPrint(
          '🔍 Checking email verification status: ${user?.emailVerified}',
        );

        if (user?.emailVerified ?? false) {
          debugPrint('✅ Email verified!');
          timer.cancel();
          emit(EmailVerificationVerified());
        }
      } catch (e) {
        debugPrint('❌ Error checking email verification: $e');
      }
    });
  }

  void _startResendTimer() {
    emit(EmailVerificationResendCooldown(60));
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is EmailVerificationResendCooldown) {
        if (currentState.countdown > 0) {
          emit(EmailVerificationResendCooldown(currentState.countdown - 1));
        } else {
          timer.cancel();
          emit(EmailVerificationCanResend());
        }
      }
    });
  }

  Future<void> resendVerificationEmail() async {
    final result = await _resendUseCase.call();
    result.fold((failure) => emit(EmailVerificationError(failure.message)), (
      _,
    ) {
      emit(EmailVerificationEmailSent());
      _startResendTimer();
    });
  }

  Future<void> checkVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(EmailVerificationError('لا يوجد مستخدم مسجل دخول'));
        return;
      }

      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      debugPrint(
        '🔍 Manual check - Email verified: ${updatedUser?.emailVerified}',
      );

      if (updatedUser?.emailVerified ?? false) {
        emit(EmailVerificationVerified());
      }
    } catch (e) {
      debugPrint('❌ Error checking verification status: $e');
      emit(EmailVerificationError('حدث خطأ أثناء التحقق من حالة البريد'));
    }
  }

  Future<void> handleVerified(BuildContext context) async {
    // Logic moved from AuthCubit to here
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("Error: No user found");
        return;
      }

      await user.reload(); // Reload to get fresh data
      if (user.emailVerified) {
        // Save user data to Firestore now that email is verified
        // logic was: await authRepository.saveUserToFirestore(_pendingUserData!);
        // We use this.userModel as pending data

        final result = await _saveUserUseCase.call(userModel);

        result.fold(
          (failure) {
            debugPrint("Error saving user to Firestore: ${failure.message}");
            // We could emit error state, but this function is called when already "Verified" state is detected by the timer?
            // Or we call this manually?
            // The UI calls handleVerified when state is EmailVerificationVerified.
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'خطأ',
              text: 'فشل حفظ البيانات: ${failure.message}',
            );
          },
          (savedUser) async {
            // ✅ Save role locally
            await getIt<CacheHelper>().saveData(
              key: 'userRole',
              value: savedUser.role,
            );

            // ✅ Clear the just registered flag
            await getIt<CacheHelper>().removeData(key: 'justRegistered');

            // ✅ Notify AuthCubit via reloading
            final authCubit = context.read<AuthCubit>();
            await authCubit.reloadUserData();

            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'تم التحقق!',
              text: 'تم التحقق من بريدك الإلكتروني بنجاح.',
              autoCloseDuration: const Duration(seconds: 2),
              showConfirmBtn: false,
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (Navigator.of(context).mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.bottomNavigationBarScreen,
                  (route) => false,
                );
              }
            });
          },
        );
      }
    } catch (e) {
      debugPrint("Error confirming email verification: $e");
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'خطأ',
        text: 'حدث خطأ أثناء التحقق من البريد الإلكتروني',
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    final authCubit = context.read<AuthCubit>();
    await authCubit.logout();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _resendTimer?.cancel();
    return super.close();
  }
}
