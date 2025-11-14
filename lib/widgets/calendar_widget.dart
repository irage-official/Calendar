import 'package:flutter/material.dart';
import 'weekdays_header.dart';
import 'month_days_gregorian.dart';
import 'month_days_solar.dart';
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

  const CalendarWidget({
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
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isSolar = appProvider.calendarSystem == 'solar' || appProvider.calendarSystem == 'shahanshahi';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Component 1: Week days header
        WeekdaysHeader(isPersian: isSolar), // Pass true for solar/shahanshahi calendar to ensure Saturday-first week
        
        // Gap between components: 16px
        const SizedBox(height: 16),
        
        // Component 2: Month days grid
        if (!isSolar)
          MonthDaysGregorian(
            displayedMonth: displayedMonth,
            selectedDate: selectedDate,
            today: today,
            onDateSelected: onDateSelected,
            isPersian: isPersian,
            isWeekView: isWeekView,
            visibleWeekIndex: visibleWeekIndex,
          )
        else
          MonthDaysSolar(
            displayedMonth: displayedMonth,
            selectedDate: selectedDate,
            today: today,
            onDateSelected: onDateSelected,
            isPersian: isPersian,
            isWeekView: isWeekView,
            visibleWeekIndex: visibleWeekIndex,
          ),
      ],
    );
  }
}
