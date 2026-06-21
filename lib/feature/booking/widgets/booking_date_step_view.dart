import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/model/pricing_period.dart';
import 'package:rebtal/core/utils/services/chalet_pricing_service.dart';
import 'package:rebtal/feature/booking/logic/wizard_cubit/booking_wizard_state.dart';
import 'package:rebtal/feature/booking/widgets/booking_pricing_ui_helper.dart';

/// Date-selection step for the booking wizard.
class BookingDateStepView extends StatelessWidget {
  const BookingDateStepView({
    super.key,
    required this.chaletName,
    required this.requestData,
    required this.state,
    required this.isDark,
    required this.onOpenCalendar,
  });

  final String chaletName;
  final Map<String, dynamic> requestData;
  final BookingWizardState state;
  final bool isDark;
  final VoidCallback onOpenCalendar;

  static const _accent = Color(0xFF00D27F);

  Color get _text => isDark ? Colors.white : const Color(0xFF111827);
  Color get _muted => isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
  Color get _surface => isDark ? const Color(0xFF1C1C1E) : Colors.white;
  Color get _surfaceElevated =>
      isDark ? const Color(0xFF242426) : const Color(0xFFF9FAFB);
  Color get _border => isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final hasDates = state.isDatesSelected;
    final periods = ChaletPricingService.bookingDisplayPeriods(requestData);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroHeader(
            chaletName: chaletName,
            isDark: isDark,
            textColor: _text,
            mutedColor: _muted,
            surfaceColor: _surface,
            borderColor: _border,
          ),
          if (periods.isNotEmpty) ...[
            const SizedBox(height: 24),
            _BookingPeriodsSection(
              periods: periods,
              isDark: isDark,
              textColor: _text,
              mutedColor: _muted,
              surfaceColor: _surface,
              surfaceElevated: _surfaceElevated,
              borderColor: _border,
            ),
          ],
          const SizedBox(height: 20),
          _CalendarActionCard(
            hasDates: hasDates,
            isDark: isDark,
            textColor: _text,
            mutedColor: _muted,
            surfaceColor: _surface,
            borderColor: _border,
            onTap: onOpenCalendar,
          ),
          if (hasDates) ...[
            const SizedBox(height: 16),
            _BookingSelectedDatesSummary(
              state: state,
              isDark: isDark,
              textColor: _text,
              mutedColor: _muted,
              surfaceColor: _surface,
              borderColor: _border,
              onEdit: onOpenCalendar,
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.chaletName,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceColor,
    required this.borderColor,
  });

  final String chaletName;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr('booking_select_trip_date'),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: textColor,
            height: 1.2,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('booking_wizard_select_dates_desc'),
          style: TextStyle(fontSize: 15, color: mutedColor, height: 1.45),
        ),
        if (chaletName.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: BookingDateStepView._accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.villa_outlined,
                    size: 22,
                    color: BookingDateStepView._accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('booking_wizard_chalet_label'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: mutedColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        chaletName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: textColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BookingPeriodsSection extends StatelessWidget {
  const _BookingPeriodsSection({
    required this.periods,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceColor,
    required this.surfaceElevated,
    required this.borderColor,
  });

  final List<PricingPeriod> periods;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceColor;
  final Color surfaceElevated;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final uniquePrices = periods.map((p) => p.price).toSet().toList()..sort();
    final minPrice = uniquePrices.first;
    final maxPrice = uniquePrices.last;
    final hasRange = uniquePrices.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('booking_pricing_periods_title'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('booking_pricing_periods_subtitle'),
                    style: TextStyle(fontSize: 13, color: mutedColor, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: BookingDateStepView._accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: BookingDateStepView._accent.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                _periodCountLabel(context, periods.length),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: BookingDateStepView._accent,
                ),
              ),
            ),
          ],
        ),
        if (hasRange) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.sell_outlined, size: 18, color: mutedColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context
                        .tr('booking_pricing_from_to')
                        .replaceAll('{from}', _compactPrice(context, minPrice))
                        .replaceAll('{to}', _compactPrice(context, maxPrice)),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        ...List.generate(periods.length, (index) {
          final uniquePrices = periods.map((p) => p.price).toSet().toList()..sort();
          final colorMap = BookingPricingUiHelper.tierColorMap(uniquePrices);
          return Padding(
            padding: EdgeInsets.only(bottom: index == periods.length - 1 ? 0 : 10),
            child: _PeriodCard(
              period: periods[index],
              index: index,
              accentColor: BookingPricingUiHelper.colorForPrice(
                periods[index].price,
                colorMap,
              ),
              isDark: isDark,
              textColor: textColor,
              mutedColor: mutedColor,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
            ),
          );
        }),
      ],
    );
  }

  String _compactPrice(BuildContext context, double price) {
    return CurrencyFormatter.egp(context, price, withSuffixPerNight: true);
  }

  String _periodCountLabel(BuildContext context, int count) {
    final key = count == 1
        ? 'booking_pricing_periods_count'
        : 'booking_pricing_periods_count_plural';
    return context.tr(key).replaceAll('{count}', '$count');
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.period,
    required this.index,
    required this.accentColor,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceColor,
    required this.borderColor,
  });

  final PricingPeriod period;
  final int index;
  final Color accentColor;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM', Localizations.localeOf(context).languageCode);
    final fmtYear = DateFormat(
      'd MMM yyyy',
      Localizations.localeOf(context).languageCode,
    );
    final hasRealRange = period.id != 'base';
    final dateLabel = hasRealRange
        ? '${fmt.format(period.from)} — ${fmt.format(period.to)}'
        : context.tr('booking_pricing_base_rate');
    final nights = period.nightCount;
    final showYear =
        hasRealRange &&
        (period.from.year != period.to.year ||
            period.from.year != DateTime.now().year);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.date_range_rounded, size: 15, color: mutedColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  dateLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (showYear) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${fmtYear.format(period.from)} → ${fmtYear.format(period.to)}',
                              style: TextStyle(fontSize: 11, color: mutedColor),
                            ),
                          ],
                          if (hasRealRange && nights > 0) ...[
                            const SizedBox(height: 6),
                            Text(
                              context
                                  .tr('booking_pricing_period_nights')
                                  .replaceAll('{nights}', '$nights'),
                              style: TextStyle(fontSize: 12, color: mutedColor),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.egp(context, period.price),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '/ ${context.tr('common_night')}',
                          style: TextStyle(fontSize: 11, color: mutedColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarActionCard extends StatelessWidget {
  const _CalendarActionCard({
    required this.hasDates,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.onTap,
  });

  final bool hasDates;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = BookingDateStepView._accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: surfaceColor,
            border: Border.all(
              color: hasDates ? accent.withValues(alpha: 0.55) : borderColor,
              width: hasDates ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: hasDates ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    hasDates
                        ? Icons.edit_calendar_rounded
                        : Icons.calendar_month_rounded,
                    color: accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasDates
                            ? context.tr('booking_tap_to_change_dates')
                            : context.tr('booking_open_calendar_title'),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('booking_open_calendar_hint'),
                        style: TextStyle(color: mutedColor, fontSize: 13, height: 1.35),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: hasDates ? accent : mutedColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingSelectedDatesSummary extends StatelessWidget {
  const _BookingSelectedDatesSummary({
    required this.state,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.onEdit,
  });

  final BookingWizardState state;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceColor;
  final Color borderColor;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(
      'd MMM yyyy',
      Localizations.localeOf(context).languageCode,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: surfaceColor,
        border: Border.all(
          color: BookingDateStepView._accent.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BookingDateStepView._accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: BookingDateStepView._accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('booking_dates_selected_title'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: BookingDateStepView._accent,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(context.tr('common_edit')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _dateRow(
            context.tr('booking_wizard_arrival'),
            dateFmt.format(state.startDate!),
          ),
          const SizedBox(height: 10),
          _dateRow(
            context.tr('booking_wizard_departure'),
            dateFmt.format(state.endDate!),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: borderColor),
          ),
          Text(
            context.tr('booking_wizard_pricing_on_next_step'),
            style: TextStyle(
              fontSize: 13,
              color: mutedColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(label, style: TextStyle(fontSize: 13, color: mutedColor)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
