import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/model/pricing_period.dart';

/// Shared palette + formatting for booking pricing calendar & period cards.
class BookingPricingUiHelper {
  BookingPricingUiHelper._();

  static const Color availableGreen = Color(0xFF22C55E);
  static const Color bookedRed = Color(0xFFEF4444);
  static const Color pendingYellow = Color(0xFFF59E0B);
  static const Color rangeAccent = Color(0xFF00D27F);
  static const Color unavailableGrey = Color(0xFF9CA3AF);

  static const Color selectedEndpoint = Color(0xFFFF5722);
  static const Color selectedEndpointAlt = Color(0xFFFF9800);
  static const Color rangeFill = Color(0xFF2196F3);
  static const Color rangeFillDark = Color(0xFF64B5F6);

  static const List<Color> tierPalette = [
    Color(0xFF2563EB),
    Color(0xFF0EA5E9),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFFDB2777),
  ];

  static final NumberFormat _compactNumber = NumberFormat('#,##0', 'en');

  static Map<double, Color> tierColorMap(List<double> prices) {
    final unique = prices.toSet().toList()..sort();
    final map = <double, Color>{};
    for (var i = 0; i < unique.length; i++) {
      map[unique[i]] = tierPalette[i % tierPalette.length];
    }
    return map;
  }

  static Color colorForPrice(double price, Map<double, Color> map) =>
      map[price] ?? tierPalette.first;

  static String compactEgp(BuildContext context, double price) {
    return '${_compactNumber.format(price)} ${context.tr('booking_egp_currency')}';
  }

  static String shortEgp(BuildContext context, double price) {
    return '${context.tr('common_egp_abbr')} ${_compactNumber.format(price)}';
  }

  static String periodDateRange(BuildContext context, PricingPeriod period) {
    final fmt = DateFormat('d MMM', Localizations.localeOf(context).languageCode);
    return '${fmt.format(period.from)} — ${fmt.format(period.to)}';
  }

  static List<MapEntry<double, Color>> legendEntries(
    List<double> prices,
    Map<double, Color> colorMap,
  ) {
    final unique = prices.toSet().toList()..sort();
    return unique.map((p) => MapEntry(p, colorMap[p]!)).toList();
  }
}

/// Premium period tier card for the booking wizard overview.
class BookingPeriodTierCard extends StatelessWidget {
  const BookingPeriodTierCard({
    super.key,
    required this.period,
    required this.tierColor,
    required this.isDark,
    required this.index,
  });

  final PricingPeriod period;
  final Color tierColor;
  final bool isDark;
  final int index;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final muted = isDark ? Colors.white60 : const Color(0xFF6B7280);

    return Container(
      width: 220,
      margin: const EdgeInsetsDirectional.only(end: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        border: Border.all(color: tierColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: isDark ? 0.18 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: tierColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.tr('booking_period_tier_badge'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: tierColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            BookingPricingUiHelper.periodDateRange(context, period),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: textColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.egp(context, period.price, withSuffixPerNight: true),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: tierColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('booking_period_nights_count').replaceAll(
              '{count}',
              '${period.nightCount + 1}',
            ),
            style: TextStyle(fontSize: 11, color: muted),
          ),
        ],
      ),
    );
  }
}

/// Calendar legend row (available / booked / price tiers).
class BookingCalendarLegend extends StatelessWidget {
  const BookingCalendarLegend({
    super.key,
    required this.isDark,
    required this.tierEntries,
    required this.showInstructions,
  });

  final bool isDark;
  final List<MapEntry<double, Color>> tierEntries;
  final bool showInstructions;

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _LegendChip(
              color: BookingPricingUiHelper.availableGreen,
              label: context.tr('booking_calendar_available'),
              isDark: isDark,
            ),
            _LegendChip(
              color: BookingPricingUiHelper.pendingYellow,
              label: context.tr('booking_calendar_pending'),
              isDark: isDark,
            ),
            _LegendChip(
              color: BookingPricingUiHelper.bookedRed,
              label: context.tr('booking_calendar_booked'),
              isDark: isDark,
            ),
            _LegendChip(
              color: BookingPricingUiHelper.selectedEndpoint,
              label: context.tr('booking_calendar_selected'),
              isDark: isDark,
            ),
            _LegendChip(
              color: BookingPricingUiHelper.rangeFill,
              label: context.tr('booking_calendar_in_range'),
              isDark: isDark,
            ),
            for (final entry in tierEntries)
              _LegendChip(
                color: entry.value,
                label: BookingPricingUiHelper.compactEgp(context, entry.key),
                isDark: isDark,
              ),
          ],
        ),
        if (showInstructions) ...[
          const SizedBox(height: 14),
          Text(
            context.tr('booking_calendar_how_to_use'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          _instruction(context, '1', context.tr('booking_calendar_tip_1'), muted),
          _instruction(context, '2', context.tr('booking_calendar_tip_2'), muted),
          _instruction(context, '3', context.tr('booking_calendar_tip_3'), muted),
        ],
      ],
    );
  }

  Widget _instruction(
    BuildContext context,
    String n,
    String text,
    Color muted,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$n.', style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: muted, height: 1.35))),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.isDark,
  });

  final Color color;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

enum BookingDayAvailability { available, pending, booked, unavailable }

/// Single calendar day cell — status colors + EGP price + selection animation.
class BookingCalendarDayCell extends StatefulWidget {
  const BookingCalendarDayCell({
    super.key,
    required this.day,
    required this.price,
    required this.availability,
    required this.isSelected,
    required this.isInRange,
    required this.isDark,
  });

  final DateTime day;
  final double? price;
  final BookingDayAvailability availability;
  final bool isSelected;
  final bool isInRange;
  final bool isDark;

  @override
  State<BookingCalendarDayCell> createState() => _BookingCalendarDayCellState();
}

class _BookingCalendarDayCellState extends State<BookingCalendarDayCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _pop;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 1.14).animate(
      CurvedAnimation(parent: _pop, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant BookingCalendarDayCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _pop.forward(from: 0).then((_) {
        if (mounted) _pop.reverse();
      });
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  Color get _baseColor {
    switch (widget.availability) {
      case BookingDayAvailability.booked:
        return BookingPricingUiHelper.bookedRed;
      case BookingDayAvailability.pending:
        return BookingPricingUiHelper.pendingYellow;
      case BookingDayAvailability.available:
        return BookingPricingUiHelper.availableGreen;
      case BookingDayAvailability.unavailable:
        return widget.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    }
  }

  BoxDecoration _selectionDecoration() {
    if (widget.isSelected) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: BookingPricingUiHelper.selectedEndpoint,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: BookingPricingUiHelper.selectedEndpoint.withValues(alpha: 0.85),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      );
    }
    if (widget.isInRange) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.isDark
            ? BookingPricingUiHelper.rangeFillDark
            : BookingPricingUiHelper.rangeFill,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: BookingPricingUiHelper.rangeFill.withValues(alpha: 0.55),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: _baseColor.withValues(alpha: widget.isDark ? 0.92 : 0.95),
      border: Border.all(color: _baseColor.withValues(alpha: 0.7), width: 1),
    );
  }

  Color get _onStatusText => Colors.white;

  Color get _onStatusSubtext => Colors.white.withValues(alpha: 0.88);

  @override
  Widget build(BuildContext context) {
    if (widget.availability == BookingDayAvailability.unavailable) {
      return _cellBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _baseColor,
          border: Border.all(
            color: widget.isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.day.day}',
              style: TextStyle(
                color: BookingPricingUiHelper.unavailableGrey,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            if (widget.price != null && widget.price! > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    BookingPricingUiHelper.shortEgp(context, widget.price!),
                    style: TextStyle(
                      color: BookingPricingUiHelper.unavailableGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 7,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (widget.availability == BookingDayAvailability.booked) {
      return _cellBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _baseColor,
          border: Border.all(color: _baseColor.withValues(alpha: 0.85)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.day.day}',
              style: TextStyle(
                color: _onStatusText,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              context.tr('booking_calendar_booked_short'),
              style: TextStyle(color: _onStatusSubtext, fontSize: 7),
            ),
          ],
        ),
      );
    }

    if (widget.availability == BookingDayAvailability.pending) {
      return _cellBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _baseColor,
          border: Border.all(color: _baseColor.withValues(alpha: 0.85)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.day.day}',
              style: TextStyle(
                color: _onStatusText,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              context.tr('booking_calendar_pending_short'),
              style: TextStyle(color: _onStatusSubtext, fontSize: 7),
            ),
          ],
        ),
      );
    }

    final subtitle = widget.price != null && widget.price! > 0
        ? BookingPricingUiHelper.shortEgp(context, widget.price!)
        : null;

    final textColor = widget.isSelected
        ? Colors.white
        : widget.isInRange
            ? Colors.white
            : _onStatusText;
    final subtitleColor = widget.isSelected
        ? Colors.white.withValues(alpha: 0.92)
        : _onStatusSubtext;

    return ScaleTransition(
      scale: _scaleAnim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(2),
        decoration: _selectionDecoration(),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: widget.isSelected ? 14 : 13,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                      height: 1.1,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cellBox({
    required BoxDecoration decoration,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: decoration,
      alignment: Alignment.center,
      child: child,
    );
  }
}
