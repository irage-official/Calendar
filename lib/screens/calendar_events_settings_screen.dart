import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_icons.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../config/constants.dart';
import '../providers/app_provider.dart';
import '../providers/calendar_provider.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../widgets/custom_radio_button.dart';
import '../widgets/toggle_item_widget.dart';
import '../utils/svg_helper.dart';
import '../utils/extensions.dart';
import '../utils/calendar_utils.dart';
import '../utils/font_helper.dart';
import '../services/year_cache_service.dart';

class CalendarEventsSettingsScreen extends StatefulWidget {
  const CalendarEventsSettingsScreen({super.key});

  @override
  State<CalendarEventsSettingsScreen> createState() =>
      _CalendarEventsSettingsScreenState();
}

class _CalendarEventsSettingsScreenState
    extends State<CalendarEventsSettingsScreen> {
  bool _hasChanges = false;
  String? _initialCalendarSystem;
  String? _initialStartWeekOn;
  List<String>? _initialDaysOff;
  String? _initialDefaultCalendarView;
  List<String>? _initialEnabledOrigins;
  List<String>? _initialEnabledEventTypes;
  String? _selectedDefaultCalendarView;
  
  String? _calendarSystem; // Local state for calendar system
  String? _startWeekOn; // 'saturday', 'sunday', 'monday'
  List<String>? _daysOff; // ['saturday', 'sunday', 'friday', 'thursday']
  List<String>? _enabledOrigins; // Local state for origins
  List<String>? _enabledEventTypes; // Local state for event types

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final currentCalendarSystem = appProvider.calendarSystem;
      _initialCalendarSystem = currentCalendarSystem;
      _calendarSystem = currentCalendarSystem; // Initialize local state
      final normalizedStartWeekOn = _normalizeStoredStartWeekOn(
        appProvider.startWeekOn,
        currentCalendarSystem,
      );
      _initialStartWeekOn = normalizedStartWeekOn;
      _initialDefaultCalendarView = appProvider.defaultCalendarView;
      _selectedDefaultCalendarView = appProvider.defaultCalendarView;
      
      // Initialize with saved values or defaults
      _startWeekOn = normalizedStartWeekOn;
      
      // Default days off based on calendar system if not saved
      if (appProvider.daysOff != null && appProvider.daysOff!.isNotEmpty) {
        _daysOff = List<String>.from(appProvider.daysOff!);
      } else {
        _daysOff = _getDefaultDaysOff(appProvider.calendarSystem);
      }
      _initialDaysOff = List<String>.from(_daysOff ?? []);
      
      // Initialize enabled origins
      final allOrigins = ['iranian', 'international', 'mixed', 'local'];
      _enabledOrigins = appProvider.enabledOrigins ??
          allOrigins;
      _initialEnabledOrigins = List<String>.from(_enabledOrigins ?? []);
      
      // Initialize enabled event types
      final allTypes = ['celebration', 'historical', 'anniversary', 'memorial', 'awareness'];
      final currentEnabled = appProvider.enabledEventTypes;
      _enabledEventTypes = currentEnabled.isEmpty ||
              !currentEnabled.every((type) => allTypes.contains(type))
          ? allTypes
          : currentEnabled;
      _initialEnabledEventTypes = List<String>.from(_enabledEventTypes ?? []);
    });
  }

  void _onChange() {
    setState(() {
      if (!_hasChanges) {
        _hasChanges = true;
      }
    });
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    final sorted1 = List<String>.from(list1)..sort();
    final sorted2 = List<String>.from(list2)..sort();
    return sorted1.toString() == sorted2.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isPersian = appProvider.language == 'fa';
        
        // Check if any settings have changed
        if (_initialCalendarSystem != null) {
          final hasCalendarSystemChanged =
              _calendarSystem != _initialCalendarSystem;
          final hasStartWeekOnChanged = _startWeekOn != _initialStartWeekOn;
          final selectedDefaultView =
              _selectedDefaultCalendarView ?? appProvider.defaultCalendarView;
          final hasDefaultCalendarViewChanged =
              selectedDefaultView != _initialDefaultCalendarView;
          final hasDaysOffChanged =
              !_listsEqual(_daysOff ?? [], _initialDaysOff ?? []);
          final hasEnabledOriginsChanged =
              !_listsEqual(_enabledOrigins ?? [], _initialEnabledOrigins ?? []);
          final hasEnabledEventTypesChanged =
              !_listsEqual(_enabledEventTypes ?? [], _initialEnabledEventTypes ?? []);

          if ((hasCalendarSystemChanged ||
                  hasStartWeekOnChanged ||
                  hasDefaultCalendarViewChanged ||
                  hasDaysOffChanged ||
                  hasEnabledOriginsChanged ||
                  hasEnabledEventTypesChanged) &&
              !_hasChanges) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _onChange();
              }
            });
          }
          
          // Don't auto-update startWeekOn and daysOff when calendar system changes
          // User should be able to change them manually after changing calendar system
        }
        
        return Scaffold(
          backgroundColor: TBg.home(context),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header with back button and Save button
                _buildHeader(context, isPersian),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, top: 0, bottom: 32.0),
                    children: [
                      // Title Section
                      _buildTitleSection(context, isPersian),
                      const SizedBox(height: 16),
                      
                      // Calendar Settings Section
                      _buildCalendarSettingsSection(
                          context, appProvider, isPersian),
                      const SizedBox(height: 16),
                      
                      // Event Settings Section
                      _buildEventSettingsSection(
                          context, appProvider, isPersian),
                      const SizedBox(height: 16),
                      
                      // Duration Day Options Section (for future)
                      // _buildDurationDayOptionsSection(context, appProvider, isPersian),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isPersian) {
    return Container(
      height: 80.0,
      color: TBg.home(context),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: TBg.main(context),
              border: Border.all(
                color: TBr.neutralTertiary(context),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10.0),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  child: SvgIconWidget(
                    assetPath: AppIcons.arrowLeft,
                    size: 16.0,
                    color: TCnt.neutralSecond(context),
                  ),
                ),
              ),
            ),
          ),
          
          // Save button
          GestureDetector(
            onTap: _hasChanges
                ? () async {
                    if (!mounted) return;
                    
                    // Capture context and providers before async operations
                    final navigator = Navigator.of(context);
                    final appProvider =
                        Provider.of<AppProvider>(context, listen: false);
                    final calendarProvider =
                        Provider.of<CalendarProvider>(context, listen: false);
              
              // Save calendar system if changed
              final bool calendarSystemWillChange =
                  _calendarSystem != null && _calendarSystem != _initialCalendarSystem;
              final finalCalendarSystem = _calendarSystem ?? appProvider.calendarSystem;
              if (calendarSystemWillChange) {
                await appProvider.setCalendarSystem(_calendarSystem!);
                if (!mounted) return;
                // Update initial value after saving
                _initialCalendarSystem = _calendarSystem;
              }
              
              // Save start week on - use default if not set
              final finalStartWeekOn = _startWeekOn ?? _getDefaultStartWeekOn(finalCalendarSystem);
              await appProvider.setStartWeekOn(finalStartWeekOn);
              if (!mounted) return;
              // Update local state and initial value after saving
              _startWeekOn = finalStartWeekOn;
              _initialStartWeekOn = finalStartWeekOn;
              
              // Save days off - use default if not set
              final List<String> finalDaysOff;
              if (_daysOff != null) {
                finalDaysOff = _daysOff!;
              } else if (calendarSystemWillChange) {
                finalDaysOff = _getDefaultDaysOff(finalCalendarSystem);
              } else if (appProvider.daysOff != null && appProvider.daysOff!.isNotEmpty) {
                finalDaysOff = appProvider.daysOff!;
              } else {
                // Use default days off for current calendar system
                finalDaysOff = _getDefaultDaysOff(finalCalendarSystem);
              }
              await appProvider.setDaysOff(finalDaysOff);
              if (!mounted) return;
              // Update local state and initial value after saving
              _daysOff = finalDaysOff;
              _initialDaysOff = List<String>.from(finalDaysOff);
              
                    final selectedDefaultView = _selectedDefaultCalendarView ??
                        appProvider.defaultCalendarView;
                    if (selectedDefaultView !=
                        appProvider.defaultCalendarView) {
                      await appProvider
                          .setDefaultCalendarView(selectedDefaultView);
                      if (!mounted) return;
                calendarProvider.applyDefaultCalendarView(
                  selectedDefaultView,
                  calendarSystem: finalCalendarSystem,
                );
                _initialDefaultCalendarView = selectedDefaultView;
              }
              calendarProvider.syncFromAppSettings(
                calendarSystem: finalCalendarSystem,
                startWeekOn: finalStartWeekOn,
                daysOff: finalDaysOff,
              );
              
              // Save enabled origins
              if (_enabledOrigins != null) {
                final allOrigins = ['iranian', 'international', 'mixed', 'local'];
                await appProvider.setEnabledOrigins(
                    _enabledOrigins!.length == allOrigins.length
                        ? null
                        : _enabledOrigins);
                if (!mounted) return;
                _initialEnabledOrigins = List<String>.from(_enabledOrigins!);
              }
              
              // Save enabled event types
              if (_enabledEventTypes != null) {
                final allTypes = ['celebration', 'historical', 'anniversary', 'memorial', 'awareness'];
                final finalTypes =
                    _enabledEventTypes!.length == allTypes.length
                        ? allTypes
                        : _enabledEventTypes!;
                await appProvider.setEnabledEventTypes(finalTypes);
                if (!mounted) return;
                _initialEnabledEventTypes = List<String>.from(finalTypes);
              }
              
              // Reset hasChanges flag after saving
              if (mounted) {
                setState(() {
                  _hasChanges = false;
                });
              }
              
              // Preload years for the new calendar system in background (non-blocking)
              // This should not block navigation
              final yearCacheService = YearCacheService();
              final now = DateTime.now();
              
              // Get current year based on the new calendar system
              int currentYear;
              String calendarSystemForPreload = finalCalendarSystem;
              if (finalCalendarSystem == 'solar') {
                final jalali = CalendarUtils.gregorianToJalali(now);
                currentYear = jalali.year;
              } else if (finalCalendarSystem == 'shahanshahi') {
                // Shahanshahi uses the same calendar structure as solar, just with year offset
                final jalali = CalendarUtils.gregorianToJalali(now);
                currentYear = jalali.year; // Use jalali year for preload (shahanshahi = solar + offset)
                calendarSystemForPreload = 'solar'; // Preload as solar since structure is the same
              } else {
                currentYear = now.year;
              }
              
              // Preload in background - don't await, just start it
              unawaited(yearCacheService.preloadYears(currentYear, calendarSystem: calendarSystemForPreload));
              
              // Navigate immediately after saving (don't wait for preload)
              if (mounted) {
                navigator.pop();
              }
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: _hasChanges
                  ? BoxDecoration(
                      color: TCnt.brandMain(context).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(100),
                    )
                  : null,
              child: Text(
                isPersian ? 'ذخیره' : 'Save',
                style: isPersian
                    ? FontHelper.getYekanBakh(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _hasChanges 
                            ? TCnt.brandMain(context)
                            : TCnt.neutralWeak(context),
                      )
                    : FontHelper.getInter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _hasChanges 
                            ? TCnt.brandMain(context)
                            : TCnt.neutralWeak(context),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, bool isPersian) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🗓️',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            isPersian ? 'تقویم و رویدادها' : 'Calendar & Events',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.6,
                    letterSpacing: -0.4, // -2% of 20 = -0.4
                    color: TCnt.neutralMain(context),
                  )
                : FontHelper.getInter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.6,
                    letterSpacing: -0.4, // -2% of 20 = -0.4
                    color: TCnt.neutralMain(context),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            isPersian 
                ? 'تنظیم کنید که تقویم شما چگونه به نظر برسد و رویدادها چگونه نمایش داده شوند — ساده و واضح امکان‌پذیر است.'
                : 'Set how your calendar looks and how events appear — simple, clear, and made for you.',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    height: 1.6,
                    letterSpacing: -0.098, // -0.7% of 14 = -0.098
                    color: isDark 
                        ? TCnt.neutralSecond(context).withOpacity(0.8)
                        : TCnt.neutralSecond(context),
                  )
                : FontHelper.getInter(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    height: 1.6,
                    letterSpacing: -0.098, // -0.7% of 14 = -0.098
                    color: isDark 
                        ? TCnt.neutralSecond(context).withOpacity(0.8)
                        : TCnt.neutralSecond(context),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSettingsSection(
      BuildContext context, AppProvider appProvider, bool isPersian) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
        //   child: Text(
        //     isPersian ? 'تنظیمات تقویم' : 'Calendar Settings',
        //     style: AppTextStyles.bodyMedium.copyWith(
        //       fontSize: 14,
        //       fontWeight: FontWeight.w500,
        //       height: 1.4,
        //       letterSpacing: -0.28, // -2% of 14 = -0.28
        //       color: TCnt.neutralTertiary(context),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 8),
        // Items
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: TBg.main(context),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: [
              _buildCalendarSettingItem(
                context: context,
                title: isPersian ? 'حالت نمایش' : 'View Mode',
                subtitle: _getCurrentDefaultCalendarText(
                  _selectedDefaultCalendarView ??
                      appProvider.defaultCalendarView,
                  isPersian,
                ),
                onTap: () => _showDefaultCalendarBottomSheet(
                    context, appProvider, isPersian),
                isRtl: isRtl,
                isPersian: isPersian,
              ),
              Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Divider(
                    height: 1,
                    thickness: 1,
                    color: TBr.neutralTertiary(context)
                        .withOpacity(isDark ? 0.3 : 0.6),
                    indent: 16,
                    endIndent: 8,
                  );
                },
              ),
              _buildCalendarSettingItem(
                context: context,
                title: isPersian ? 'سیستم تقویم' : 'Calendar System',
                subtitle: _getCurrentCalendarSystemText(
                    _calendarSystem ?? appProvider.calendarSystem, isPersian),
                onTap: () => _showCalendarSystemBottomSheet(context, isPersian),
                isRtl: isRtl,
                isPersian: isPersian,
              ),
              Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Divider(
                    height: 1,
                    thickness: 1,
                    color: TBr.neutralTertiary(context)
                        .withOpacity(isDark ? 0.3 : 0.6),
                    indent: 16,
                    endIndent: 8,
                  );
                },
              ),
              _buildCalendarSettingItem(
                context: context,
                title: isPersian ? 'شروع هفته از' : 'Start week on',
                subtitle: _getCurrentStartWeekOnText(appProvider, isPersian),
                onTap: () => _showStartWeekOnBottomSheet(
                    context, appProvider, isPersian),
                isRtl: isRtl,
                isPersian: isPersian,
              ),
              Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Divider(
                    height: 1,
                    thickness: 1,
                    color: TBr.neutralTertiary(context)
                        .withOpacity(isDark ? 0.3 : 0.6),
                    indent: 16,
                    endIndent: 8,
                  );
                },
              ),
              _buildCalendarSettingItem(
                context: context,
                title: isPersian ? 'روزهای تعطیل' : 'Days off',
                subtitle: _getCurrentDaysOffText(appProvider, isPersian),
                onTap: () =>
                    _showDaysOffBottomSheet(context, appProvider, isPersian),
                isRtl: isRtl,
                isPersian: isPersian,
              ),
            ],
          ),
        ),
        // const SizedBox(height: 8),
        // Description
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //   child: Text(
        //     isPersian 
        //         ? 'تنظیم کنید که تقویم شما چگونه نمایش داده شود و هفته از کدام روز شروع شود.'
        //         : 'Set how your calendar is displayed and which day the week starts on.',
        //     style: AppTextStyles.bodySmall.copyWith(
        //       fontSize: 12,
        //       fontWeight: FontWeight.normal,
        //       height: 1.6,
        //       letterSpacing: -0.24, // -2% of 12 = -0.24
        //       color: TCnt.neutralFourth(context),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildCalendarSettingItem({
    required BuildContext context,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isRtl,
    required bool isPersian,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        child: Padding(
          padding: EdgeInsets.only(
            left: isRtl ? 8.0 : 16.0,
            right: isRtl ? 16.0 : 8.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: isPersian
                              ? FontHelper.getYekanBakh(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: TCnt.neutralMain(context),
                                  height: 1.4,
                                  letterSpacing: -0.007,
                                )
                              : FontHelper.getInter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: TCnt.neutralMain(context),
                                  height: 1.4,
                                  letterSpacing: -0.007,
                                ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        Text(
                          subtitle,
                          style: isPersian
                              ? FontHelper.getYekanBakh(
                                  fontSize: 12,
                                  color: TCnt.neutralFourth(context),
                                  height: 1.4,
                                  letterSpacing: -0.007,
                                )
                              : FontHelper.getInter(
                                  fontSize: 12,
                                  color: TCnt.neutralFourth(context),
                                  height: 1.4,
                                  letterSpacing: -0.007,
                                ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(4),
                child: Transform(
                  alignment: Alignment.center,
                  transform: isRtl
                      ? (Matrix4.identity()..rotateY(3.1415926535))
                      : Matrix4.identity(),
                  child: SvgPicture.asset(
                    AppIcons.chevronRight,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      TCnt.neutralWeak(context),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventSettingsSection(
      BuildContext context, AppProvider appProvider, bool isPersian) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: Text(
            isPersian ? 'تنظیمات رویداد' : 'Event Settings',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: -0.28, // -2% of 14 = -0.28
                    color: TCnt.neutralTertiary(context),
                  )
                : FontHelper.getInter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: -0.28, // -2% of 14 = -0.28
                    color: TCnt.neutralTertiary(context),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        // Items
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: TBg.main(context),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: [
              _buildSettingItemWithoutIcon(
                context: context,
                title: isPersian ? 'منابع' : 'Origins',
                onTap: () {
                  _showOriginsSelection(context, isPersian);
                },
                isRtl: isRtl,
                isPersian: isPersian,
              ),
              Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Divider(
                    height: 1,
                    thickness: 1,
                    color: TBr.neutralTertiary(context)
                        .withOpacity(isDark ? 0.3 : 0.6),
                    indent: 16,
                    endIndent: 8,
                  );
                },
              ),
              _buildSettingItemWithoutIcon(
                context: context,
                title: isPersian ? 'انواع رویداد' : 'Event Types',
                onTap: () {
                  _showEventTypesSelection(context, isPersian);
                },
                isRtl: isRtl,
                isPersian: isPersian,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            isPersian 
                ? 'انتخاب کنید که کدام منابع و انواع رویدادها را می‌خواهید ببینید.'
                : 'Choose which event origins and types you want to see.',
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    height: 1.6,
                    letterSpacing: -0.24, // -2% of 12 = -0.24
                    color: TCnt.neutralFourth(context),
                  )
                : FontHelper.getInter(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    height: 1.6,
                    letterSpacing: -0.24, // -2% of 12 = -0.24
                    color: TCnt.neutralFourth(context),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItemWithoutIcon({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    required bool isRtl,
    required bool isPersian,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        child: Padding(
          padding: EdgeInsets.only(
            left: isRtl ? 8.0 : 16.0,
            right: isRtl ? 16.0 : 8.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  child: Text(
                    title,
                    style: isPersian
                        ? FontHelper.getYekanBakh(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: TCnt.neutralMain(context),
                            height: 1.4,
                            letterSpacing: -0.007,
                          )
                        : FontHelper.getInter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: TCnt.neutralMain(context),
                            height: 1.4,
                            letterSpacing: -0.007,
                          ),
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(4),
                child: Transform(
                  alignment: Alignment.center,
                  transform: isRtl
                      ? (Matrix4.identity()..rotateY(3.1415926535))
                      : Matrix4.identity(),
                  child: SvgPicture.asset(
                    AppIcons.chevronRight,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      TCnt.neutralWeak(context),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildDurationDayOptionsSection(BuildContext context, AppProvider appProvider, bool isPersian) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.only(bottom: 12.0),
  //         child: Text(
  //           isPersian ? 'گزینه‌های روز مدت' : 'Duration day options',
  //           style: AppTextStyles.bodyMedium.copyWith(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w500,
  //             color: TCnt.neutralMain(context).withOpacity(0.4),
  //           ),
  //         ),
  //       ),
  //       Container(
  //         padding: const EdgeInsets.all(16.0),
  //         decoration: BoxDecoration(
  //           color: TBg.card(context),
  //           borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
  //         ),
  //         child: Column(
  //           children: [
  //             SettingItem(
  //               icon: AppIcons.clockCircle,
  //               title: isPersian ? 'شروع در' : 'Starts at',
  //               subtitle: '08:00 AM',
  //               onTap: () {},
  //               margin: EdgeInsets.zero,
  //             ),
  //             SettingItem(
  //               icon: AppIcons.clockCircle,
  //               title: isPersian ? 'پایان در' : 'Ends at',
  //               subtitle: '06:00 PM',
  //               onTap: () {},
  //               margin: EdgeInsets.zero,
  //             ),
  //             SettingItem(
  //               icon: AppIcons.clockCircle,
  //               title: isPersian ? 'زمان پیش‌فرض' : 'Default time',
  //               subtitle: isPersian ? '1 ساعت' : '1 hour',
  //               onTap: () {},
  //               margin: EdgeInsets.zero,
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         isPersian 
  //             ? 'زمان شروع، زمان پایان و مدت پیش‌فرض مورد نظر خود را تنظیم کنید.'
  //             : 'Set your preferred start time, end time, and default duration.',
  //         style: AppTextStyles.bodySmall.copyWith(
  //           fontSize: 12,
  //           color: TCnt.neutralFourth(context),
  //           height: 1.5,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  String _getDefaultStartWeekOn(String calendarSystem) {
    return calendarSystem == 'gregorian' ? 'monday' : 'saturday';
  }

  List<String> _getDefaultDaysOff(String calendarSystem) {
    if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
      return ['friday'];
    }
    return ['saturday', 'sunday'];
  }

  String _effectiveStartWeekOn(AppProvider appProvider) {
    if (_startWeekOn != null) {
      return _startWeekOn!;
    }
    // Use local calendar system if available, otherwise use appProvider's
    final calendarSystem = _calendarSystem ?? appProvider.calendarSystem;
    return _getDefaultStartWeekOn(calendarSystem);
  }

  String _normalizeStoredStartWeekOn(
      String? storedValue, String calendarSystem) {
    const allowedValues = {'saturday', 'sunday', 'monday'};
    if (storedValue == null) {
      return _getDefaultStartWeekOn(calendarSystem);
    }
    if (allowedValues.contains(storedValue)) {
      return storedValue;
    }
    if (storedValue == 'region') {
      return _getDefaultStartWeekOn(calendarSystem);
    }
    return _getDefaultStartWeekOn(calendarSystem);
  }

  String _getCurrentCalendarSystemText(String calendarSystem, bool isPersian) {
    if (calendarSystem == 'solar') {
      return isPersian ? 'شمسی' : 'Solar Hijri';
    } else if (calendarSystem == 'shahanshahi') {
      return isPersian ? 'شاهنشاهی' : 'Shahanshahi';
    } else {
      return isPersian ? 'میلادی' : 'Gregorian';
    }
  }

  String _getCurrentStartWeekOnText(AppProvider appProvider, bool isPersian) {
    // Use _effectiveStartWeekOn to get the correct value (respects local state)
    final startWeekOn = _effectiveStartWeekOn(appProvider);
    switch (startWeekOn) {
      case 'saturday':
        return isPersian ? 'شنبه' : 'Saturday';
      case 'sunday':
        return isPersian ? 'یکشنبه' : 'Sunday';
      case 'monday':
        return isPersian ? 'دوشنبه' : 'Monday';
      default:
        final calendarSystem = _calendarSystem ?? appProvider.calendarSystem;
        final defaultDay = _getDefaultStartWeekOn(calendarSystem);
        return defaultDay == 'monday'
            ? (isPersian ? 'دوشنبه' : 'Monday')
            : (isPersian ? 'شنبه' : 'Saturday');
    }
  }

  String _getCurrentDefaultCalendarText(
      String defaultCalendarView, bool isPersian) {
    if (defaultCalendarView == 'month') {
      return isPersian ? 'ماهانه' : 'Monthly';
    } else {
      return isPersian ? 'هفته‌ای' : 'Weekly';
    }
  }

  String _getCurrentDaysOffText(AppProvider appProvider, bool isPersian) {
    // Use _daysOff if available, otherwise use appProvider.daysOff
    // If calendar system changed, show preview of default days off for new system
    final calendarSystem = _calendarSystem ?? appProvider.calendarSystem;
    final bool calendarSystemChanged =
        _calendarSystem != null && _calendarSystem != appProvider.calendarSystem;
    final List<String> daysOff;
    if (_daysOff != null) {
      daysOff = _daysOff!;
    } else if (calendarSystemChanged) {
      daysOff = _getDefaultDaysOff(calendarSystem);
    } else if (appProvider.daysOff != null && appProvider.daysOff!.isNotEmpty) {
      daysOff = appProvider.daysOff!;
    } else {
      // Show preview of default days off for current calendar system
      daysOff = _getDefaultDaysOff(calendarSystem);
    }
    if (daysOff.isEmpty) {
      return isPersian ? 'هیچ' : 'None';
    }
    
    final dayNames = <String, String>{
      'monday': isPersian ? 'دوشنبه' : 'Monday',
      'tuesday': isPersian ? 'سه‌شنبه' : 'Tuesday',
      'wednesday': isPersian ? 'چهارشنبه' : 'Wednesday',
      'thursday': isPersian ? 'پنج‌شنبه' : 'Thursday',
      'friday': isPersian ? 'جمعه' : 'Friday',
      'saturday': isPersian ? 'شنبه' : 'Saturday',
      'sunday': isPersian ? 'یکشنبه' : 'Sunday',
    };
    
    final translatedDays = daysOff.map((day) => dayNames[day] ?? day).toList();
    return translatedDays.join(isPersian ? '، ' : ', ');
  }

  void _showCalendarSystemBottomSheet(BuildContext context, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      isScrollControlled: true,
      builder: (context) => Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final currentCalendarSystem = _calendarSystem ?? appProvider.calendarSystem;
          return SettingsBottomSheet(
            title: isPersian ? 'تغییر تقویم' : 'Change Calendar',
            description: isPersian
                ? 'سیستم تقویمی را بر اساس نیازتان انتخاب کنید.'
                : 'Choose the calendar system that fits your preference.',
            content: Column(
              children: [
                // Gregorian option
                CustomRadioButton(
                  label: isPersian ? 'میلادی (Gregorian)' : 'Gregorian',
                  isSelected: currentCalendarSystem == 'gregorian',
                  onTap: () {
                    setState(() {
                      // Update calendar system and reset startWeekOn/daysOff to null
                      // So user can change them manually (they'll show preview of defaults)
                      _calendarSystem = 'gregorian';
                      _startWeekOn = null; // Reset to allow user to change
                      _daysOff = null; // Reset to allow user to change
                      _onChange();
                    });
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                // Shahanshahi option
                CustomRadioButton(
                  label: isPersian
                      ? 'شاهنشاهی (Shahanshahi)'
                      : 'Shahanshahi (شاهنشاهی)',
                  isSelected: currentCalendarSystem == 'shahanshahi',
                  onTap: () {
                    setState(() {
                      // Update calendar system and reset startWeekOn/daysOff to null
                      // So user can change them manually (they'll show preview of defaults)
                      _calendarSystem = 'shahanshahi';
                      _startWeekOn = null; // Reset to allow user to change
                      _daysOff = null; // Reset to allow user to change
                      _onChange();
                    });
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                // Solar Hijri option
                CustomRadioButton(
                  label:
                      isPersian ? 'شمسی (Solar Hijri)' : 'Solar Hijri (شمسی)',
                  isSelected: currentCalendarSystem == 'solar',
                  onTap: () {
                    setState(() {
                      // Update calendar system and reset startWeekOn/daysOff to null
                      // So user can change them manually (they'll show preview of defaults)
                      _calendarSystem = 'solar';
                      _startWeekOn = null; // Reset to allow user to change
                      _daysOff = null; // Reset to allow user to change
                      _onChange();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStartWeekOnBottomSheet(
      BuildContext context, AppProvider appProvider, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      isScrollControlled: true,
      builder: (context) {
        return SettingsBottomSheet(
          title: isPersian ? 'شروع هفته از' : 'Start week on',
          description: isPersian
              ? 'روز شروع هفته را انتخاب کنید.'
              : 'Choose which day the week starts on.',
          content: Column(
            children: [
              CustomRadioButton(
                label: isPersian ? 'شنبه' : 'Saturday',
                isSelected: _effectiveStartWeekOn(appProvider) == 'saturday',
                onTap: () {
                  setState(() {
                    _startWeekOn = 'saturday';
                    _onChange();
                  });
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              CustomRadioButton(
                label: isPersian ? 'یکشنبه' : 'Sunday',
                isSelected: _effectiveStartWeekOn(appProvider) == 'sunday',
                onTap: () {
                  setState(() {
                    _startWeekOn = 'sunday';
                    _onChange();
                  });
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              CustomRadioButton(
                label: isPersian ? 'دوشنبه' : 'Monday',
                isSelected: _effectiveStartWeekOn(appProvider) == 'monday',
                onTap: () {
                  setState(() {
                    _startWeekOn = 'monday';
                    _onChange();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDefaultCalendarBottomSheet(
      BuildContext context, AppProvider appProvider, bool isPersian) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      isScrollControlled: true,
      builder: (context) {
        return SettingsBottomSheet(
          title: isPersian ? 'حالت نمایش' : 'Default Calendar View',
          description: isPersian
              ? 'نوع نمایش پیش‌فرض تقویم را انتخاب کنید.'
              : 'Select your preferred default calendar layout for the Home screen.',
          content: Column(
            children: [
              CustomRadioButton(
                label: isPersian ? 'هفته‌ای' : 'Weekly',
                isSelected: (_selectedDefaultCalendarView ??
                        appProvider.defaultCalendarView) ==
                    'week',
                onTap: () {
                  setState(() {
                    _selectedDefaultCalendarView = 'week';
                  });
                  _onChange();
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              CustomRadioButton(
                label: isPersian ? 'ماهانه' : 'Monthly',
                isSelected: (_selectedDefaultCalendarView ??
                        appProvider.defaultCalendarView) ==
                    'month',
                onTap: () {
                  setState(() {
                    _selectedDefaultCalendarView = 'month';
                  });
                  _onChange();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDaysOffBottomSheet(
      BuildContext context, AppProvider appProvider, bool isPersian) {
    // Get initial days off from state or appProvider
    // If calendar system changed, use preview of default days off
    final calendarSystem = _calendarSystem ?? appProvider.calendarSystem;
    final bool calendarSystemChanged =
        _calendarSystem != null && _calendarSystem != appProvider.calendarSystem;
    final List<String> initialDaysOff;
    if (_daysOff != null) {
      initialDaysOff = List<String>.from(_daysOff!);
    } else if (calendarSystemChanged) {
      initialDaysOff = _getDefaultDaysOff(calendarSystem);
    } else if (appProvider.daysOff != null && appProvider.daysOff!.isNotEmpty) {
      initialDaysOff = List<String>.from(appProvider.daysOff!);
    } else {
      // Use preview of default days off for current calendar system
      initialDaysOff = _getDefaultDaysOff(calendarSystem);
    }
    // Store state outside builder to persist across rebuilds
    final localDaysOff = <String>[];
    localDaysOff.addAll(initialDaysOff);
    
    // Get startWeekOn to order days correctly - use local state if available
    final startWeekOn = _startWeekOn ?? _getDefaultStartWeekOn(calendarSystem);
    
    // Get ordered week days based on startWeekOn
    final weekdayKeys = CalendarUtils.getOrderedWeekdayKeys(startWeekOn);
    
    // Map for day labels
    final dayLabels = {
      'monday': {'fa': 'د', 'en': 'Mon'},
      'tuesday': {'fa': 'س', 'en': 'Tue'},
      'wednesday': {'fa': 'چ', 'en': 'Wed'},
      'thursday': {'fa': 'پ', 'en': 'Thu'},
      'friday': {'fa': 'ج', 'en': 'Fri'},
      'saturday': {'fa': 'ش', 'en': 'Sat'},
      'sunday': {'fa': 'ی', 'en': 'Sun'},
    };
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SettingsBottomSheet(
              title: isPersian ? 'روزهای تعطیل' : 'Select days off',
              description: isPersian
                  ? 'روزهای تعطیل را انتخاب کنید.'
                  : 'Choose which days are off for you.',
          content: Column(
            children: [
                  // Horizontal row of day buttons
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Get actual available width (constraints already account for padding)
                      final availableWidth = constraints.maxWidth;
                      final buttonSize = 36.0;
                      final totalButtonsWidth = buttonSize * 7;
                      final availableSpace = availableWidth - totalButtonsWidth;
                      // Calculate spacing: 7 buttons need 6 gaps between them
                      // Each button has spacing on the right (except the last one)
                      // So we divide by 6 for the gaps between buttons
                      final spacing = availableSpace.clamp(0.0, double.infinity) / 6; // 6 gaps between 7 buttons
                      
                      return SizedBox(
                        width: availableWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: weekdayKeys.map((day) {
                            return _buildDayOffButton(
                              spacing: spacing,
                              context: context,
                              day: day,
                              label: dayLabels[day]?[isPersian ? 'fa' : 'en'] ?? day,
                              isSelected: localDaysOff.contains(day),
                              onTap: () {
                                // Check if trying to add when already 3 days selected
                                if (!localDaysOff.contains(day) &&
                                    localDaysOff.length >= 3) {
                                  context.showToast(
                                    isPersian
                                        ? 'نمیشه و بیشتر از ۳ روز امکان پذیر نیست!'
                                        : 'Cannot select more than 3 days!',
                                  );
                                  return;
                                }
                                
                                setModalState(() {
                                  if (localDaysOff.contains(day)) {
                                    // Don't allow removing if it's the last day
                                    if (localDaysOff.length > 1) {
                                      localDaysOff.remove(day);
                                    }
                                  } else {
                                    localDaysOff.add(day);
                                  }
                                  // Update parent state for save button
                                  _daysOff = List<String>.from(localDaysOff);
                                });
                                // Update main screen UI
                                _onChange();
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Display selected days text
                  _buildSelectedDaysText(context, localDaysOff, isPersian),
            ],
          ),
            );
          },
        );
      },
    );
  }

  Widget _buildDayOffButton({
    required BuildContext context,
    required String day,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required double spacing,
  }) {
    final buttonSize = 36.0;
    
    return Padding(
      padding: EdgeInsets.only(right: spacing),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? TCnt.brandMain(context)
                  : Theme.of(context).brightness == Brightness.dark
                      ? TBg.neutralButton(context)
                      : ThemeColors.gray900.withOpacity(0.06),
            ),
            child: Center(
              child: Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  final isPersian = appProvider.language == 'fa';
                  return Text(
                    label,
                    style: isPersian
                        ? FontHelper.getYekanBakh(
                            fontSize: 14,
                            height: 1.4, // 140%
                            letterSpacing: -0.098, // -0.7% of 14 = -0.098
                            fontWeight: isSelected
                                ? FontWeight.w600 // semi bold
                                : FontWeight.w400, // regular
                            color: isSelected
                                ? TCnt.unsurface(context)
                                : TCnt.neutralTertiary(context),
                          )
                        : FontHelper.getInter(
                            fontSize: 14,
                            height: 1.4, // 140%
                            letterSpacing: -0.098, // -0.7% of 14 = -0.098
                            fontWeight: isSelected
                                ? FontWeight.w600 // semi bold
                                : FontWeight.w400, // regular
                            color: isSelected
                                ? TCnt.unsurface(context)
                                : TCnt.neutralTertiary(context),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDaysText(
      BuildContext context, List<String> daysOff, bool isPersian) {
    if (daysOff.isEmpty) {
      return const SizedBox.shrink();
    }

    final dayNames = {
      'monday': {'fa': 'دوشنبه', 'en': 'Monday'},
      'tuesday': {'fa': 'سه‌شنبه', 'en': 'Tuesday'},
      'wednesday': {'fa': 'چهارشنبه', 'en': 'Wednesday'},
      'thursday': {'fa': 'پنج‌شنبه', 'en': 'Thursday'},
      'friday': {'fa': 'جمعه', 'en': 'Friday'},
      'saturday': {'fa': 'شنبه', 'en': 'Saturday'},
      'sunday': {'fa': 'یکشنبه', 'en': 'Sunday'},
    };

    final selectedDayNames = daysOff
        .map((day) => dayNames[day]?[isPersian ? 'fa' : 'en'] ?? day)
        .toList();
    
    // Keep a copy for bold text detection
    final selectedDayNamesCopy = List<String>.from(selectedDayNames);

    String text;
    if (selectedDayNames.length == 1) {
      text = isPersian
          ? '${selectedDayNames[0]} تعطیل است'
          : '${selectedDayNames[0]} is day off';
    } else if (selectedDayNames.length == 2) {
      text = isPersian
          ? '${selectedDayNames[0]} و ${selectedDayNames[1]} تعطیل هستند'
          : '${selectedDayNames[0]} and ${selectedDayNames[1]} is day off';
    } else {
      final lastDay = selectedDayNames.removeLast();
      final otherDays = selectedDayNames.join(isPersian ? '، ' : ', ');
      text = isPersian
          ? '$otherDays و $lastDay تعطیل هستند'
          : '$otherDays and $lastDay is day off';
    }

    // Build text with selected days in semi-bold
    return _buildTextWithBoldDays(
      context: context,
      text: text,
      selectedDays: selectedDayNamesCopy,
      isPersian: isPersian,
    );
  }

  Widget _buildTextWithBoldDays({
    required BuildContext context,
    required String text,
    required List<String> selectedDays,
    required bool isPersian,
  }) {
    final spans = <TextSpan>[];
    
    // Find all matches for selected days (whole words only)
    // We need to match whole words to avoid matching "شنبه" inside "چهارشنبه" or "یکشنبه"
    int lastIndex = 0;
    final matches = <({int start, int end, String text})>[];
    
    // Sort selected days by length (longest first) to match longer names first
    final sortedDays = List<String>.from(selectedDays)..sort((a, b) => b.length.compareTo(a.length));
    
    for (final day in sortedDays) {
      // Find all occurrences of this day as a whole word
      int searchIndex = 0;
      while (true) {
        final index = text.indexOf(day, searchIndex);
        if (index == -1) break;
        
        // Check if it's a whole word (not part of another word)
        final beforeChar = index > 0 ? text[index - 1] : ' ';
        final afterIndex = index + day.length;
        final afterChar = afterIndex < text.length ? text[afterIndex] : ' ';
        final isWordBoundary = (index == 0 || beforeChar == ' ' || beforeChar == '،' || beforeChar == ',') &&
                                (afterIndex >= text.length || afterChar == ' ' || afterChar == '،' || afterChar == ',');
        
        if (isWordBoundary) {
          // Check if this match doesn't overlap with existing matches
          bool overlaps = false;
          for (final existing in matches) {
            if (index < existing.end && index + day.length > existing.start) {
              overlaps = true;
              break;
            }
          }
          if (!overlaps) {
            matches.add((start: index, end: index + day.length, text: day));
          }
        }
        
        searchIndex = index + 1;
      }
    }
    
    // Sort matches by start position
    matches.sort((a, b) => a.start.compareTo(b.start));
    
    for (final match in matches) {
      // Add text before match
      if (match.start > lastIndex) {
        final beforeText = text.substring(lastIndex, match.start);
        if (beforeText.isNotEmpty) {
          spans.add(TextSpan(
            text: beforeText,
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: TCnt.neutralMain(context),
                  )
                : FontHelper.getInter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: TCnt.neutralMain(context),
                  ),
          ));
        }
      }
      
      // Add matched day in bold
      spans.add(TextSpan(
        text: match.text,
        style: isPersian
            ? FontHelper.getYekanBakh(
                fontSize: 14,
                fontWeight: FontWeight.w600, // semi bold
                color: TCnt.neutralMain(context),
              )
            : FontHelper.getInter(
                fontSize: 14,
                fontWeight: FontWeight.w600, // semi bold
                color: TCnt.neutralMain(context),
              ),
      ));
      
      lastIndex = match.end;
    }
    
    // Add remaining text
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        spans.add(TextSpan(
          text: remainingText,
          style: isPersian
              ? FontHelper.getYekanBakh(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: TCnt.neutralMain(context),
                )
              : FontHelper.getInter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: TCnt.neutralMain(context),
                ),
        ));
      }
    }
    
    // If no matches found, return regular text
    if (spans.isEmpty) {
      return Text(
        text,
        style: isPersian
            ? FontHelper.getYekanBakh(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: TCnt.neutralMain(context),
              )
            : FontHelper.getInter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: TCnt.neutralMain(context),
              ),
        textAlign: TextAlign.center,
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.center,
    );
  }

  void _showOriginsSelection(BuildContext context, bool isPersian) {
    // Use local state instead of appProvider
    final allOrigins = ['iranian', 'international', 'mixed', 'local'];
    final initialOrigins = _enabledOrigins ?? allOrigins;
    final localOrigins = <String>[];
    localOrigins.addAll(initialOrigins);

    final originLabels = {
      'iranian': {'fa': 'ایرانی', 'en': 'Iranian'},
      'international': {'fa': 'بین‌المللی', 'en': 'International'},
      'mixed': {'fa': 'ترکیبی', 'en': 'Mixed'},
      'local': {'fa': 'محلی', 'en': 'Local'},
    };
    final originDescriptions = {
      'iranian': {
        'fa': 'رویدادهای ریشه‌دار در میراث و هویت ایرانی',
        'en': 'Events rooted in Iranian heritage and identity.'
      },
      'international': {
        'fa': 'رویدادهای مهم جهانی یا فرهنگی در سراسر جهان',
        'en': 'Major global or worldwide cultural events.'
      },
      'mixed': {
        'fa': 'رویدادهای ترکیبی یا چندمنبعی',
        'en': 'Combined or multi-origin events.'
      },
      'local': {
        'fa': 'رویدادهای منطقه‌ای یا شهری',
        'en': 'Region-specific or city events.'
      },
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SettingsBottomSheet(
              title: isPersian ? 'منابع' : 'Origins',
              description: isPersian
                  ? 'منبع رویدادهایی را که می‌خواهید در تقویم شما نمایش داده شوند انتخاب کنید.'
                  : 'Choose the origin of events you want to appear in your calendar.',
              content: Column(
                children: allOrigins.map((origin) {
                  final isSelected = localOrigins.contains(origin);
                  final label =
                      originLabels[origin]?[isPersian ? 'fa' : 'en'] ?? origin;
                  final description =
                      originDescriptions[origin]?[isPersian ? 'fa' : 'en'] ?? '';

                  return Column(
                    children: [
                      ToggleItem(
                        title: label,
                        description: description,
                        isSelected: isSelected,
                        origin: origin,
                        isRtl: isPersian,
                        onChanged: (value) {
                          setModalState(() {
                            if (value) {
                              if (!localOrigins.contains(origin)) {
                                localOrigins.add(origin);
                              }
                            } else {
                              localOrigins.remove(origin);
                            }
                            // Update local state
                            _enabledOrigins = List<String>.from(localOrigins);
                            _onChange();
                          });
                        },
                      ),
                      if (origin != allOrigins.last) const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _showEventTypesSelection(BuildContext context, bool isPersian) {
    // Only 5 event types as per design
    final allTypes = [
      'celebration',
      'historical',
      'anniversary',
      'memorial',
      'awareness',
    ];

    // Use local state instead of appProvider
    final initialTypes = _enabledEventTypes ?? allTypes;
    final localTypes = <String>[];
    localTypes.addAll(initialTypes);

    final typeLabels = {
      'celebration': {'fa': 'جشن', 'en': 'Celebration'},
      'historical': {'fa': 'تاریخی', 'en': 'Historical'},
      'anniversary': {'fa': 'سالگرد', 'en': 'Anniversary'},
      'memorial': {'fa': 'یادبود', 'en': 'Memorial'},
      'awareness': {'fa': 'آگاهی', 'en': 'Awareness'},
    };
    final typeDescriptions = {
      'celebration': {
        'fa': 'مناسبت‌های شاد فرهنگی یا شخصی',
        'en': 'Joyful cultural or personal occasions'
      },
      'historical': {
        'fa': 'نقاط عطف مهم سیاسی، اجتماعی یا فرهنگی',
        'en': 'Significant political, social, or cultural milestones'
      },
      'anniversary': {
        'fa': 'سالگرد تولد، درگذشت یا رویدادهای مهم',
        'en': 'Birth, death, or major event anniversaries'
      },
      'memorial': {
        'fa': 'گرامیداشت جان‌های از دست رفته یا یادآوری رویدادهای تأثیرگذار',
        'en': 'Honoring lives lost or remembering impactful times'
      },
      'awareness': {
        'fa': 'روزهای اختصاص یافته به مسائل اجتماعی، سلامت یا جهانی',
        'en': 'Days dedicated to social, health, or global causes'
      },
    };
    final typeEmojis = {
      'celebration': '🎉',
      'historical': '🏛️',
      'anniversary': '🎂',
      'memorial': '🕯️',
      'awareness': '🌱',
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SettingsBottomSheet(
              title: isPersian ? 'انواع رویداد' : 'Event Types',
              description: isPersian
                  ? 'دسته‌بندی‌های رویدادهایی را که ترجیح می‌دهید در تقویم خود ببینید انتخاب کنید.'
                  : 'Choose the categories of events you prefer to see on your calendar.',
              content: Column(
                children: allTypes.map((type) {
                  final isSelected = localTypes.contains(type);
                  final label =
                      typeLabels[type]?[isPersian ? 'fa' : 'en'] ?? type;
                  final description =
                      typeDescriptions[type]?[isPersian ? 'fa' : 'en'] ?? '';
                  final emoji = typeEmojis[type];

                  return Column(
                    children: [
                      ToggleItem(
                        title: label,
                        description: description,
                        isSelected: isSelected,
                        icon: emoji != null
                            ? Text(
                                emoji,
                                style: const TextStyle(fontSize: 22),
                              )
                            : null,
                        isRtl: isPersian,
                        onChanged: (value) {
                          setModalState(() {
                            if (value) {
                              if (!localTypes.contains(type)) {
                                localTypes.add(type);
                              }
                            } else {
                              localTypes.remove(type);
                            }
                            // Update local state
                            _enabledEventTypes = List<String>.from(localTypes);
                            _onChange();
                          });
                        },
                      ),
                      if (type != allTypes.last) const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

// Helper function to run async code without awaiting
void unawaited(Future<void> future) {
  future.catchError((error) {
    debugPrint('Unawaited future error: $error');
  });
}
