import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/widgets/shimmers.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/navigation/ui/bottom_nav_controller.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:rebtal/core/services/chalet_filter_service.dart';

class PublicChaletCard extends StatefulWidget {
  final Map<String, dynamic> chaletData;
  final String docId;

  const PublicChaletCard({
    super.key,
    required this.chaletData,
    required this.docId,
  });

  @override
  State<PublicChaletCard> createState() => _PublicChaletCardState();
}

class _PublicChaletCardState extends State<PublicChaletCard> {
  bool _isFavorite = false;
  String? _userId;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    try {
      final user = context.read<AuthCubit>().getCurrentUser();
      _userId = user?.uid;
    } catch (_) {}
    _checkFavoriteInitial();
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
        if (result.length >= 5) break;
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
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
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
                  child: PageView.builder(
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

              // Favorite Button
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite
                          ? const Color(0xFFEF4444)
                          : Colors.white,
                      size: 24,
                    ),
                  ),
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
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 2. Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
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
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.6)
                                        : Colors.grey[600],
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

                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFD700),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.8', // Placeholder rating
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Features
                if (widget.chaletData['features'] != null &&
                    (widget.chaletData['features'] as List).isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (widget.chaletData['features'] as List)
                        .take(3)
                        .map(
                          (feature) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              feature.toString(),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Children Count
                if (widget.chaletData['childrenCount'] != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.child_care_rounded,
                        size: 14,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Children: ${widget.chaletData['childrenCount']}',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Price and Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'السعر لليلة',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (widget.chaletData['discountEnabled'] == true &&
                            widget.chaletData['discountValue'] != null) ...[
                          Text(
                            CurrencyFormatter.egp(
                              (price is num)
                                  ? price
                                  : double.tryParse(
                                          (price ?? '').toString().replaceAll(
                                            RegExp('[^0-9.]'),
                                            '',
                                          ),
                                        ) ??
                                        0,
                              withSuffixPerNight: false,
                            ),
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.grey[500],
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _calculateDiscountedPrice(widget.chaletData),
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else
                          Text(
                            CurrencyFormatter.egp(
                              (price is num)
                                  ? price
                                  : double.tryParse(
                                          (price ?? '').toString().replaceAll(
                                            RegExp('[^0-9.]'),
                                            '',
                                          ),
                                        ) ??
                                        0,
                              withSuffixPerNight: false,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: () {
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
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
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

  String _calculateDiscountedPrice(Map<String, dynamic> data) {
    final basePrice = (data['price'] is num)
        ? data['price'].toDouble()
        : double.tryParse(
                (data['price'] ?? '').toString().replaceAll(
                  RegExp('[^0-9.]'),
                  '',
                ),
              ) ??
              0.0;
    final discountType = data['discountType'];
    final discountValue = double.tryParse(data['discountValue'] ?? '0') ?? 0.0;

    double finalPrice = basePrice;
    if (discountType == 'percentage' && discountValue > 0) {
      finalPrice = basePrice * (1 - discountValue / 100);
    } else if (discountType == 'fixed' && discountValue > 0) {
      finalPrice = basePrice - discountValue;
      if (finalPrice < 0) finalPrice = 0;
    }

    return CurrencyFormatter.egp(finalPrice, withSuffixPerNight: false);
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
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تحميل الشاليهات',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  emptyTitle ?? 'لا توجد شاليهات متاحة',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
            print('🎯 Active filters:');
            print('   - Query: "${filters.query}"');
            print('   - Location: ${filters.location}');
            print('   - Price Range: ${filters.priceRange}');
            print('   - Min Bedrooms: ${filters.minBedrooms}');
            print('   - Min Bathrooms: ${filters.minBathrooms}');
            print('   - Min Area: ${filters.minArea}');
            print('   - Features: ${filters.features}');
            print('   - Facilities: ${filters.facilities}');
            print('   - Is Empty: ${filters.isEmpty}');

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

            print('✅ Filtered results: ${filtered.length} chalets');
            if (filtered.isNotEmpty && filtered.length <= 3) {
              print('📝 Sample filtered chalet names:');
              for (var doc in filtered) {
                final data = doc.data() as Map<String, dynamic>;
                print(
                  '   - ${data['chaletName']} (${data['location']}, ${data['price']} EGP)',
                );
              }
            }
            print('🔍 === END DEBUG ===\n');

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      emptyIcon ?? Icons.home_outlined,
                      size: 72,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      emptyTitle ?? 'لا توجد شاليهات متاحة',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
