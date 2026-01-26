import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/chalet/logic/cubit/services_cubit.dart';

class PropertyFeaturesCard extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final bool isDark;

  const PropertyFeaturesCard({
    super.key,
    required this.requestData,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bedrooms = requestData['bedrooms']?.toString() ?? 'N/A';
    final bathrooms = requestData['bathrooms']?.toString() ?? 'N/A';
    final chaletArea = requestData['chaletArea']?.toString();
    final childrenCount = requestData['childrenCount']?.toString();
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocProvider(
      create: (context) => ServicesCubit()..loadAmenities(requestData),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Specs Section
            Text(
              'Property Specs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? ColorManager.chaletTextPrimaryDark
                    : ColorManager.chaletTextPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),

            // Minimal Grid for Specs
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 3.5,
              children: [
                _buildSimpleFeature(
                  context,
                  Icons.bed_rounded,
                  bedrooms,
                  'Bedrooms',
                  isDark,
                  ColorManager.chaletActionBlue,
                ),
                _buildSimpleFeature(
                  context,
                  Icons.bathtub_outlined,
                  bathrooms,
                  'Bathrooms',
                  isDark,
                  ColorManager.purple8B5CF6,
                ),
                if (chaletArea != null && chaletArea.isNotEmpty)
                  _buildSimpleFeature(
                    context,
                    Icons.square_foot_rounded,
                    '$chaletArea m²',
                    'Area',
                    isDark,
                    ColorManager.orangeF59E0B, // Use Orange
                  ),
                if (childrenCount != null)
                  _buildSimpleFeature(
                    context,
                    Icons.child_care_rounded,
                    childrenCount,
                    'Children',
                    isDark,
                    ColorManager.chaletGalleryPink, // Use Pink
                  ),
              ],
            ),

            const SizedBox(height: 32),
            Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
            const SizedBox(height: 32),

            // المرافق والخدمات فقط (بدون المميزات الإضافية القديمة Sea View / Garden / Pool / WiFi / BBQ / Parking)
            BlocBuilder<ServicesCubit, ServicesState>(
              builder: (context, state) {
                final hasAmenities =
                    state is ServicesLoaded && state.amenities.isNotEmpty;
                if (!hasAmenities) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المرافق والخدمات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? ColorManager.chaletTextPrimaryDark
                            : ColorManager.chaletTextPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: state.amenities.length,
                      itemBuilder: (context, index) {
                        final item = state.amenities[index];
                        final List<Color> palette = [
                          ColorManager.chaletActionBlue,
                          ColorManager.purple8B5CF6,
                          ColorManager.orangeF59E0B,
                          ColorManager.chaletGalleryPink,
                          ColorManager.chaletAvailableGreen,
                          Colors.teal,
                          Colors.indigo,
                          Colors.redAccent,
                        ];
                        final color = palette[index % palette.length];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['label'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey[800],
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleFeature(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    bool isDark,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 28,
          color: color, // Always use vibrant color
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? ColorManager.chaletTextPrimaryDark
                    : Colors.black87, // Darker text
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
