import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:rebtal/core/utils/helper/chalet_booked_calendar_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/booking/widgets/booking_pricing_ui_helper.dart';

bool _rangeCrossesBlocked(
  DateTime start,
  DateTime end,
  Set<DateTime> booked,
  Set<DateTime> pending,
) {
  var c = chaletDateOnly(start);
  final e = chaletDateOnly(end);
  final lo = c.isBefore(e) ? c : e;
  var hi = c.isBefore(e) ? e : c;
  var x = lo;
  while (!x.isAfter(hi)) {
    if (booked.contains(x) || pending.contains(x)) return true;
    x = x.add(const Duration(days: 1));
  }
  return false;
}

typedef BookingDayPriceResolver = double? Function(DateTime day);

Future<DateTimeRange?> showBookingTableRangePicker(
  BuildContext context, {
  required DateTime firstDate,
  required DateTime lastDate,
  required Set<DateTime> bookedDays,
  Set<DateTime> pendingDays = const {},
  DateTimeRange? initialRange,
  BookingDayPriceResolver? dayPriceFor,
  Future<ChaletCalendarOccupancy>? occupancyFuture,
}) {
  return showModalBottomSheet<DateTimeRange>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (sheetContext) => _BookingTableRangePickerBody(
      firstDate: chaletDateOnly(firstDate),
      lastDate: chaletDateOnly(lastDate),
      bookedDays: bookedDays,
      pendingDays: pendingDays,
      initialRange: initialRange == null
          ? null
          : DateTimeRange(
              start: chaletDateOnly(initialRange.start),
              end: chaletDateOnly(initialRange.end),
            ),
      dayPriceFor: dayPriceFor,
      occupancyFuture: occupancyFuture,
    ),
  );
}

class _BookingTableRangePickerBody extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final Set<DateTime> bookedDays;
  final Set<DateTime> pendingDays;
  final DateTimeRange? initialRange;
  final BookingDayPriceResolver? dayPriceFor;
  final Future<ChaletCalendarOccupancy>? occupancyFuture;

  const _BookingTableRangePickerBody({
    required this.firstDate,
    required this.lastDate,
    required this.bookedDays,
    required this.pendingDays,
    this.initialRange,
    this.dayPriceFor,
    this.occupancyFuture,
  });

  @override
  State<_BookingTableRangePickerBody> createState() =>
      _BookingTableRangePickerBodyState();
}

class _BookingTableRangePickerBodyState
    extends State<_BookingTableRangePickerBody> {
  late DateTime _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late Set<DateTime> _bookedDays;
  late Set<DateTime> _pendingDays;
  bool _occupancyRefreshing = false;

  @override
  void initState() {
    super.initState();
    _bookedDays = Set<DateTime>.from(widget.bookedDays);
    _pendingDays = Set<DateTime>.from(widget.pendingDays);
    final i = widget.initialRange;
    if (i != null) {
      _rangeStart = chaletDateOnly(i.start);
      _rangeEnd = chaletDateOnly(i.end);
      _focusedDay = _rangeStart!;
    } else {
      _focusedDay = widget.firstDate;
    }
    _loadOccupancyIfNeeded();
  }

  Future<void> _loadOccupancyIfNeeded() async {
    final future = widget.occupancyFuture;
    if (future == null) return;
    setState(() => _occupancyRefreshing = true);
    try {
      final occupancy = await future;
      if (!mounted) return;
      setState(() {
        _bookedDays = Set<DateTime>.from(occupancy.confirmedBooked);
        _pendingDays = Set<DateTime>.from(occupancy.pendingReview);
        _occupancyRefreshing = false;
      });
    } catch (_) {
      if (mounted) setState(() => _occupancyRefreshing = false);
    }
  }

  bool _inBounds(DateTime d) {
    final x = chaletDateOnly(d);
    return !x.isBefore(widget.firstDate) && !x.isAfter(widget.lastDate);
  }

  bool _isBooked(DateTime d) => _bookedDays.contains(chaletDateOnly(d));

  bool _isPending(DateTime d) => _pendingDays.contains(chaletDateOnly(d));

  BookingDayAvailability _availability(DateTime d) {
    if (!_inBounds(d)) return BookingDayAvailability.unavailable;
    if (_isBooked(d)) return BookingDayAvailability.booked;
    if (_isPending(d)) return BookingDayAvailability.pending;
    return BookingDayAvailability.available;
  }

  bool _isRangeDay(DateTime d) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    final x = chaletDateOnly(d);
    final a = chaletDateOnly(_rangeStart!);
    final b = chaletDateOnly(_rangeEnd!);
    final lo = a.isBefore(b) ? a : b;
    final hi = a.isBefore(b) ? b : a;
    return !x.isBefore(lo) && !x.isAfter(hi);
  }

  bool _isRangeEndpoint(DateTime d) {
    if (_rangeStart == null && _rangeEnd == null) return false;
    final x = chaletDateOnly(d);
    return (_rangeStart != null && x == chaletDateOnly(_rangeStart!)) ||
        (_rangeEnd != null && x == chaletDateOnly(_rangeEnd!));
  }

  void _handleDayTap(DateTime selectedDay, DateTime focusedDay) {
    final day = chaletDateOnly(selectedDay);
    if (!_inBounds(day) || _isBooked(day) || _isPending(day)) return;

    setState(() {
      if (_rangeStart == null) {
        _rangeStart = day;
        _rangeEnd = null;
      } else if (_rangeEnd == null) {
        final start = chaletDateOnly(_rangeStart!);
        if (day == start) {
          _rangeEnd = day;
        } else if (day.isBefore(start)) {
          _rangeEnd = _rangeStart;
          _rangeStart = day;
        } else {
          _rangeEnd = day;
        }
      } else {
        _rangeStart = day;
        _rangeEnd = null;
      }
      _focusedDay = focusedDay;
    });

    if (_rangeStart != null &&
        _rangeEnd != null &&
        _rangeCrossesBlocked(
          _rangeStart!,
          _rangeEnd!,
          _bookedDays,
          _pendingDays,
        )) {
      if (mounted) {
        final msg = _rangeIncludesPending(_rangeStart!, _rangeEnd!)
            ? context.tr('booking_range_invalid_pending')
            : context.tr('booking_range_invalid_booked');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
      setState(() {
        _rangeStart = null;
        _rangeEnd = null;
      });
    }
  }

  bool _rangeIncludesPending(DateTime start, DateTime end) {
    var c = chaletDateOnly(start);
    final e = chaletDateOnly(end);
    final lo = c.isBefore(e) ? c : e;
    var hi = c.isBefore(e) ? e : c;
    var x = lo;
    while (!x.isAfter(hi)) {
      if (_pendingDays.contains(x)) return true;
      x = x.add(const Duration(days: 1));
    }
    return false;
  }

  bool get _canSave => _rangeStart != null && _rangeEnd != null;

  void _confirmSelection() {
    if (!_canSave) return;

    var a = chaletDateOnly(_rangeStart!);
    var b = chaletDateOnly(_rangeEnd!);
    if (b.isBefore(a)) {
      final t = a;
      a = b;
      b = t;
    }

    if (_rangeCrossesBlocked(a, b, _bookedDays, _pendingDays)) {
      final msg = _rangeIncludesPending(a, b)
          ? context.tr('booking_range_invalid_pending')
          : context.tr('booking_range_invalid_booked');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      return;
    }

    var checkout = b;
    if (a == b) {
      checkout = a.add(const Duration(days: 1));
    }

    Navigator.of(context).pop(DateTimeRange(start: a, end: checkout));
  }

  Widget _dayCell(BuildContext context, DateTime day) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availability = _availability(day);
    final price = availability == BookingDayAvailability.booked
        ? null
        : widget.dayPriceFor?.call(chaletDateOnly(day));

    return BookingCalendarDayCell(
      day: day,
      price: price,
      availability: availability,
      isSelected: _isRangeEndpoint(day),
      isInRange: _isRangeDay(day) && !_isRangeEndpoint(day),
      isDark: isDark,
    );
  }

  List<MapEntry<double, Color>> _legendPriceTiers() {
    final prices = <double>{};
    var cursor = widget.firstDate;
    while (!cursor.isAfter(widget.lastDate)) {
      final p = widget.dayPriceFor?.call(cursor);
      if (p != null && p > 0) prices.add(p);
      cursor = cursor.add(const Duration(days: 1));
    }
    if (prices.isEmpty) return const [];
    final sorted = prices.toList()..sort();
    final colorMap = BookingPricingUiHelper.tierColorMap(sorted);
    return BookingPricingUiHelper.legendEntries(sorted, colorMap);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF141820) : Colors.white;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      color: sheetBg,
      child: Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('booking_select_dates'),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (_occupancyRefreshing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: BookingPricingUiHelper.rangeAccent,
                  backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
            if (_rangeStart != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Padding(
                  key: ValueKey(_rangeEnd == null ? 'wait' : 'ready'),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      _rangeEnd == null
                          ? context.tr('booking_calendar_tap_again_same_day')
                          : context.tr('booking_calendar_range_ready'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _rangeEnd == null
                            ? BookingPricingUiHelper.pendingYellow
                            : BookingPricingUiHelper.rangeAccent,
                      ),
                    ),
                  ),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: sheetBg,
                        cardColor: sheetBg,
                        listTileTheme: ListTileThemeData(
                          tileColor: sheetBg,
                          selectedTileColor: sheetBg,
                          iconColor: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      child: TableCalendar<void>(
                      locale: Localizations.localeOf(context).toLanguageTag(),
                      firstDay: widget.firstDate,
                      lastDay: widget.lastDate,
                      focusedDay: _focusedDay,
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      rangeSelectionMode: RangeSelectionMode.disabled,
                      availableGestures: AvailableGestures.horizontalSwipe,
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      rowHeight: 52,
                      daysOfWeekHeight: 32,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        weekendStyle: TextStyle(
                          color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                        cellMargin: EdgeInsets.zero,
                        rangeHighlightColor: Colors.transparent,
                        rangeStartDecoration: BoxDecoration(),
                        rangeEndDecoration: BoxDecoration(),
                        defaultDecoration: BoxDecoration(),
                        todayDecoration: BoxDecoration(),
                        selectedDecoration: BoxDecoration(),
                        disabledDecoration: BoxDecoration(),
                      ),
                      enabledDayPredicate: (day) {
                        if (!_inBounds(day)) return false;
                        return !_isBooked(day) && !_isPending(day);
                      },
                      calendarBuilders: CalendarBuilders<void>(
                        defaultBuilder: (ctx, day, _) => _dayCell(ctx, day),
                        todayBuilder: (ctx, day, _) => _dayCell(ctx, day),
                        disabledBuilder: (ctx, day, _) => _dayCell(ctx, day),
                        outsideBuilder: (ctx, day, _) => _dayCell(ctx, day),
                        selectedBuilder: (ctx, day, _) => _dayCell(ctx, day),
                        rangeStartBuilder: (ctx, day, _) => _dayCell(ctx, day),
                        rangeEndBuilder: (ctx, day, _) => _dayCell(ctx, day),
                        withinRangeBuilder: (ctx, day, _) => _dayCell(ctx, day),
                      ),
                      onDaySelected: _handleDayTap,
                      onPageChanged: (f) => setState(() => _focusedDay = f),
                    ),
                    ),
                    const SizedBox(height: 12),
                    BookingCalendarLegend(
                      isDark: isDark,
                      tierEntries: _legendPriceTiers(),
                      showInstructions: true,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1218) : const Color(0xFFF9FAFB),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(context.tr('common_cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: BookingPricingUiHelper.rangeAccent,
                          disabledBackgroundColor:
                              isDark ? Colors.white12 : Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _canSave ? _confirmSelection : null,
                        child: Text(
                          context.tr('common_save'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
