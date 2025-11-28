import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'dart:async';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/onboarding/logic/cubit/terms_cubit.dart';
import 'package:rebtal/feature/onboarding/ui/terms_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  late AnimationController _textAnimationController;
  late AnimationController _overlayController;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _overlayAnimation;

  // Flag to check if animations are initialized
  bool _animationsInitialized = false;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      image:
          "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop",
      title: "Luxury Stays Await",
      description:
          "Discover premium hotels and resorts with world-class amenities and exceptional service",
    ),
    OnboardingData(
      image:
          "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&h=600&fit=crop",
      title: "Book with Confidence",
      description:
          "Easy booking, instant confirmation, and flexible cancellation for your peace of mind",
    ),
    OnboardingData(
      image:
          "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&h=600&fit=crop",
      title: "Unforgettable Experiences",
      description:
          "Create lasting memories with our curated selection of the finest accommodations",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAutoSlider();
    _animateText();
  }

  void _initializeAnimations() {
    try {
      _textAnimationController = AnimationController(
        duration: Duration(milliseconds: 1200),
        vsync: this,
      );

      _overlayController = AnimationController(
        duration: Duration(milliseconds: 800),
        vsync: this,
      );

      _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _textAnimationController,
          curve: Interval(0.3, 1.0, curve: Curves.easeOut),
        ),
      );

      _textSlideAnimation =
          Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _textAnimationController,
              curve: Curves.easeOutCubic,
            ),
          );

      _overlayAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _overlayController, curve: Curves.easeInOut),
      );

      // Mark animations as initialized
      _animationsInitialized = true;

      // Start overlay animation
      _overlayController.forward();
    } catch (e) {
      debugPrint('Error initializing animations: $e');
    }
  }

  void _startAutoSlider() {
    _autoSlideTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        if (_currentPage < _onboardingData.length - 1) {
          _nextPage();
        } else {
          _goToPage(0);
        }
      }
    });
  }

  void _animateText() {
    if (_animationsInitialized && mounted) {
      _textAnimationController.reset();
      _textAnimationController.forward();
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _completeOnboarding() async {
    _autoSlideTimer?.cancel();

    try {
      // Navigate to Terms & Conditions screen
      // Don't save onboarding completion yet - wait for terms acceptance
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => TermsCubit(getIt()),
              child: const TermsScreen(),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }

  void _skipOnboarding() {
    _autoSlideTimer?.cancel();
    _completeOnboarding();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    if (_animationsInitialized) {
      _textAnimationController.dispose();
      _overlayController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading until animations are initialized
    if (!_animationsInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Images with smooth transitions
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _animateText();
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'onboarding_$index',
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: AppImageHelper(
                    path: _onboardingData[index].image,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          // Enhanced Dark Overlay with animation
          AnimatedBuilder(
            animation: _overlayAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(_overlayAnimation.value * 0.4),
                      Colors.black.withOpacity(_overlayAnimation.value * 0.8),
                      Colors.black.withOpacity(_overlayAnimation.value * 0.9),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              );
            },
          ),

          // Enhanced Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: GestureDetector(
              onTap: _skipOnboarding,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Enhanced Bottom Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
              padding: EdgeInsets.fromLTRB(30, 60, 30, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Enhanced Animated Text Content
                  AnimatedBuilder(
                    animation: _textAnimationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textFadeAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Column(
                            children: [
                              Text(
                                _onboardingData[_currentPage].title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              Container(
                                width: 60,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                _onboardingData[_currentPage].description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white.withOpacity(0.85),
                                  height: 1.6,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 50),

                  // Enhanced Dots Indicator
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => GestureDetector(
                          onTap: () => _goToPage(index),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            margin: EdgeInsets.symmetric(horizontal: 6),
                            height: _currentPage == index ? 10 : 8,
                            width: _currentPage == index ? 32 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: _currentPage == index
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Enhanced Action Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          _completeOnboarding();
                        } else {
                          _nextPage();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Row(
                          key: ValueKey(_currentPage),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _onboardingData.length - 1
                                  ? "Get Started"
                                  : "Next",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              _currentPage == _onboardingData.length - 1
                                  ? Icons.hotel
                                  : Icons.arrow_forward,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
