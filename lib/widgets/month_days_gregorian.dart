import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/calendar_utils.dart';
import '../providers/app_provider.dart';
import '../providers/event_provider.dart';
import '../config/theme_roles.dart';
import 'day_widget_gregorian.dart';

class MonthDaysGregorian extends StatefulWidget {
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final DateTime today;
  final Function(DateTime) onDateSelected;
  final bool isPersian;
  final bool isWeekView; // NEW parameter
  final int visibleWeekIndex; // NEW parameter - which week to show (0-5)

  const MonthDaysGregorian({
    Key? key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.today,
    required this.onDateSelected,
    this.isPersian = false,
    this.isWeekView = false, // Default to month view
    this.visibleWeekIndex = 0,
  }) : super(key: key);

  @override
  State<MonthDaysGregorian> createState() => _MonthDaysGregorianState();
}

class _MonthDaysGregorianState extends State<MonthDaysGregorian> {
  List<DateTime> _monthDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthDates();
  }

  @override
  void didUpdateWidget(MonthDaysGregorian oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayedMonth != widget.displayedMonth) {
      _loadMonthDates();
    }
  }

  Future<void> _loadMonthDates() async {
    setState(() => _isLoading = true);
    
    // Gregorian-only
    const calendarSystem = 'gregorian';
    
    try {
      final monthDates = await CalendarUtils.getMonthDates(
        widget.displayedMonth,
        calendarSystem: calendarSystem,
      );
      
      if (mounted) {
        setState(() {
          _monthDates = monthDates;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading month dates: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink(); // Or a loading indicator
    }
    
    return _buildCalendarGrid(_monthDates);
  }

  Widget _buildCalendarGrid(List<DateTime> monthDates) {
    // Group dates by weeks
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < monthDates.length; i += 7) {
      weeks.add(monthDates.sublist(i, (i + 7 > monthDates.length) ? monthDates.length : i + 7));
    }

    // Filter out the last week if all its days belong to next month (don't show extra 6th week)
    // Gregorian-only
    const calendarSystem = 'gregorian';
    final filteredWeeks = <List<DateTime>>[];
    for (int i = 0; i < weeks.length; i++) {
      final week = weeks[i];
      // Check if this is the last week and if all days belong to next month
      if (i == weeks.length - 1) {
        // Check if all days in the last week belong to next month
        final allDaysFromNextMonth = week.every((date) => !CalendarUtils.isCurrentMonth(date, widget.displayedMonth, calendarSystem: calendarSystem));
        if (allDaysFromNextMonth) {
          // Skip this week - it's an extra 6th week that belongs entirely to next month
          break;
        }
      }
      filteredWeeks.add(week);
    }

    // If week view: show only the selected week
    // If month view: show filtered weeks (without extra 6th week)
    final weeksToDisplay = widget.isWeekView 
        ? [filteredWeeks[widget.visibleWeekIndex.clamp(0, filteredWeeks.length - 1)]] 
        : filteredWeeks;

    return Column(
      children: [
        for (int weekIndex = 0; weekIndex < weeksToDisplay.length; weekIndex++) ...[
          // Week row
          _buildWeekRow(weeksToDisplay[weekIndex]),
          
          // Add spacing between weeks (except for the last week)
          if (weekIndex < weeksToDisplay.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildWeekRow(List<DateTime> weekDates) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Row(
          children: weekDates.map((date) {
            final selectedDateNonNull = widget.selectedDate;
            
            // Convert date to appropriate format based on calendar type and language
            String mainDate;
            String equivalentDate;
            
            final isPersianLang = appProvider.language == 'fa';
            // Gregorian-only: main = Gregorian day; equivalent = Jalali day
            mainDate = isPersianLang
                ? CalendarUtils.englishToPersianDigits(date.day.toString())
                : date.day.toString();
            final jalali = CalendarUtils.gregorianToJalali(date);
            equivalentDate = isPersianLang
                ? CalendarUtils.englishToPersianDigits(jalali.day.toString())
                : CalendarUtils.englishToPersianDigits(jalali.day.toString());
        
        // Normalize date
        final normalizedDate = DateTime(date.year, date.month, date.day);
        
        // Check if date is in current month
        final isCurrentMonth = CalendarUtils.isCurrentMonth(date, widget.displayedMonth, calendarSystem: 'gregorian');
        
        final isSelected = normalizedDate.year == selectedDateNonNull.year &&
            normalizedDate.month == selectedDateNonNull.month &&
            normalizedDate.day == selectedDateNonNull.day;
        
        final isToday = normalizedDate.year == widget.today.year &&
            normalizedDate.month == widget.today.month &&
            normalizedDate.day == widget.today.day;
        
        // For Gregorian calendar: Saturday and Sunday are off days
        final isOffDay = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
        
        // Get event colors for this date
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        final eventColors = eventProvider.getEventColorsForDate(date);
        
        return Expanded(
          child: GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: DayWidgetGregorian(
              mainDate: mainDate,
              equivalentDate: equivalentDate.isNotEmpty ? equivalentDate : null,
              isSelected: isSelected,
              isToday: isToday,
              isCurrentMonth: isCurrentMonth,
              weekday: date.weekday,
              isOffDay: isOffDay,
              eventIndicatorColors: eventColors,
            ),
          ),
        );
          }).toList(),
        );
      },
    );
  }
}
