import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/utils/function/user_manger.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/feature/admin/logic/cubit/admin_cubit.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'dart:async';

class HeaderChletDetailes extends StatefulWidget {
  final List<String> images;
  final String status;
  final AdminState state;

  const HeaderChletDetailes({
    super.key,
    required this.images,
    required this.status,
    required this.state,
  });

  @override
  State<HeaderChletDetailes> createState() => _HeaderChletDetailesState();
}

class _HeaderChletDetailesState extends State<HeaderChletDetailes>
    with TickerProviderStateMixin {
  Timer? _autoSlideTimer;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shadowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _shadowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shadowController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _shadowController.forward();

    // Auto-slide setup
    _startAutoSlide();
  }

  void _startAutoSlide() {
    if (widget.images.length > 1) {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (mounted) {
          final cubit = context.read<AdminCubit>();
          final currentIndex = widget.state is AdminCurrentIndex
              ? (widget.state as AdminCurrentIndex).currentIndex
              : 0;
          final nextIndex = (currentIndex + 1) % widget.images.length;

          cubit.pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    _shadowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminCubit>();

    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 380,
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  // Main shadow effect

                  // Inner glow effect
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Images Container
                  widget.images.isNotEmpty
                      ? PageView.builder(
                          controller: cubit.pageController,
                          itemCount: widget.images.length,
                          onPageChanged: (index) {
                            cubit.changeImage(index);
                            // Reset auto-slide timer
                            _autoSlideTimer?.cancel();
                            _startAutoSlide();
                          },
                          itemBuilder: (context, i) => GestureDetector(
                            onTap: () => cubit.openFullScreen(
                              context,
                              images: widget.images,
                              start: i,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Main Image
                                AppImageHelper(
                                  path: widget.images[i],
                                  fit: BoxFit.cover,
                                ),
                                // Parallax overlay effect
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.1),
                                        Colors.black.withOpacity(0.4),
                                      ],
                                      stops: const [0.0, 0.7, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue[100]!,
                                Colors.blue[200]!,
                                Colors.grey[300]!,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.villa_outlined,
                                  size: 64,
                                  color: Colors.white70,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No Images Available',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                  // Floating Back Button
                  Positioned(
                    top: 40,
                    left: 16,
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _fadeAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Animated Status Badge (للـ Admin فقط)
                  if (context.read<AuthCubit>().getCurrentRole() == 'admin')
                    AnimatedBuilder(
                      animation: _shadowAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 120,
                          right: 20,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              -10 * (1 - _shadowAnimation.value),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    UserManager.statusColor(widget.status),
                                    UserManager.statusColor(
                                      widget.status,
                                    ).withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: UserManager.statusColor(
                                      widget.status,
                                    ).withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    UserManager.statusIcon(widget.status),
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // Floating Image Counter
                  if (widget.images.length > 1)
                    Positioned(
                      top: 120,
                      left: 20,
                      child: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.photo_library_outlined,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${(widget.state is AdminCurrentIndex ? (widget.state as AdminCurrentIndex).currentIndex + 1 : 1)}/${widget.images.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Enhanced Page Indicators at Bottom
                  if (widget.images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.images.asMap().entries.map((entry) {
                          final index = entry.key;
                          final isActive =
                              widget.state is AdminCurrentIndex &&
                              (widget.state as AdminCurrentIndex)
                                      .currentIndex ==
                                  index;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                            width: isActive ? 32 : 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: isActive
                                  ? LinearGradient(
                                      colors: [Colors.white, Colors.blue[100]!],
                                    )
                                  : null,
                              color: isActive
                                  ? null
                                  : Colors.white.withOpacity(0.4),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: isActive
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue[300]!,
                                          Colors.blue[500]!,
                                        ],
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
