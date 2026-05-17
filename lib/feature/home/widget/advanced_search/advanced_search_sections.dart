import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/app_constants.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';
import 'package:rebtal/feature/home/widget/advanced_search/advanced_search_palette.dart';
import 'package:rebtal/feature/home/widget/advanced_search/advanced_search_slider_shapes.dart';
import 'package:rebtal/feature/home/ui/search_results_screen.dart';

class AdvancedSearchQueryField extends StatelessWidget {
  const AdvancedSearchQueryField({
    super.key,
    required this.controller,
    required this.isDark,
    required this.themeColor,
    required this.cardColor,
  });

  final TextEditingController controller;
  final bool isDark;
  final Color themeColor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          final cubit = context.read<HomeCubit>();
          cubit.updateAdvancedSearch(
            cubit.state.advancedSearch.copyWith(query: value),
          );
        },
        style: TextStyle(color: themeColor, fontSize: 15),
        decoration: InputDecoration(
          hintText: context.tr('home_search_hint'),
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: AdvancedSearchPalette.primaryGreen,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class AdvancedSearchBookingOptions extends StatelessWidget {
  const AdvancedSearchBookingOptions({
    super.key,
    required this.isDark,
    required this.themeColor,
    required this.cardColor,
  });

  final bool isDark;
  final Color themeColor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.advancedSearch.dayUseOnly != current.advancedSearch.dayUseOnly ||
          previous.advancedSearch.hasOffers != current.advancedSearch.hasOffers,
      builder: (context, state) {
        final form = state.advancedSearch;
        final cubit = context.read<HomeCubit>();

        return Row(
          children: [
            Expanded(
              child: AdvancedSearchOptionCard(
                title: context.tr('chalet_day_use'),
                icon: Icons.wb_sunny_rounded,
                isSelected: form.dayUseOnly,
                onTap: () => cubit.updateAdvancedSearch(
                  form.copyWith(dayUseOnly: !form.dayUseOnly),
                ),
                isDark: isDark,
                themeColor: themeColor,
                cardColor: cardColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdvancedSearchOptionCard(
                title: context.tr('nav_offers'),
                icon: Icons.local_offer_rounded,
                isSelected: form.hasOffers,
                onTap: () => cubit.updateAdvancedSearch(
                  form.copyWith(hasOffers: !form.hasOffers),
                ),
                isDark: isDark,
                themeColor: themeColor,
                cardColor: cardColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class AdvancedSearchOptionCard extends StatelessWidget {
  const AdvancedSearchOptionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.themeColor,
    required this.cardColor,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color themeColor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    const primaryColor = AdvancedSearchPalette.primaryGreen;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor.withOpacity(0.5)
                : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.grey[400] : Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? primaryColor : themeColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvancedSearchPriceRangeSection extends StatelessWidget {
  const AdvancedSearchPriceRangeSection({
    super.key,
    required this.cardColor,
    required this.themeColor,
    required this.isDark,
  });

  final Color cardColor;
  final Color themeColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const primaryColor = AdvancedSearchPalette.primaryGreen;

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.advancedSearch.priceRange != current.advancedSearch.priceRange,
      builder: (context, state) {
        final priceRange = state.advancedSearch.priceRange;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AdvancedSearchPriceBadge(
                    '${priceRange.start.round()} EGP',
                    expanded: true,
                  ),
                  Container(
                    width: 12,
                    height: 2,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  AdvancedSearchPriceBadge(
                    '${priceRange.end.round()} EGP',
                    expanded: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 12,
                  activeTrackColor: primaryColor,
                  inactiveTrackColor: isDark
                      ? Colors.white10
                      : Colors.black.withOpacity(0.05),
                  thumbColor: Colors.white,
                  overlayColor: primaryColor.withOpacity(0.1),
                  rangeTrackShape: DashedRangeSliderTrackShape(),
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    elevation: 3,
                    pressedElevation: 6,
                  ),
                ),
                child: RangeSlider(
                  values: priceRange,
                  min: 0,
                  max: 10000,
                  onChanged: (values) {
                    context.read<HomeCubit>().updateAdvancedSearch(
                          state.advancedSearch.copyWith(priceRange: values),
                        );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdvancedSearchPriceBadge extends StatelessWidget {
  const AdvancedSearchPriceBadge(this.text, {super.key, this.expanded = false});

  final String text;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    const primaryColor = AdvancedSearchPalette.primaryGreen;
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
    return expanded ? Expanded(child: Center(child: badge)) : badge;
  }
}

class AdvancedSearchAreaSection extends StatelessWidget {
  const AdvancedSearchAreaSection({
    super.key,
    required this.cardColor,
    required this.isDark,
  });

  final Color cardColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const primaryColor = AdvancedSearchPalette.primaryGreen;

    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.advancedSearch.minArea != current.advancedSearch.minArea,
      builder: (context, state) {
        final minArea = state.advancedSearch.minArea;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: AdvancedSearchPriceBadge(
                  '${minArea.round()} ${context.tr('common_m2')} +',
                ),
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 12,
                  activeTrackColor: primaryColor,
                  inactiveTrackColor: isDark
                      ? Colors.white10
                      : Colors.black.withOpacity(0.05),
                  thumbColor: Colors.white,
                  overlayColor: primaryColor.withOpacity(0.1),
                  trackShape: DashedSliderTrackShape(),
                  thumbShape: const RoundSliderThumbShape(
                    elevation: 3,
                    pressedElevation: 6,
                  ),
                ),
                child: Slider(
                  value: minArea,
                  min: 0,
                  max: 1000,
                  onChanged: (value) {
                    context.read<HomeCubit>().updateAdvancedSearch(
                          state.advancedSearch.copyWith(minArea: value),
                        );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdvancedSearchCapacitySection extends StatelessWidget {
  const AdvancedSearchCapacitySection({
    super.key,
    required this.cardColor,
    required this.themeColor,
    required this.isDark,
  });

  final Color cardColor;
  final Color themeColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.advancedSearch.minBedrooms !=
              current.advancedSearch.minBedrooms ||
          previous.advancedSearch.minBathrooms !=
              current.advancedSearch.minBathrooms ||
          previous.advancedSearch.minChildren !=
              current.advancedSearch.minChildren,
      builder: (context, state) {
        final form = state.advancedSearch;
        final cubit = context.read<HomeCubit>();

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
            ),
          ),
          child: Column(
            children: [
              AdvancedSearchCounterRow(
                label: context.tr('home_bedrooms'),
                icon: Icons.bed_rounded,
                value: form.minBedrooms,
                onChanged: (value) => cubit.updateAdvancedSearch(
                  value == null
                      ? form.copyWith(clearMinBedrooms: true)
                      : form.copyWith(minBedrooms: value),
                ),
                themeColor: themeColor,
              ),
              AdvancedSearchDivider(isDark: isDark),
              AdvancedSearchCounterRow(
                label: context.tr('home_bathrooms'),
                icon: Icons.bathtub_rounded,
                value: form.minBathrooms,
                onChanged: (value) => cubit.updateAdvancedSearch(
                  value == null
                      ? form.copyWith(clearMinBathrooms: true)
                      : form.copyWith(minBathrooms: value),
                ),
                themeColor: themeColor,
              ),
              AdvancedSearchDivider(isDark: isDark),
              AdvancedSearchCounterRow(
                label: context.tr('booking_children'),
                icon: Icons.child_care_rounded,
                value: form.minChildren,
                onChanged: (value) => cubit.updateAdvancedSearch(
                  value == null
                      ? form.copyWith(clearMinChildren: true)
                      : form.copyWith(minChildren: value),
                ),
                themeColor: themeColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdvancedSearchDivider extends StatelessWidget {
  const AdvancedSearchDivider({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
        height: 1,
      ),
    );
  }
}

class AdvancedSearchCounterRow extends StatelessWidget {
  const AdvancedSearchCounterRow({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.themeColor,
  });

  final String label;
  final IconData icon;
  final int? value;
  final ValueChanged<int?> onChanged;
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    const primaryColor = AdvancedSearchPalette.primaryGreen;
    final count = value ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: themeColor.withOpacity(0.5)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: themeColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              AdvancedSearchCircleButton(
                icon: Icons.remove,
                onTap: () {
                  if (count > 0) {
                    onChanged(count - 1 == 0 ? null : count - 1);
                  }
                },
                themeColor: themeColor,
              ),
              SizedBox(
                width: 36,
                child: Text(
                  count == 0 ? context.tr('common_any') : '$count+',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: themeColor,
                  ),
                ),
              ),
              AdvancedSearchCircleButton(
                icon: Icons.add,
                onTap: () => onChanged(count + 1),
                themeColor: themeColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdvancedSearchCircleButton extends StatelessWidget {
  const AdvancedSearchCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.themeColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: themeColor.withOpacity(0.1)),
        ),
        child: Icon(icon, size: 18, color: themeColor.withOpacity(0.8)),
      ),
    );
  }
}

class AdvancedSearchFacilitiesSection extends StatelessWidget {
  const AdvancedSearchFacilitiesSection({
    super.key,
    required this.isDark,
    required this.themeColor,
    required this.cardColor,
  });

  final bool isDark;
  final Color themeColor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.advancedSearch.selectedFacilities !=
          current.advancedSearch.selectedFacilities,
      builder: (context, state) {
        final selected = state.advancedSearch.selectedFacilities;
        final cubit = context.read<HomeCubit>();

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.serviceFacilities.map((facility) {
            final value = facility['value'] as String;
            final isSelected = selected.contains(value);

            return AdvancedSearchFacilityChip(
              label: context.tr(facility['labelKey'] as String),
              icon: facility['icon'] as IconData?,
              isSelected: isSelected,
              onTap: () {
                final updated = List<String>.from(selected);
                if (isSelected) {
                  updated.remove(value);
                } else {
                  updated.add(value);
                }
                cubit.updateAdvancedSearch(
                  state.advancedSearch.copyWith(selectedFacilities: updated),
                );
              },
              isDark: isDark,
              themeColor: themeColor,
              cardColor: cardColor,
            );
          }).toList(),
        );
      },
    );
  }
}

class AdvancedSearchFacilityChip extends StatelessWidget {
  const AdvancedSearchFacilityChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.themeColor,
    required this.cardColor,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color themeColor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    const primary = AdvancedSearchPalette.primaryGreen;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.1) : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primary.withOpacity(0.5)
                : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? primary : themeColor.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primary : themeColor.withOpacity(0.8),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvancedSearchBottomBar extends StatelessWidget {
  const AdvancedSearchBottomBar({super.key, required this.bgColor});

  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 24, right: 24),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.03))),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            context.read<HomeCubit>().applyAdvancedSearch();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchResultsScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AdvancedSearchPalette.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_rounded, size: 22),
              const SizedBox(width: 8),
              Text(
                context.tr('home_show_results'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
