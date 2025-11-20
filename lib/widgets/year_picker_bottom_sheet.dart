import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../config/app_icons.dart';
import '../providers/app_provider.dart';
import '../providers/calendar_provider.dart';
import '../utils/calendar_utils.dart';
import '../utils/svg_helper.dart';
import '../utils/font_helper.dart';
import '../services/date_converter_service.dart';
import '../services/year_cache_service.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom scroll physics for 50% faster scrolling
class FastScrollPhysics extends ClampingScrollPhysics {
  const FastScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  FastScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Increase scroll speed by 50% (multiply by 1.5)
    return super.applyPhysicsToUserOffset(position, offset * 1.5);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Increase velocity by 50% for faster scrolling
    return super.createBallisticSimulation(position, velocity * 1.5);
  }
}

class YearPickerBottomSheet extends StatefulWidget {
  const YearPickerBottomSheet({super.key});

  @override
  State<YearPickerBottomSheet> createState() => _YearPickerBottomSheetState();
}

class _YearPickerBottomSheetState extends State<YearPickerBottomSheet> {
  // Track visible years (start with ONLY current year)
  late List<int> _visibleYears;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _currentYearKey = GlobalKey();
  final GlobalKey _scrollableKey = GlobalKey();
  final YearCacheService _yearCacheService = YearCacheService();
  String? _currentCalendarSystem;
  bool _hasScrolled = false; // Track if user has scrolled
  bool _isLoadingYears = false; // Prevent multiple simultaneous loads
  bool _hasCentered = false; // Track if we've centered the current year
  
  @override
  void initState() {
    super.initState();
    // Initialize with ONLY current year
    final calendarProvider = context.read<CalendarProvider>();
    final appProvider = context.read<AppProvider>();
    final calendarSystem = appProvider.calendarSystem;
    _currentCalendarSystem = calendarSystem;
    
    final dateConverter = DateConverterService();
    int currentYear;
    if (calendarSystem == 'solar') {
      // For solar calendar, get the Jalali year
      final jalali = CalendarUtils.gregorianToJalali(calendarProvider.displayedMonth);
      currentYear = jalali.year;
    } else if (calendarSystem == 'shahanshahi') {
      // For shahanshahi calendar, get the Shahanshahi year
      final jalali = CalendarUtils.gregorianToJalali(calendarProvider.displayedMonth);
      currentYear = dateConverter.getShahanshahiYear(jalali.year);
    } else {
      currentYear = calendarProvider.displayedMonth.year;
    }
    
    // Start with current year + 5 years before + 5 years after (11 years total)
    // Show all years (they should be preloaded in splash screen, but show them anyway)
    _visibleYears = [];
    for (int i = -5; i <= 5; i++) {
      final year = currentYear + i;
      // For solar calendar, years are typically 1300-1500
      // For shahanshahi calendar, years are typically 2480-2680 (1300+1180 to 1500+1180)
      // For Gregorian 1900-2100
      if (calendarSystem == 'solar') {
        if (year >= 1300 && year <= 1500) {
          _visibleYears.add(year);
        }
      } else if (calendarSystem == 'shahanshahi') {
        if (year >= 2480 && year <= 2680) {
          _visibleYears.add(year);
        }
      } else {
        if (year >= 1900 && year <= 2100) {
          _visibleYears.add(year);
        }
      }
    }
    
    // Listen to scroll for lazy loading
    _scrollController.addListener(_handleScroll);
    
    // Preload 10 years before and after in background
    _preloadMoreYears(currentYear, calendarSystem);
    
    // Scroll to center current year after frames are rendered
    // Use multiple post frame callbacks to ensure everything is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _scrollToCenterCurrentYear();
      });
    });
  }
  
  void _scrollToCenterCurrentYear() {
    if (_hasCentered) return; // Only center once
    
    if (!_scrollController.hasClients) {
      // Retry after a delay if scroll controller is not ready
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_hasCentered) _scrollToCenterCurrentYear();
      });
      return;
    }
    
    final BuildContext? currentYearContext = _currentYearKey.currentContext;
    if (currentYearContext == null) {
      // Retry after a delay if context is not ready
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_hasCentered) _scrollToCenterCurrentYear();
      });
      return;
    }
    
    // Use Scrollable.ensureVisible to center the current year
    // This will automatically calculate the correct scroll position
    try {
      Scrollable.ensureVisible(
        currentYearContext,
        duration: const Duration(milliseconds: 0), // Instant scroll
        curve: Curves.linear,
        alignment: 0.5, // Center the year (0.0 = top, 0.5 = center, 1.0 = bottom)
      );
      _hasCentered = true;
    } catch (e) {
      // If it fails, retry after a delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_hasCentered) _scrollToCenterCurrentYear();
      });
    }
  }
  
  void _preloadMoreYears(int currentYear, String calendarSystem) {
    // Get min/max years based on calendar system
    final minYear = calendarSystem == 'solar' ? 1300 : (calendarSystem == 'shahanshahi' ? 2480 : 1900);
    final maxYear = calendarSystem == 'solar' ? 1500 : (calendarSystem == 'shahanshahi' ? 2680 : 2100);
    
    // Preload 10 years before current year
    if (currentYear > minYear) {
      final startYear = (currentYear - 10).clamp(minYear, currentYear);
      final endYear = currentYear - 1;
      if (startYear <= endYear) {
        unawaited(_yearCacheService.preloadYearRange(startYear, endYear, calendarSystem: calendarSystem));
      }
    }
    
    // Preload 10 years after current year
    if (currentYear < maxYear) {
      final startYear = currentYear + 1;
      final endYear = (currentYear + 10).clamp(startYear, maxYear);
      if (startYear <= endYear) {
        unawaited(_yearCacheService.preloadYearRange(startYear, endYear, calendarSystem: calendarSystem));
      }
    }
  }
  
  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    
    final position = _scrollController.position;
    final calendarSystem = _currentCalendarSystem ?? 'gregorian';
    
    // Mark that user has scrolled
    if (!_hasScrolled && position.pixels.abs() > 10) {
      _hasScrolled = true;
    }
    
    // Calculate approximate year height (roughly 600px based on 12 months grid)
    const double estimatedYearHeight = 600.0;
    final viewportHeight = position.viewportDimension;
    
    // Get min/max years based on calendar system
    final minYear = calendarSystem == 'solar' ? 1300 : (calendarSystem == 'shahanshahi' ? 2480 : 1900);
    final maxYear = calendarSystem == 'solar' ? 1500 : (calendarSystem == 'shahanshahi' ? 2680 : 2100);
    
    // If scrolling up (near top of viewport), load 5 previous years from cache (for testing)
    // Check if we're in the top portion of the scrollable area
    if (position.pixels < estimatedYearHeight && _visibleYears.isNotEmpty && _visibleYears.first > minYear) {
      _loadPreviousYears(calendarSystem);
    }
    
    // If scrolling down (near bottom), load 5 next years from cache (for testing)
    // Check if we're near the bottom of the scrollable area
    final distanceFromBottom = position.maxScrollExtent - position.pixels;
    if (distanceFromBottom < estimatedYearHeight && _visibleYears.isNotEmpty && _visibleYears.last < maxYear) {
      _loadNextYears(calendarSystem);
    }
    
    // Preload more years when reaching 3rd year from start or end (adjusted for 5 years)
    if (_visibleYears.length >= 3) {
      final currentYear = _getCurrentYear();
      final currentIndex = _visibleYears.indexOf(currentYear);
      
      // If we're at 3rd year from start, preload 5 more before
      if (currentIndex >= 2 && _visibleYears.first > minYear) {
        final startYear = (_visibleYears.first - 5).clamp(minYear, _visibleYears.first);
        final endYear = _visibleYears.first - 1;
        if (startYear <= endYear) {
          unawaited(_yearCacheService.preloadYearRange(startYear, endYear, calendarSystem: calendarSystem));
        }
      }
      
      // If we're at 3rd year from end, preload 5 more after
      if (_visibleYears.length - currentIndex - 1 >= 2 && _visibleYears.last < maxYear) {
        final startYear = _visibleYears.last + 1;
        final endYear = (_visibleYears.last + 5).clamp(startYear, maxYear);
        if (startYear <= endYear) {
          unawaited(_yearCacheService.preloadYearRange(startYear, endYear, calendarSystem: calendarSystem));
        }
      }
    }
  }
  
  int _getCurrentYear() {
    final calendarProvider = context.read<CalendarProvider>();
    final appProvider = context.read<AppProvider>();
    final calendarSystem = appProvider.calendarSystem;
    final dateConverter = DateConverterService();
    
    if (calendarSystem == 'solar') {
      final jalali = CalendarUtils.gregorianToJalali(calendarProvider.displayedMonth);
      return jalali.year;
    } else if (calendarSystem == 'shahanshahi') {
      final jalali = CalendarUtils.gregorianToJalali(calendarProvider.displayedMonth);
      return dateConverter.getShahanshahiYear(jalali.year);
    } else {
      return calendarProvider.displayedMonth.year;
    }
  }
  
  void _loadPreviousYears(String calendarSystem) {
    if (_visibleYears.isEmpty) return;
    final minYear = calendarSystem == 'solar' ? 1300 : (calendarSystem == 'shahanshahi' ? 2480 : 1900);
    if (_visibleYears.first <= minYear) return;
    
    // Prevent multiple simultaneous loads
    if (_isLoadingYears) return;
    _isLoadingYears = true;
    
    // Save current scroll position to maintain it after adding years
    final currentScrollPosition = _scrollController.hasClients 
        ? _scrollController.position.pixels 
        : 0.0;
    
    // Load up to 5 years before from cache (for testing)
    final firstYear = _visibleYears.first;
    final yearsToAdd = <int>[];
    for (int i = 1; i <= 5; i++) {
      final year = firstYear - i;
      if (year < minYear) break;
      
      if (_yearCacheService.isYearCached(year, calendarSystem: calendarSystem)) {
        yearsToAdd.add(year);
      }
    }
    
    if (yearsToAdd.isNotEmpty) {
      yearsToAdd.sort();
      
      setState(() {
        _visibleYears = [...yearsToAdd, ..._visibleYears];
        
        // Keep max 30 years visible to avoid performance issues
        if (_visibleYears.length > 30) {
          final currentYear = _getCurrentYear();
          final currentIndex = _visibleYears.indexOf(currentYear);
          
          // Remove from the end if we're closer to start
          if (currentIndex < 15) {
            _visibleYears = _visibleYears.take(30).toList();
          } else {
            // Remove from the start if we're closer to end
            _visibleYears = _visibleYears.skip(_visibleYears.length - 30).toList();
          }
        }
      });
      
      // Adjust scroll position after adding years (each year block is roughly 600px + 48px divider)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          const estimatedYearHeight = 648.0; // 600px year + 48px divider (24+1+24)
          final addedHeight = yearsToAdd.length * estimatedYearHeight;
          _scrollController.jumpTo(currentScrollPosition + addedHeight);
        }
        _isLoadingYears = false;
      });
    } else {
      _isLoadingYears = false;
    }
  }
  
  void _loadNextYears(String calendarSystem) {
    if (_visibleYears.isEmpty) return;
    final maxYear = calendarSystem == 'solar' ? 1500 : (calendarSystem == 'shahanshahi' ? 2680 : 2100);
    if (_visibleYears.last >= maxYear) return;
    
    // Prevent multiple simultaneous loads
    if (_isLoadingYears) return;
    _isLoadingYears = true;
    
    // Load up to 5 years after from cache (for testing)
    final lastYear = _visibleYears.last;
    final yearsToAdd = <int>[];
    for (int i = 1; i <= 5; i++) {
      final year = lastYear + i;
      if (year > maxYear) break;
      
      if (_yearCacheService.isYearCached(year, calendarSystem: calendarSystem)) {
        yearsToAdd.add(year);
      }
    }
    
    if (yearsToAdd.isNotEmpty) {
      setState(() {
        _visibleYears = [..._visibleYears, ...yearsToAdd];
        
        // Keep max 30 years visible to avoid performance issues
        if (_visibleYears.length > 30) {
          final currentYear = _getCurrentYear();
          final currentIndex = _visibleYears.indexOf(currentYear);
          
          // Remove from the start if we're closer to end
          if (currentIndex >= 15) {
            _visibleYears = _visibleYears.skip(_visibleYears.length - 30).toList();
          } else {
            // Remove from the end if we're closer to start
            _visibleYears = _visibleYears.take(30).toList();
          }
        }
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoadingYears = false;
      });
    } else {
      _isLoadingYears = false;
    }
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, CalendarProvider>(
      builder: (context, appProvider, calendarProvider, child) {
        final calendarSystem = appProvider.calendarSystem;
        final isSolarHijri = calendarSystem == 'solar' || calendarSystem == 'shahanshahi';
        final isPersianLang = appProvider.language == 'fa';
        final dateConverter = DateConverterService();
        
        // Get current year based on calendar system
        final int currentYear;
        if (calendarSystem == 'solar') {
          final jalali = CalendarUtils.gregorianToJalali(calendarProvider.displayedMonth);
          currentYear = jalali.year;
        } else if (calendarSystem == 'shahanshahi') {
          final jalali = CalendarUtils.gregorianToJalali(calendarProvider.displayedMonth);
          currentYear = dateConverter.getShahanshahiYear(jalali.year);
        } else {
          currentYear = calendarProvider.displayedMonth.year;
        }

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => Navigator.of(context).pop(),
          child: Stack(
            clipBehavior: Clip.none, // Allow overflow for drag handle
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.90, // Fixed height at 90% of screen
                  clipBehavior: Clip.antiAlias, // Clip content to borderRadius
                  decoration: BoxDecoration(
                    color: TBg.bottomSheet(context),
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                  ),
                  child: Stack(
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          // Handle scroll notifications for better detection
                          if (notification is ScrollUpdateNotification) {
                            _handleScroll();
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          key: _scrollableKey,
                          controller: _scrollController,
                          physics: const FastScrollPhysics(), // 50% faster scrolling
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24), // 24px horizontal padding
                            child: Column(
                              children: [
                                // Year blocks
                                for (int i = 0; i < _visibleYears.length; i++) ...[
                                i == 0 ? const SizedBox(height: 0) : Column(
                                  children: [
                                    const SizedBox(height: 24), // Gap before divider
                                    Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        color: TBr.neutralTertiary(context).withOpacity(
                                          Theme.of(context).brightness == Brightness.dark ? 0.3 : 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24), // Gap after divider
                                  ],
                                ),
                                _YearBlock(
                                  key: _visibleYears[i] == currentYear ? _currentYearKey : ValueKey(_visibleYears[i]),
                                  year: _visibleYears[i],
                                  highlight: _visibleYears[i] == currentYear,
                                  isSolarHijri: isSolarHijri,
                                  isPersianLang: isPersianLang,
                                  calendarSystem: calendarSystem,
                  onMonthTap: (int month) async {
                    final appProvider = context.read<AppProvider>();
                    final calendarSystem = appProvider.calendarSystem;
                    final dateConverter = DateConverterService();
                    
                      if (calendarSystem == 'solar') {
                      // For solar calendar: select the first day of the solar month
                      final solarYear = _visibleYears[i];
                      final solarMonth = month;
                      final firstDaySolar = Jalali(solarYear, solarMonth, 1);
                      final gregorianFirstDay = dateConverter.jalaliToGregorian(
                        firstDaySolar.year, firstDaySolar.month, firstDaySolar.day);
                      
                      // Switch to month view and set selected date (also aligns displayedMonth to solar month)
                        calendarProvider.applyDefaultCalendarView(
                          'month',
                          calendarSystem: calendarSystem,
                        );
                      calendarProvider.setSelectedDateForSolar(gregorianFirstDay);
                    } else if (calendarSystem == 'shahanshahi') {
                      // For shahanshahi calendar: convert shahanshahi year to jalali year first
                      final shahanshahiYear = _visibleYears[i];
                      final jalaliYear = dateConverter.getJalaliYearFromShahanshahi(shahanshahiYear);
                      final shahanshahiMonth = month;
                      final firstDayJalali = Jalali(jalaliYear, shahanshahiMonth, 1);
                      final gregorianFirstDay = dateConverter.jalaliToGregorian(
                        firstDayJalali.year, firstDayJalali.month, firstDayJalali.day);
                      
                      // Switch to month view and set selected date (also aligns displayedMonth to solar month)
                      calendarProvider.applyDefaultCalendarView(
                        'month',
                        calendarSystem: calendarSystem,
                      );
                      calendarProvider.setSelectedDateForSolar(gregorianFirstDay);
                    } else {
                      // Gregorian: select the first day of the chosen month
                      final firstDay = DateTime(_visibleYears[i], month, 1);
                      calendarProvider.setWeekView(false);
                      calendarProvider.selectDate(firstDay);
                    }
                    
                    Navigator.of(context).pop();
                  },
                                ),
                              ],
                            ],
                            ),
                          ),
                        ),
                      ),
                      // Top gradient overlay
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  TBg.bottomSheet(context),
                                  TBg.bottomSheet(context).withOpacity(0.8),
                                  TBg.bottomSheet(context).withOpacity(0),
                                ],
                                stops: const [0.0, 0.3, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Bottom gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  TBg.bottomSheet(context),
                                  TBg.bottomSheet(context).withOpacity(0.8),
                                  TBg.bottomSheet(context).withOpacity(0),
                                ],
                                stops: const [0.0, 0.3, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Floating close button (X-circle) - 24px padding from top and right
                      Positioned(
                        top: 24,
                        right: 24,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 32,
                            height: 32,
                            padding: const EdgeInsets.all(2),
                            child: SvgIconWidget(
                              assetPath: AppIcons.xCircle,
                              size: 28,
                              color: TCnt.neutralSecond(context),
                            ),
                          ),
                        ),
                      ),
                      // Floating action buttons at bottom
                      Positioned(
                        bottom: 24,
                        left: 24,
                        right: 24,
                        child: Row(
                          children: [
                            // Today button (left action)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                final calendarProvider = context.read<CalendarProvider>();
                                final appProvider = context.read<AppProvider>();
                                
                                final today = DateTime.now();
                                
                                // If solar/shahanshahi calendar, use setSelectedDateForSolar with today's date
                                if (appProvider.calendarSystem == 'solar' || appProvider.calendarSystem == 'shahanshahi') {
                                  calendarProvider.setSelectedDateForSolar(today);
                                } else {
                                  // For Gregorian calendar, use jumpToToday
                                  calendarProvider.jumpToToday();
                                }
                                
                                Navigator.of(context).pop();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 48,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? ThemeColors.gray100.withOpacity(0.1)
                                          : ThemeColors.gray900.withOpacity(0.06),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isPersianLang ? 'امروز' : 'Today',
                                        style: isPersianLang
                                            ? FontHelper.getYekanBakh(
                                                fontSize: 14,
                                                height: 1.4,
                                                fontWeight: FontWeight.w600, // Semibold
                                                color: TCnt.neutralSecond(context),
                                              )
                                            : GoogleFonts.inter(
                                                fontSize: 14,
                                                height: 1.4,
                                                fontWeight: FontWeight.w600, // Semibold
                                                color: TCnt.neutralSecond(context),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Auto gap between left and right actions
                            const Spacer(),
                            // Right actions (Search and Add Event)
                            Row(
                              children: [
                                // Search button (disabled)
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    final appProvider = context.read<AppProvider>();
                                    final isPersianLang = appProvider.language == 'fa';
                                    final msg = isPersianLang
                                        ? 'این قابلیت به زودی فعال خواهد شد'
                                        : 'This feature will be available soon';
                                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(msg),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? ThemeColors.gray100.withOpacity(0.1)
                                                : ThemeColors.gray900.withOpacity(0.06),
                                          ),
                                          child: SvgIconWidget(
                                            assetPath: AppIcons.search,
                                            size: 24,
                                            color: TCnt.neutralSecond(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8), // 8px gap between Search and Add Event
                                // Add event button (disabled)
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    final appProvider = context.read<AppProvider>();
                                    final isPersianLang = appProvider.language == 'fa';
                                    final msg = isPersianLang
                                        ? 'این قابلیت به زودی فعال خواهد شد'
                                        : 'This feature will be available soon';
                                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(msg),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? ThemeColors.gray100.withOpacity(0.06)
                                                : ThemeColors.gray900.withOpacity(0.06),
                                          ),
                                          child: SvgIconWidget(
                                            assetPath: AppIcons.calendarPlus,
                                            size: 24,
                                            color: TCnt.neutralSecond(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Drag handle - floating outside the box with overflow
              // 12px gap between handle and top of bottom sheet
              Positioned(
                top: -16, // -4 (handle height) - 12 (gap) = -16
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ThemeColors.white.withOpacity(0.75), // White with 75% opacity for both light and dark
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _YearBlock extends StatelessWidget {
  final int year;
  final bool highlight;
  final bool isSolarHijri;
  final bool isPersianLang;
  final String calendarSystem;
  final ValueChanged<int> onMonthTap;

  const _YearBlock({
    super.key,
    required this.year,
    required this.highlight,
    required this.isSolarHijri,
    required this.isPersianLang,
    required this.calendarSystem,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
        final yearStyle = isPersianLang
            ? FontHelper.getYekanBakh(
                fontSize: 24,
                height: 1.4,
                letterSpacing: -0.48, // -2%
                fontWeight: FontWeight.w700,
                color: highlight ? TCnt.brandMain(context) : TCnt.neutralMain(context),
              )
            : GoogleFonts.inter(
                fontSize: 24,
                height: 1.4,
                letterSpacing: -0.48, // -2%
                fontWeight: FontWeight.w700,
                color: highlight ? TCnt.brandMain(context) : TCnt.neutralMain(context),
              );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isPersianLang ? CalendarUtils.englishToPersianDigits(year.toString()) : year.toString(), style: yearStyle),
        const SizedBox(height: 24), // gap between year label and months
        _MonthsGrid(
          year: year,
          isSolarHijri: isSolarHijri,
          isPersianLang: isPersianLang,
          calendarSystem: calendarSystem,
          onMonthTap: onMonthTap,
          currentMonth: context.read<CalendarProvider>().displayedMonth,
          selectedDate: context.read<CalendarProvider>().selectedDate,
        ),
      ],
    );
  }
}

class _MonthsGrid extends StatelessWidget {
  final int year;
  final bool isSolarHijri;
  final bool isPersianLang;
  final String calendarSystem;
  final ValueChanged<int> onMonthTap;
  final DateTime currentMonth; // To determine which month is active
  final DateTime selectedDate; // To determine which date is selected

  const _MonthsGrid({
    required this.year,
    required this.isSolarHijri,
    required this.isPersianLang,
    required this.calendarSystem,
    required this.onMonthTap,
    required this.currentMonth,
    required this.selectedDate,
  });

  List<String> _monthNames() {
    if (isSolarHijri) {
      // For solar calendar, use English names if language is English
      return isPersianLang
          ? ['فروردین','اردیبهشت','خرداد','تیر','مرداد','شهریور','مهر','آبان','آذر','دی','بهمن','اسفند']
          : ['Farvardin','Ordibehesht','Khordad','Tir','Mordad','Shahrivar','Mehr','Aban','Azar','Dey','Bahman','Esfand'];
    }
    // English vs Persian for Gregorian
    return isPersianLang
        ? ['ژانویه','فوریه','مارس','آوریل','مه','ژوئن','ژوئیه','اوت','سپتامبر','اکتبر','نوامبر','دسامبر']
        : ['January','February','March','April','May','June','July','August','September','October','November','December'];
  }

  @override
  Widget build(BuildContext context) {
    final months = List<int>.generate(12, (i) => i + 1);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate month width for 3 months per row
        // 3 months with 2 gaps of 24px = 48px for gaps
        final totalWidth = constraints.maxWidth;
        final availableWidth = totalWidth - 48; // Subtract gaps (padding already in parent)
        final monthWidth = availableWidth / 3;
        
        return Wrap(
          spacing: 24, // horizontal gap between months
          runSpacing: 16, // vertical gap between months
          alignment: WrapAlignment.start,
          children: months.map((m) => SizedBox(
            width: monthWidth,
            child: _MiniMonth(
              year: year,
              month: m,
              isSolarHijri: isSolarHijri,
              isPersianLang: isPersianLang,
              calendarSystem: calendarSystem,
              monthLabel: _monthNames()[m - 1],
              onTap: () => onMonthTap(m),
              currentMonth: currentMonth,
              selectedDate: selectedDate,
            ),
          )).toList(),
        );
      },
    );
  }
}

class _MiniMonth extends StatelessWidget {
  final int year;
  final int month;
  final bool isSolarHijri;
  final bool isPersianLang;
  final String calendarSystem;
  final String monthLabel;
  final VoidCallback onTap;
  final DateTime currentMonth;
  final DateTime selectedDate;

  const _MiniMonth({
    required this.year,
    required this.month,
    required this.isSolarHijri,
    required this.isPersianLang,
    required this.calendarSystem,
    required this.monthLabel,
    required this.onTap,
    required this.currentMonth,
    required this.selectedDate,
  });

  // Helper to get weekday name from DateTime weekday
  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if this month is the active month
    final bool isActiveMonth;
    if (isSolarHijri) {
      final currentJalali = CalendarUtils.gregorianToJalali(currentMonth);
      // If shahanshahi, convert current jalali year to shahanshahi year for comparison
      if (calendarSystem == 'shahanshahi') {
        final dateConverter = DateConverterService();
        final currentShahanshahiYear = dateConverter.getShahanshahiYear(currentJalali.year);
        isActiveMonth = year == currentShahanshahiYear && month == currentJalali.month;
      } else {
        isActiveMonth = year == currentJalali.year && month == currentJalali.month;
      }
    } else {
      isActiveMonth = year == currentMonth.year && month == currentMonth.month;
    }
    
    final labelStyle = isPersianLang
        ? FontHelper.getYekanBakh(
            fontSize: 14,
            height: 1.4,
            letterSpacing: -0.28, // -2%
            color: isActiveMonth ? TCnt.brandMain(context) : TCnt.neutralSecond(context),
            fontWeight: FontWeight.w600,
          )
        : GoogleFonts.inter(
            fontSize: 14,
            height: 1.4,
            letterSpacing: -0.28, // -2%
            color: isActiveMonth ? TCnt.brandMain(context) : TCnt.neutralSecond(context),
            fontWeight: FontWeight.w600,
          );

    // Get settings from AppProvider
    final appProvider = Provider.of<AppProvider>(context);
    final startWeekOn = appProvider.effectiveStartWeekOn;
    final daysOff = appProvider.effectiveDaysOff;
    
    // Build calendar grid cells (7 columns), only days of target month are shown
    // For solar/shahanshahi calendar, we need to convert solar year/month to Gregorian first
    final DateTime firstDay;
    final int lastDay;
    
    if (isSolarHijri) {
      // Convert solar (Jalali) year/month to Gregorian
      final dateConverter = DateConverterService();
      // If shahanshahi, convert shahanshahi year to jalali year first
      int jalaliYear = calendarSystem == 'shahanshahi' 
          ? dateConverter.getJalaliYearFromShahanshahi(year)
          : year;
      final gregorianFirstDay = dateConverter.jalaliToGregorian(jalaliYear, month, 1);
      firstDay = gregorianFirstDay;
      
      // Get days in solar month (can be 31, 30, or 29 for Esfand)
      final jalaliFirstDay = Jalali(jalaliYear, month, 1);
      lastDay = jalaliFirstDay.monthLength;
    } else {
      firstDay = DateTime(year, month, 1);
      lastDay = DateTime(year, month + 1, 0).day;
    }
    
    // Use startWeekOn setting to get week start
    final weekStartCalendarSystem = isSolarHijri ? 'solar' : 'gregorian';
    final weekStart = CalendarUtils.getWeekStart(
      firstDay,
      calendarSystem: weekStartCalendarSystem,
      startWeekOn: startWeekOn,
    );
    final offset = firstDay.difference(weekStart).inDays; // leading blanks
    final totalCells = offset + lastDay;
    final rows = (totalCells / 7).ceil();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(monthLabel, style: labelStyle),
          const SizedBox(height: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(rows, (row) {
              return Padding(
                padding: EdgeInsets.only(bottom: row == rows - 1 ? 0 : 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (col) {
                    final cellIndex = row * 7 + col;
                    final dayNumber = cellIndex - offset + 1;
                    if (dayNumber < 1 || dayNumber > lastDay) {
                      return const SizedBox(width: 16, height: 16);
                    }
                    
                    // For solar/shahanshahi calendar, dayNumber is the solar day (1-31, 30, or 29)
                    // For Gregorian, dayNumber is the Gregorian day
                    final DateTime date;
                    final int solarDayNumber;
                    
                    if (isSolarHijri) {
                      // Convert solar year/month/day to Gregorian
                      final dateConverter = DateConverterService();
                      // If shahanshahi, convert shahanshahi year to jalali year first
                      int jalaliYear = calendarSystem == 'shahanshahi' 
                          ? dateConverter.getJalaliYearFromShahanshahi(year)
                          : year;
                      date = dateConverter.jalaliToGregorian(jalaliYear, month, dayNumber);
                      solarDayNumber = dayNumber; // This is already the solar day
                    } else {
                      date = DateTime(year, month, dayNumber);
                      solarDayNumber = dayNumber;
                    }
                    
                    final isSelected = date.year == selectedDate.year && 
                                      date.month == selectedDate.month && 
                                      date.day == selectedDate.day;
                    
                    // Check if this day is a day off based on settings
                    final weekdayName = _weekdayName(date.weekday);
                    final isOffDay = daysOff.contains(weekdayName);
                    
                    Color textColor;
                    Color? backgroundColor;
                    FontWeight textWeight = FontWeight.w500;
                    
                    if (isSelected) {
                      textColor = ThemeColors.white;
                      backgroundColor = TCnt.brandMain(context);
                      textWeight = FontWeight.bold;
                    } else if (isActiveMonth) {
                      // Active month days: errorMd for days off, neutral_secondary for regular days, neutral_tertiary for weekends
                      if (isOffDay) {
                        // Days off in active month: show with errorMd (red) color
                        textColor = TCnt.errorMd(context);
                      } else {
                        final isWeekendGregorian = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
                        if (isWeekendGregorian) {
                          // Saturday and Sunday (if not in daysOff)
                          textColor = TCnt.neutralTertiary(context);
                        } else {
                          // Regular days in active month
                          textColor = TCnt.neutralSecond(context);
                        }
                      }
                    } else {
                      // Inactive months: errorMd for days off, rest with neutralTertiary
                      if (isOffDay) {
                        // Days off in inactive months: show with errorMd (red) color
                        textColor = TCnt.errorMd(context);
                      } else {
                        textColor = TCnt.neutralTertiary(context);
                      }
                    }
                    
                    // Display the solar day number for solar calendar, Gregorian for Gregorian
                    final text = isPersianLang
                        ? CalendarUtils.englishToPersianDigits(solarDayNumber.toString())
                        : solarDayNumber.toString();
                    
                    return Container(
                      width: 16,
                      height: 16,
                      decoration: backgroundColor != null
                          ? BoxDecoration(
                              color: backgroundColor,
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Center(
                        child: Text(
                          text,
                          style: isPersianLang
                              ? FontHelper.getYekanBakh(
                                  fontSize: 9,
                                  height: 1.3,
                                  color: textColor,
                                  fontWeight: textWeight,
                                )
                              : GoogleFonts.inter(
                                  fontSize: 9,
                                  height: 1.3,
                                  color: textColor,
                                  fontWeight: textWeight,
                                ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Helper function to run async code without awaiting
void unawaited(Future<void> future) {
  future.catchError((error) {
    debugPrint('Unawaited future error: $error');
  });
}
