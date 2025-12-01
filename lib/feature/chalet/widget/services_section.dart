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
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
