import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

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
      title: 'معلومات المالك',
      color: ColorManager.blue2563EB,
      child: Column(
        children: [
          _InfoRow(
            isDark: isDark,
            label: 'اسم المالك',
            value: name,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            isDark: isDark,
            label: 'البريد الإلكتروني',
            value: email,
            icon: Icons.email_rounded,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            isDark: isDark,
            label: 'رقم الهاتف',
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
      title: 'تفاصيل الشاليه',
      color: ColorManager.purple764BA2,
      child: Column(
        children: [
          _ModernTextField(
            key: const ValueKey('chalet_name'),
            isDark: isDark,
            initialValue: initialName,
            label: 'اسم الشاليه',
            icon: Icons.villa_rounded,
            hint: 'أدخل اسم الشاليه',
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 16),
          _ModernTextField(
            key: const ValueKey('chalet_desc'),
            isDark: isDark,
            initialValue: initialDescription,
            label: 'الوصف',
            icon: Icons.description_rounded,
            hint: 'اكتب وصفاً للشاليه...',
            maxLines: 4,
            onChanged: onDescriptionChanged,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// Location Section
// ==========================================
class LocationSection extends StatelessWidget {
  final String address;
  final VoidCallback onPickLocation;

  const LocationSection({
    super.key,
    required this.address,
    required this.onPickLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final hasLocation = address.isNotEmpty;

    return _ModernCard(
      isDark: isDark,
      icon: Icons.location_on_rounded,
      title: 'الموقع',
      color: ColorManager.orangeF59E0B,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ColorManager.orangeF59E0B, Color(0xFFF97316)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.orangeF59E0B.withOpacity(0.3),
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: ColorManager.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'اختر الموقع على الخريطة',
                      style: TextStyle(
                        color: ColorManager.white,
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
              label: 'العنوان المحدد',
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
      title: 'تفاصيل العقار',
      color: ColorManager.mainBlue,
      child: Column(
        children: [
          _ModernTextField(
            key: const ValueKey('chalet_price'),
            isDark: isDark,
            initialValue: initialPrice,
            label: 'السعر لليلة (جنيه)',
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
            label: 'المساحة (م²)',
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
                  label: 'غرف النوم',
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
                  label: 'الحمامات',
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
      title: 'فترة التوفر',
      color: ColorManager.cyan06B6D4,
      child: Row(
        children: [
          Expanded(
            child: _DateButton(
              isDark: isDark,
              label: 'من تاريخ',
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
              label: 'إلى تاريخ',
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
        'label': 'مسبح',
        'icon': Icons.pool_rounded,
        'color': ColorManager.cyan06B6D4,
      },
      {
        'key': 'Sea View',
        'label': 'إطلالة بحرية',
        'icon': Icons.waves_rounded,
        'color': ColorManager.blue2563EB,
      },
      {
        'key': 'Garden',
        'label': 'حديقة',
        'icon': Icons.local_florist_rounded,
        'color': ColorManager.mainBlue,
      },
      {
        'key': 'WiFi',
        'label': 'واي فاي',
        'icon': Icons.wifi_rounded,
        'color': ColorManager.purple764BA2,
      },
      {
        'key': 'BBQ',
        'label': 'منطقة شواء',
        'icon': Icons.outdoor_grill_rounded,
        'color': ColorManager.bookingsWarningOrange,
      },
      {
        'key': 'Parking',
        'label': 'موقف سيارات',
        'icon': Icons.local_parking_rounded,
        'color': ColorManager.grey600,
      },
    ];

    return _ModernCard(
      isDark: isDark,
      icon: Icons.star_rounded,
      title: 'المميزات الإضافية',
      color: ColorManager.yellowEAB308,
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
      title: 'الخصومات والعروض',
      color: ColorManager.redFF3B30,
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'تفعيل الخصم',
              style: TextStyle(
                color: isDark ? ColorManager.white : ColorManager.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'قم بتفعيل هذا الخيار لإضافة خصم على السعر',
              style: TextStyle(
                color: isDark ? ColorManager.grey400 : ColorManager.grey600,
                fontSize: 12,
              ),
            ),
            value: isEnabled,
            activeColor: ColorManager.redFF3B30,
            onChanged: onDiscountEnabledChanged,
            contentPadding: EdgeInsets.zero,
          ),
          if (isEnabled) ...[
            const SizedBox(height: 20),
            // Row 1: Discount Type Title
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'نوع الخصم',
                style: TextStyle(
                  color: isDark ? ColorManager.grey400 : ColorManager.grey600,
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
                            ? ColorManager.redFF3B30
                            : (isDark
                                  ? ColorManager.darkBlue2A2E4B.withOpacity(0.5)
                                  : ColorManager.grey50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: discountType == 'percentage'
                              ? ColorManager.redFF3B30
                              : (isDark
                                    ? ColorManager.grey800.withOpacity(0.3)
                                    : ColorManager.grey300),
                          width: discountType == 'percentage' ? 2 : 1,
                        ),
                        boxShadow: discountType == 'percentage'
                            ? [
                                BoxShadow(
                                  color: ColorManager.redFF3B30.withOpacity(
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
                                  ? ColorManager.white
                                  : (isDark
                                        ? ColorManager.grey400
                                        : ColorManager.grey600),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'نسبة مئوية (%)',
                              style: TextStyle(
                                color: discountType == 'percentage'
                                    ? ColorManager.white
                                    : (isDark
                                          ? ColorManager.white
                                          : ColorManager.black),
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
                            ? ColorManager.redFF3B30
                            : (isDark
                                  ? ColorManager.darkBlue2A2E4B.withOpacity(0.5)
                                  : ColorManager.grey50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: discountType == 'fixed'
                              ? ColorManager.redFF3B30
                              : (isDark
                                    ? ColorManager.grey800.withOpacity(0.3)
                                    : ColorManager.grey300),
                          width: discountType == 'fixed' ? 2 : 1,
                        ),
                        boxShadow: discountType == 'fixed'
                            ? [
                                BoxShadow(
                                  color: ColorManager.redFF3B30.withOpacity(
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
                                  ? ColorManager.white
                                  : (isDark
                                        ? ColorManager.grey400
                                        : ColorManager.grey600),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'مبلغ ثابت (EGP)',
                              style: TextStyle(
                                color: discountType == 'fixed'
                                    ? ColorManager.white
                                    : (isDark
                                          ? ColorManager.white
                                          : ColorManager.black),
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
                  ? 'أدخل نسبة الخصم (%)'
                  : 'أدخل قيمة الخصم (EGP)',
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
                color: (isDark ? ColorManager.green3DDC84 : ColorManager.green)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      (isDark ? ColorManager.green3DDC84 : ColorManager.green)
                          .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: isDark
                        ? ColorManager.green3DDC84
                        : ColorManager.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'السعر بعد الخصم: ',
                    style: TextStyle(
                      color: isDark
                          ? ColorManager.grey400
                          : ColorManager.grey600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${discountedPrice.toStringAsFixed(2)} جنيه',
                    style: TextStyle(
                      color: isDark ? ColorManager.white : ColorManager.black,
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
      title: 'خصائص الحجز (Day Use)',
      color: ColorManager.green3DDC84,
      child: SwitchListTile(
        title: Text(
          'تفعيل خاصية "Day Use"',
          style: TextStyle(
            color: isDark ? ColorManager.white : ColorManager.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'السماح للمستخدمين بحجز الشاليه لقضاء اليوم فقط بدون مبيت',
          style: TextStyle(
            color: isDark ? ColorManager.grey400 : ColorManager.grey600,
            fontSize: 12,
          ),
        ),
        value: isEnabled,
        activeColor: ColorManager.green3DDC84,
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
        color: isDark ? ColorManager.darkBlue1A1A2E : ColorManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ColorManager.grey800.withOpacity(0.3)
              : ColorManager.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? ColorManager.black.withOpacity(0.3)
                : ColorManager.black.withOpacity(0.05),
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
                    color: isDark ? ColorManager.white : ColorManager.black,
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
            ? ColorManager.darkBlue2A2E4B.withOpacity(0.5)
            : ColorManager.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? ColorManager.grey800.withOpacity(0.3)
              : ColorManager.grey300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? ColorManager.grey400 : ColorManager.grey600,
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
                    color: isDark ? ColorManager.grey400 : ColorManager.grey600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'غير محدد',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? ColorManager.white : ColorManager.black,
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
        color: isDark ? ColorManager.white : ColorManager.black,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: isDark ? ColorManager.grey400 : ColorManager.grey600,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: isDark ? ColorManager.grey600 : ColorManager.grey400,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? ColorManager.grey400 : ColorManager.grey600,
          size: 20,
        ),
        filled: true,
        fillColor: isDark
            ? ColorManager.darkBlue2A2E4B.withOpacity(0.5)
            : ColorManager.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? ColorManager.grey800.withOpacity(0.3)
                : ColorManager.grey300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorManager.blue2563EB,
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
              ? ColorManager.darkBlue2A2E4B.withOpacity(0.5)
              : ColorManager.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? ColorManager.grey800.withOpacity(0.3)
                : ColorManager.grey300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? ColorManager.grey400 : ColorManager.grey600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? 'اختر التاريخ',
                    style: TextStyle(
                      color: value != null
                          ? (isDark ? ColorManager.white : ColorManager.black)
                          : (isDark
                                ? ColorManager.grey600
                                : ColorManager.grey400),
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
                  color: ColorManager.cyan06B6D4,
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
    final activeColor = color ?? ColorManager.yellowEAB308;

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
                    ? ColorManager.darkBlue2A2E4B.withOpacity(0.5)
                    : ColorManager.grey50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark
                      ? ColorManager.grey800.withOpacity(0.3)
                      : ColorManager.grey300),
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
                          ? ColorManager.grey800.withOpacity(0.3)
                          : ColorManager.grey200),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? ColorManager.white
                    : (isDark
                          ? ColorManager.grey400
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
                    : (isDark ? ColorManager.grey300 : ColorManager.grey700),
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
