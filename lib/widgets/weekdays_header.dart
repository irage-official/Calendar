import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../utils/calendar_utils.dart';
import '../providers/app_provider.dart';

class WeekdaysHeader extends StatelessWidget {
  final bool isPersian;
  
  const WeekdaysHeader({
    super.key,
    this.isPersian = false,
  });

  /// Determine the font family for weekday names based on app language and calendar type
  String _getWeekdayFontFamily(String language, bool isPersian) {
    // When app is in English and calendar is Gregorian: Use Inter
    // When app is in Persian and calendar is Jalali: Use Vazir
    if (language == 'en' && !isPersian) {
      return 'Inter';
    } else if (language == 'fa' && isPersian) {
      return 'Vazir';
    }
    // Default fallback
    return 'Inter';
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final calendarSystem = appProvider.calendarSystem;
    // Use effective language (resolves 'system' to actual system language)
    final effectiveLanguage = appProvider.effectiveLanguage;
    // Only use Persian labels if the effective language is Persian
    final shouldUsePersianLabels = effectiveLanguage == 'fa';
    final weekDayNames = CalendarUtils.getWeekDayNames(
      context, 
      isPersian: shouldUsePersianLabels, 
      calendarSystem: calendarSystem,
    );
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: weekDayNames.map((dayName) => _buildDayName(dayName)).toList(),
      ),
    );
  }

  Widget _buildDayName(String dayName) {
    return Expanded(
      child: Center(
        child: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            final effectiveLanguage = appProvider.effectiveLanguage;
            final fontFamily = _getWeekdayFontFamily(effectiveLanguage, isPersian);
            
            return Text(
              dayName,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
                color: TCnt.neutralFourth(context),
                fontFamily: fontFamily,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
      ),
    );
  }
}
