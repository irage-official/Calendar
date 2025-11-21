import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../config/app_icons.dart';
import '../providers/app_provider.dart';
import '../services/date_converter_service.dart';
import '../utils/calendar_utils.dart';
import '../utils/font_helper.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onTodayPressed;
  final VoidCallback? onLogoPressed;

  const HeaderWidget({
    Key? key,
    required this.onTodayPressed,
    this.onLogoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final now = DateTime.now();
        final isPersian = appProvider.language == 'fa';
        final calendarSystem = appProvider.calendarSystem;
        final dateConverter = DateConverterService();
        
        // Get date display based on calendar system
        final String dayMonthText = _getDateDisplay(now, isPersian, calendarSystem, dateConverter);
        final String yearText = _getYearDisplay(now, isPersian, calendarSystem, dateConverter);
        final String todayLabel = isPersian ? 'امروز' : 'Today';
        
        return Container(
        color: TBg.home(context),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          height: 94,
          child: SizedBox(
            height: 42,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo - tappable for About sheet
                GestureDetector(
                  onTap: onLogoPressed,
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    AppIcons.logoLauncher,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
                // Today's Date - NO Background, aligned horizontally
                GestureDetector(
                  onTap: onTodayPressed,
                  child: Directionality(
                    textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Day and Month - Font size 30, Bold
                      Text(
                        dayMonthText,
                          textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
                        style: isPersian
                            ? FontHelper.getYekanBakh(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: TCnt.neutralMain(context),
                                height: 1.4, /* 42px */
                                letterSpacing: -0.6,
                              )
                            : FontHelper.getInter(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: TCnt.neutralMain(context),
                                height: 1.4, /* 42px */
                                letterSpacing: -0.6,
                              ),
                      ),
                      const SizedBox(width: 8),
                      // Year and Today - Stacked vertically on the right
                      Column(
                        mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: isPersian ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Year - Font size 14, Dark gray (900)
                          Text(
                              yearText,
                              textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
                              style: isPersian
                                  ? FontHelper.getYekanBakh(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: TCnt.neutralSecond(context),
                                      height: 1.4,
                                    )
                                  : FontHelper.getInter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: TCnt.neutralSecond(context),
                                      height: 1.4,
                                    ),
                            ),
                            // Today label - Font size 14, Light gray (700)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  todayLabel,
                                  textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
                                  style: isPersian
                                      ? FontHelper.getYekanBakh(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: TCnt.neutralTertiary(context),
                                          height: 1.4,
                                        )
                                      : FontHelper.getInter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: TCnt.neutralTertiary(context),
                                          height: 1.4,
                                        ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDateDisplay(DateTime now, bool isPersian, String calendarSystem, DateConverterService dateConverter) {
    if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
      // Solar Hijri or Shahanshahi calendar (same month/day structure)
      final jalali = dateConverter.gregorianToJalali(now);
      if (isPersian) {
        // Persian language: show Persian digits
        return '${CalendarUtils.englishToPersianDigits(jalali.day.toString())} ${dateConverter.getJalaliMonthNameFa(jalali.month)}';
      } else {
        // English language: show English digits - format: "23 Aban" (day month) with thin space
        return '${jalali.day}\u2009${dateConverter.getJalaliMonthNameEn(jalali.month)}';
      }
    } else {
      // Gregorian calendar
      if (isPersian) {
        // Persian language: show Persian digits
        return '${CalendarUtils.englishToPersianDigits(now.day.toString())} ${dateConverter.getGregorianMonthNameFa(now.month)}';
      } else {
        // English language: show English digits
        return '${dateConverter.getGregorianMonthNameShortEn(now.month)} ${now.day}';
      }
    }
  }

  String _getYearDisplay(DateTime now, bool isPersian, String calendarSystem, DateConverterService dateConverter) {
    if (calendarSystem == 'solar') {
      // Solar Hijri calendar
      final jalali = dateConverter.gregorianToJalali(now);
      if (isPersian) {
        // Persian language: show Persian digits
        return CalendarUtils.englishToPersianDigits(jalali.year.toString());
      } else {
        // English language: show English digits
        return jalali.year.toString();
      }
    } else if (calendarSystem == 'shahanshahi') {
      // Shahanshahi calendar (same as Solar but with year offset)
      final shahanshahi = dateConverter.gregorianToShahanshahi(now);
      if (isPersian) {
        // Persian language: show Persian digits
        return CalendarUtils.englishToPersianDigits(shahanshahi.year.toString());
      } else {
        // English language: show English digits
        return shahanshahi.year.toString();
      }
    } else {
      // Gregorian calendar
      if (isPersian) {
        // Persian language: show Persian digits
        return CalendarUtils.englishToPersianDigits(now.year.toString());
      } else {
        // English language: show English digits
        return now.year.toString();
      }
    }
  }

}