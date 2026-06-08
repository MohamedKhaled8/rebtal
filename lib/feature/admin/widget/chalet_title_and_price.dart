import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class ChaletTitleAndPrice extends StatelessWidget {
  final String chaletName;
  final String price;
  final Map<String, dynamic> requestData;

  const ChaletTitleAndPrice({
    super.key,
    required this.chaletName,
    required this.price,
    required this.requestData,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = requestData['discountEnabled'] == true && requestData['discountValue'] != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            chaletName,
            style: TextStyle(color: ColorsManager.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasDiscount)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$$price', style: TextStyle(color: ColorsManager.gray, fontSize: 13.sp, decoration: TextDecoration.lineThrough, decorationColor: ColorsManager.red)),
              Text(
                (() {
                  final p = double.tryParse(price.toString()) ?? 0;
                  final val = double.tryParse(requestData['discountValue'].toString()) ?? 0;
                  final finalPrice = requestData['discountType'] == 'percentage' ? p - (p * (val / 100)) : p - val;
                  return '\$${finalPrice.toStringAsFixed(0)} / ${context.tr('chalet_night') ?? 'الليلة'}';
                })(),
                style: TextStyle(color: ColorsManager.kPrimaryGradient.colors.first, fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
            ],
          )
        else
          Text(
            '\$$price / ${context.tr('chalet_night') ?? 'الليلة'}',
            style: TextStyle(color: ColorsManager.kPrimaryGradient.colors.first, fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
