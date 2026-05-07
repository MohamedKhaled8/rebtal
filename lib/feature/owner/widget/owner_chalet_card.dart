import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/utils/owner_helper.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

double _averageRatingFromMap(Map<String, dynamic> d) {
  final v = d['averageRating'] ?? d['avgRating'] ?? d['rating'];
  if (v is num) return v.toDouble();
  return 0.0;
}

int _ratingCountFromMap(Map<String, dynamic> d) {
  final c = d['ratingCount'] ?? d['reviewCount'];
  if (c is num) return c.toInt();
  return 0;
}

class OwnerChaletCard extends StatelessWidget {
  final Map<String, dynamic> chaletData;
  final String docId;
  final EdgeInsets? margin;

  const OwnerChaletCard({
    super.key,
    required this.chaletData,
    required this.docId,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final ownerCubit = context.read<AppCubit>().ownerCubit;
    final chaletName =
        chaletData['chaletName'] ?? context.tr('home_chalet_no_name');
    final location =
        chaletData['location'] ?? context.tr('home_location_unknown');
    final price = chaletData['price'];
    final images = OwnerHelper.collectChaletImages(chaletData);
    final status = chaletData['status'] ?? 'pending';

    final bool isVisible = chaletData['isVisible'] ?? true;
    final String bookingStatus =
        chaletData['bookingAvailability'] ??
        (chaletData['isAvailable'] == true ? 'available' : 'unavailable');
    final bool isBookingAvailable = bookingStatus == 'available';

    final isDark = DynamicThemeManager.isDarkMode(context);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChaletDetailPage(
            requestData: chaletData,
            docId: docId,
            status: status,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? ColorsManager.chaletBackgroundDark
              : ColorsManager.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? ColorsManager.white.withValues(alpha: 0.05)
                : ColorsManager.chaletGrey200.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? ColorsManager.black.withValues(alpha: 0.2)
                  : ColorsManager.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Stack
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: AppImageHelper(
                      path: images.first,
                      fit: BoxFit.cover,
                      cacheScope: docId,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _StatusBadge(status: status),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      children: [
                        _CompactBadge(
                          label: isVisible
                              ? context.tr('common_visible')
                              : context.tr('common_hidden'),
                          color: isVisible
                              ? ColorsManager.chaletActionBlue
                              : ColorsManager.grey,
                        ),
                        const SizedBox(width: 8),
                        _CompactBadge(
                          label: isBookingAvailable
                              ? context.tr('common_available')
                              : context.tr('common_closed'),
                          color: isBookingAvailable
                              ? ColorsManager.green
                              : ColorsManager.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chaletName,
                      style: TextStyle(
                        color: isDark
                            ? ColorsManager.white
                            : ColorsManager.chaletBackgroundDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _LocationRow(location: location),
                    const SizedBox(height: 12),

                    // Info Row: Bed, Bath, Children
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _InfoBadge(
                            icon: Icons.bed_outlined,
                            text:
                                '${chaletData['bedrooms'] ?? 0} ${context.tr('common_rooms')}',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 12),
                          _InfoBadge(
                            icon: Icons.bathtub_outlined,
                            text:
                                '${chaletData['bathrooms'] ?? 0} ${context.tr('common_baths')}',
                            isDark: isDark,
                          ),
                          if (chaletData['childrenCount'] != null &&
                              (chaletData['childrenCount'] as int) > 0) ...[
                            const SizedBox(width: 12),
                            _InfoBadge(
                              icon: Icons.child_care_outlined,
                              text:
                                  '${chaletData['childrenCount']} ${context.tr('common_children')}',
                              isDark: isDark,
                            ),
                          ],
                          if (chaletData['chaletArea'] != null &&
                              chaletData['chaletArea'].toString().isNotEmpty) ...[
                            const SizedBox(width: 12),
                            _InfoBadge(
                              icon: Icons.square_foot_rounded,
                              text:
                                  '${chaletData['chaletArea']} ${context.tr('common_m2')}',
                              isDark: isDark,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Rating Row (Firestore: averageRating, ratingCount / reviewCount)
                    _RatingRow(chaletData: chaletData),

                    const SizedBox(height: 12),

                    // Calculate discount
                    (() {
                      final hasDiscount = chaletData['discountEnabled'] == true;
                      if (hasDiscount) {
                        final discountValue =
                            double.tryParse(
                              chaletData['discountValue']?.toString() ?? '0',
                            ) ??
                            0;
                        final isPercentage =
                            chaletData['discountType'] == 'percentage';
                        final discountAmount = isPercentage
                            ? (price * discountValue / 100)
                            : discountValue;
                        final discountedPrice = (price - discountAmount).clamp(
                          0.0,
                          double.infinity,
                        );

                        return _PriceRow(
                          originalPrice: price,
                          finalPrice: discountedPrice,
                          hasDiscount: true,
                        );
                      } else {
                        return _PriceRow(
                          originalPrice: price,
                          finalPrice: price,
                          hasDiscount: false,
                        );
                      }
                    })(),

                    const SizedBox(height: 16),

                    // Management Actions
                    Row(
                      children: [
                        Expanded(
                          child: _ActionToggle(
                            icon: isVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            label: isVisible
                                ? context.tr('common_hide')
                                : context.tr('common_show'),
                            color: isVisible
                                ? ColorsManager.orange
                                : ColorsManager.green,
                            onTap: () => ownerCubit.toggleChaletVisibility(
                              docId,
                              isVisible,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionToggle(
                            icon: isBookingAvailable
                                ? Icons.lock
                                : Icons.lock_open,
                            label: isBookingAvailable
                                ? context.tr('owner_stop_booking')
                                : context.tr('owner_open_booking'),
                            color: isBookingAvailable
                                ? ColorsManager.red
                                : ColorsManager.green,
                            onTap: () => ownerCubit.toggleBookingAvailability(
                              docId,
                              bookingStatus,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChaletDetailPage(
                              requestData: chaletData,
                              docId: docId,
                              status: status,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: ColorsManager.purple),
                        ),
                        child: Text(context.tr('owner_view_full_details')),
                      ),
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
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'approved'
        ? ColorsManager.green
        : status == 'rejected'
        ? ColorsManager.red
        : ColorsManager.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status == 'approved'
            ? context.tr('common_approved')
            : status == 'rejected'
            ? context.tr('common_rejected')
            : context.tr('booking_status_pending'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CompactBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CompactBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final String location;
  const _LocationRow({required this.location});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 14,
          color: isDark
              ? ColorsManager.white.withValues(alpha: 0.6)
              : ColorsManager.chaletGrey500,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            style: TextStyle(
              color: isDark
                  ? ColorsManager.white.withValues(alpha: 0.6)
                  : ColorsManager.chaletGrey500,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final dynamic originalPrice;
  final double finalPrice;
  final bool hasDiscount;

  const _PriceRow({
    required this.originalPrice,
    required this.finalPrice,
    required this.hasDiscount,
  });

  @override
  Widget build(BuildContext context) {
    final double basePrice = (originalPrice is num)
        ? originalPrice.toDouble()
        : double.tryParse(
                originalPrice.toString().replaceAll(RegExp('[^0-9.]'), ''),
              ) ??
              0;

    return Row(
      children: [
        Text(
          CurrencyFormatter.egp(context, finalPrice, withSuffixPerNight: true),
          style: TextStyle(
            color: ColorsManager.blue2563EB,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 8),
          Text(
            CurrencyFormatter.egp(context, basePrice),
            style: TextStyle(
              color: ColorsManager.grey400,
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionToggle({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? ColorsManager.white.withValues(alpha: 0.7)
              : ColorsManager.grey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? ColorsManager.white.withValues(alpha: 0.7)
                : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final Map<String, dynamic> chaletData;

  const _RatingRow({required this.chaletData});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final rating = _averageRatingFromMap(chaletData);
    final count = _ratingCountFromMap(chaletData);

    if (count <= 0 && rating <= 0) {
      return Text(
        context.tr('chalet_detail_no_reviews'),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white54 : Colors.grey[600],
        ),
      );
    }

    final label = count > 0
        ? '${rating == rating.roundToDouble() ? rating.toInt() : rating.toStringAsFixed(1)} ($count ${context.tr('common_ratings')})'
        : (rating == rating.roundToDouble()
              ? rating.toInt().toString()
              : rating.toStringAsFixed(1));

    return Row(
      children: [
        ...List.generate(5, (index) {
          IconData icon = Icons.star_border;
          Color color = ColorsManager.chaletGrey400;
          if (index < rating.floor()) {
            icon = Icons.star;
            color = Colors.amber;
          } else if (index < rating && (rating - index) >= 0.5) {
            icon = Icons.star_half;
            color = Colors.amber;
          }
          return Icon(icon, size: 18, color: color);
        }),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
