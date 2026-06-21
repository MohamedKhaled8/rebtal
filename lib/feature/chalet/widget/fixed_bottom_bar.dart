import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/feature/chalet/logic/cubit/fixed_bottom_bar_cubit.dart';
import 'package:rebtal/feature/owner/utils/owner_helper.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

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
    this.bookingId,
    this.isReOffer = false,
  });

  final String? bookingId;
  final bool isReOffer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final appCubit = context.read<AppCubit>();
        final currentUser = appCubit.authCubit.getCurrentUser();
        return FixedBottomBarCubit()..loadData(
          price: price,
          requestData: requestData,
          bookingId: bookingId,
          currentUserId: currentUser?.uid,
        );
      },
      child: BlocBuilder<FixedBottomBarCubit, FixedBottomBarState>(
        builder: (context, state) {
          if (state is FixedBottomBarLoaded) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Price Section (Left)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.originalPriceValue != null)
                            Text(
                              CurrencyFormatter.egp(
                                context,
                                state.originalPriceValue!,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF717171),
                                decorationColor: isDark
                                    ? Colors.white54
                                    : const Color(0xFF717171),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.egp(
                                  context,
                                  state.displayPriceValue,
                                  withSuffixPerNight: false,
                                ),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700, // Bold
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF222222),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  OwnerHelper.shouldLabelPricePerDay(
                                        requestData,
                                      )
                                      ? context.tr('common_day')
                                      : context.tr('chalet_night'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF717171),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Optional date placeholder or offer info
                          if (isReOffer)
                            Text(
                              'Re-offer',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Button Section (Right)
                    if (isReOffer && state.booking != null) ...[
                      if (state.isOriginalOfferOwner) ...[
                        // Cancellation Button
                        _buildActionButton(
                          context: context,
                          label: 'إلغاء العرض',
                          color: const Color(0xFFE51D42), // Red
                          onPressed: () => context
                              .read<FixedBottomBarCubit>()
                              .cancelOffer(context, docId: docId),
                        ),
                      ] else ...[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!state.hasContactedOriginalTenant) {
                                    context
                                        .read<FixedBottomBarCubit>()
                                        .markContacted();
                                    _showContactInfo(context, state.booking!);
                                  } else {
                                    context
                                        .read<FixedBottomBarCubit>()
                                        .confirmTransfer(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF222222),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  state.hasContactedOriginalTenant
                                      ? 'قبول الحجز'
                                      : 'موافقة مبدئية',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ] else ...[
                      // Reserve Now Button (Standard)
                      Builder(
                        builder: (context) {
                          // Availability for normal bookings is controlled via `bookingAvailability`.
                          // For day-use, we scope the "unavailable" flag to admin-confirmed payments only.
                          final bool supportsDayUse =
                              OwnerHelper.supportsDayUseBooking(requestData);
                          final String? dayUseBookedAt =
                              requestData['dayUseBookedAt']?.toString();
                          final String? dayUseStatus =
                              requestData['dayUseBookingAvailability']
                                  ?.toString();

                          final now = DateTime.now();
                          final todayKey =
                              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                          final status = requestData['bookingAvailability'];
                          final isAvailable = supportsDayUse
                              ? !(dayUseStatus == 'unavailable' &&
                                  dayUseBookedAt == todayKey)
                              : status != 'unavailable';

                          return SizedBox(
                            width: 140,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isAvailable
                                  ? () => context
                                        .read<FixedBottomBarCubit>()
                                        .handleBooking(
                                          context,
                                          docId: docId,
                                          requestData: requestData,
                                          price: price,
                                        )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFE51D55,
                                ), // Vibrant Pink/Red
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                disabledBackgroundColor: isDark
                                    ? const Color(0xFF2B2B2B)
                                    : const Color(0xFFE5E7EB),
                                disabledForegroundColor: isDark
                                    ? Colors.white70
                                    : const Color(0xFF4B5563),
                              ),
                              child: Text(
                                isAvailable
                                    ? context.tr('chalet_reserve')
                                    : context.tr('chalet_unavailable'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: 140,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showContactInfo(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? ColorsManager.chaletCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "بيانات المستأجر الأول",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.person,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              title: Text(
                booking.userName,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.phone_in_talk,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              title: Text(
                booking.userPhone ?? "غير متوفر",
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              subtitle: const Text(
                "اضغط للاتصال مباشره",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              onTap: () {
                if (booking.userPhone != null) {
                  UriLauncherService.launchPhoneCall(
                    context,
                    booking.userPhone!,
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (booking.userPhone != null) {
                        UriLauncherService.launchPhoneCall(
                          context,
                          booking.userPhone!,
                        );
                      }
                    },
                    icon: const Icon(Icons.phone_forwarded_rounded, size: 20),
                    label: const Text("اتصال هاتفى"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white10
                          : Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.blue.shade200, width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (booking.userPhone != null) {
                        UriLauncherService.launchWhatsAppContact(
                          context: context,
                          phone: booking.userPhone!,
                          message:
                              'مرحباً ${booking.userName}، أنا مهتم بالحصول على حجزك في ${booking.chaletName}',
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                    ),
                    label: const Text("واتساب"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 4,
                      shadowColor: const Color(0xFF25D366).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
