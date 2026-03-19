import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/app_constants.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/ui/search_results_screen.dart';

class AdvancedSearchSheet extends StatefulWidget {
  const AdvancedSearchSheet({super.key});

  @override
  State<AdvancedSearchSheet> createState() => _AdvancedSearchSheetState();
}

class _AdvancedSearchSheetState extends State<AdvancedSearchSheet> {
  late TextEditingController _queryController;
  late TextEditingController _locationController;
  late TextEditingController _exactPriceController;
  RangeValues _priceRange = const RangeValues(0, 10000);
  int? _minBedrooms;
  int? _minBathrooms;
  int? _minChildren;
  bool _dayUseOnly = false;
  bool _hasOffers = false;
  List<String> _selectedFeatures = [];
  List<String> _selectedFacilities = [];
  double _minArea = 0;

  @override
  void initState() {
    super.initState();
    final currentFilters = HomeSearch.filters.value;
    _queryController = TextEditingController(text: currentFilters.query);
    _locationController = TextEditingController(text: currentFilters.location);
    _exactPriceController = TextEditingController(
      text: currentFilters.exactPrice != null
          ? currentFilters.exactPrice!.toStringAsFixed(0)
          : '',
    );
    if (currentFilters.priceRange != null) {
      _priceRange = currentFilters.priceRange!;
    }
    _minBedrooms = currentFilters.minBedrooms;
    _minBathrooms = currentFilters.minBathrooms;
    _minChildren = currentFilters.minChildren;
    _dayUseOnly = currentFilters.dayUseOnly;
    _hasOffers = currentFilters.hasOffers;
    _selectedFeatures = List.from(currentFilters.features);
    _selectedFacilities = List.from(currentFilters.facilities);
    _minArea = currentFilters.minArea ?? 0;
  }

  @override
  void dispose() {
    _queryController.dispose();
    _locationController.dispose();
    _exactPriceController.dispose();
    super.dispose();
  }

  void _applySearch() {
    final exactPriceText = _exactPriceController.text.trim();
    final exactPrice = exactPriceText.isEmpty ? null : double.tryParse(exactPriceText);

    final RangeValues? activePriceRange =
        (_priceRange.start > 0 || _priceRange.end < 10000) ? _priceRange : null;

    HomeSearch.filters.value = SearchFilters(
      query: _queryController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      priceRange: activePriceRange,
      exactPrice: exactPrice,
      minBedrooms: _minBedrooms,
      minBathrooms: _minBathrooms,
      minChildren: _minChildren,
      dayUseOnly: _dayUseOnly,
      hasOffers: _hasOffers,
      features: _selectedFeatures,
      facilities: _selectedFacilities,
      minArea: _minArea > 0 ? _minArea : null,
    );
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchResultsScreen()),
    );
  }

  void _resetFilters() {
    HomeSearch.clear();
    setState(() {
      _queryController.clear();
      _locationController.clear();
      _exactPriceController.clear();
      _priceRange = const RangeValues(0, 10000);
      _minBedrooms = null;
      _minBathrooms = null;
      _minChildren = null;
      _dayUseOnly = false;
      _hasOffers = false;
      _selectedFeatures = [];
      _selectedFacilities = [];
      _minArea = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final themeColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF151520) : const Color(0xFFFFFFFF); // Lighter background
    final cardColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF9FAFB); // Very light grey for light mode
    const primaryGreen = Color(0xFF10B981);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), // Reduced radius
      ),
      child: Column(
        children: [
          _buildHeader(themeColor, isDark),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Softer padding
              children: [
                _buildSectionHeader(context.tr('home_search'), Icons.search_rounded, themeColor),
                const SizedBox(height: 12),
                _buildSearchInput(isDark, themeColor, cardColor),

                const SizedBox(height: 28), // Reduced spacing
                _buildSectionHeader(context.tr('owner_availability_period'), Icons.explore_rounded, themeColor),
                const SizedBox(height: 12),
                _buildBookingOptions(isDark, primaryGreen, themeColor, cardColor),

                const SizedBox(height: 28),
                _buildSectionHeader(context.tr('home_price_range_per_night'), Icons.payments_rounded, themeColor),
                const SizedBox(height: 12),
                _buildPriceRange(cardColor, primaryGreen, themeColor, isDark),

                const SizedBox(height: 28),
                _buildSectionHeader(context.tr('home_chalet_area_m2'), Icons.square_foot_rounded, themeColor),
                const SizedBox(height: 12),
                _buildAreaSlider(cardColor, primaryGreen, themeColor, isDark),

                const SizedBox(height: 28),
                _buildSectionHeader(context.tr('home_rooms_facilities'), Icons.meeting_room_rounded, themeColor),
                const SizedBox(height: 12),
                _buildCapacityCard(cardColor, themeColor, primaryGreen, isDark),

                const SizedBox(height: 28),
                _buildSectionHeader(context.tr('home_features'), Icons.loyalty_rounded, themeColor),
                const SizedBox(height: 12),
                _buildFeaturesWrap(isDark, primaryGreen, themeColor, cardColor),

                const SizedBox(height: 28),
                _buildSectionHeader(context.tr('home_facilities_services'), Icons.spa_rounded, themeColor),
                const SizedBox(height: 12),
                _buildFacilitiesWrap(isDark, primaryGreen, themeColor, cardColor),

                const SizedBox(height: 32),
              ],
            ),
          ),
          _buildBottomBar(bgColor, primaryGreen),
        ],
      ),
    );
  }

  Widget _buildHeader(Color themeColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('home_advanced_search'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: themeColor,
                  letterSpacing: -0.3,
                ),
              ),
              InkWell(
                onTap: _resetFilters,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    context.tr('home_reset'),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color themeColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF10B981)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: themeColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInput(bool isDark, Color themeColor, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16), // Lighter radius
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: TextField(
        controller: _queryController,
        style: TextStyle(color: themeColor, fontSize: 15),
        decoration: InputDecoration(
          hintText: context.tr('home_search_hint'),
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(Icons.search_rounded, color: Color(0xFF10B981), size: 20),
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

  Widget _buildBookingOptions(bool isDark, Color primaryColor, Color themeColor, Color cardColor) {
    return Row(
      children: [
        Expanded(
          child: _buildOptionCard(
            title: context.tr('chalet_day_use'),
            icon: Icons.wb_sunny_rounded,
            isSelected: _dayUseOnly,
            onTap: () => setState(() => _dayUseOnly = !_dayUseOnly),
            isDark: isDark,
            primaryColor: primaryColor,
            themeColor: themeColor,
            cardColor: cardColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOptionCard(
            title: context.tr('nav_offers'),
            icon: Icons.local_offer_rounded,
            isSelected: _hasOffers,
            onTap: () => setState(() => _hasOffers = !_hasOffers),
            isDark: isDark,
            primaryColor: primaryColor,
            themeColor: themeColor,
            cardColor: cardColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
    required Color themeColor,
    required Color cardColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : cardColor,
          borderRadius: BorderRadius.circular(16), // Lighter radius
          border: Border.all(
            color: isSelected ? primaryColor.withOpacity(0.5) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? primaryColor : (isDark ? Colors.grey[400] : Colors.grey[500]),
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

  Widget _buildPriceRange(Color cardColor, Color primaryColor, Color themeColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceBadge('${_priceRange.start.round()} EGP', primaryColor, true),
              Container(width: 12, height: 2, color: isDark ? Colors.white24 : Colors.black12),
              _buildPriceBadge('${_priceRange.end.round()} EGP', primaryColor, true),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 12, // Thicker track for dashed lines
              activeTrackColor: primaryColor,
              inactiveTrackColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              thumbColor: Colors.white,
              overlayColor: primaryColor.withOpacity(0.1),
              rangeTrackShape: DashedRangeSliderTrackShape(),
              rangeThumbShape: const RoundRangeSliderThumbShape(elevation: 3, pressedElevation: 6),
            ),
            child: RangeSlider(
              values: _priceRange,
              min: 0,
              max: 10000,
              onChanged: (values) => setState(() => _priceRange = values),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaSlider(Color cardColor, Color primaryColor, Color themeColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Center(
            child: _buildPriceBadge('${_minArea.round()} ${context.tr('common_m2')} +', primaryColor, false),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 12,
              activeTrackColor: primaryColor,
              inactiveTrackColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              thumbColor: Colors.white,
              overlayColor: primaryColor.withOpacity(0.1),
              trackShape: DashedSliderTrackShape(),
              thumbShape: const RoundSliderThumbShape(elevation: 3, pressedElevation: 6),
            ),
            child: Slider(
              value: _minArea,
              min: 0,
              max: 1000,
              onChanged: (value) => setState(() => _minArea = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBadge(String text, Color primaryColor, bool isExpanded) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10), // lighter radius
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
    return isExpanded ? Expanded(child: Center(child: badge)) : badge;
  }

  Widget _buildCapacityCard(Color cardColor, Color themeColor, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          _buildCounterRow(context.tr('home_bedrooms'), Icons.bed_rounded, _minBedrooms, (v) => setState(() => _minBedrooms = v), themeColor, primaryColor),
          _buildDivider(isDark),
          _buildCounterRow(context.tr('home_bathrooms'), Icons.bathtub_rounded, _minBathrooms, (v) => setState(() => _minBathrooms = v), themeColor, primaryColor),
          _buildDivider(isDark),
          _buildCounterRow(context.tr('booking_children'), Icons.child_care_rounded, _minChildren, (v) => setState(() => _minChildren = v), themeColor, primaryColor),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03), height: 1),
    );
  }

  Widget _buildCounterRow(
    String label,
    IconData icon,
    int? value,
    Function(int?) onChanged,
    Color themeColor,
    Color primaryColor,
  ) {
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: themeColor),
              ),
            ],
          ),
          Row(
            children: [
              _buildCircleBtn(Icons.remove, () {
                if (count > 0) onChanged(count - 1 == 0 ? null : count - 1);
              }, primaryColor, themeColor),
              SizedBox(
                width: 36,
                child: Text(
                  count == 0 ? context.tr('common_any') : '$count+',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: themeColor),
                ),
              ),
              _buildCircleBtn(Icons.add, () => onChanged(count + 1), primaryColor, themeColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap, Color primaryColor, Color themeColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: themeColor.withOpacity(0.1)),
          color: Colors.transparent,
        ),
        child: Icon(icon, size: 18, color: themeColor.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildFeaturesWrap(bool isDark, Color primaryColor, Color themeColor, Color cardColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.chaletCategories.map((cat) {
        final isSelected = _selectedFeatures.contains(cat['value']);
        return _buildChip(cat['label'], null, isSelected, () {
          setState(() {
            if (isSelected) {
              _selectedFeatures.remove(cat['value']);
            } else {
              _selectedFeatures.add(cat['value']);
            }
          });
        }, isDark, primaryColor, themeColor, cardColor);
      }).toList(),
    );
  }

  Widget _buildFacilitiesWrap(bool isDark, Color primaryColor, Color themeColor, Color cardColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.serviceFacilities.map((fac) {
        final isSelected = _selectedFacilities.contains(fac['value']);
        return _buildChip(fac['label'], fac['icon'], isSelected, () {
          setState(() {
            if (isSelected) {
              _selectedFacilities.remove(fac['value']);
            } else {
              _selectedFacilities.add(fac['value']);
            }
          });
        }, isDark, primaryColor, themeColor, cardColor);
      }).toList(),
    );
  }

  Widget _buildChip(String label, IconData? icon, bool isSelected, VoidCallback onTap, bool isDark, Color primary, Color theme, Color card) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.1) : card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary.withOpacity(0.5) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? primary : theme.withOpacity(0.5)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primary : theme.withOpacity(0.8),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(Color bgColor, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 24, right: 24),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.03))),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _applySearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
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

/// Custom RangeSlider track that draws dashed lines (like a histogram filter)
class DashedRangeSliderTrackShape extends RangeSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset startThumbCenter,
    required Offset endThumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackRect.height
      ..strokeCap = StrokeCap.round;

    final Paint activePaint = Paint()
      ..color = sliderTheme.activeTrackColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackRect.height
      ..strokeCap = StrokeCap.round;

    final double dashWidth = 4.0;
    final double dashSpace = 4.0;
    double startX = trackRect.left;

    while (startX < trackRect.right) {
      final double endX = startX + dashWidth;
      final bool isActive = startX >= startThumbCenter.dx && endX <= endThumbCenter.dx;
      
      canvas.drawLine(
        Offset(startX, trackRect.center.dy),
        Offset(endX > trackRect.right ? trackRect.right : endX, trackRect.center.dy),
        isActive ? activePaint : inactivePaint,
      );
      
      startX += dashWidth + dashSpace;
    }
  }
}

/// Custom Slider track that draws dashed lines
class DashedSliderTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackRect.height
      ..strokeCap = StrokeCap.round;

    final Paint activePaint = Paint()
      ..color = sliderTheme.activeTrackColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackRect.height
      ..strokeCap = StrokeCap.round;

    final double dashWidth = 4.0;
    final double dashSpace = 4.0;
    double startX = trackRect.left;

    while (startX < trackRect.right) {
      final double endX = startX + dashWidth;
      final bool isActive = startX <= thumbCenter.dx;
      
      canvas.drawLine(
        Offset(startX, trackRect.center.dy),
        Offset(endX > trackRect.right ? trackRect.right : endX, trackRect.center.dy),
        isActive ? activePaint : inactivePaint,
      );
      
      startX += dashWidth + dashSpace;
    }
  }
}
