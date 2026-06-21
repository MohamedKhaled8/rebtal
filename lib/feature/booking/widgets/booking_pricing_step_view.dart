import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/booking/logic/wizard_cubit/booking_wizard_state.dart';

/// Step 2 — nightly price breakdown with total.
class BookingPricingStepView extends StatelessWidget {
  const BookingPricingStepView({
    super.key,
    required this.state,
    required this.isDark,
  });

  final BookingWizardState state;
  final bool isDark;

  static const _accent = Color(0xFF00D27F);

  Color get _text => isDark ? Colors.white : const Color(0xFF111827);
  Color get _muted => isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
  Color get _surface => isDark ? const Color(0xFF1C1C1E) : Colors.white;
  Color get _border => isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(
      'EEEE، d MMM yyyy',
      Localizations.localeOf(context).languageCode,
    );
    final shortFmt = DateFormat(
      'd MMM',
      Localizations.localeOf(context).languageCode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('booking_wizard_pricing_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _text,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('booking_wizard_pricing_subtitle'),
                style: TextStyle(fontSize: 14, color: _muted, height: 1.4),
              ),
              if (state.startDate != null && state.endDate != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.date_range_rounded, size: 18, color: _muted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${shortFmt.format(state.startDate!)} — ${shortFmt.format(state.endDate!)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: _text,
                          ),
                        ),
                      ),
                      Text(
                        '${state.nights} ${context.tr('booking_wizard_nights')}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            itemCount: state.nightlyBreakdown.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final line = state.nightlyBreakdown[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _accent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFmt.format(line.date),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('booking_one_night_stay'),
                            style: TextStyle(fontSize: 12, color: _muted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.egp(context, line.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: _accent,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6),
            border: Border(top: BorderSide(color: _border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('booking_total_label').replaceAll(':', ''),
                      style: TextStyle(
                        fontSize: 13,
                        color: _muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.egp(context, state.totalAmount),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: _text,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${state.nights} ${context.tr('booking_wizard_nights')}',
                  style: const TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
