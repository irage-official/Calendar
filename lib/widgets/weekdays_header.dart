import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../utils/calendar_utils.dart';
import '../utils/font_helper.dart';
import '../providers/app_provider.dart';

class WeekdaysHeader extends StatelessWidget {
  final bool isPersian;
  final bool short;
  
  const WeekdaysHeader({
    super.key,
    this.isPersian = false,
    this.short = false,
  });

  /// Determine if should use Persian font based on app language and calendar type
  bool _shouldUsePersianFont(String language, bool isPersian) {
    // When app is in Persian and calendar is Jalali: Use YekanBakh
    // Otherwise use Inter (from Google Fonts)
    return language == 'fa' && isPersian;
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
      startWeekOn: appProvider.effectiveStartWeekOn,
      short: short,
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
            final usePersianFont = _shouldUsePersianFont(effectiveLanguage, isPersian);
            
            return Text(
              dayName,
              style: usePersianFont
                  ? FontHelper.getYekanBakh(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: TCnt.neutralFourth(context),
                      height: 1.2,
                    )
                  : FontHelper.getInter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: TCnt.neutralFourth(context),
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
