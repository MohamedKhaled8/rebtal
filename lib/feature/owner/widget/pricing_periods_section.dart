import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/model/pricing_period.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PricingPeriodsSection extends StatefulWidget {
  final List<PricingPeriod> periods;
  final bool Function(DateTime from, DateTime to, double price) onAdd;
  final void Function(String id) onRemove;
  final bool overlapError;

  const PricingPeriodsSection({
    super.key,
    required this.periods,
    required this.onAdd,
    required this.onRemove,
    this.overlapError = false,
  });

  @override
  State<PricingPeriodsSection> createState() => _PricingPeriodsSectionState();
}

class _PricingPeriodsSectionState extends State<PricingPeriodsSection> {
  DateTime? _draftFrom;
  DateTime? _draftTo;
  final _priceController = TextEditingController();
  bool _showOverlapHint = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final now = DateTime.now();
    final initial = isFrom
        ? (_draftFrom ?? now)
        : (_draftTo ?? _draftFrom ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _draftFrom = PricingPeriod.dateOnly(picked);
        if (_draftTo != null && _draftTo!.isBefore(_draftFrom!)) {
          _draftTo = _draftFrom;
        }
      } else {
        _draftTo = PricingPeriod.dateOnly(picked);
      }
      _showOverlapHint = false;
    });
  }

  void _submitPeriod() {
    final price = double.tryParse(_priceController.text.trim());
    if (_draftFrom == null || _draftTo == null || price == null || price <= 0) {
      return;
    }
    final ok = widget.onAdd(_draftFrom!, _draftTo!, price);
    setState(() {
      if (ok) {
        _draftFrom = null;
        _draftTo = null;
        _priceController.clear();
        _showOverlapHint = false;
      } else {
        _showOverlapHint = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final dateFmt = DateFormat('yyyy-MM-dd');

    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
        borderRadius: BorderRadius.circular(20.sp),
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
            blurRadius: 20.sp,
            offset: Offset(0, 4.sp),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: ColorsManager.cyan06B6D4.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Icon(
                  Icons.date_range_rounded,
                  color: ColorsManager.cyan06B6D4,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.sw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('owner_pricing_periods_title'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? ColorsManager.white
                            : ColorsManager.black,
                      ),
                    ),
                    Text(
                      context.tr('owner_pricing_periods_subtitle'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? ColorsManager.grey400
                            : ColorsManager.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.periods.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.sp,
                    vertical: 4.sp,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.cyan06B6D4.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Text(
                    '${widget.periods.length}',
                    style: TextStyle(
                      color: ColorsManager.cyan06B6D4,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.sh),

          if (widget.periods.isEmpty)
            _EmptyPeriodsHint(isDark: isDark)
          else
            ...widget.periods.map(
              (p) => _PeriodCard(
                isDark: isDark,
                period: p,
                dateFmt: dateFmt,
                onRemove: () => widget.onRemove(p.id),
              ),
            ),

          SizedBox(height: 16.sh),
          Divider(
            color: isDark
                ? ColorsManager.grey800.withOpacity(0.4)
                : ColorsManager.grey200,
          ),
          SizedBox(height: 16.sh),

          Text(
            context.tr('owner_pricing_periods_add_new'),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? ColorsManager.white : ColorsManager.black,
            ),
          ),
          SizedBox(height: 12.sh),

          Row(
            children: [
              Expanded(
                child: _DateChip(
                  isDark: isDark,
                  label: context.tr('booking_from_date'),
                  value: _draftFrom == null
                      ? null
                      : dateFmt.format(_draftFrom!),
                  onTap: () => _pickDate(isFrom: true),
                ),
              ),
              SizedBox(width: 10.sw),
              Expanded(
                child: _DateChip(
                  isDark: isDark,
                  label: context.tr('booking_to_date'),
                  value: _draftTo == null ? null : dateFmt.format(_draftTo!),
                  onTap: () => _pickDate(isFrom: false),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sh),

          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: isDark ? ColorsManager.white : ColorsManager.black,
              fontSize: 15.sp,
            ),
            decoration: InputDecoration(
              labelText: context.tr('owner_pricing_periods_price_label'),
              hintText: context.tr('owner_price_hint_zero'),
              labelStyle: TextStyle(
                color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
              ),
              prefixIcon: Icon(
                Icons.payments_rounded,
                color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
              ),
              suffixText: context.tr('booking_egp_currency'),
              filled: true,
              fillColor: isDark
                  ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
                  : ColorsManager.grey50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.sp),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.sp),
                borderSide: BorderSide(
                  color: isDark
                      ? ColorsManager.grey800.withOpacity(0.3)
                      : ColorsManager.grey300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.sp),
                borderSide: const BorderSide(
                  color: ColorsManager.cyan06B6D4,
                  width: 2,
                ),
              ),
            ),
          ),

          if (_showOverlapHint || widget.overlapError) ...[
            SizedBox(height: 8.sh),
            Text(
              context.tr('owner_pricing_periods_overlap_error'),
              style: TextStyle(color: ColorsManager.redFF3B30, fontSize: 12.sp),
            ),
          ],

          SizedBox(height: 16.sh),

          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ColorsManager.cyan06B6D4, ColorsManager.blue2563EB],
                ),
                borderRadius: BorderRadius.circular(14.sp),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.cyan06B6D4.withOpacity(0.35),
                    blurRadius: 12.sp,
                    offset: Offset(0, 4.sp),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _submitPeriod,
                  borderRadius: BorderRadius.circular(14.sp),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.sh),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: ColorsManager.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.sw),
                        Text(
                          context.tr('owner_pricing_periods_add_button'),
                          style: TextStyle(
                            color: ColorsManager.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPeriodsHint extends StatelessWidget {
  final bool isDark;

  const _EmptyPeriodsHint({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.darkBlue2A2E4B.withOpacity(0.4)
            : ColorsManager.grey50,
        borderRadius: BorderRadius.circular(14.sp),
        border: Border.all(
          color: ColorsManager.cyan06B6D4.withOpacity(0.25),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: ColorsManager.cyan06B6D4,
            size: 22.sp,
          ),
          SizedBox(width: 12.sw),
          Expanded(
            child: Text(
              context.tr('owner_pricing_periods_empty_hint'),
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final bool isDark;
  final PricingPeriod period;
  final DateFormat dateFmt;
  final VoidCallback onRemove;

  const _PeriodCard({
    required this.isDark,
    required this.period,
    required this.dateFmt,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.sh),
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  ColorsManager.cyan06B6D4.withOpacity(0.12),
                  ColorsManager.blue2563EB.withOpacity(0.08),
                ]
              : [
                  ColorsManager.cyan06B6D4.withOpacity(0.08),
                  ColorsManager.blue2563EB.withOpacity(0.04),
                ],
        ),
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: ColorsManager.cyan06B6D4.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: ColorsManager.cyan06B6D4.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: ColorsManager.cyan06B6D4,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.sw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dateFmt.format(period.from)} → ${dateFmt.format(period.to)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: isDark ? ColorsManager.white : ColorsManager.black,
                  ),
                ),
                SizedBox(height: 4.sh),
                Text(
                  context
                      .tr('owner_pricing_periods_price_per_night')
                      .replaceAll('{price}', period.price.toStringAsFixed(0)),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: ColorsManager.cyan06B6D4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: ColorsManager.redFF3B30,
              size: 22.sp,
            ),
            tooltip: context.tr('common_delete'),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final bool isDark;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DateChip({
    required this.isDark,
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.sp),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: isDark
              ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
              : ColorsManager.grey50,
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(
            color: hasValue
                ? ColorsManager.cyan06B6D4.withOpacity(0.5)
                : (isDark
                      ? ColorsManager.grey800.withOpacity(0.3)
                      : ColorsManager.grey300),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: isDark ? ColorsManager.grey400 : ColorsManager.grey600,
              ),
            ),
            SizedBox(height: 4.sh),
            Text(
              value ?? context.tr('owner_pricing_periods_pick_date'),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: hasValue
                    ? (isDark ? ColorsManager.white : ColorsManager.black)
                    : (isDark ? ColorsManager.grey600 : ColorsManager.grey400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
