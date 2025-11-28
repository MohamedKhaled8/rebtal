import 'package:flutter/material.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/helper/extensions.dart';

class LoginLinkWidget extends StatelessWidget {
  const LoginLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Already exploring with us? ",
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: () => context.pushNamed(Routes.loginScreen),
              child: const Text(
                "Sign In",
                style: TextStyle(
                  color: Color(0xFF0EA5E9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF0EA5E9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
