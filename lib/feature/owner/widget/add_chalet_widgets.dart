import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/constant/popular_destinations.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

// ==========================================
// Owner Info Section
// ==========================================
class OwnerInfoSection extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const OwnerInfoSection({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return _ModernCard(
      isDark: isDark,
      icon: Icons.person_outline_rounded,
      title: context.tr('owner_info'),
      color: ColorsManager.blue2563EB,
      child: Column(
        children: [
          _InfoRow(
            isDark: isDark,
            label: context.tr('owner_name'),
            value: name,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            isDark: isDark,
            label: context.tr('common_email'),
            value: email,
            icon: Icons.email_rounded,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            isDark: isDark,
            label: context.tr('common_phone'),
            value: phone,
            icon: Icons.phone_rounded,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// Chalet Details Section
// ==========================================
class ChaletDetailsSection extends StatelessWidget {
  final String? initialName;
  final String? initialDescription;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescriptionChanged;

  const ChaletDetailsSection({
    super.key,
    this.initialName,
    this.initialDescription,
    required this.onNameChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return _ModernCard(
      isDark: isDark,
      icon: Icons.villa_rounded,
      title: context.tr('owner_chalet_details'),
      color: ColorsManager.purple764BA2,
      child: Column(
        children: [
          _ModernTextField(
            key: const ValueKey('chalet_name'),
            isDark: isDark,
            initialValue: initialName,
            label: context.tr('owner_chalet_name'),
            icon: Icons.villa_rounded,
            hint: context.tr('owner_enter_chalet_name'),
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 16),
          _ModernTextField(
            key: const ValueKey('chalet_desc'),
            isDark: isDark,
            initialValue: initialDescription,
            label: context.tr('owner_description'),
            icon: Icons.description_rounded,
            hint: context.tr('booking_write_notes'),
            maxLines: 4,
            onChanged: onDescriptionChanged,
          ),
        ],
      ),
    );
  }
}

/// In-place animated dropdown for popular destinations (replaces full-screen sheet).
class PopularDestinationAnimatedDropdown extends StatefulWidget {
  final bool isDark;
  final String? selectedKey;
  final ValueChanged<String?> onChanged;

  const PopularDestinationAnimatedDropdown({
    super.key,
    required this.isDark,
    required this.selectedKey,
    required this.onChanged,
  });

  @override
  State<PopularDestinationAnimatedDropdown> createState() =>
      _PopularDestinationAnimatedDropdownState();
}

class _PopularDestinationAnimatedDropdownState
    extends State<PopularDestinationAnimatedDropdown> {
  bool _expanded = false;

  String _headerLabel(BuildContext context) {
    if (widget.selectedKey == null) {
      return context.tr('owner_is_from_popular_destination');
    }
    return PopularDestinations.getByKey(widget.selectedKey!)
            ?.getLocalizedName(context) ??
        context.tr('owner_is_from_popular_destination');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _expanded = !_expanded);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark
                    ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
                    : ColorsManager.grey50,
                border: Border.all(
                  color: _expanded
                      ? ColorsManager.orangeF59E0B.withOpacity(0.65)
                      : (isDark
                          ? ColorsManager.grey800.withOpacity(0.3)
                          : ColorsManager.grey300),
                  width: _expanded ? 1.5 : 1,
                ),
                boxShadow: _expanded
                    ? [
                        BoxShadow(
                          color: ColorsManager.orangeF59E0B.withOpacity(0.14),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.map_rounded,
                    color: ColorsManager.orangeF59E0B,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _headerLabel(context),
                      style: TextStyle(
                        color: isDark
                            ? ColorsManager.white
                            : ColorsManager.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: ColorsManager.orangeF59E0B,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      height: 260,
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorsManager.darkBlue1A1A2E
                            : ColorsManager.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? ColorsManager.grey800.withOpacity(0.35)
                              : ColorsManager.grey300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.selectedKey != null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  widget.onChanged(null);
                                  setState(() => _expanded = false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    context.tr(
                                      'owner_clear_popular_destination',
                                    ),
                                    style: const TextStyle(
                                      color: ColorsManager.orangeF59E0B,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (widget.selectedKey != null)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: PopularDestinations.all.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: Colors.grey.withOpacity(0.1),
                              ),
                              itemBuilder: (context, i) {
                                final d = PopularDestinations.all[i];
                                final selected = widget.selectedKey == d.key;
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(
                                    milliseconds: 180 + (i * 28).clamp(0, 220),
                                  ),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, t, child) {
                                    return Opacity(
                                      opacity: t,
                                      child: Transform.translate(
                                        offset: Offset(0, 6 * (1 - t)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        widget.onChanged(d.key);
                                        setState(() => _expanded = false);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                d.imageUrl,
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  width: 48,
                                                  height: 48,
                                                  color: Colors.grey.shade700,
                                                  child: const Icon(
                                                    Icons.place_outlined,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                d.getLocalizedName(context),
                                                style: TextStyle(
                                                  fontWeight: selected
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: isDark
                                                      ? ColorsManager.white
                                                      : ColorsManager.black87,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            if (selected)
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                color: ColorsManager
                                                    .orangeF59E0B,
                                                size: 22,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// Location Section
// ==========================================
class LocationSection extends StatelessWidget {
  final String address;
  final VoidCallback onPickLocation;
  final String? selectedPopularDestination;
  final ValueChanged<String?>? onPopularDestinationChanged;

  const LocationSection({
    super.key,
    required this.address,
    required this.onPickLocation,
    this.selectedPopularDestination,
    this.onPopularDestinationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final hasLocation = address.isNotEmpty;

    return _ModernCard(
      isDark: isDark,
      icon: Icons.location_on_rounded,
      title: context.tr('owner_location'),
      color: ColorsManager.orangeF59E0B,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onPopularDestinationChanged != null) ...[
            PopularDestinationAnimatedDropdown(
              isDark: isDark,
              selectedKey: selectedPopularDestination,
              onChanged: onPopularDestinationChanged!,
            ),
            SizedBox(height: 12.sh),
          ],
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ColorsManager.orangeF59E0B, Color(0xFFF97316)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.orangeF59E0B.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPickLocation,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      color: ColorsManager.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('owner_select_on_map'),
                      style: const TextStyle(
                        color: ColorsManager.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasLocation) ...[
            const SizedBox(height: 12),
            _InfoRow(
              isDark: isDark,
              label: context.tr('owner_selected_address'),
              value: address,
              icon: Icons.place_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================
// Property Details Section
// ==========================================
class PropertyDetailsSection extends StatelessWidget {
  final String? initialPrice;
  final String? initialArea;
  final String? initialBedrooms;
  final String? initialBathrooms;
  final Function(String) onPriceChanged;
  final Function(String) onAreaChanged;
  final Function(String) onBedroomsChanged;
  final Function(String) onBathroomsChanged;

  const PropertyDetailsSection({
    super.key,
    this.initialPrice,
    this.initialArea,
    this.initialBedrooms,
    this.initialBathrooms,
    required this.onPriceChanged,
    required this.onAreaChanged,
    required this.onBedroomsChanged,
    required this.onBathroomsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return _ModernCard(
      isDark: isDark,
      icon: Icons.attach_money_rounded,
      title: context.tr('owner_property_details'),
      color: ColorsManager.mainBlue,
      child: Column(
        children: [
          _ModernTextField(
            key: const ValueKey('chalet_price'),
            isDark: isDark,
            initialValue: initialPrice,
            label: context.tr('owner_price_per_night'),
            icon: Icons.payments_rounded,
            hint: '0',
            keyboardType: TextInputType.number,
            onChanged: onPriceChanged,
          ),
          const SizedBox(height: 16),
          _ModernTextField(
            key: const ValueKey('chalet_area'),
            isDark: isDark,
            initialValue: initialArea,
            label: context.tr('owner_area_m2'),
            icon: Icons.square_foot_rounded,
            hint: '0',
            keyboardType: TextInputType.number,
            onChanged: onAreaChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ModernTextField(
                  key: const ValueKey('chalet_bedrooms'),
                  isDark: isDark,
                  initialValue: initialBedrooms,
                  label: context.tr('home_bedrooms'),
                  icon: Icons.bed_rounded,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  onChanged: onBedroomsChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernTextField(
                  key: const ValueKey('chalet_bathrooms'),
                  isDark: isDark,
                  initialValue: initialBathrooms,
                  label: context.tr('home_bathrooms'),
                  icon: Icons.bathtub_rounded,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  onChanged: onBathroomsChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// Availability Section
// ==========================================
class AvailabilitySection extends StatelessWidget {
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final VoidCallback onSelectFrom;
  final VoidCallback onSelectTo;

  const AvailabilitySection({
    super.key,
    required this.availableFrom,
    required this.availableTo,
    required this.onSelectFrom,
    required this.onSelectTo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return _ModernCard(
      isDark: isDark,
      icon: Icons.calendar_today_rounded,
      title: context.tr('owner_availability_period'),
      color: ColorsManager.cyan06B6D4,
      child: Row(
        children: [
          Expanded(
            child: _DateButton(
              isDark: isDark,
              label: context.tr('booking_from_date'),
              value: availableFrom != null
                  ? dateFormat.format(availableFrom!)
                  : null,
              onTap: onSelectFrom,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DateButton(
              isDark: isDark,
              label: context.tr('booking_to_date'),
              value: availableTo != null
                  ? dateFormat.format(availableTo!)
                  : null,
              onTap: onSelectTo,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// Features Section
// ==========================================
class FeaturesSection extends StatelessWidget {
  final List<String> selectedFeatures;
  final Function(String) onToggleFeature;

  const FeaturesSection({
    super.key,
    required this.selectedFeatures,
    required this.onToggleFeature,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    // Map features to icons, labels, AND colors
    final List<Map<String, dynamic>> featuresData = [
      {
        'key': 'Pool',
        'label': context.tr('chalet_pool'),
        'icon': Icons.pool_rounded,
        'color': ColorsManager.cyan06B6D4,
      },
      {
        'key': 'Sea View',
        'label': context.tr('chalet_beach_view'),
        'icon': Icons.waves_rounded,
        'color': ColorsManager.blue2563EB,
      },
      {
        'key': 'Garden',
        'label': context.tr('chalet_garden'),
        'icon': Icons.local_florist_rounded,
        'color': ColorsManager.mainBlue,
      },
      {
        'key': 'WiFi',
        'label': context.tr('chalet_wifi'),
        'icon': Icons.wifi_rounded,
        'color': ColorsManager.purple764BA2,
      },
      {
        'key': 'BBQ',
        'label': context.tr('chalet_bbq'),
        'icon': Icons.outdoor_grill_rounded,
        'color': ColorsManager.bookingsWarningOrange,
      },
      {
        'key': 'Parking',
        'label': context.tr('chalet_parking'),
        'icon': Icons.local_parking_rounded,
        'color': ColorsManager.grey600,
      },
    ];

    return _ModernCard(
      isDark: isDark,
      icon: Icons.star_rounded,
      title: context.tr('owner_extra_features'),
      color: ColorsManager.yellowEAB308,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: featuresData.length,
        itemBuilder: (context, index) {
          final item = featuresData[index];
          final key = item['key'] as String;
          final isSelected = selectedFeatures.contains(key);

          return _BouncyFeatureCard(
            isDark: isDark,
            label: item['label'] as String,
            icon: item['icon'] as IconData,
            color: item['color'] as Color?,
            isSelected: isSelected,
            onTap: () => onToggleFeature(key),
          );
        },
      ),
    );
  }
}

// ==========================================
// Discount Section
// ==========================================
class DiscountSection extends StatelessWidget {
  final bool? discountEnabled;
  final String? discountType;
  final String? discountValue;
  final double originalPrice;
  final ValueChanged<bool> onDiscountEnabledChanged;
  final ValueChanged<String?> onDiscountTypeChanged;
  final ValueChanged<String?> onDiscountValueChanged;

  const DiscountSection({
    super.key,
    this.discountEnabled,
    this.discountType,
    this.discountValue,
    required this.originalPrice,
    required this.onDiscountEnabledChanged,
    required this.onDiscountTypeChanged,
    required this.onDiscountValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final isEnabled = discountEnabled ?? false;

    // Calculate discounted price for display
    double? discountedPrice;
    if (isEnabled && discountValue != null && discountValue!.isNotEmpty) {
      final value = double.tryParse(discountValue!) ?? 0;
      if (discountType == 'percentage') {
        discountedPrice = originalPrice - (originalPrice * (value / 100));
      } else {
        discountedPrice = originalPrice - value;
      }
      if (discountedPrice < 0) discountedPrice = 0;
    }

    return _ModernCard(
      isDark: isDark,
      icon: Icons.local_offer_rounded,
      title: context.tr('owner_discounts_offers'),
      color: ColorsManager.redFF3B30,
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              context.tr('owner_enable_discount'),
              style: TextStyle(
                color: isDark ? ColorsManager.white : ColorsManager.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              context.tr('owner_enable_discount_hint'),
              style: TextStyle(
                color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
                fontSize: 12,
              ),
            ),
            value: isEnabled,
            activeColor: ColorsManager.redFF3B30,
            onChanged: onDiscountEnabledChanged,
            contentPadding: EdgeInsets.zero,
          ),
          if (isEnabled) ...[
            const SizedBox(height: 20),
            // Row 1: Discount Type Title
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                context.tr('owner_discount_type'),
                style: TextStyle(
                  color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Row 2: Discount Type Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onDiscountTypeChanged('percentage'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 60,
                      decoration: BoxDecoration(
                        color: discountType == 'percentage'
                            ? ColorsManager.redFF3B30
                            : (isDark
                                  ? ColorsManager.darkBlue2A2E4B.withOpacity(
                                      0.5,
                                    )
                                  : ColorsManager.grey50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: discountType == 'percentage'
                              ? ColorsManager.redFF3B30
                              : (isDark
                                    ? ColorsManager.grey800.withOpacity(0.3)
                                    : ColorsManager.grey300),
                          width: discountType == 'percentage' ? 2 : 1,
                        ),
                        boxShadow: discountType == 'percentage'
                            ? [
                                BoxShadow(
                                  color: ColorsManager.redFF3B30.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.percent_rounded,
                              color: discountType == 'percentage'
                                  ? ColorsManager.white
                                  : (isDark
                                        ? ColorsManager.grey400
                                        : ColorsManager.grey600),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('owner_discount_percentage'),
                              style: TextStyle(
                                color: discountType == 'percentage'
                                    ? ColorsManager.white
                                    : (isDark
                                          ? ColorsManager.white
                                          : ColorsManager.black),
                                fontSize: 16,
                                fontWeight: discountType == 'percentage'
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onDiscountTypeChanged('fixed'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 60,
                      decoration: BoxDecoration(
                        color: discountType == 'fixed'
                            ? ColorsManager.redFF3B30
                            : (isDark
                                  ? ColorsManager.darkBlue2A2E4B.withOpacity(
                                      0.5,
                                    )
                                  : ColorsManager.grey50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: discountType == 'fixed'
                              ? ColorsManager.redFF3B30
                              : (isDark
                                    ? ColorsManager.grey800.withOpacity(0.3)
                                    : ColorsManager.grey300),
                          width: discountType == 'fixed' ? 2 : 1,
                        ),
                        boxShadow: discountType == 'fixed'
                            ? [
                                BoxShadow(
                                  color: ColorsManager.redFF3B30.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              color: discountType == 'fixed'
                                  ? ColorsManager.white
                                  : (isDark
                                        ? ColorsManager.grey400
                                        : ColorsManager.grey600),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('owner_discount_fixed'),
                              style: TextStyle(
                                color: discountType == 'fixed'
                                    ? ColorsManager.white
                                    : (isDark
                                          ? ColorsManager.white
                                          : ColorsManager.black),
                                fontSize: 16,
                                fontWeight: discountType == 'fixed'
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Row 3: Discount Value Input
            _ModernTextField(
              isDark: isDark,
              initialValue: discountValue,
              label: discountType == 'percentage'
                  ? context.tr('owner_enter_discount_percentage')
                  : context.tr('owner_enter_discount_fixed'),
              icon: discountType == 'percentage'
                  ? Icons.percent_rounded
                  : Icons.attach_money_rounded,
              hint: '0',
              keyboardType: TextInputType.number,
              onChanged: (val) => onDiscountValueChanged(val),
            ),
          ],

          // Show calculated price
          if (discountedPrice != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    (isDark ? ColorsManager.green3DDC84 : ColorsManager.green)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      (isDark ? ColorsManager.green3DDC84 : ColorsManager.green)
                          .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: isDark
                        ? ColorsManager.green3DDC84
                        : ColorsManager.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('owner_price_after_discount'),
                    style: TextStyle(
                      color: isDark
                          ? ColorsManager.grey400
                          : ColorsManager.grey600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${discountedPrice.toStringAsFixed(2)} ${context.tr('common_egp')}',
                    style: TextStyle(
                      color: isDark ? ColorsManager.white : ColorsManager.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================
// Day Use Section
// ==========================================
class DayUseSection extends StatelessWidget {
  final bool? dayUseEnabled;
  final ValueChanged<bool> onDayUseChanged;

  const DayUseSection({
    super.key,
    this.dayUseEnabled,
    required this.onDayUseChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final isEnabled = dayUseEnabled ?? false;

    return _ModernCard(
      isDark: isDark,
      icon: Icons.access_time_rounded,
      title: context.tr('owner_day_use_feature'),
      color: ColorsManager.green3DDC84,
      child: SwitchListTile(
        title: Text(
          context.tr('owner_enable_day_use'),
          style: TextStyle(
            color: isDark ? ColorsManager.white : ColorsManager.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          context.tr('owner_day_use_hint'),
          style: TextStyle(
            color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
            fontSize: 12,
          ),
        ),
        value: isEnabled,
        activeColor: ColorsManager.green3DDC84,
        onChanged: (val) => onDayUseChanged(val),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ==========================================
// Private Widgets
// ==========================================

class _ModernCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _ModernCard({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ColorsManager.grey800.withOpacity(0.3)
              : ColorsManager.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? ColorsManager.black.withOpacity(0.3)
                : ColorsManager.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? ColorsManager.white : ColorsManager.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.isDark,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
            : ColorsManager.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? ColorsManager.grey800.withOpacity(0.3)
              : ColorsManager.grey300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? ColorsManager.grey400
                        : ColorsManager.grey600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : context.tr('common_undetermined'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? ColorsManager.white : ColorsManager.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernTextField extends StatelessWidget {
  final bool isDark;
  final String? initialValue;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final void Function(String)? onChanged;

  const _ModernTextField({
    super.key,
    required this.isDark,
    this.initialValue,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? ColorsManager.white : ColorsManager.black,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: isDark ? ColorsManager.grey600 : ColorsManager.grey400,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
          size: 20,
        ),
        filled: true,
        fillColor: isDark
            ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
            : ColorsManager.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? ColorsManager.grey800.withOpacity(0.3)
                : ColorsManager.grey300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorsManager.blue2563EB,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final bool isDark;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DateButton({
    required this.isDark,
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
              : ColorsManager.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? ColorsManager.grey800.withOpacity(0.3)
                : ColorsManager.grey300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? context.tr('owner_select_date'),
                    style: TextStyle(
                      color: value != null
                          ? (isDark ? ColorsManager.white : ColorsManager.black)
                          : (isDark
                                ? ColorsManager.grey600
                                : ColorsManager.grey400),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: ColorsManager.cyan06B6D4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BouncyFeatureCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final IconData icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _BouncyFeatureCard({
    required this.isDark,
    required this.label,
    required this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use passed color or default to yellow
    final activeColor = color ?? ColorsManager.yellowEAB308;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    activeColor.withOpacity(0.2),
                    activeColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark
                    ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
                    : ColorsManager.grey50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark
                      ? ColorsManager.grey800.withOpacity(0.3)
                      : ColorsManager.grey300),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor // Solid color when selected
                    : (isDark
                          ? ColorsManager.grey800.withOpacity(0.3)
                          : ColorsManager.grey200),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? ColorsManager.white
                    : (isDark
                          ? ColorsManager.grey400
                          : activeColor.withOpacity(0.7)),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? activeColor
                    : (isDark ? ColorsManager.grey300 : ColorsManager.grey700),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
