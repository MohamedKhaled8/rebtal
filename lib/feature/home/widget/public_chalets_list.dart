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

  PageController? _pageController;
  bool _favoriteChecked = false;

  @override
  void initState() {
    super.initState();
    try {
      final user = context.read<AppCubit>().authCubit.getCurrentUser();
      _userId = user?.uid;
    } catch (_) {}
    // Initialize carousel without auto-play for better performance
    final images = _collectChaletImages(widget.chaletData);
    if (images.length > 1) {
      _pageController = PageController();
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  // Check favorite status on demand (lazy loading)
  Future<bool> _checkFavoriteStatus() async {
    if (_userId == null) return false;
    try {
      final favDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(widget.docId)
          .get();
      return favDoc.exists;
    } catch (_) {
      return false;
    }
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

    final images = _collectChaletImages(widget.chaletData);
    final isDark = DynamicThemeManager.isDarkMode(context);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B0F0D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
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
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image & Overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          // Page index changed
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

                  // Top Badges
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RatingDisplayWidget(
                          chaletId: widget.docId,
                          isDark: false,
                          isBadge: true,
                        ),

                        FutureBuilder<bool>(
                          future: _favoriteChecked
                              ? null
                              : _checkFavoriteStatus(),
                          builder: (context, snapshot) {
                            if (!_favoriteChecked && snapshot.hasData) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    _isFavorite = snapshot.data ?? false;
                                    _favoriteChecked = true;
                                  });
                                }
                              });
                            }
                            return GestureDetector(
                              onTap: _toggleFavorite,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _isFavorite
                                      ? Colors.redAccent
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Discount Badge if applicable
                  if (_hasDiscount())
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'عرض خاص',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // 2. Info Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chaletName,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPriceSection(isDark),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Stats
                    Row(
                      children: [
                        _buildStat(
                          Icons.bed_outlined,
                          '${widget.chaletData['bedrooms'] ?? 0} نوم',
                          isDark,
                        ),
                        const SizedBox(width: 16),
                        _buildStat(
                          Icons.bathtub_outlined,
                          '${widget.chaletData['bathrooms'] ?? 0} حمام',
                          isDark,
                        ),
                        const SizedBox(width: 16),
                        if (widget.chaletData['chaletArea'] != null)
                          _buildStat(
                            Icons.square_foot_outlined,
                            '${widget.chaletData['chaletArea']} م²',
                            isDark,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? Colors.white38 : Colors.black45),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(bool isDark) {
    final price = widget.chaletData['price'];
    final discounted = _calculateDiscountedPrice();
    final hasDisc = _hasDiscount();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasDisc)
          Text(
            '$price',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              hasDisc ? discounted : '$price',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'ج.م',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
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
}

class PublicChaletsList extends StatefulWidget {
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
  State<PublicChaletsList> createState() => _PublicChaletsListState();
}

class _PublicChaletsListState extends State<PublicChaletsList> {
  int _displayLimit = 10; // Start with 10 items as requested
  final int _increment = 10;

  void _loadMore() {
    setState(() {
      _displayLimit += _increment;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chalets')
          .where('status', isEqualTo: 'approved')
          .where('isVisible', isEqualTo: true)
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
                  widget.emptyIcon ?? Icons.home_outlined,
                  size: 72,
                  color: ColorManager.chaletGrey400,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.emptyTitle ?? 'لا توجد شاليهات متاحة',
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
            // print('🔍 === SEARCH DEBUG ===');
            // print('📊 Total chalets from Firestore: ${docs.length}');

            final filtered = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              // Category filter
              if (widget.selectedCategory != null) {
                final features = data['features'] as List<dynamic>?;
                if (features == null ||
                    !features.contains(widget.selectedCategory)) {
                  return false;
                }
              }

              // Apply search filters
              final singleList = [data];
              final result = ChaletFilterService.filterChalets(
                singleList,
                filters,
              );
              return result.isNotEmpty;
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.emptyIcon ?? Icons.search_off_rounded,
                          size: 60,
                          color: isDark ? Colors.white24 : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.emptyTitle ?? 'لا توجد نتائج',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Pagination Logic
            // If user has filtered search, show all valid results to avoid hiding matches
            // If default view, use pagination limit
            final isFiltering = !filters.isEmpty;

            final int countToShow = isFiltering
                ? filtered.length
                : (_displayLimit > filtered.length
                      ? filtered.length
                      : _displayLimit);
            final bool hasMore =
                !isFiltering && filtered.length > _displayLimit;

            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 0, bottom: 20),
                  itemCount: countToShow,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data() as Map<String, dynamic>;
                    return PublicChaletCard(chaletData: data, docId: doc.id);
                  },
                ),

                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loadMore,
                        icon: const Icon(
                          Icons.expand_more,
                          color: Colors.white,
                        ),
                        label: Text(
                          'عرض المزيد (${filtered.length - countToShow} شاليه)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: ColorManager.chaletAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 60),
              ],
            );
          },
        );
      },
    );
  }
}
