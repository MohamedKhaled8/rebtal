import 'package:flutter/material.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class AuthEntryScreen extends StatefulWidget {
  const AuthEntryScreen({super.key});

  @override
  State<AuthEntryScreen> createState() => _AuthEntryScreenState();
}

class _AuthEntryScreenState extends State<AuthEntryScreen> {
  static const String _bgAsset = 'assets/images/jpg/onboarding_2.jpg';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_bgAsset), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final safeTop = MediaQuery.paddingOf(context).top;
          final safeBottom = MediaQuery.paddingOf(context).bottom;
          final w = constraints.maxWidth;

          final contentMaxWidth = w >= 900 ? 560.0 : 420.0;
          final titleSize = (w * 0.080).clamp(26.0, 44.0);
          final subtitleSize = (w * 0.034).clamp(12.5, 16.0);

          return Stack(
            children: [
              const _Bg(assetPath: _bgAsset),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.28),
                        Colors.black.withOpacity(0.34),
                        Colors.black.withOpacity(0.66),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 18 + safeBottom,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: safeTop + 10),
                          Text(
                            context.tr('auth_entry_title'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.tr('auth_entry_subtitle'),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: subtitleSize,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Segmented(
                            left: context.tr('auth_login'),
                            right: context.tr('auth_create_account'),
                            onLeft: () => Navigator.of(context)
                                .pushNamed(Routes.loginScreen),
                            onRight: () => Navigator.of(context)
                                .pushNamed(Routes.registerScreen),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _BenefitRow(
                                  icon: Icons.verified_user_outlined,
                                  text: context.tr('auth_entry_benefit_safe'),
                                ),
                                const SizedBox(height: 8),
                                _BenefitRow(
                                  icon: Icons.bolt_outlined,
                                  text: context.tr('auth_entry_benefit_fast'),
                                ),
                                const SizedBox(height: 8),
                                _BenefitRow(
                                  icon: Icons.support_agent_outlined,
                                  text: context.tr('auth_entry_benefit_support'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(Routes.loginScreen),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.45),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                context.tr('auth_entry_continue'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
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
            ],
          );
        },
      ),
    );
  }
}

class _Bg extends StatelessWidget {
  const _Bg({required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(assetPath, fit: BoxFit.cover),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.left,
    required this.right,
    required this.onLeft,
    required this.onRight,
  });

  final String left;
  final String right;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _SegBtn(
              label: left,
              onTap: onLeft,
              filled: true,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SegBtn(
              label: right,
              onTap: onRight,
              filled: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  const _SegBtn({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        decoration: BoxDecoration(
          color: filled ? Colors.white.withOpacity(0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.94),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}

