import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../services/date_converter_service.dart';

class CalendarProvider extends ChangeNotifier {
  final DateConverterService _dateConverter = DateConverterService();
  
  // Current selected date (independent from today)
  DateTime _selectedDate = DateTime.now();
  
  // Today's date (fixed, never changes)
  DateTime _today = DateTime.now();
  
  // Current displayed month for calendar grid
  DateTime _displayedMonth = DateTime.now();
  
  // Current displayed week/month (legacy support)
  DateTime _currentWeekStart = DateTime.now();
  DateTime _currentMonthStart = DateTime.now();
  
  // Calendar view state
  bool _isCalendarExpanded = false;
  String _calendarView = 'month'; // Default to month view for new grid
  bool _isCalendarMinimized = false;
  
  // Week/Month view toggle state
  bool _isWeekView = true;
  
  // Year picker state
  bool _isYearPickerOpen = false;
  
  // Getters
  DateTime get selectedDate => _selectedDate;
  DateTime get today => _today;
  DateTime get displayedMonth => _displayedMonth;
  DateTime get currentWeekStart => _currentWeekStart;
  DateTime get currentMonthStart => _currentMonthStart;
  bool get isCalendarExpanded => _isCalendarExpanded;
  String get calendarView => _calendarView;
  bool get isCalendarMinimized => _isCalendarMinimized;
  bool get isYearPickerOpen => _isYearPickerOpen;
  bool get isWeekView => _isWeekView;
  
  // Jalali getters
  Jalali get selectedJalaliDate => _dateConverter.gregorianToJalali(_selectedDate);
  Jalali get todayJalaliDate => _dateConverter.gregorianToJalali(_today);
  Jalali get displayedJalaliMonth => _dateConverter.gregorianToJalali(_displayedMonth);
  Jalali get currentJalaliWeekStart => _dateConverter.gregorianToJalali(_currentWeekStart);
  Jalali get currentJalaliMonthStart => _dateConverter.gregorianToJalali(_currentMonthStart);
  
  // Check if selected date is today
  bool get isSelectedDateToday => _dateConverter.isGregorianToday(_selectedDate);
  
  // Check if selected date is in current week
  bool get isSelectedDateInCurrentWeek {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    return _selectedDate.isAfter(_currentWeekStart.subtract(const Duration(days: 1))) &&
           _selectedDate.isBefore(weekEnd.add(const Duration(days: 1)));
  }
  
  // Check if selected date is in current month
  bool get isSelectedDateInCurrentMonth {
    return _selectedDate.year == _currentMonthStart.year &&
           _selectedDate.month == _currentMonthStart.month;
  }

  // Set selected date
  // Note: This method doesn't know about calendar system, so it works with Gregorian dates
  // The caller should ensure displayedMonth is set correctly for solar calendar if needed
  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    
    // Update displayed month to show the selected date
    // Use Gregorian month start - for solar calendar, the calling code should handle conversion
    _displayedMonth = _dateConverter.getGregorianMonthStart(_selectedDate);
    
    // Update current week/month to show the selected date (legacy support)
    _currentWeekStart = _dateConverter.getGregorianWeekStart(_selectedDate);
    _currentMonthStart = _dateConverter.getGregorianMonthStart(_selectedDate);
    
    notifyListeners();
  }
  
  // Set selected date and update displayed month for solar calendar
  // This ensures displayedMonth matches the solar month of the selected date
  void setSelectedDateForSolar(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    
    // Convert selected date to Jalali
    final selectedJalali = _dateConverter.gregorianToJalali(_selectedDate);
    
    // Get first day of the solar month containing the selected date
    final firstDayJalali = Jalali(selectedJalali.year, selectedJalali.month, 1);
    final firstDayGregorian = _dateConverter.jalaliToGregorian(
      firstDayJalali.year, firstDayJalali.month, firstDayJalali.day);
    
    // Set displayedMonth to the Gregorian equivalent of the first day of the solar month
    _displayedMonth = firstDayGregorian;
    _currentMonthStart = firstDayGregorian;
    
    // Update week start
    _currentWeekStart = _dateConverter.getGregorianWeekStart(_selectedDate);
    
    notifyListeners();
  }

  // Select date (alias for setSelectedDate)
  void selectDate(DateTime date) {
    setSelectedDate(date);
  }

  // Set selected Jalali date
  void setSelectedJalaliDate(Jalali date) {
    final gregorianDate = _dateConverter.jalaliToGregorian(date.year, date.month, date.day);
    setSelectedDate(gregorianDate);
  }

  // Jump to today
  void jumpToToday() {
    _today = DateTime.now();
    _selectedDate = _today;
    _displayedMonth = _dateConverter.getGregorianMonthStart(_today);
    _currentWeekStart = _dateConverter.getGregorianWeekStart(_today);
    _currentMonthStart = _dateConverter.getGregorianMonthStart(_today);
    notifyListeners();
  }

  // Change displayed month
  void changeMonth(DateTime newMonth) {
    _displayedMonth = _dateConverter.getGregorianMonthStart(newMonth);
    notifyListeners();
  }

  // Navigate to previous week
  void goToPreviousWeek() {
    _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  // Navigate to next week
  void goToNextWeek() {
    _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  // Navigate to previous month
  void goToPreviousMonth() {
    _displayedMonth = _dateConverter.addMonthsToGregorian(_displayedMonth, -1);
    _currentMonthStart = _displayedMonth;
    notifyListeners();
  }

  // Navigate to next month
  void goToNextMonth() {
    _displayedMonth = _dateConverter.addMonthsToGregorian(_displayedMonth, 1);
    _currentMonthStart = _displayedMonth;
    notifyListeners();
  }

  // Navigate to specific week
  void goToWeek(DateTime weekStart) {
    _currentWeekStart = _dateConverter.getGregorianWeekStart(weekStart);
    notifyListeners();
  }

  // Navigate to specific month
  void goToMonth(DateTime monthStart) {
    _displayedMonth = _dateConverter.getGregorianMonthStart(monthStart);
    _currentMonthStart = _displayedMonth;
    notifyListeners();
  }

  // Toggle calendar expansion
  void toggleCalendarExpansion() {
    _isCalendarExpanded = !_isCalendarExpanded;
    notifyListeners();
  }

  // Set calendar expansion state
  void setCalendarExpansion(bool expanded) {
    _isCalendarExpanded = expanded;
    notifyListeners();
  }

  // Set calendar view
  void setCalendarView(String view) {
    _calendarView = view;
    notifyListeners();
  }

  // Set week view state
  void setWeekView(bool isWeek) {
    _isWeekView = isWeek;
    notifyListeners();
  }

  // Toggle between week and month view
  void toggleWeekView() {
    _isWeekView = !_isWeekView;
    notifyListeners();
  }

  // Minimize calendar (triggered by event scrolling)
  void minimizeCalendar() {
    _isCalendarMinimized = true;
    _isCalendarExpanded = false;
    notifyListeners();
  }

  // Restore calendar to normal state
  void restoreCalendar() {
    _isCalendarMinimized = false;
    notifyListeners();
  }

  // Toggle calendar minimization
  void toggleCalendarMinimization() {
    _isCalendarMinimized = !_isCalendarMinimized;
    if (_isCalendarMinimized) {
      _isCalendarExpanded = false;
    }
    notifyListeners();
  }

  // Get week dates
  List<DateTime> getWeekDates() {
    final dates = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      dates.add(_currentWeekStart.add(Duration(days: i)));
    }
    return dates;
  }

  // Get month dates
  List<DateTime> getMonthDates() {
    final dates = <DateTime>[];
    final monthStart = _currentMonthStart;
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
    
    // Add days from previous month to fill first week
    final firstWeekStart = _dateConverter.getGregorianWeekStart(monthStart);
    if (firstWeekStart.isBefore(monthStart)) {
      for (int i = 0; i < monthStart.difference(firstWeekStart).inDays; i++) {
        dates.add(firstWeekStart.add(Duration(days: i)));
      }
    }
    
    // Add days of current month
    for (int i = 1; i <= monthEnd.day; i++) {
      dates.add(DateTime(monthStart.year, monthStart.month, i));
    }
    
    // Add days from next month to fill last week
    final lastWeekEnd = monthEnd.add(Duration(days: 6 - monthEnd.weekday));
    for (int i = 1; i <= lastWeekEnd.difference(monthEnd).inDays; i++) {
      dates.add(monthEnd.add(Duration(days: i)));
    }
    
    return dates;
  }

  // Get Jalali week dates
  List<Jalali> getJalaliWeekDates() {
    return getWeekDates().map((date) => _dateConverter.gregorianToJalali(date)).toList();
  }

  // Get Jalali month dates
  List<Jalali> getJalaliMonthDates() {
    return getMonthDates().map((date) => _dateConverter.gregorianToJalali(date)).toList();
  }

  // Check if date is in current week
  bool isDateInCurrentWeek(DateTime date) {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    return date.isAfter(_currentWeekStart.subtract(const Duration(days: 1))) &&
           date.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  // Check if date is in current month
  bool isDateInCurrentMonth(DateTime date) {
    return date.year == _currentMonthStart.year &&
           date.month == _currentMonthStart.month;
  }

  // Get formatted date strings
  String getSelectedDateString({bool useJalali = true}) {
    if (useJalali) {
      return _dateConverter.formatJalaliDate(selectedJalaliDate);
    } else {
      return _dateConverter.formatGregorianDate(_selectedDate);
    }
  }

  String getTodayDateString({bool useJalali = true}) {
    if (useJalali) {
      return _dateConverter.formatJalaliDate(todayJalaliDate);
    } else {
      return _dateConverter.formatGregorianDate(_today);
    }
  }

  // Reset to current date
  void resetToCurrentDate() {
    final now = DateTime.now();
    _selectedDate = now;
    _today = now;
    _displayedMonth = _dateConverter.getGregorianMonthStart(now);
    _currentWeekStart = _dateConverter.getGregorianWeekStart(now);
    _currentMonthStart = _dateConverter.getGregorianMonthStart(now);
    notifyListeners();
  }

  // Year picker methods
  void openYearPicker() {
    _isYearPickerOpen = true;
    notifyListeners();
  }

  void closeYearPicker() {
    _isYearPickerOpen = false;
    notifyListeners();
  }

  void toggleYearPicker() {
    _isYearPickerOpen = !_isYearPickerOpen;
    notifyListeners();
  }

  // Navigate to specific year and month
  // Note: year and month are Gregorian when called from year picker
  // For solar calendar, they should already be converted from solar year/month
  void goToYearMonth(int year, int month) {
    // Create the first day of the Gregorian month
    final newMonthStart = DateTime(year, month, 1);
    _displayedMonth = newMonthStart;
    _currentMonthStart = newMonthStart;
    _currentWeekStart = _dateConverter.getGregorianWeekStart(newMonthStart);
    
    // Debug: verify the conversion for solar calendar
    if (_displayedMonth.year >= 2020 && _displayedMonth.year <= 2030) {
      final jalali = _dateConverter.gregorianToJalali(_displayedMonth);
      print('goToYearMonth: Gregorian $year-$month-01 -> Jalali ${jalali.year}-${jalali.month}-${jalali.day}');
    }
    
    notifyListeners();
  }

  // Get the week index (0-5) of the selected date in the displayed month
  // For solar/shahanshahi calendar, needs to work with solar dates properly
  int getWeekIndexOfSelectedDate({String? calendarSystem}) {
    if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
      // For solar calendar, calculate based on Jalali dates
      final selectedJalali = gregorianToJalali(_selectedDate);
      final displayedJalali = gregorianToJalali(_displayedMonth);
      
      // If selected date is in the displayed month
      if (selectedJalali.year == displayedJalali.year && 
          selectedJalali.month == displayedJalali.month) {
        // Calculate week index by finding which week contains the selected day
        // Solar calendar weeks start on Saturday
        // Get first day of month in Jalali and convert to Gregorian
        final firstDayJalali = Jalali(displayedJalali.year, displayedJalali.month, 1);
        final firstDayGregorian = _dateConverter.jalaliToGregorian(
          firstDayJalali.year, firstDayJalali.month, firstDayJalali.day);
        
        // Get week start for solar (Saturday) - this is the start of the first week containing the month
        final firstWeekStart = _getSolarWeekStart(firstDayGregorian);
        
        // Find the week start containing the selected date
        final selectedWeekStart = _getSolarWeekStart(_selectedDate);
        
        // Calculate which week index by counting weeks from first week start
        final daysFromFirstWeek = selectedWeekStart.difference(firstWeekStart).inDays;
        final weekIndex = (daysFromFirstWeek / 7).floor();
        
        // Clamp to valid range (0-5)
        return weekIndex >= 0 ? weekIndex.clamp(0, 5) : 0;
      }
      
      // If not in current month, return 0
      return 0;
    }
    
    // For Gregorian calendar, use existing logic
    final monthDates = _getMonthDatesForDisplayedMonth();
    
    // Group dates by weeks
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < monthDates.length; i += 7) {
      weeks.add(monthDates.sublist(i, (i + 7 > monthDates.length) ? monthDates.length : i + 7));
    }
    
    // Find which week contains the selected date
    for (int weekIndex = 0; weekIndex < weeks.length; weekIndex++) {
      final week = weeks[weekIndex];
      for (final date in week) {
        if (date.year == _selectedDate.year && 
            date.month == _selectedDate.month && 
            date.day == _selectedDate.day) {
          return weekIndex;
        }
      }
    }
    
    // Fallback: return 0 if not found
    return 0;
  }
  
  // Helper to get Saturday (week start for solar calendar)
  DateTime _getSolarWeekStart(DateTime date) {
    // Solar calendar week starts on Saturday
    // DateTime.weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
    final dayOfWeek = date.weekday;
    int daysToSubtract;
    if (dayOfWeek == 6) {
      daysToSubtract = 0; // Saturday
    } else if (dayOfWeek == 7) {
      daysToSubtract = 1; // Sunday
    } else {
      daysToSubtract = dayOfWeek + 1; // Monday-Friday
    }
    return date.subtract(Duration(days: daysToSubtract));
  }
  
  // Helper to convert Gregorian to Jalali (delegate to dateConverter)
  Jalali gregorianToJalali(DateTime date) {
    return _dateConverter.gregorianToJalali(date);
  }

  // Helper method to get month dates for the displayed month
  List<DateTime> _getMonthDatesForDisplayedMonth() {
    final dates = <DateTime>[];
    
    // Get the first day of the month
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    
    // Get the first day of the week containing the first day of month
    final firstWeekStart = _dateConverter.getGregorianWeekStart(firstDayOfMonth);
    
    // Add days from previous month to fill first week
    if (firstWeekStart.isBefore(firstDayOfMonth)) {
      for (int i = 0; i < firstDayOfMonth.difference(firstWeekStart).inDays; i++) {
        dates.add(firstWeekStart.add(Duration(days: i)));
      }
    }
    
    // Add days of current month
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      dates.add(DateTime(_displayedMonth.year, _displayedMonth.month, i));
    }
    
    // Add days from next month to fill last week
    final lastWeekEnd = lastDayOfMonth.add(Duration(days: 6 - lastDayOfMonth.weekday));
    for (int i = 1; i <= lastWeekEnd.difference(lastDayOfMonth).inDays; i++) {
      dates.add(lastDayOfMonth.add(Duration(days: i)));
    }
    
    return dates;
  }

  // Removed unnecessary override - parent dispose() is sufficient
}
