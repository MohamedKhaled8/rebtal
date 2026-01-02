import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/services_cubit.dart';
import 'package:rebtal/feature/chalet/widget/amenity_card.dart';

class ServicesSection extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final bool isDark;

  const ServicesSection({
    super.key,
    required this.requestData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServicesCubit()..loadAmenities(requestData),
      child: BlocBuilder<ServicesCubit, ServicesState>(
        builder: (context, state) {
          if (state is ServicesLoaded) {
            if (state.amenities.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Services & Facilities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? ColorManager.chaletTextPrimaryDark
                        : ColorManager.chaletTextPrimaryLight,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: state.amenities.length,
                  itemBuilder: (context, index) {
                    final item = state.amenities[index];
                    return AmenityCard(
                      label: item['label'] as String,
                      icon: item['icon'] as IconData,
                      isDark: isDark,
                    );
                  },
                ),

                // Additional Features (Dynamic Tags)
                if (requestData['features'] != null &&
                    (requestData['features'] as List).isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Divider(
                    height: 1,
                    color: isDark ? ColorManager.white10 : ColorManager.grey200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Additional Features',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? ColorManager.chaletTextPrimaryDark
                          : ColorManager.chaletTextPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (requestData['features'] as List).map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? ColorManager.chaletIconBackgroundDark
                              : ColorManager.greyF3F4F6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              size: 16,
                              color: isDark
                                  ? ColorManager.white.withOpacity(0.8)
                                  : ColorManager.chaletActionGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              feature.toString(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? ColorManager.chaletTextSecondaryDark
                                    : ColorManager.grey374151,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
