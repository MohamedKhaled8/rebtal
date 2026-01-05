import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/fixed_bottom_bar_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';

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
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? ColorManager.chaletCardDark
                      : ColorManager.chaletCardLight,
                  boxShadow: [
                    BoxShadow(
                      color: ColorManager.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
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
                            if (state.originalPrice != null) ...[
                              Text(
                                '${state.originalPrice} / night',
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
                                    text: state.displayPrice.split(' /')[0],
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
                                          : ColorManager
                                                .chaletTextSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (isReOffer && state.booking != null) ...[
                        if (state.isOriginalOfferOwner) ...[
                          // Cancellation Button for Original Tenant
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context
                                  .read<FixedBottomBarCubit>()
                                  .cancelOffer(context, docId: docId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.chaletActionRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'إلغاء العرض',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Accept & Contact Buttons for New Tenant
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Accept Button (Top)
                                SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (!state.hasContactedOriginalTenant) {
                                        context
                                            .read<FixedBottomBarCubit>()
                                            .markContacted();
                                        _showContactInfo(
                                          context,
                                          state.booking!,
                                        );
                                      } else {
                                        context
                                            .read<FixedBottomBarCubit>()
                                            .confirmTransfer(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ColorManager.chaletActionGreen,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      state.hasContactedOriginalTenant
                                          ? 'قبول الحجز الآن'
                                          : 'موافقة مبدئية',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Contact Button (Bottom)
                                SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      context
                                          .read<FixedBottomBarCubit>()
                                          .markContacted();
                                      _showContactInfo(context, state.booking!);
                                    },
                                    icon: const Icon(
                                      Icons.chat_outlined,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'تواصل مع المستأجر',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                      side: BorderSide(
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.black12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        // Reserve Now Button (Normal Flow)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context
                                .read<FixedBottomBarCubit>()
                                .handleBooking(
                                  context,
                                  docId: docId,
                                  requestData: requestData,
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.chaletAccent,
                              foregroundColor: ColorManager.white,
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showContactInfo(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? ColorManager.chaletCardDark : Colors.white,
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
