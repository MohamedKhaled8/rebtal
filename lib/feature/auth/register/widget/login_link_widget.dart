import 'package:flutter/material.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/helper/extensions.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class LoginLinkWidget extends StatelessWidget {
  final bool isDark;

  const LoginLinkWidget({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('auth_have_account'),
          style: TextStyle(
            fontSize: 15,
            color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => context.pushNamed(Routes.loginScreen),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          child: Text(
            context.tr('auth_login'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? ColorsManager.bookingsAccentPrimary
                  : ColorsManager.blue2563EB,
            ),
          ),
        ),
      ],
    );
  }
}
