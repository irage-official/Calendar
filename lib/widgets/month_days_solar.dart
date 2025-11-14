import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../providers/app_provider.dart';
import '../providers/event_provider.dart';
import '../utils/calendar_utils.dart';
import '../config/theme_roles.dart';
import 'day_widget_solar.dart';

/// Solar calendar month days widget - uses calculations (same as Gregorian)
class MonthDaysSolar extends StatefulWidget {
  final DateTime displayedMonth; // Gregorian DateTime; we derive Jalali year/month
  final DateTime selectedDate;
  final DateTime today;
  final Function(DateTime) onDateSelected;
  final bool isPersian;
  final bool isWeekView;
  final int visibleWeekIndex;

  const MonthDaysSolar({
    Key? key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.today,
    required this.onDateSelected,
    this.isPersian = false,
    this.isWeekView = false,
    this.visibleWeekIndex = 0,
  }) : super(key: key);

  @override
  State<MonthDaysSolar> createState() => _MonthDaysSolarState();
}

class _MonthDaysSolarState extends State<MonthDaysSolar> {
  List<DateTime> _monthDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthDates();
  }

  @override
  void didUpdateWidget(MonthDaysSolar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayedMonth != widget.displayedMonth ||
        oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.today != widget.today) {
      _loadMonthDates();
    }
  }

  Future<void> _loadMonthDates() async {
    setState(() => _isLoading = true);
    
    // Use solar calendar system for both solar and shahanshahi (they're the same, only year differs)
    const calendarSystem = 'solar';
    
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
      return const SizedBox.shrink();
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
    // Use solar calendar system for both solar and shahanshahi (they're the same, only year differs)
    const calendarSystem = 'solar';
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
            // Solar calendar: main = Solar (Jalali) day; equivalent = Gregorian day
            final jalali = CalendarUtils.gregorianToJalali(date);
            mainDate = jalali.day.toString();
            if (isPersianLang) {
              mainDate = CalendarUtils.englishToPersianDigits(mainDate);
            }
            // Equivalent is Gregorian day
            equivalentDate = date.day.toString();
        
            // Normalize date
            final normalizedDate = DateTime(date.year, date.month, date.day);
            
            // Check if date is in current month (for solar/shahanshahi, compare Jalali months)
            // Use solar calendar system for both solar and shahanshahi (they're the same, only year differs)
            const calendarSystem = 'solar';
            final isCurrentMonth = CalendarUtils.isCurrentMonth(date, widget.displayedMonth, calendarSystem: calendarSystem);
            
            final isSelected = normalizedDate.year == selectedDateNonNull.year &&
                normalizedDate.month == selectedDateNonNull.month &&
                normalizedDate.day == selectedDateNonNull.day;
            
            final isToday = normalizedDate.year == widget.today.year &&
                normalizedDate.month == widget.today.month &&
                normalizedDate.day == widget.today.day;
            
            // For Solar calendar: Friday is off day
            final isOffDay = date.weekday == DateTime.friday;
            
            // Get event colors for this date (using Solar date)
            final eventProvider = Provider.of<EventProvider>(context, listen: false);
            final eventColors = eventProvider.getEventColorsForSolarDate(
              jalali.year,
              jalali.month,
              jalali.day,
            );
            
            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: DayWidgetSolar(
                  mainDate: mainDate,
                  equivalentDate: equivalentDate.isNotEmpty ? equivalentDate : null,
                  isSelected: isSelected,
                  isToday: isToday,
                  isCurrentMonth: isCurrentMonth,
                  weekdayGregorian: date.weekday,
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


