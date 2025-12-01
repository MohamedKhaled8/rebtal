import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/fixed_bottom_bar_cubit.dart';

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
    return BlocProvider(
      create: (context) =>
          FixedBottomBarCubit()
            ..loadData(price: price, requestData: requestData),
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
                      // Reserve Now Button
                      ElevatedButton(
                        onPressed: () =>
                            context.read<FixedBottomBarCubit>().handleBooking(
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
}
