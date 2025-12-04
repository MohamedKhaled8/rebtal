import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/app_constants.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

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
    final exactPrice = exactPriceText.isEmpty
        ? null
        : double.tryParse(exactPriceText);

    // Only include priceRange if it's not the default (0-100000)
    final RangeValues? activePriceRange =
        (_priceRange.start > 0 || _priceRange.end < 10000) ? _priceRange : null;

    HomeSearch.filters.value = SearchFilters(
      query: _queryController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      priceRange: activePriceRange,
      exactPrice: exactPrice,
      minBedrooms: _minBedrooms,
      minBathrooms: _minBathrooms,
      features: _selectedFeatures,
      facilities: _selectedFacilities,
      minArea: _minArea > 0 ? _minArea : null,
    );
    Navigator.pop(context);
  }

  void _resetFilters() {
    // Reset global filters immediately
    HomeSearch.clear();

    // Reset local state
    setState(() {
      _queryController.clear();
      _locationController.clear();
      _exactPriceController.clear();
      _priceRange = const RangeValues(0, 10000);
      _minBedrooms = null;
      _minBathrooms = null;
      _selectedFeatures = [];
      _selectedFacilities = [];
      _minArea = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final themeColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle Bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'بحث متقدم',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'إعادة تعيين',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Search Query
                Text(
                  'البحث',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _queryController,
                  style: TextStyle(color: themeColor),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن شاليه بالاسم أو الوصف...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Price Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'نطاق السعر (لليلة)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                      ),
                    ),
                    Text(
                      '${_priceRange.start.round()} - ${_priceRange.end.round()} EGP',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  activeColor: const Color(0xFF10B981),
                  inactiveColor: Colors.grey.withOpacity(0.3),
                  labels: RangeLabels(
                    '${_priceRange.start.round()}',
                    '${_priceRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Area
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مساحة الشاليه (م²)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                      ),
                    ),
                    Text(
                      '${_minArea.round()} م²',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _minArea,
                  min: 0,
                  max: 1000,
                  divisions: 100,
                  activeColor: const Color(0xFF10B981),
                  inactiveColor: Colors.grey.withOpacity(0.3),
                  label: '${_minArea.round()} م²',
                  onChanged: (value) {
                    setState(() {
                      _minArea = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Rooms
                Text(
                  'الغرف والمرافق',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCounterRow(
                  'غرف النوم',
                  _minBedrooms,
                  (val) {
                    setState(() => _minBedrooms = val);
                  },
                  themeColor,
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildCounterRow(
                  'الحمامات',
                  _minBathrooms,
                  (val) {
                    setState(() => _minBathrooms = val);
                  },
                  themeColor,
                  isDark,
                ),

                const SizedBox(height: 24),

                // Amenities
                Text(
                  'المميزات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.chaletCategories.map((cat) {
                    final isSelected = _selectedFeatures.contains(cat['value']);
                    return FilterChip(
                      label: Text(cat['label']),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFeatures.add(cat['value']);
                          } else {
                            _selectedFeatures.remove(cat['value']);
                          }
                        });
                      },
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                      selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF10B981),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : themeColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Facilities
                Text(
                  'المرافق والخدمات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.serviceFacilities.map((fac) {
                    final isSelected = _selectedFacilities.contains(
                      fac['value'],
                    );
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            fac['icon'],
                            size: 16,
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : themeColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(fac['label']),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFacilities.add(fac['value']);
                          } else {
                            _selectedFacilities.remove(fac['value']);
                          }
                        });
                      },
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                      selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF10B981),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : themeColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Footer Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _applySearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'عرض النتائج',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow(
    String label,
    int? value,
    Function(int?) onChanged,
    Color themeColor,
    bool isDark,
  ) {
    final count = value ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: themeColor.withOpacity(0.8)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (count > 0) {
                    onChanged(count - 1 == 0 ? null : count - 1);
                  }
                },
                icon: Icon(Icons.remove, size: 18, color: themeColor),
              ),
              Text(
                count == 0 ? 'أي' : '$count+',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  onChanged(count + 1);
                },
                icon: Icon(Icons.add, size: 18, color: themeColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
