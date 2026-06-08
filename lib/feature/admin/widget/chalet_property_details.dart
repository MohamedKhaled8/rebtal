import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class ChaletPropertyDetails extends StatelessWidget {
  final String bedrooms;
  final String bathrooms;
  final String childrenCount;
  final String chaletArea;

  const ChaletPropertyDetails({
    super.key,
    required this.bedrooms,
    required this.bathrooms,
    required this.childrenCount,
    required this.chaletArea,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.bed, size: 18.sp, color: Colors.grey),
              horizintalSpace(1),
              Text('$bedrooms ${context.tr('common_beds_short') ?? ''}'),
            ],
          ),
          horizintalSpace(3),
          Row(
            children: [
              Icon(Icons.bathtub_outlined, size: 18.sp, color: Colors.grey),
              horizintalSpace(1),
              Text('$bathrooms ${context.tr('common_baths_short') ?? ''}'),
            ],
          ),
          if (childrenCount.isNotEmpty) ...[
            horizintalSpace(3),
            Row(
              children: [
                Icon(Icons.child_care_rounded, size: 18.sp, color: Colors.grey),
                horizintalSpace(1),
                Text('$childrenCount ${context.tr('booking_children') ?? ''}'),
              ],
            ),
          ],
          if (chaletArea.isNotEmpty) ...[
            horizintalSpace(3),
            Row(
              children: [
                Icon(Icons.square_foot_rounded, size: 18.sp, color: Colors.grey),
                horizintalSpace(1),
                Text('$chaletArea ${context.tr('common_m2') ?? ''}'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
