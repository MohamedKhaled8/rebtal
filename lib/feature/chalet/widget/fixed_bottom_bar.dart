import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/ui/booking_bridge_widget.dart';

class FixedBottomBar extends StatelessWidget {
  final dynamic price;
  final Map<String, dynamic> requestData;
  final bool isDark;
  final String docId;

  const FixedBottomBar({
    super.key,
    required this.price,
    required this.requestData,
    required this.isDark,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice = CurrencyFormatter.egp(
      (price is num) ? price : double.tryParse((price ?? '').toString()) ?? 0,
      withSuffixPerNight: true,
    );

    // Calculate discount logic
    final discountEnabled = requestData['discountEnabled'] == true;
    final discountValue =
        double.tryParse(requestData['discountValue']?.toString() ?? '0') ?? 0;

    String displayPrice;
    String? originalPriceStr;

    if (discountEnabled && discountValue > 0) {
      // Calculate discounted price
      final basePrice = (price is num)
          ? price.toDouble()
          : double.tryParse(
                  (price ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), ''),
                ) ??
                0.0;

      final discountType = requestData['discountType'];
      double finalPrice = basePrice;

      if (discountType == 'percentage') {
        finalPrice = basePrice * (1 - discountValue / 100);
      } else if (discountType == 'fixed') {
        finalPrice = basePrice - discountValue;
      }
      if (finalPrice < 0) finalPrice = 0;

      displayPrice = CurrencyFormatter.egp(
        finalPrice,
        withSuffixPerNight: true,
      );
      originalPriceStr = CurrencyFormatter.egp(
        basePrice,
        withSuffixPerNight: false,
      );
    } else {
      displayPrice = formattedPrice;
      originalPriceStr = null;
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? ColorManager.chaletCardDark
              : ColorManager.chaletCardLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Price Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (originalPriceStr != null) ...[
                      Text(
                        '$originalPriceStr / night',
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: isDark
                              ? ColorManager.chaletTextSecondaryDark
                              : ColorManager.chaletTextSecondaryLight,
                          decorationThickness: 2,
                          color: isDark
                              ? ColorManager.chaletTextSecondaryDark
                              : ColorManager.chaletTextSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: displayPrice.split(' /')[0],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: ColorManager.chaletAccent,
                            ),
                          ),
                          TextSpan(
                            text: ' / night',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? ColorManager.chaletTextSecondaryDark
                                  : ColorManager.chaletTextSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Reserve Now Button
              ElevatedButton(
                onPressed: () => _handleBooking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.chaletAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Reserve Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBooking(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.getCurrentUser();
    if (currentUser == null) return;

    final bookingAvailability =
        requestData['bookingAvailability'] ?? 'available';
    final isBookingAvailable = bookingAvailability == 'available';

    if (isBookingAvailable) {
      var ownerId = requestData['ownerId'] ?? requestData['userId'] ?? '';
      if (ownerId.isEmpty) {
        ownerId = '';
      }

      final chaletId = docId;
      final chaletName =
          requestData['chaletName'] ?? requestData['name'] ?? 'شاليه';
      final ownerName =
          requestData['merchantName'] ??
          requestData['ownerName'] ??
          'صاحب الشاليه';

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => BookingBridgeWidget(
          chaletId: chaletId,
          chaletName: chaletName,
          ownerId: ownerId,
          ownerName: ownerName,
          userId: currentUser.uid,
          userName: currentUser.name,
          requestData: requestData,
          parentContext: context,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'الحجز غير متاح حالياً',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
