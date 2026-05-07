import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/chalet/ui/chalet_detail_page.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class AutomatedOfferCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final bool isDark;

  const AutomatedOfferCard({
    super.key,
    required this.data,
    required this.docId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Logic to calculate discount percentage
    final price = (data['price'] as num?)?.toDouble() ?? 0.0;
    final discountValue =
        double.tryParse(data['discountValue'].toString()) ?? 0.0;
    final discountType = data['discountType'] ?? 'amount';

    double discountedPrice = price;
    int percentage = 0;

    if (discountType == 'percentage') {
      percentage = discountValue.toInt();
      discountedPrice = price - (price * (discountValue / 100));
    } else {
      if (price > 0) {
        percentage = ((discountValue / price) * 100).round();
      }
      discountedPrice = price - discountValue;
    }

    final images = data['images'] as List<dynamic>?;
    final imageUrl = (images != null && images.isNotEmpty)
        ? images[0]
        : data['profileImage'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChaletDetailPage(
              requestData: data,
              docId: docId,
              status: 'approved',
            ),
          ),
        );
      },
      child: Container(
        width: otv(
          context: context,
          portrait: stv(
            context: context,
            mobile: 65.w,
            tablet: 70.w,
            desktop: 75.w,
          ),
          landscape: stv(
            context: context,
            mobile: 35.w,
            tablet: 45.w,
            desktop: 30.w,
          ),
        ),
        margin: EdgeInsets.only(
          right: stv(
            context: context,
            mobile: 16.sw,
            tablet: 24.sw,
            desktop: 32.sw,
          ),
          bottom: otv(context: context, portrait: 8.sh, landscape: 4.sh),
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.sp),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full Background Image
              AppImageHelper(
                path: imageUrl.toString(),
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheScope: docId,
              ),

              // Gradient Overlay for Text Readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorsManager.transparent,
                        ColorsManager.black.withOpacity(0.2),
                        ColorsManager.black.withOpacity(0.8),
                      ],
                      stops: const [0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Discount Badge
              Positioned(
                top: otv(context: context, portrait: 16.sh, landscape: 20.sh),
                right: stv(
                  context: context,
                  mobile: 16.sw,
                  tablet: 24.sw,
                  desktop: 32.sw,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: stv(
                      context: context,
                      mobile: 12.sw,
                      tablet: 16.sw,
                      desktop: 20.sw,
                    ),
                    vertical: otv(
                      context: context,
                      portrait: 6.sh,
                      landscape: 4.sh,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30.sw),
                    boxShadow: [
                      BoxShadow(
                        color: ColorsManager.red.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_offer_rounded,
                        color: ColorsManager.white,
                        size: stv(
                          context: context,
                          mobile: 14.spScaled,
                          tablet: 16.spScaled,
                          desktop: 18.spScaled,
                        ),
                      ),
                      SizedBox(
                        width: stv(
                          context: context,
                          mobile: 6.sw,
                          tablet: 8.sw,
                          desktop: 10.sw,
                        ),
                      ),
                      Text(
                        '${context.tr('common_discount')} $percentage%',
                        style: TextStyle(
                          color: ColorsManager.white,
                          fontSize: stv(
                            context: context,
                            mobile: 16.spScaled,
                            tablet: 18.spScaled,
                            desktop: 20.spScaled,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Text Info Overlay
              Positioned(
                bottom: otv(context: context, portrait: 16.sh, landscape: 8.sh),
                right: stv(
                  context: context,
                  mobile: 16.sw,
                  tablet: 24.sw,
                  desktop: 32.sw,
                ),
                left: stv(
                  context: context,
                  mobile: 16.sw,
                  tablet: 24.sw,
                  desktop: 32.sw,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data['chaletName'] ?? context.tr('home_featured_chalet'),
                      style: TextStyle(
                        fontSize: stv(
                          context: context,
                          mobile: 22.spScaled,
                          tablet: 26.spScaled,
                          desktop: 30.spScaled,
                        ),
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: otv(
                        context: context,
                        portrait: 6.sh,
                        landscape: 4.sh,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${discountedPrice.round()} ${context.tr('booking_egp_currency')}',
                          style: TextStyle(
                            color: ColorsManager.white,
                            fontSize: stv(
                              context: context,
                              mobile: 16.spScaled,
                              tablet: 20.spScaled,
                              desktop: 24.spScaled,
                            ),
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
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
                        Text(
                          '${price.round()} ${context.tr('booking_egp_currency')}',
                          style: TextStyle(
                            color: ColorsManager.white.withOpacity(0.7),
                            fontSize: stv(
                              context: context,
                              mobile: 16.spScaled,
                              tablet: 20.spScaled,
                              desktop: 24.spScaled,
                            ),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: ColorsManager.black,
                          ),
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
}
