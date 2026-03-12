import 'package:flutter/material.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/helper/extensions.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _introController;
  double _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Curated stays',
      description: 'Discover modern chalets and villas selected by experts.',
      asset: 'assets/images/png/logo.png',
    ),
    _OnboardingSlide(
      title: 'Plan with ease',
      description: 'Manage bookings, payments, and support in one place.',
      asset: 'assets/images/png/help.png',
    ),
    _OnboardingSlide(
      title: 'Stay inspired',
      description: 'Save favorites and receive tailored recommendations.',
      asset: 'assets/images/png/logoApp.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _WelcomeBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _introController,
                  curve: Curves.easeOut,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(1),
                    Text(
                      "Welcome to Rebtal",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: ColorsManager.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    verticalSpace(0.5),
                    Text(
                      "Rent and showcase beautiful chalets with a couple of taps.",
                      style: TextStyle(
                        color: ColorsManager.white.withOpacity(0.8),
                      ),
                    ),
                    verticalSpace(5),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        itemBuilder: (_, index) {
                          final slide = _slides[index];
                          return _OnboardingCard(
                            slide: slide,
                            page: _currentPage,
                            index: index,
                          );
                        },
                      ),
                    ),
                    verticalSpace(2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final isActive =
                            (_currentPage.roundToDouble() - index).abs() < 0.5;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: isActive ? 32 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isActive
                                ? ColorsManager.white
                                : ColorsManager.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }),
                    ),
                    verticalSpace(3),
                    SizedBox(
                      width: double.infinity,
                      height: 6.4.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.white,
                          foregroundColor: ColorsManager.darkSlate0F172A,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: () => context.pushNamed(Routes.loginScreen),
                        child: const Text(
                          "Get started",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    verticalSpace(1),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            context.pushNamed(Routes.registerScreen),
                        child: const Text(
                          "Create a new account",
                          style: TextStyle(
                            color: ColorsManager.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    verticalSpace(1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBackground extends StatelessWidget {
  const _WelcomeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorsManager.darkSlate0F172A, ColorsManager.blue1E40AF],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -30,
            child: _blurCircle(ColorsManager.blue93C5FD.withOpacity(0.25)),
          ),
          Positioned(
            bottom: 0,
            left: -40,
            child: _blurCircle(ColorsManager.purple312E81.withOpacity(0.35)),
          ),
        ],
      ),
    );
  }

  Widget _blurCircle(Color color) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 160,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.slide,
    required this.page,
    required this.index,
  });

  final _OnboardingSlide slide;
  final double page;
  final int index;

  @override
  Widget build(BuildContext context) {
    final progress = (page - index).clamp(-1.0, 1.0);
    final opacity = 1 - progress.abs();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 400),
              scale: 0.96 + (0.04 * opacity),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  color: ColorsManager.greyE2E8F0,
                  child: Image.asset(
                    slide.asset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: ColorsManager.blueEFF6FF,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.holiday_village,
                        color: ColorsManager.skyBlue38BDF8.withOpacity(0.8),
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          verticalSpace(2),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: ColorsManager.darkSlate0F172A,
              fontWeight: FontWeight.w700,
            ),
          ),
          verticalSpace(0.5),
          Text(
            slide.description,
            style: const TextStyle(color: ColorsManager.slate475569),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String description;
  final String asset;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.asset,
  });
}
