import 'package:flutter/material.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'dart:async';

class TravelOnboardingScreen extends StatefulWidget {
  const TravelOnboardingScreen({super.key});

  @override
  State<TravelOnboardingScreen> createState() => _TravelOnboardingScreenState();
}

class _TravelOnboardingScreenState extends State<TravelOnboardingScreen> {
  late final PageController _controller;
  int _index = 0;
  List<_Slide> _slides = const [];
  Timer? _autoTimer;
  bool _userInteracted = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchSlides();
    });
    _autoTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      if (_userInteracted) return;
      _nextAuto();
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _completeAndGoNext() {
    Navigator.of(context).pushReplacementNamed(Routes.termsScreen);
  }

  void _skip() {
    _userInteracted = true;
    _completeAndGoNext();
  }

  void _goTo(int page) {
    _userInteracted = true;
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_index >= 2) {
      _completeAndGoNext();
    } else {
      _goTo(_index + 1);
    }
  }

  void _goToAuto(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextAuto() {
    if (_index >= 2) {
      _goToAuto(0);
    } else {
      _goToAuto(_index + 1);
    }
  }

  void _prev() {
    if (_index == 0) return;
    _goTo(_index - 1);
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      _Slide(
        assetPath: 'assets/images/jpg/onboarding_1.jpg',
        title: context.tr('welcome_slide1_title'),
        subtitle: context.tr('welcome_slide1_subtitle'),
        cta: context.tr('welcome_begin_adventure'),
      ),
      _Slide(
        assetPath: 'assets/images/jpg/onboarding_2.jpg',
        title: context.tr('welcome_slide2_title'),
        subtitle: context.tr('welcome_slide2_subtitle'),
        cta: context.tr('welcome_next'),
      ),
      _Slide(
        assetPath: 'assets/images/jpg/onboarding_3.jpg',
        title: context.tr('welcome_slide3_title'),
        subtitle: context.tr('welcome_slide3_subtitle'),
        cta: context.tr('welcome_get_started'),
      ),
    ];

    _slides = slides;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final safeBottom = MediaQuery.paddingOf(context).bottom;
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          final contentMaxWidth = w >= 900 ? 560.0 : 420.0;
          final titleSize = (w * 0.085).clamp(28.0, 46.0);
          final subtitleSize = (w * 0.035).clamp(12.5, 16.0);
          final bottomPad = 18.0 + safeBottom;

          return Stack(
            children: [
              NotificationListener<ScrollStartNotification>(
                onNotification: (n) {
                  if (n.dragDetails != null) _userInteracted = true;
                  return false;
                },
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  allowImplicitScrolling: true,
                  onPageChanged: (i) {
                    setState(() => _index = i);
                    _prefetchAround(i, slides);
                  },
                  itemBuilder: (context, i) => _FullBleedImage(
                    assetPath: slides[i].assetPath,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.22),
                        Colors.black.withOpacity(0.14),
                        Colors.black.withOpacity(0.50),
                        Colors.black.withOpacity(0.76),
                      ],
                      stops: const [0.0, 0.45, 0.72, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 14,
                right: 16,
                child: _SkipButton(
                  label: context.tr('onboarding_skip'),
                  onTap: _skip,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomPad,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DotsIndicator(
                            count: slides.length,
                            index: _index,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            slides[_index].title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slides[_index].subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.88),
                              fontSize: subtitleSize,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _RoundIconButton(
                                icon: Icons.arrow_back_rounded,
                                onTap: _prev,
                                filled: false,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PillCta(
                                  height: (h * 0.06).clamp(44.0, 52.0),
                                  label: slides[_index].cta,
                                  onTap: _next,
                                ),
                              ),
                            ],
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

  void _prefetchSlides() {
    if (!mounted) return;
    _prefetchAround(_index, _slides.isEmpty ? [] : _slides);
  }

  void _prefetchAround(int i, List<_Slide> slides) {
    if (!mounted || slides.isEmpty) return;
    final toPrefetch = <int>{i, i + 1, i - 1}
        .where((x) => x >= 0 && x < slides.length)
        .toList();
    for (final idx in toPrefetch) {
      precacheImage(AssetImage(slides[idx].assetPath), context);
    }
  }
}

class _Slide {
  const _Slide({
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.cta,
  });

  final String assetPath;
  final String title;
  final String subtitle;
  final String cta;
}

class _FullBleedImage extends StatelessWidget {
  const _FullBleedImage({required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: const Color(0xFF0B1220),
        child: Image.asset(assetPath, fit: BoxFit.cover),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 8),
          height: 7,
          width: active ? 18 : 7,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(active ? 1.0 : 0.45),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled
              ? ColorsManager.blue2563EB
              : Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withOpacity(filled ? 0.0 : 0.18),
          ),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
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

class _PillCta extends StatelessWidget {
  const _PillCta({
    required this.height,
    required this.label,
    required this.onTap,
  });

  final double height;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: ColorsManager.blue2563EB,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

