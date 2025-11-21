import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/theme_roles.dart';
import '../models/event.dart';
import '../utils/calendar_utils.dart';
import '../utils/font_helper.dart';
import '../providers/app_provider.dart';

/// Display + behavior settings required to render a single day cell.
class DayWidgetConfig {
  const DayWidgetConfig({
    required this.date,
    required this.displayedMonth,
    required this.selectedDate,
    required this.today,
    required this.calendarSystem,
    required this.language,
    this.daysOff = const [],
    this.showEquivalentDate = true,
    this.showEventIndicators = true,
    this.events = const [],
    this.enabledOrigins,
    this.enabledTypes,
  });

  /// Base Gregorian date that represents this cell.
  final DateTime date;

  /// Gregorian month currently displayed (used to detect greyed-out days).
  final DateTime displayedMonth;

  /// Currently selected day in Gregorian.
  final DateTime selectedDate;

  /// Today's date (Gregorian).
  final DateTime today;

  /// One of: gregorian, solar, shahanshahi.
  final String calendarSystem;

  /// Active UI language (fa / en / ...).
  final String language;

  /// Weekday names (e.g. ['friday','thursday']) to highlight as days off.
  final List<String> daysOff;

  /// Whether to show the secondary (equivalent) date label.
  final bool showEquivalentDate;

  /// Whether to show colored event indicators.
  final bool showEventIndicators;

  /// Events that belong to this exact date (already filtered by date).
  final List<Event> events;

  /// Optional whitelist of origins (e.g., iranian, international).
  final List<String>? enabledOrigins;

  /// Optional whitelist of event types (e.g., festival, remembrance).
  final List<String>? enabledTypes;

  bool get isSolarSystem =>
      calendarSystem == 'solar' || calendarSystem == 'shahanshahi';
  bool get isPersianLanguage => language == 'fa';
}

/// Immutable model that's easy for UI widgets to consume.
class DayWidgetModel {
  const DayWidgetModel({
    required this.mainLabel,
    required this.equivalentLabel,
    required this.isSelected,
    required this.isToday,
    required this.isCurrentMonth,
    required this.isOffDay,
    required this.eventIndicatorColors,
  });

  final String mainLabel;
  final String? equivalentLabel;
  final bool isSelected;
  final bool isToday;
  final bool isCurrentMonth;
  final bool isOffDay;
  final List<Color> eventIndicatorColors;
}

/// Builder that merges Gregorian/Solar logic into one place.
class DayWidgetBuilder {
  DayWidgetBuilder._();

  static DayWidgetModel build(DayWidgetConfig config) {
    final normalizedDate = _normalize(config.date);
    final normalizedSelected = _normalize(config.selectedDate);
    final normalizedToday = _normalize(config.today);

    final isCurrentMonth = CalendarUtils.isCurrentMonth(
      normalizedDate,
      config.displayedMonth,
      calendarSystem: config.calendarSystem,
    );

    final isSelected = normalizedDate.isAtSameMomentAs(normalizedSelected);
    final isToday = normalizedDate.isAtSameMomentAs(normalizedToday);
    final isOffDay = _isConfiguredDayOff(normalizedDate, config.daysOff);

    final _DayLabels labels = _buildLabels(config);
    final List<Color> eventColors = config.showEventIndicators
        ? _buildEventColors(config)
        : const <Color>[];

    return DayWidgetModel(
      mainLabel: labels.main,
      equivalentLabel: config.showEquivalentDate ? labels.equivalent : null,
      isSelected: isSelected,
      isToday: isToday,
      isCurrentMonth: isCurrentMonth,
      isOffDay: isOffDay,
      eventIndicatorColors: eventColors,
    );
  }

  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool _isConfiguredDayOff(DateTime date, List<String> daysOff) {
    if (daysOff.isEmpty) return false;
    final weekdayName = _weekdayName(date.weekday);
    return daysOff.any((off) => off.toLowerCase() == weekdayName);
  }

  static String _weekdayName(int weekday) {
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

  static _DayLabels _buildLabels(DayWidgetConfig config) {
    final bool isSolar = config.isSolarSystem;
    final bool isLanguagePersian = config.isPersianLanguage;

    final Jalali jalali = CalendarUtils.gregorianToJalali(config.date);
    final String mainDigits =
        isSolar ? jalali.day.toString() : config.date.day.toString();
    final String equivalentDigits =
        isSolar ? config.date.day.toString() : jalali.day.toString();

    final String mainLabel = isLanguagePersian
        ? CalendarUtils.englishToPersianDigits(mainDigits)
        : mainDigits;

    // Keep Gregorian equivalent digits in English when viewing Solar/Shahanshahi,
    // but convert to Persian when the base calendar is Gregorian and the UI is Persian.
    final bool convertEquivalentToPersian = isLanguagePersian && !isSolar;
    final String equivalentLabel = convertEquivalentToPersian
        ? CalendarUtils.englishToPersianDigits(equivalentDigits)
        : equivalentDigits;

    return _DayLabels(main: mainLabel, equivalent: equivalentLabel);
  }

  static List<Color> _buildEventColors(DayWidgetConfig config) {
    if (config.events.isEmpty) return const <Color>[];

    // Calendar donuts filter by both origins AND event types
    // If an event type is disabled, its donut should not appear in calendar
    
    // All possible event types
    const allEventTypes = ['celebration', 'historical', 'anniversary', 'memorial', 'awareness'];
    
    // Check if all event types are enabled (user hasn't disabled any)
    final bool allTypesEnabled = config.enabledTypes == null ||
        (config.enabledTypes!.length == allEventTypes.length &&
            allEventTypes.every((type) => config.enabledTypes!.contains(type)));
    
    final Set<String>? allowedTypes = allTypesEnabled
        ? null // Don't filter by type if all types are enabled
        : config.enabledTypes!.map((type) => type.toLowerCase()).toSet();

    // If enabledOrigins is null, show all origins
    if (config.enabledOrigins == null) {
      final List<Color> colors = [];
      for (final event in config.events) {
        final String origin = event.origin.toLowerCase();
        final String type = event.type.toLowerCase();

        // Check if event type is enabled (only if not all types are enabled)
        if (allowedTypes != null) {
          final bool typeAllowed = allowedTypes.contains(type);
          if (!typeAllowed) {
            continue;
          }
        }

        final color = AppColors.getEventTypeColor(origin);
        if (!colors.contains(color)) {
          colors.add(color);
        }
        if (colors.length == 4) {
          break;
        }
      }
      return colors;
    }

    final Set<String> allowedOrigins = config.enabledOrigins!
        .map((origin) => origin.toLowerCase())
        .toSet();

    // If the user disabled every origin, return no donuts.
    if (allowedOrigins.isEmpty) {
      return const <Color>[];
    }

    final List<Color> colors = [];
    for (final event in config.events) {
      final String origin = event.origin.toLowerCase();
      final String type = event.type.toLowerCase();

      // Check if origin is enabled
      final bool originAllowed = allowedOrigins.contains(origin);
      if (!originAllowed) {
        continue;
      }

      // Check if event type is enabled (only if not all types are enabled)
      if (allowedTypes != null) {
        final bool typeAllowed = allowedTypes.contains(type);
        if (!typeAllowed) {
          continue;
        }
      }

      final color = AppColors.getEventTypeColor(origin);
      if (!colors.contains(color)) {
        colors.add(color);
      }

      if (colors.length == 4) {
        break;
      }
    }

    return colors;
  }
}

class _DayLabels {
  const _DayLabels({required this.main, required this.equivalent});

  final String main;
  final String equivalent;
}

/// Unified widget for rendering a single day item.
class DayWidget extends StatelessWidget {
  const DayWidget({
    super.key,
    required this.model,
    this.onTap,
  });

  final DayWidgetModel model;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isPersian = appProvider.language == 'fa';
    
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _backgroundColor(context),
            borderRadius: BorderRadius.circular(12),
            border: model.isToday && !model.isSelected
                ? Border.all(
                    color: TCnt.brandMain(context).withOpacity(0.4),
                    width: 1,
                  )
                : null,
          ),
      child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                model.mainLabel,
                textAlign: TextAlign.center,
                style: isPersian
                    ? FontHelper.getYekanBakh(
                        fontSize: 15,
                        fontWeight: model.isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: _mainTextColor(context),
                    height: 2.0,
                      )
                    : TextStyle(
                        fontSize: 15,
                        fontWeight:
                            model.isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: _mainTextColor(context),
                        height: 1.0,
                      ),
              ),
              if (model.equivalentLabel != null)
                Positioned(
                  top: 3,
                  right: model.isSelected ? 4 : 3,
                  child: Text(
                    model.equivalentLabel!,
                    style: isPersian
                        ? FontHelper.getYekanBakh(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: _equivalentTextColor(context),
                            height: 1.0,
                          )
                        : FontHelper.getInter(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: _equivalentTextColor(context),
                            height: 1.0,
                          ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _buildIndicators(),
      ],
    );

    final wrapped =
        model.isCurrentMonth ? content : Opacity(opacity: 0.5, child: content);

    if (onTap == null) {
      return wrapped;
    }

    return GestureDetector(
      onTap: onTap,
      child: wrapped,
    );
  }

  Color _backgroundColor(BuildContext context) {
    if (model.isSelected) return TCnt.brandMain(context);
    return Colors.transparent;
  }

  Color _mainTextColor(BuildContext context) {
    if (model.isSelected) return TCnt.unsurface(context);
    if (!model.isCurrentMonth) return TCnt.neutralTertiary(context);
    if (model.isOffDay) return TCnt.errorMd(context);
    return TCnt.neutralMain(context);
  }

  Color _equivalentTextColor(BuildContext context) {
    if (model.isSelected) {
      return TCnt.unsurface(context).withOpacity(0.85);
    }
    return TCnt.neutralTertiary(context);
  }

  Widget _buildIndicators() {
    if (model.eventIndicatorColors.isEmpty) return const SizedBox(height: 4);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < model.eventIndicatorColors.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: model.eventIndicatorColors[i],
                width: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

