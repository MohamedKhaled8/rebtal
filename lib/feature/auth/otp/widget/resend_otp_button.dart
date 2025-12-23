import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/auth/otp/cubit/otp_cubit.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class ResendOtpButton extends StatelessWidget {
  final String phoneNumber;

  const ResendOtpButton({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpCubit, OtpState>(
      builder: (context, state) {
        final cubit = context.read<OtpCubit>();
        final canResend = cubit.canResend;
        final remainingSeconds = cubit.remainingSeconds;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: canResend
              ? _buildEnabledButton(context)
              : _buildDisabledButton(remainingSeconds),
        );
      },
    );
  }

  Widget _buildEnabledButton(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<OtpCubit>().resendOtp();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            SizedBox(width: 2.w),
            const Text(
              'Resend OTP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledButton(int remainingSeconds) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: Colors.grey.shade600, size: 20),
          SizedBox(width: 2.w),
          Text(
            'Resend in ${remainingSeconds}s',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
