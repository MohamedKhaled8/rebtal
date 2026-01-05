import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/widgets/rating_display_widget.dart';
import 'package:rebtal/core/utils/widgets/shimmers.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/navigation/ui/bottom_nav_controller.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:rebtal/core/utils/services/chalet_filter_service.dart';
import 'package:rebtal/feature/admin/ui/full_screen_image_gallery.dart';

class PublicChaletCard extends StatefulWidget {
  final Map<String, dynamic> chaletData;
  final String docId;
  final VoidCallback? onDetailsPressed;
  final Widget? badge;

  const PublicChaletCard({
    super.key,
    required this.chaletData,
    required this.docId,
    this.onDetailsPressed,
    this.badge,
  });

  @override
  State<PublicChaletCard> createState() => _PublicChaletCardState();
}

class _PublicChaletCardState extends State<PublicChaletCard> {
  bool _isFavorite = false;
  String? _userId;
  int _currentImageIndex = 0;
  PageController? _pageController;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    try {
      final user = context.read<AppCubit>().authCubit.getCurrentUser();
      _userId = user?.uid;
    } catch (_) {}
    _checkFavoriteInitial();
    _initImageCarousel();
  }

  void _initImageCarousel() {
    final images = _collectChaletImages(widget.chaletData);
    if (images.length > 1) {
      _pageController = PageController();
      _startAutoPlay(images.length);
    }
  }

  void _startAutoPlay(int imageCount) {
    _autoPlayTimer?.cancel();
    if (imageCount > 1) {
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController?.hasClients == true) {
          final nextIndex = (_currentImageIndex + 1) % imageCount;
          _pageController?.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteInitial() async {
    if (_userId == null) return;
    try {
      final favDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(widget.docId)
          .get();
      if (mounted) {
        setState(() {
          _isFavorite = favDoc.exists;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null) return;
    try {
      final favRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(widget.docId);

      if (_isFavorite) {
        await favRef.delete();
      } else {
        await favRef.set({
          'chaletId': widget.docId,
          'name': widget.chaletData['chaletName'] ?? 'Unnamed Chalet',
          'location': widget.chaletData['location'] ?? '',
          'image':
              (widget.chaletData['images'] is List &&
                  widget.chaletData['images'].isNotEmpty)
              ? widget.chaletData['images'][0]
              : (widget.chaletData['profileImage'] ?? ''),
          'price': widget.chaletData['price'],
          'createdAt': FieldValue.serverTimestamp(),
          'chaletData': widget.chaletData,
        });
      }

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        if (_isFavorite) {
          bottomNavIndex.value = 1;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر تحديث المفضلة: $e')));
      }
    }
  }

  List<String> _collectChaletImages(Map<String, dynamic> data) {
    final List<dynamic>? imgs = data['images'] as List<dynamic>?;
    final List<String> result = [];

    // Add profile image first if available
    final String? profile = data['profileImage']?.toString();
    if (profile != null && profile.isNotEmpty) {
      result.add(profile);
    }

    if (imgs != null) {
      for (final e in imgs) {
        if (e == null) continue;
        final s = e.toString();
        if (s.isNotEmpty && s != profile) {
          result.add(s);
        }
        // Removed the limit - show all images
      }
    }

    if (result.isEmpty) {
      // Fallback placeholder if absolutely no images
      result.add('https://via.placeholder.com/400x300?text=No+Image');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final chaletName = widget.chaletData['chaletName'] ?? 'شاليه بدون اسم';
    final location = widget.chaletData['location'] ?? 'الموقع غير محدد';
    final price = widget.chaletData['price'];
    final images = _collectChaletImages(widget.chaletData);
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
      decoration: BoxDecoration(
        color: isDark ? ColorManager.chaletBackgroundDark : ColorManager.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? ColorManager.white.withOpacity(0.05)
              : ColorManager.chaletGrey200.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? ColorManager.black.withOpacity(0.2)
                : ColorManager.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Carousel
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: SizedBox(
                  height: 240,
                  child: GestureDetector(
                    onTap: () {
                      // Open full screen gallery when tapping on image
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImageGallery(
                            images: images,
                            initialIndex: _currentImageIndex,
                          ),
                        ),
                      );
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return AppImageHelper(
                          path: images[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Favorite Button
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorManager.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite
                          ? ColorManager.chaletUnavailableRed
                          : ColorManager.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Rating Badge (Live Fetch)
              Positioned(
                top: 16,
                left: 16,
                child: RatingDisplayWidget(
                  chaletId: widget.docId,
                  isDark: false, // Badge always dark bg
                  isBadge: true,
                ),
              ),

              // Image Indicators
              if (images.length > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentImageIndex == index ? 8 : 6,
                        height: _currentImageIndex == index ? 8 : 6,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? ColorManager.white
                              : ColorManager.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.badge != null)
                Positioned(top: 50, right: 16, child: widget.badge!),
            ],
          ),

          // 2. Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chaletName,
                            style: TextStyle(
                              color: isDark
                                  ? ColorManager.white
                                  : ColorManager.chaletBackgroundDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: isDark
                                    ? ColorManager.white.withOpacity(0.6)
                                    : ColorManager.chaletGrey500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    color: isDark
                                        ? ColorManager.white.withOpacity(0.6)
                                        : ColorManager.chaletGrey500,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // DETAILS: Bedrooms, Bathrooms, Children
                Row(
                  children: [
                    // Bedrooms
                    _buildInfoBadge(
                      context,
                      icon: Icons.bed_outlined,
                      text: '${widget.chaletData['bedrooms'] ?? 0} غرف',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),

                    // Bathrooms
                    _buildInfoBadge(
                      context,
                      icon: Icons.bathtub_outlined,
                      text: '${widget.chaletData['bathrooms'] ?? 0} حمام',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),

                    // Children
                    if (widget.chaletData['childrenCount'] != null &&
                        (widget.chaletData['childrenCount'] as int) > 0) ...[
                      _buildInfoBadge(
                        context,
                        icon: Icons.child_care_outlined,
                        text: '${widget.chaletData['childrenCount']} أطفال',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Chalet Area
                    if (widget.chaletData['chaletArea'] != null &&
                        widget.chaletData['chaletArea'].toString().isNotEmpty)
                      _buildInfoBadge(
                        context,
                        icon: Icons.square_foot_rounded,
                        text: '${widget.chaletData['chaletArea']} م²',
                        isDark: isDark,
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // STAR RATING (Live Fetch)
                RatingDisplayWidget(
                  chaletId: widget.docId,
                  isDark: isDark,
                  isBadge: false,
                ),

                const SizedBox(height: 16),

                // Price and Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_hasDiscount()) ...[
                          Text(
                            '$price جنيه',
                            style: TextStyle(
                              color: isDark
                                  ? ColorManager.white.withOpacity(0.5)
                                  : ColorManager.chaletGrey500,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              decorationColor:
                                  ColorManager.chaletUnavailableRed,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _calculateDiscountedPrice(),
                                style: TextStyle(
                                  color: ColorManager
                                      .kPrimaryGradient
                                      .colors
                                      .first,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'جنيه / ليلة',
                                style: TextStyle(
                                  color: isDark
                                      ? ColorManager.white.withOpacity(0.7)
                                      : ColorManager.chaletGrey600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$price',
                                style: TextStyle(
                                  color: ColorManager
                                      .kPrimaryGradient
                                      .colors
                                      .first,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'جنيه / ليلة',
                                style: TextStyle(
                                  color: isDark
                                      ? ColorManager.white.withOpacity(0.7)
                                      : ColorManager.chaletGrey600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    ElevatedButton(
                      onPressed:
                          widget.onDetailsPressed ??
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChaletDetailPage(
                                  requestData: widget.chaletData,
                                  docId: widget.docId,
                                  status: 'approved',
                                ),
                              ),
                            );
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? ColorManager.white
                            : ColorManager.black,
                        foregroundColor: isDark
                            ? ColorManager.black
                            : ColorManager.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'عرض التفاصيل',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasDiscount() {
    final discountEnabled = widget.chaletData['discountEnabled'] ?? false;
    final discountValue = widget.chaletData['discountValue'];
    return discountEnabled == true &&
        discountValue != null &&
        discountValue.toString().isNotEmpty;
  }

  String _calculateDiscountedPrice() {
    final price = widget.chaletData['price'];
    final discountType = widget.chaletData['discountType'];
    final discountValue = widget.chaletData['discountValue'];

    if (!_hasDiscount() || price == null) return price?.toString() ?? '0';

    final originalPrice = (price is num)
        ? price.toDouble()
        : double.tryParse(price.toString().replaceAll(RegExp('[^0-9.]'), '')) ??
              0.0;

    final value = (discountValue is num)
        ? discountValue.toDouble()
        : double.tryParse(
                discountValue.toString().replaceAll(RegExp('[^0-9.]'), ''),
              ) ??
              0.0;

    double discountedPrice = originalPrice;

    if (discountType == 'percentage') {
      discountedPrice = originalPrice - (originalPrice * (value / 100));
    } else {
      discountedPrice = originalPrice - value;
    }

    if (discountedPrice < 0) discountedPrice = 0;
    return discountedPrice.toStringAsFixed(0);
  }

  Widget _buildInfoBadge(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? ColorManager.white.withOpacity(0.7)
              : ColorManager.grey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? ColorManager.white.withOpacity(0.7)
                : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PublicChaletsList extends StatelessWidget {
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;
  final String? selectedCategory;

  const PublicChaletsList({
    super.key,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chalets')
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: 3,
            itemBuilder: (context, i) => const PublicChaletCardShimmer(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: ColorManager.chaletUnavailableRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تحميل الشاليهات',
                  style: TextStyle(
                    fontSize: 18,
                    color: ColorManager.chaletGrey500,
                  ),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  emptyIcon ?? Icons.home_outlined,
                  size: 72,
                  color: ColorManager.chaletGrey400,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyTitle ?? 'لا توجد شاليهات متاحة',
                  style: TextStyle(
                    fontSize: 18,
                    color: ColorManager.chaletGrey500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        final docs = snapshot.data!.docs;

        return ValueListenableBuilder<SearchFilters>(
          valueListenable: HomeSearch.filters,
          builder: (context, filters, _) {
            // Debug logging
            print('🔍 === SEARCH DEBUG ===');
            print('📊 Total chalets from Firestore: ${docs.length}');
            final filtered = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              // Visibility check
              final isVisible = data['isVisible'] ?? true;
              if (!isVisible) return false;

              // Category filter (from home screen tabs)
              if (selectedCategory != null) {
                final features = data['features'] as List<dynamic>?;
                if (features == null || !features.contains(selectedCategory)) {
                  return false;
                }
              }

              // Apply search filters using centralized service
              final singleList = [data];
              final result = ChaletFilterService.filterChalets(
                singleList,
                filters,
              );
              return result.isNotEmpty;
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      emptyIcon ?? Icons.home_outlined,
                      size: 72,
                      color: ColorManager.chaletGrey400,
                      key: const Key('empty-icon'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      emptyTitle ?? 'لا توجد شاليهات متاحة',
                      style: TextStyle(
                        fontSize: 18,
                        color: ColorManager.chaletGrey500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 0, bottom: 80),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final doc = filtered[i];
                final data = doc.data() as Map<String, dynamic>;
                return PublicChaletCard(chaletData: data, docId: doc.id);
              },
            );
          },
        );
      },
    );
  }
}
