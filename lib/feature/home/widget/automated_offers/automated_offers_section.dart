import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';
import 'package:rebtal/feature/home/widget/automated_offers/automated_offer_card.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class AutomatedOffersSection extends StatelessWidget {
  const AutomatedOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (!state.showDiscountedSection) {
          return const SizedBox.shrink();
        }

        final isDark = DynamicThemeManager.isDarkMode(context);
        final offers = state.discountedOffers;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: stv(
                  context: context,
                  mobile: 16.sw,
                  tablet: 24.sw,
                  desktop: 32.sw,
                ),
                vertical: otv(
                  context: context,
                  portrait: 8.sh,
                  landscape: 4.sh,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('home_exclusive_offers'),
                    style: TextStyle(
                      fontSize: stv(
                        context: context,
                        mobile: 18.spScaled,
                        tablet: 22.spScaled,
                        desktop: 26.spScaled,
                      ),
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? ColorsManager.white
                          : ColorsManager.black87,
                    ),
                  ),
                  Text(
                    '${offers.length} ${context.tr('home_offers_available')}',
                    style: TextStyle(
                      color: ColorsManager.primaryColor,
                      fontSize: stv(
                        context: context,
                        mobile: 13.spScaled,
                        tablet: 16.spScaled,
                        desktop: 18.spScaled,
                      ),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: otv(
                context: context,
                portrait: stv(
                  context: context,
                  mobile: 32.h,
                  tablet: 40.h,
                  desktop: 50.h,
                ),
                landscape: stv(
                  context: context,
                  mobile: 60.h,
                  tablet: 65.h,
                  desktop: 70.h,
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return AutomatedOfferCard(
                    data: offer.data,
                    docId: offer.id,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
