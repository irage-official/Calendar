import 'package:flutter/material.dart';
import 'weekdays_header.dart';
import 'month_days.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final DateTime today;
  final Function(DateTime) onDateSelected;
  final bool isPersian;
  final bool isWeekView; // NEW parameter
  final int visibleWeekIndex; // NEW parameter
  final bool shortWeekdays; // NEW parameter for short weekday names

  const CalendarWidget({
    Key? key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.today,
    required this.onDateSelected,
    this.isPersian = false,
    this.isWeekView = false, // Default to month view
    this.visibleWeekIndex = 0,
    this.shortWeekdays = false, // Default to full names
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isSolar = appProvider.calendarSystem == 'solar' ||
        appProvider.calendarSystem == 'shahanshahi';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Component 1: Week days header
        WeekdaysHeader(
            isPersian: isSolar,
            short: shortWeekdays), // Use short names if requested (e.g., in bottom sheet)

        // Gap between components: 16px
        const SizedBox(height: 16),

        // Component 2: Month days grid
        MonthDays(
          displayedMonth: displayedMonth,
          selectedDate: selectedDate,
          today: today,
          onDateSelected: onDateSelected,
          isWeekView: isWeekView,
          visibleWeekIndex: visibleWeekIndex,
        ),
      ],
    );
  }
}
