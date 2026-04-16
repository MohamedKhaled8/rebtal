import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:rebtal/core/utils/helper/chalet_booked_calendar_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

bool _rangeCrossesBooked(
  DateTime start,
  DateTime end,
  Set<DateTime> booked,
) {
  var c = chaletDateOnly(start);
  final e = chaletDateOnly(end);
  final lo = c.isBefore(e) ? c : e;
  var hi = c.isBefore(e) ? e : c;
  var x = lo;
  while (!x.isAfter(hi)) {
    if (booked.contains(x)) return true;
    x = x.add(const Duration(days: 1));
  }
  return false;
}

/// تقويم نطاق تواريخ: الأيام المحجوزة تظهر كدوائر حمراء «محددة» ولا تُقبل في النطاق.
Future<DateTimeRange?> showBookingTableRangePicker(
  BuildContext context, {
  required DateTime firstDate,
  required DateTime lastDate,
  required Set<DateTime> bookedDays,
  DateTimeRange? initialRange,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (ctx) => _BookingTableRangePickerBody(
      firstDate: chaletDateOnly(firstDate),
      lastDate: chaletDateOnly(lastDate),
      bookedDays: bookedDays,
      initialRange: initialRange == null
          ? null
          : DateTimeRange(
              start: chaletDateOnly(initialRange.start),
              end: chaletDateOnly(initialRange.end),
            ),
    ),
  );
}

class _BookingTableRangePickerBody extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final Set<DateTime> bookedDays;
  final DateTimeRange? initialRange;

  const _BookingTableRangePickerBody({
    required this.firstDate,
    required this.lastDate,
    required this.bookedDays,
    this.initialRange,
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

  static const _rangeGreen = Color(0xFF00D27F);
  static const _lockedRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    final i = widget.initialRange;
    if (i != null) {
      _rangeStart = i.start;
      _rangeEnd = i.end;
      _focusedDay = i.start;
    } else {
      _focusedDay = widget.firstDate;
    }
  }

  bool _inBounds(DateTime d) {
    final x = chaletDateOnly(d);
    return !x.isBefore(widget.firstDate) && !x.isAfter(widget.lastDate);
  }

  bool _isBooked(DateTime d) =>
      widget.bookedDays.contains(chaletDateOnly(d));

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    if (start != null && end != null) {
      if (_rangeCrossesBooked(start, end, widget.bookedDays)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('booking_range_invalid_booked')),
            ),
          );
        }
        setState(() {
          _rangeStart = null;
          _rangeEnd = null;
          _focusedDay = focusedDay;
        });
        return;
      }
    }
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: Row(
        children: [
          Expanded(
            child: Text(
              context.tr('booking_select_dates'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width.clamp(300, 420),
          child: TableCalendar<void>(
            locale: Localizations.localeOf(context).toLanguageTag(),
            firstDay: widget.firstDate,
            lastDay: widget.lastDate,
            focusedDay: _focusedDay,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: RangeSelectionMode.enforced,
            availableGestures: AvailableGestures.horizontalSwipe,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: isDark ? Colors.white : Colors.black54,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white : Colors.black54,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: isDark ? Colors.white60 : Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(4),
              rangeHighlightColor: _rangeGreen.withValues(alpha: 0.22),
              rangeStartDecoration: const BoxDecoration(
                color: _rangeGreen,
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: const BoxDecoration(
                color: _rangeGreen,
                shape: BoxShape.circle,
              ),
              withinRangeTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              defaultTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              weekendTextStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              disabledTextStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            enabledDayPredicate: (day) {
              if (!_inBounds(day)) return false;
              return !_isBooked(day);
            },
            calendarBuilders: CalendarBuilders<void>(
              disabledBuilder: (context, day, focusedDay) {
                if (_isBooked(day)) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _lockedRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            onRangeSelected: _onRangeSelected,
            onPageChanged: (f) => setState(() => _focusedDay = f),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('common_cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _rangeGreen),
          onPressed: _rangeStart != null && _rangeEnd != null
              ? () {
                  var a = chaletDateOnly(_rangeStart!);
                  var b = chaletDateOnly(_rangeEnd!);
                  if (b.isBefore(a)) {
                    final t = a;
                    a = b;
                    b = t;
                  }
                  if (_rangeCrossesBooked(a, b, widget.bookedDays)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('booking_range_invalid_booked')),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, DateTimeRange(start: a, end: b));
                }
              : null,
          child: Text(context.tr('common_save')),
        ),
      ],
    );
  }
}
