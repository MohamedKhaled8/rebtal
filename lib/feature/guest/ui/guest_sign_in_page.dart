import 'package:flutter/material.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class GuestSignInPage extends StatelessWidget {
  const GuestSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: stv(
                context: context,
                mobile: 24.sw,
                tablet: 40.sw,
                desktop: 48.sw,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: stv(
                  context: context,
                  mobile: 420.sw,
                  tablet: 480.sw,
                  desktop: 520.sw,
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  stv(
                    context: context,
                    mobile: 28.sw,
                    tablet: 36.sw,
                    desktop: 40.sw,
                  ),
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: ColorsManager.blue2563EB.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_open_rounded,
                        size: 42,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(height: 20.sh),
                    Text(
                      context.tr('guest_sign_in_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: stv(
                          context: context,
                          mobile: 20.spScaled,
                          tablet: 24.spScaled,
                          desktop: 26.spScaled,
                        ),
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 10.sh),
                    Text(
                      context.tr('guest_sign_in_subtitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: stv(
                          context: context,
                          mobile: 14.spScaled,
                          tablet: 16.spScaled,
                          desktop: 17.spScaled,
                        ),
                        color: subColor,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 28.sh),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(Routes.loginScreen),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.tr('auth_login'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(Routes.registerScreen),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFF2563EB),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          context.tr('auth_create_account'),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isDark ? Colors.white : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
