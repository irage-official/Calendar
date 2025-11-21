import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../providers/calendar_provider.dart';
import '../providers/app_provider.dart';
import '../services/date_converter_service.dart';
import '../utils/calendar_utils.dart';
import 'calendar_header_widget.dart';
import 'calendar_widget.dart';
import 'year_picker_bottom_sheet.dart';

class CalendarBottomSheetWidget extends StatefulWidget {
  const CalendarBottomSheetWidget({super.key});

  @override
  State<CalendarBottomSheetWidget> createState() => _CalendarBottomSheetWidgetState();
}

class _CalendarBottomSheetWidgetState extends State<CalendarBottomSheetWidget> {
  int? _cachedWeekCount;
  DateTime? _cachedWeekCountMonth;
  String? _cachedCalendarSystem;
  String? _cachedStartWeekOn;
  String? _lastCalendarSystem;
  String? _lastStartWeekOn;
  List<String>? _lastDaysOff;
  String? _lastDefaultCalendarView;

  /// Helper function to compare two lists
  bool _listsEqual(List<String>? list1, List<String>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;
    final sorted1 = List<String>.from(list1)..sort();
    final sorted2 = List<String>.from(list2)..sort();
    return sorted1.toString() == sorted2.toString();
  }

  /// Calculate the appropriate height for the bottom sheet based on calendar content
  double _calculateBottomSheetHeight(BuildContext context, CalendarProvider calendarProvider, AppProvider appProvider) {
    // If calendar is minimized, return minimal height (just header)
    if (calendarProvider.isCalendarMinimized) {
      const double topPadding = 24.0;
      const double headerHeight = 64.0;
      const double bottomPadding = 16.0;
      return topPadding + headerHeight + bottomPadding;
    }
    
    // Top padding
    const double topPadding = 24.0;
    
    // Header section height (48px button + 8px padding top + 8px padding bottom)
    const double headerHeight = 64.0;
    
    // Gap between header and divider
    const double headerGap = 16.0;
    
    // Divider height (1px)
    const double dividerHeight = 1.0;
    
    // Gap between divider and weekdays
    const double dividerGap = 16.0;
    
    // Weekdays header height (8px padding top + 8px padding bottom + ~12px text)
    const double weekdaysHeaderHeight = 28.0;
    
    // Gap between weekdays header and month days
    const double weekdaysGap = 16.0;
    
    // Calculate actual number of weeks needed for the current month
    // Use cached value if available and calendar system/startWeekOn haven't changed
    final currentCalendarSystem = appProvider.calendarSystem;
    final currentStartWeekOn = appProvider.effectiveStartWeekOn;
    int actualWeeks;
    if (_cachedWeekCount != null && 
        _cachedWeekCountMonth == calendarProvider.displayedMonth &&
        _cachedCalendarSystem == currentCalendarSystem &&
        _cachedStartWeekOn == currentStartWeekOn) {
      actualWeeks = _cachedWeekCount!;
    } else {
      // Estimate: most months have 5 weeks, some have 6
      actualWeeks = 5;
      // Calculate async and cache for next time
      _updateWeekCount(calendarProvider, appProvider);
    }
    
    // Month days height calculation:
    // - Each week: 36px (cell) + 4px (event indicators) + 8px (spacing) = 48px
    // - Gap between weeks: 12px (n-1 gaps for n weeks)
    // - Use actual number of weeks, but if week view, only show 1 week
    final int weeksToShow = calendarProvider.isWeekView ? 1 : actualWeeks;
    const double gapBetweenWeeks = 12.0;
    final double monthDaysHeight = (weeksToShow * 44.0) + ((weeksToShow - 1) * gapBetweenWeeks);
    
    // Bottom padding - always 16px for consistency (added in Column, not here)
    const double bottomPadding = 16.0;
    
    // Total calculated height based on actual content
    final double calculatedHeight = topPadding + headerHeight + headerGap + dividerHeight + 
                                   dividerGap + weekdaysHeaderHeight + weekdaysGap + 
                                   monthDaysHeight + bottomPadding;
    
    // Screen height constraints
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxHeight = screenHeight * 0.7; // Maximum 70% of screen height
    
    // Return calculated height, clamped to max height only
    // No minimum height to avoid extra space
    return calculatedHeight.clamp(0, maxHeight);
  }

  /// Calculate and cache the actual number of weeks needed for the current displayed month
  Future<void> _updateWeekCount(CalendarProvider calendarProvider, AppProvider appProvider) async {
    try {
      final calendarSystem = appProvider.calendarSystem;
      final displayedMonth = calendarProvider.displayedMonth;
      final monthDates = await CalendarUtils.getMonthDates(
        displayedMonth,
        calendarSystem: calendarSystem,
        startWeekOn: appProvider.effectiveStartWeekOn,
      );
      
      // Group dates by weeks (same logic as in MonthDays._buildCalendarGrid)
      final weeks = <List<DateTime>>[];
      for (int i = 0; i < monthDates.length; i += 7) {
        weeks.add(monthDates.sublist(i, (i + 7 > monthDates.length) ? monthDates.length : i + 7));
      }
      
      // Filter out the last week if all its days belong to next month (don't show extra 6th week)
      final filteredWeeks = <List<DateTime>>[];
      for (int i = 0; i < weeks.length; i++) {
        final week = weeks[i];
        // Check if this is the last week and if all days belong to next month
        if (i == weeks.length - 1) {
          // Check if all days in the last week belong to next month
          final allDaysFromNextMonth = week.every((date) => !CalendarUtils.isCurrentMonth(date, displayedMonth, calendarSystem: calendarSystem));
          if (allDaysFromNextMonth) {
            // Skip this week - it's an extra 6th week that belongs entirely to next month
            break;
          }
        }
        filteredWeeks.add(week);
      }
      
      if (mounted) {
        setState(() {
          _cachedWeekCount = filteredWeeks.length;
          _cachedWeekCountMonth = displayedMonth;
          _cachedCalendarSystem = calendarSystem;
          _cachedStartWeekOn = appProvider.effectiveStartWeekOn;
        });
      }
    } catch (e) {
      // Ignore errors, use default estimate
    }
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final calendarProvider = context.read<CalendarProvider>();
      final appProvider = context.read<AppProvider>();
      _lastCalendarSystem = appProvider.calendarSystem;
      _lastStartWeekOn = appProvider.effectiveStartWeekOn;
      _lastDaysOff = List<String>.from(appProvider.effectiveDaysOff);
      _lastDefaultCalendarView = appProvider.defaultCalendarView;
      
      calendarProvider.syncFromAppSettings(
        calendarSystem: appProvider.calendarSystem,
        startWeekOn: appProvider.effectiveStartWeekOn,
        daysOff: appProvider.effectiveDaysOff,
      );
      // Initialize week view based on defaultCalendarView
      final defaultView = appProvider.defaultCalendarView;
      calendarProvider.applyDefaultCalendarView(
        defaultView,
        calendarSystem: appProvider.calendarSystem,
      );
      
      _updateWeekCount(calendarProvider, appProvider);
      
      // Listen to displayedMonth changes
      calendarProvider.addListener(() {
        final currentStartWeekOn = appProvider.effectiveStartWeekOn;
        if (calendarProvider.displayedMonth != _cachedWeekCountMonth ||
            _cachedStartWeekOn != currentStartWeekOn) {
          _updateWeekCount(calendarProvider, appProvider);
        }
      });
      
      // Listen to calendar system, startWeekOn, daysOff, and defaultCalendarView changes
      // Note: Language changes should NOT trigger calendar settings changes
      appProvider.addListener(() {
        final currentSystem = appProvider.calendarSystem;
        final currentStartWeekOn = appProvider.effectiveStartWeekOn;
        final currentDaysOff = appProvider.effectiveDaysOff;
        final currentDefaultView = appProvider.defaultCalendarView;
        
        // Only sync settings if calendar system, startWeekOn, or daysOff actually changed
        final hasCalendarSettingsChanged = 
            _lastCalendarSystem != currentSystem ||
            _lastStartWeekOn != currentStartWeekOn ||
            !_listsEqual(_lastDaysOff, currentDaysOff);
        
        if (hasCalendarSettingsChanged) {
          calendarProvider.syncFromAppSettings(
            calendarSystem: currentSystem,
            startWeekOn: currentStartWeekOn,
            daysOff: currentDaysOff,
          );
          
          // Update cached values
          _lastCalendarSystem = currentSystem;
          _lastStartWeekOn = currentStartWeekOn;
          _lastDaysOff = List<String>.from(currentDaysOff);
        }
        
        // Update week view if defaultCalendarView changed
        if (_lastDefaultCalendarView != currentDefaultView) {
          _lastDefaultCalendarView = currentDefaultView;
          calendarProvider.applyDefaultCalendarView(
            currentDefaultView,
            calendarSystem: appProvider.calendarSystem,
          );
        }
        
        if (_lastCalendarSystem != currentSystem) {
          // Reset cache when calendar system changes
          _cachedWeekCount = null;
          _cachedWeekCountMonth = null;
          _cachedCalendarSystem = null;
          _cachedStartWeekOn = null;
          // When calendar system changes, preserve the defaultCalendarView setting
          calendarProvider.applyDefaultCalendarView(
            currentDefaultView,
            calendarSystem: appProvider.calendarSystem,
          );
          if (currentSystem == 'solar' || currentSystem == 'shahanshahi') {
            // Align displayed month to solar/shahanshahi month containing the current selected date
            calendarProvider.setSelectedDateForSolar(calendarProvider.selectedDate);
          } else {
            // Back to Gregorian: ensure displayed month aligns to Gregorian month
            calendarProvider.selectDate(calendarProvider.selectedDate);
          }
          // Recalculate week count for new calendar system
          _updateWeekCount(calendarProvider, appProvider);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CalendarProvider, AppProvider>(
      builder: (context, calendarProvider, appProvider, child) {
        return GestureDetector(
          onPanUpdate: (details) {
            // Only handle drag gestures, not taps
            // This allows date clicks to work properly
          },
          onPanEnd: (details) {
            // Toggle week/month view on drag end
            calendarProvider.toggleWeekView();
          },
          child: Stack(
            clipBehavior: Clip.none, // Allow overflow for drag handle and gradient
            children: [
              // Gradient fade container - floating outside the box, height not calculated in bottom sheet height
              // This container has 0 height in layout but contains 48px gradient inside
              // Gradient starts exactly from the top of bottom sheet (top: 0)
              // Smooth blur transition like iOS 16 - more layers with smaller blur increments for smoother fade
              Positioned(
                top: -48, // 48px above bottom sheet, so gradient starts at top: 0 of bottom sheet
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: ClipRect(
                    child: Stack(
                      children: [
                        // Base gradient container
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                TBg.home(context).withOpacity(0.0),
                                TBg.home(context).withOpacity(0.3),
                                TBg.home(context).withOpacity(0.7),
                                TBg.home(context),
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            ),
                          ),
                        ),
                        // Gradient blur layers - more layers with smaller increments for smoother transition
                        // Layer 1: Bottom 6px with blur 5
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                height: 6,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 2: Next 6px with blur 4.5
                        Positioned(
                          bottom: 6,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
                              child: Container(
                                height: 6,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 3: Next 6px with blur 4
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: Container(
                                height: 6,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 4: Next 6px with blur 3.5
                        Positioned(
                          bottom: 18,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                              child: Container(
                                height: 6,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 5: Next 6px with blur 3
                        Positioned(
                          bottom: 24,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Container(
                                height: 6,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 6: Next 6px with blur 2.5
                        Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                              child: Container(
                                height: 6,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 7: Next 6px with blur 2
                        Positioned(
                          bottom: 36,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                              child: Container(
                                height: 6,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 8: Next 6px with blur 1
                        Positioned(
                          bottom: 42,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                              child: Container(
                                height: 6,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Top 0px has no blur (blur 0) - smooth fade out
                      ],
                    ),
                  ),
                ),
              ),
              
              // Drag handle - positioned 12px from bottom of gradient (which is at top: 0 of bottom sheet)
              // Handle is 4px height, so its center is at -12, and top is at -14
              // Handle is centered horizontally
              Positioned(
                top: -14, // -12 (center position) - 2 (half of 4px height) = -14
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? ThemeColors.white.withOpacity(0.5)
                          : ThemeColors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                  ),
                ),
              ),
              
              // Bottom sheet container - only this height is calculated
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: _calculateBottomSheetHeight(context, calendarProvider, appProvider),
                decoration: BoxDecoration(
                  color: TBg.bottomSheet(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top padding for header
                    const SizedBox(height: 24),
                    
                    // Calendar header with proper padding
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildNewHeader(calendarProvider, appProvider),
                    ),
                    
                    // Only show calendar content if not minimized
                    if (!calendarProvider.isCalendarMinimized) ...[
                      // Gap between header and divider
                      const SizedBox(height: 16),
                      
                      // Divider line
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: TBr.neutralTertiary(context).withOpacity(
                            Theme.of(context).brightness == Brightness.dark ? 0.3 : 1.0,
                          ),
                        ),
                      ),
                      
                      // Gap between divider and calendar
                      const SizedBox(height: 16),
                      
                      // Calendar content with proper padding - no scroll needed as height is fixed
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildCalendarContent(calendarProvider, appProvider),
                      ),
                      
                      // Bottom padding - always 16px for consistency
                      const SizedBox(height: 16),
                    ] else
                      // Bottom padding when minimized
                      const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildNewHeader(CalendarProvider calendarProvider, AppProvider appProvider) {
    final dateConverter = DateConverterService();
    final calendarSystem = appProvider.calendarSystem;
    final isSolarHijri = calendarSystem == 'solar' || calendarSystem == 'shahanshahi';
    final isPersianLang = appProvider.language == 'fa';
    
    String monthName;
    int year;
    
    if (calendarProvider.calendarView == 'week') {
      if (isSolarHijri) {
        final weekStart = calendarProvider.currentJalaliWeekStart;
        monthName = isPersianLang 
            ? dateConverter.getJalaliMonthNameFa(weekStart.month)
            : dateConverter.getJalaliMonthNameEn(weekStart.month);
        // For shahanshahi, convert jalali year to shahanshahi year
        year = calendarSystem == 'shahanshahi' 
            ? dateConverter.getShahanshahiYear(weekStart.year)
            : weekStart.year;
      } else {
        final weekStart = calendarProvider.currentWeekStart;
        monthName = isPersianLang 
            ? dateConverter.getGregorianMonthNameFa(weekStart.month)
            : dateConverter.getGregorianMonthNameShortEn(weekStart.month);
        year = weekStart.year;
      }
    } else {
      if (isSolarHijri) {
        final monthStart = calendarProvider.currentJalaliMonthStart;
        monthName = isPersianLang 
            ? dateConverter.getJalaliMonthNameFa(monthStart.month)
            : dateConverter.getJalaliMonthNameEn(monthStart.month); // English name for solar months when language is English
        // For shahanshahi, convert jalali year to shahanshahi year
        year = calendarSystem == 'shahanshahi' 
            ? dateConverter.getShahanshahiYear(monthStart.year)
            : monthStart.year;
      } else {
        final monthStart = calendarProvider.currentMonthStart;
        // Use full month name for English, not short
        if (isPersianLang) {
          monthName = dateConverter.getGregorianMonthNameFa(monthStart.month);
        } else {
          final monthNames = {
            1: 'January', 2: 'February', 3: 'March', 4: 'April',
            5: 'May', 6: 'June', 7: 'July', 8: 'August',
            9: 'September', 10: 'October', 11: 'November', 12: 'December'
          };
          monthName = monthNames[monthStart.month] ?? 'Month';
        }
        year = monthStart.year;
      }
    }
    
    return CalendarHeaderWidget(
      monthName: monthName,
      year: year,
      onAddReminder: null, // Disabled for now
      onMultitasking: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.3), // 30% opacity black backdrop
          isScrollControlled: true,
          builder: (context) => const YearPickerBottomSheet(),
        );
      },
      onSearch: null, // Disabled for now
      onSettings: () {
        Navigator.of(context).pushNamed('/settings');
      },
      isPersian: isSolarHijri,
    );
  }


  Widget _buildCalendarContent(CalendarProvider calendarProvider, AppProvider appProvider) {
    final calendarSystem = appProvider.calendarSystem;
    final isSolarHijri = calendarSystem == 'solar' || calendarSystem == 'shahanshahi';
    
    return CalendarWidget(
      displayedMonth: calendarProvider.displayedMonth,
      selectedDate: calendarProvider.selectedDate,
      today: DateTime.now(),
      isPersian: isSolarHijri,
      isWeekView: calendarProvider.isWeekView, // Pass week view state
      visibleWeekIndex: calendarProvider.getWeekIndexOfSelectedDate(calendarSystem: calendarSystem), // Pass visible week index
      shortWeekdays: false, // Use full weekday names (شنبه، ۱شنبه، ۲شنبه، ...) in bottom sheet
      onDateSelected: (date) {
        // For solar/shahanshahi calendar, use special method to ensure displayedMonth matches solar month
        // Make this synchronous to avoid blocking UI in Android
        if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
          calendarProvider.setSelectedDateForSolar(date);
        } else {
          calendarProvider.selectDate(date);
        }
      },
    );
  }
}