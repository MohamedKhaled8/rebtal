import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/model/pricing_period.dart';
import 'package:rebtal/core/utils/services/chalet_pricing_service.dart';
import 'package:rebtal/feature/booking/logic/wizard_cubit/booking_wizard_state.dart';
import 'package:rebtal/feature/booking/widgets/booking_pricing_ui_helper.dart';

const _kAccent = Color(0xFF00D27F);
const _kCyan = Color(0xFF22D3EE);

/// Redesigned date-selection step for the booking wizard.
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

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final hasDates = state.isDatesSelected;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BookingStepHeroHeader(
            chaletName: chaletName,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 20),
          _BookingPeriodsStrip(requestData: requestData, isDark: isDark),
          const SizedBox(height: 20),
          _BookingCalendarLaunchButton(
            hasDates: hasDates,
            isDark: isDark,
            onTap: onOpenCalendar,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: hasDates
                ? Padding(
                    key: ValueKey(
                      '${state.startDate}_${state.endDate}_${state.totalAmount}',
                    ),
                    padding: const EdgeInsets.only(top: 16),
                    child: _BookingSelectedDatesSummary(
                      state: state,
                      isDark: isDark,
                      textColor: textColor,
                      onEdit: onOpenCalendar,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no_dates')),
          ),
        ],
      ),
    );
  }
}

class _BookingStepHeroHeader extends StatelessWidget {
  const _BookingStepHeroHeader({
    required this.chaletName,
    required this.isDark,
    required this.textColor,
  });

  final String chaletName;
  final bool isDark;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  const Color(0xFF0D3D2E),
                  const Color(0xFF0F172A),
                  const Color(0xFF1E1B4B).withValues(alpha: 0.6),
                ]
              : [
                  const Color(0xFFECFDF5),
                  const Color(0xFFE0F2FE),
                  Colors.white,
                ],
        ),
        border: Border.all(
          color: _kAccent.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kAccent, _kCyan]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('booking_select_trip_date'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      context.tr('booking_wizard_select_dates_desc'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (chaletName.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.villa_rounded, size: 18, color: _kAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chaletName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _BookingPeriodsStrip extends StatelessWidget {
  const _BookingPeriodsStrip({required this.requestData, required this.isDark});

  final Map<String, dynamic> requestData;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final periods = ChaletPricingService.withDiscountedDisplay(
      requestData,
      ChaletPricingService.periodsFromChalet(requestData),
    );
    if (periods.isEmpty) return const SizedBox.shrink();

    final prices = periods.map((p) => p.price).toList();
    final colorMap = BookingPricingUiHelper.tierColorMap(prices);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('booking_pricing_periods_title'),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: periods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final p = periods[i];
              final color = BookingPricingUiHelper.colorForPrice(
                p.price,
                colorMap,
              );
              return _PeriodCompactChip(
                period: p,
                color: color,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PeriodCompactChip extends StatelessWidget {
  const _PeriodCompactChip({
    required this.period,
    required this.color,
    required this.isDark,
  });

  final PricingPeriod period;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            BookingPricingUiHelper.periodDateRange(context, period),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.egp(
              context,
              period.price,
              withSuffixPerNight: true,
            ),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCalendarLaunchButton extends StatefulWidget {
  const _BookingCalendarLaunchButton({
    required this.hasDates,
    required this.isDark,
    required this.onTap,
  });

  final bool hasDates;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_BookingCalendarLaunchButton> createState() =>
      _BookingCalendarLaunchButtonState();
}

class _BookingCalendarLaunchButtonState
    extends State<_BookingCalendarLaunchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: widget.hasDates
                  ? [const Color(0xFF059669), const Color(0xFF0891B2)]
                  : [_kAccent, const Color(0xFF6366F1)],
            ),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) {
                    final scale = widget.hasDates
                        ? 1.0
                        : 1.0 + _pulse.value * 0.06;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hasDates
                            ? context.tr('booking_tap_to_change_dates')
                            : context.tr('booking_open_calendar_title'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        context.tr('booking_open_calendar_hint'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 18,
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
    required this.onEdit,
  });

  final BookingWizardState state;
  final bool isDark;
  final Color textColor;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(
      'd MMM',
      Localizations.localeOf(context).languageCode,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border.all(color: _kAccent.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: _kAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('booking_dates_selected_title'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                child: Text(context.tr('common_edit')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _datePill(
                  context,
                  label: context.tr('booking_wizard_arrival'),
                  value: dateFmt.format(state.startDate!),
                  color: const Color(0xFF22C55E),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: isDark ? Colors.white38 : Colors.grey,
                  size: 20,
                ),
              ),
              Expanded(
                child: _datePill(
                  context,
                  label: context.tr('booking_wizard_departure'),
                  value: dateFmt.format(state.endDate!),
                  color: const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kAccent.withValues(alpha: 0.12),
                  _kCyan.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.nights} ${context.tr('booking_wizard_nights')}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                Text(
                  CurrencyFormatter.egp(context, state.totalAmount),
                  style: const TextStyle(
                    color: _kAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePill(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
