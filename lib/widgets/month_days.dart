import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/app_provider.dart';
import '../providers/event_provider.dart';
import '../utils/calendar_utils.dart';
import 'day_widget.dart';

class MonthDays extends StatefulWidget {
  const MonthDays({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.today,
    required this.onDateSelected,
    this.isWeekView = false,
    this.visibleWeekIndex = 0,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final DateTime today;
  final bool isWeekView;
  final int visibleWeekIndex;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<MonthDays> createState() => _MonthDaysState();
}

class _MonthDaysState extends State<MonthDays> {
  List<List<DateTime>> _weeks = const [];
  bool _isLoading = true;

  DateTime? _cachedDisplayedMonth;
  String? _cachedCalendarSystem;
  String? _cachedStartWeekOn;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appProvider = Provider.of<AppProvider>(context);

    final shouldReload = _cachedDisplayedMonth == null ||
        _cachedDisplayedMonth != widget.displayedMonth ||
        _cachedCalendarSystem != appProvider.calendarSystem ||
        _cachedStartWeekOn != appProvider.effectiveStartWeekOn;

    if (shouldReload) {
      _cachedDisplayedMonth = widget.displayedMonth;
      _cachedCalendarSystem = appProvider.calendarSystem;
      _cachedStartWeekOn = appProvider.effectiveStartWeekOn;
      _loadMonthDates(appProvider);
    }
  }

  @override
  void didUpdateWidget(MonthDays oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayedMonth != widget.displayedMonth) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      _cachedDisplayedMonth = widget.displayedMonth;
      _loadMonthDates(appProvider);
    }
  }

  Future<void> _loadMonthDates(AppProvider appProvider) async {
    setState(() => _isLoading = true);
    try {
      final monthDates = await CalendarUtils.getMonthDates(
        widget.displayedMonth,
        calendarSystem: appProvider.calendarSystem,
        startWeekOn: appProvider.effectiveStartWeekOn,
      );
      final weeks = _groupIntoWeeks(
        monthDates,
        appProvider.calendarSystem,
        widget.displayedMonth,
      );
      if (!mounted) return;
      setState(() {
        _weeks = weeks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<List<DateTime>> _groupIntoWeeks(
    List<DateTime> dates,
    String calendarSystem,
    DateTime displayedMonth,
  ) {
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < dates.length; i += 7) {
      final end = (i + 7 > dates.length) ? dates.length : i + 7;
      weeks.add(dates.sublist(i, end));
    }

    // Filter out the last week if all days belong to the next month
    final filteredWeeks = <List<DateTime>>[];
    for (int i = 0; i < weeks.length; i++) {
      final week = weeks[i];
      final isLastWeek = i == weeks.length - 1;
      if (isLastWeek) {
        final allFromNextMonth = week.every(
          (date) => !CalendarUtils.isCurrentMonth(
            date,
            displayedMonth,
            calendarSystem: calendarSystem,
          ),
        );
        if (allFromNextMonth) {
          break;
        }
      }
      filteredWeeks.add(week);
    }
    return filteredWeeks;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_weeks.isEmpty) {
      return const SizedBox.shrink();
    }

    final weeksToDisplay = widget.isWeekView
        ? [_weeks[_clampWeekIndex(widget.visibleWeekIndex, _weeks.length)]]
        : _weeks;

    return Column(
      children: [
        for (int weekIndex = 0;
            weekIndex < weeksToDisplay.length;
            weekIndex++) ...[
          _buildWeekRow(weeksToDisplay[weekIndex]),
          if (weekIndex < weeksToDisplay.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  int _clampWeekIndex(int index, int length) {
    if (length <= 1) return 0;
    return index.clamp(0, length - 1);
  }

  Widget _buildWeekRow(List<DateTime> weekDates) {
    return Consumer2<AppProvider, EventProvider>(
      builder: (context, appProvider, eventProvider, child) {
        final calendarSystem = appProvider.calendarSystem;
        final language = appProvider.effectiveLanguage;
        final daysOff = appProvider.effectiveDaysOff;
        // If null, all origins are enabled by default
        final enabledOrigins = appProvider.enabledOrigins ??
            ['iranian', 'international', 'mixed', 'local'];
        // Calendar donuts filter by both origins AND event types
        // If an event type is disabled, its donut should not appear in calendar
        final enabledEventTypes = appProvider.enabledEventTypes;
        final showEquivalent =
            calendarSystem == 'solar' || calendarSystem == 'shahanshahi'
                ? appProvider.showGregorianDates
                : true;

        return Row(
          children: weekDates.map((date) {
            final events = _eventsForDate(
              date,
              calendarSystem,
              eventProvider,
            );

            final model = DayWidgetBuilder.build(
              DayWidgetConfig(
                date: date,
                displayedMonth: widget.displayedMonth,
                selectedDate: widget.selectedDate,
                today: widget.today,
                calendarSystem: calendarSystem,
                language: language,
                daysOff: daysOff,
                showEquivalentDate: showEquivalent,
                showEventIndicators: true,
                events: events,
                enabledOrigins: enabledOrigins,
                // Pass enabledTypes - calendar donuts filter by both origins and types
                enabledTypes: enabledEventTypes.isNotEmpty ? enabledEventTypes : null,
              ),
            );

            return Expanded(
              child: DayWidget(
                model: model,
                onTap: () => widget.onDateSelected(date),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  List<Event> _eventsForDate(
    DateTime date,
    String calendarSystem,
    EventProvider eventProvider,
  ) {
    if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
      final jalali = CalendarUtils.gregorianToJalali(date);
      return eventProvider.getEventsForSolarDate(
        jalali.year,
        jalali.month,
        jalali.day,
      );
    }
    return eventProvider.getEventsForDate(date);
  }
}
