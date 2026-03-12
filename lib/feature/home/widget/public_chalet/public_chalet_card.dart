import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';

import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/widgets/rating_display_widget.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PublicChaletCard extends StatefulWidget {
  final Map<String, dynamic> chaletData;
  final String docId;
  final VoidCallback? onDetailsPressed;
  final Widget? badge;
  final EdgeInsetsGeometry? margin;

  const PublicChaletCard({
    super.key,
    required this.chaletData,
    required this.docId,
    this.onDetailsPressed,
    this.badge,
    this.margin,
  });

  @override
  State<PublicChaletCard> createState() => _PublicChaletCardState();
}

class _PublicChaletCardState extends State<PublicChaletCard> {
  bool _isFavorite = false;
  String? _userId;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    try {
      final user = context.read<AppCubit>().authCubit.getCurrentUser();
      _userId = user?.uid;
      _checkInitialFavoriteStatus();
    } catch (_) {}
    final images = _collectChaletImages(widget.chaletData);
    if (images.length > 1) {
      _pageController = PageController();
    }
  }

  Future<void> _checkInitialFavoriteStatus() async {
    if (_userId == null) return;
    try {
      final favDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(widget.docId)
          .get();
      if (mounted && favDoc.exists) {
        setState(() {
          _isFavorite = true;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null) return;

    final wasFavorite = _isFavorite;

    // 1. Optimistic Update
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      final favRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(widget.docId);

      if (wasFavorite) {
        // Was favorite, now removing
        await favRef.delete();
      } else {
        // Was not favorite, now adding
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
    } catch (e) {
      // 2. Rollback on failure
      if (mounted) {
        setState(() {
          _isFavorite = wasFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('favorites_update_error')}: $e'),
          ),
        );
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
      }
    }

    if (result.isEmpty) {
      result.add('https://via.placeholder.com/400x300?text=No+Image');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final chaletName =
        widget.chaletData['chaletName'] ?? context.tr('home_chalet_no_name');
    final location =
        widget.chaletData['location'] ?? context.tr('home_location_unknown');

    final images = _collectChaletImages(widget.chaletData);
    final isDark = DynamicThemeManager.isDarkMode(context);

    return RepaintBoundary(
      child: Container(
        margin:
            widget.margin ??
            EdgeInsets.only(
              bottom: otv(context: context, portrait: 24.sh, landscape: 12.sh),
              left: stv(
                context: context,
                mobile: 16.sw,
                tablet: 24.sw,
                desktop: 32.sw,
              ),
              right: stv(
                context: context,
                mobile: 16.sw,
                tablet: 24.sw,
                desktop: 32.sw,
              ),
            ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B0F0D) : Colors.white,
          borderRadius: BorderRadius.circular(12.sp),
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
          borderRadius: BorderRadius.circular(12.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image & Overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.sp),
                    ),
                    child: SizedBox(
                      height: otv(
                        context: context,
                        portrait: stv(
                          context: context,
                          mobile: 230.sh,
                          tablet: 235.sh,
                          desktop: 245.sh,
                        ),
                        landscape: stv(
                          context: context,
                          mobile: 330.sh,
                          tablet: 350.sh,
                          desktop: 400.sh,
                        ),
                      ),
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
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
                    top: 20,
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isNewChalet())
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  context.tr('common_new_badge'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: _toggleFavorite,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder:
                                      (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                  child: Icon(
                                    _isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    key: ValueKey<bool>(_isFavorite),
                                    color: _isFavorite
                                        ? Colors.redAccent
                                        : Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          context.tr('home_special_offer'),
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
                padding: EdgeInsets.all(
                  stv(
                    context: context,
                    mobile: 10.sw,
                    tablet: 12.sw,
                    desktop: 15.sw,
                  ),
                ),
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
                              fontSize: stv(
                                context: context,
                                mobile: 18.spScaled,
                                tablet: 22.spScaled,
                                desktop: 26.spScaled,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: stv(
                            context: context,
                            mobile: 8.sw,
                            tablet: 12.sw,
                            desktop: 16.sw,
                          ),
                        ),
                        _buildPriceSection(context, isDark),
                      ],
                    ),
                    SizedBox(
                      height: otv(
                        context: context,
                        portrait: 4.sh,
                        landscape: 2.sh,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: stv(
                            context: context,
                            mobile: 14.spScaled,
                            tablet: 16.spScaled,
                            desktop: 18.spScaled,
                          ),
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                        SizedBox(
                          width: stv(
                            context: context,
                            mobile: 4.sw,
                            tablet: 6.sw,
                            desktop: 8.sw,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey[600],
                              fontSize: stv(
                                context: context,
                                mobile: 12.spScaled,
                                tablet: 14.spScaled,
                                desktop: 16.spScaled,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: otv(
                        context: context,
                        portrait: 12.sh,
                        landscape: 6.sh,
                      ),
                    ),

                    // Stats
                    Row(
                      children: [
                        _buildStat(
                          context,
                          Icons.bed_outlined,
                          '${widget.chaletData['bedrooms'] ?? 0} ${context.tr('common_beds_short')}',
                          isDark,
                        ),
                        SizedBox(
                          width: stv(
                            context: context,
                            mobile: 16.sw,
                            tablet: 24.sw,
                            desktop: 32.sw,
                          ),
                        ),
                        _buildStat(
                          context,
                          Icons.bathtub_outlined,
                          '${widget.chaletData['bathrooms'] ?? 0} ${context.tr('common_baths_short')}',
                          isDark,
                        ),
                        SizedBox(
                          width: stv(
                            context: context,
                            mobile: 16.sw,
                            tablet: 24.sw,
                            desktop: 32.sw,
                          ),
                        ),
                        if (widget.chaletData['chaletArea'] != null)
                          _buildStat(
                            context,
                            Icons.square_foot_outlined,
                            '${widget.chaletData['chaletArea']} ${context.tr('common_m2')}',
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

  Widget _buildStat(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: stv(
            context: context,
            mobile: 14.spScaled,
            tablet: 16.spScaled,
            desktop: 18.spScaled,
          ),
          color: isDark ? Colors.white38 : Colors.black45,
        ),
        SizedBox(
          width: stv(
            context: context,
            mobile: 4.sw,
            tablet: 6.sw,
            desktop: 8.sw,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: stv(
              context: context,
              mobile: 11.spScaled,
              tablet: 13.spScaled,
              desktop: 15.spScaled,
            ),
            color: isDark ? Colors.white38 : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context, bool isDark) {
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
              fontSize: stv(
                context: context,
                mobile: 15.spScaled,
                tablet: 17.spScaled,
                desktop: 19.spScaled,
              ),
              color: isDark ? Colors.white54 : Colors.grey[700],
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.red.withOpacity(0.5),
              decorationThickness: 2,
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
                fontSize: stv(
                  context: context,
                  mobile: 18.spScaled,
                  tablet: 22.spScaled,
                  desktop: 26.spScaled,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: stv(
                context: context,
                mobile: 4.sw,
                tablet: 6.sw,
                desktop: 8.sw,
              ),
            ),
            Text(
              context.tr('booking_egp_currency'),
              style: TextStyle(
                fontSize: stv(
                  context: context,
                  mobile: 10.spScaled,
                  tablet: 12.spScaled,
                  desktop: 14.spScaled,
                ),
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isNewChalet() {
    final createdAt = widget.chaletData['createdAt'];
    if (createdAt == null) return false;

    DateTime? date;
    if (createdAt is Timestamp) {
      date = createdAt.toDate();
    } else if (createdAt is String) {
      date = DateTime.tryParse(createdAt);
    }

    if (date == null) return false;

    final difference = DateTime.now().difference(date);
    return difference.inHours <= 48;
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
