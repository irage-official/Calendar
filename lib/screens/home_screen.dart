import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';
import '../config/theme_roles.dart';
import '../providers/app_provider.dart';
import '../widgets/header_widget.dart';
import '../widgets/calendar_bottom_sheet_widget.dart';
import '../widgets/event_list_widget.dart';
import '../utils/logger.dart';
import '../widgets/about_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  VoidCallback? _appProviderListener;
  AppProvider? _appProvider;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
    _setupScrollListener();
    _setupAppProviderListener();
  }

  void _setupAppProviderListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appProvider = context.read<AppProvider>();
      final calendarProvider = context.read<CalendarProvider>();
      
      // Sync CalendarProvider with AppProvider's defaultCalendarView
      _appProviderListener = () {
        if (mounted && _appProvider != null) {
          calendarProvider.syncFromAppSettings(
            calendarSystem: _appProvider!.calendarSystem,
            startWeekOn: _appProvider!.effectiveStartWeekOn,
            daysOff: _appProvider!.effectiveDaysOff,
          );
          final defaultView = _appProvider!.defaultCalendarView;
          calendarProvider.applyDefaultCalendarView(
            defaultView,
            calendarSystem: _appProvider!.calendarSystem,
          );
        }
      };
      _appProvider!.addListener(_appProviderListener!);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_appProviderListener != null && _appProvider != null) {
      _appProvider!.removeListener(_appProviderListener!);
    }
    super.dispose();
  }

  Future<void> _initializeProviders() async {
    try {
      setState(() => _isLoading = true);
      
      // Check if AppProvider is already initialized (from splash screen)
      final appProvider = context.read<AppProvider>();
      if (!appProvider.isInitialized) {
        await appProvider.initialize();
      }
      
      // Ensure CalendarProvider is synced with AppProvider's preferences
      // Use postFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final calendarProvider = context.read<CalendarProvider>();
          calendarProvider.syncFromAppSettings(
            calendarSystem: appProvider.calendarSystem,
            startWeekOn: appProvider.effectiveStartWeekOn,
            daysOff: appProvider.effectiveDaysOff,
          );
          final defaultView = appProvider.defaultCalendarView;
          calendarProvider.applyDefaultCalendarView(
            defaultView,
            calendarSystem: appProvider.calendarSystem,
          );
        }
      });
      
      AppLogger.info('HomeScreen initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing HomeScreen', error: e);
      // Don't show toast - initialization already happened in splash screen
      // This is just a safety check
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setupScrollListener() {
      _scrollController.addListener(() {
      final calendarProvider = context.read<CalendarProvider>();
      
      // Auto-minimize calendar when scrolling down
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (calendarProvider.isCalendarExpanded) {
          calendarProvider.setCalendarExpansion(false);
        }
        calendarProvider.minimizeCalendar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TBg.home(context),
      body: Consumer2<CalendarProvider, AppProvider>(
        builder: (context, calendarProvider, appProvider, child) {
          final isPersian = appProvider.language == 'fa';
          // Calculate header height
          final headerHeight = 74.0 + MediaQuery.of(context).padding.top;
          
          // Calculate bottom sheet height
          final bottomSheetHeight = _calculateBottomSheetHeight(
            context,
            calendarProvider,
            appProvider,
          );
          
          return Stack(
            children: [
              // Header - fixed at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: HeaderWidget(
                    onTodayPressed: () {
                      final calendarProvider = context.read<CalendarProvider>();
                      final appProvider = context.read<AppProvider>();
                      if (appProvider.calendarSystem == 'solar' || appProvider.calendarSystem == 'shahanshahi') {
                        // For solar calendar, use setSelectedDateForSolar to ensure correct month
                        calendarProvider.setSelectedDateForSolar(DateTime.now());
                      } else {
                        // For Gregorian calendar, use standard jumpToToday
                        calendarProvider.jumpToToday();
                      }
                    },
                    onLogoPressed: () {
                      showAboutBottomSheet(
                        context,
                        isPersian: isPersian,
                      );
                    },
                  ),
                ),
              ),
              
              // Event List - scrollable content between header and bottom sheet
              Positioned(
                top: headerHeight,
                left: 0,
                right: 0,
                bottom: bottomSheetHeight + MediaQuery.of(context).padding.bottom,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: const EventListWidget(),
                ),
              ),
              
              // Calendar Bottom Sheet - fixed at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: const CalendarBottomSheetWidget(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Calculate bottom sheet height (same logic as in CalendarBottomSheetWidget)
  double _calculateBottomSheetHeight(
    BuildContext context,
    CalendarProvider calendarProvider,
    AppProvider appProvider,
  ) {
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
    
    // Estimate: most months have 5 weeks, some have 6
    const int actualWeeks = 5;
    
    // Month days height calculation:
    // - Each week: 36px (cell) + 4px (event indicators) + 8px (spacing) = 48px
    // - Gap between weeks: 12px (n-1 gaps for n weeks)
    // - Use actual number of weeks, but if week view, only show 1 week
    final int weeksToShow = calendarProvider.isWeekView ? 1 : actualWeeks;
    const double gapBetweenWeeks = 12.0;
    final double monthDaysHeight = (weeksToShow * 48.0) + ((weeksToShow - 1) * gapBetweenWeeks);
    
    // Bottom padding - less for week view to remove extra space
    final double bottomPadding = calendarProvider.isWeekView ? 8.0 : 16.0;
    
    // Total calculated height based on actual content
    final double calculatedHeight = topPadding + headerHeight + headerGap + dividerHeight + 
                                   dividerGap + weekdaysHeaderHeight + weekdaysGap + 
                                   monthDaysHeight + bottomPadding;
    
    // Screen height constraints
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxHeight = screenHeight * 0.7; // Maximum 70% of screen height
    
    // For week view, don't enforce minimum height to avoid extra space
    // For month view, enforce minimum height
    if (calendarProvider.isWeekView) {
      return calculatedHeight.clamp(0, maxHeight);
    } else {
      final double minHeight = screenHeight * 0.3; // Minimum 30% of screen height
      return calculatedHeight.clamp(minHeight, maxHeight);
    }
  }

}
