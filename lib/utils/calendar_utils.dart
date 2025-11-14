import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../services/date_converter_service.dart';
import '../models/calendar_data.dart';

class CalendarUtils {
  static final DateConverterService _dateConverter = DateConverterService();

  /// Convert Gregorian to Jalali
  static Jalali gregorianToJalali(DateTime gregorian) {
    return _dateConverter.gregorianToJalali(gregorian);
  }

  /// Convert Jalali to Gregorian
  static DateTime jalaliToGregorian(Jalali jalali) {
    return _dateConverter.jalaliToGregorian(jalali.year, jalali.month, jalali.day);
  }

  /// Format Jalali date for display (no leading zeros)
  /// For equivalent dates: English app shows Persian digits, Persian app shows English digits
  static String formatJalaliDate(Jalali date, {String language = 'en'}) {
    final dayString = date.day.toString(); // No padding
    if (language == 'en') {
      // English app: show Persian digits for Jalali equivalent dates
      return englishToPersianDigits(dayString);
    } else {
      // Persian app: show English digits for Jalali equivalent dates
      return dayString;
    }
  }

  /// Format Gregorian date for display (no leading zeros)
  /// For equivalent dates: English app shows Persian digits, Persian app shows English digits
  static String formatGregorianDate(DateTime date, {String language = 'en'}) {
    final dayString = date.day.toString(); // No padding
    if (language == 'en') {
      // English app: show Persian digits for Gregorian equivalent dates
      return englishToPersianDigits(dayString);
    } else {
      // Persian app: show English digits for Gregorian equivalent dates
      return dayString;
    }
  }

  /// Check if two dates are the same day
  static bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return _dateConverter.isGregorianToday(date);
  }

  /// Check if date is in current month
  /// For solar/shahanshahi calendar, compares based on solar (Jalali) months
  static bool isCurrentMonth(DateTime date, DateTime currentMonth, {String calendarSystem = 'gregorian'}) {
    if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
      final dateJalali = _dateConverter.gregorianToJalali(date);
      final currentJalali = _dateConverter.gregorianToJalali(currentMonth);
      return dateJalali.year == currentJalali.year && dateJalali.month == currentJalali.month;
    }
    return date.year == currentMonth.year && date.month == currentMonth.month;
  }

  /// Get week day names based on locale and calendar system
  /// 
  /// Rules:
  /// - English + Gregorian: Monday start (Mon, Tue, Wed, Thu, Fri, Sat, Sun)
  /// - English + Solar Hijri/Shahanshahi: Saturday start (Sat, Sun, Mon, Tue, Wed, Thu, Fri)
  /// - Persian + Solar Hijri/Shahanshahi: Saturday start (شنبه، یکشنبه، دوشنبه، سه‌شنبه، چهارشنبه، پنج‌شنبه، جمعه)
  /// - Persian + Gregorian: Saturday start (شنبه، یکشنبه، دوشنبه، سه‌شنبه، چهارشنبه، پنج‌شنبه، جمعه)
  static List<String> getWeekDayNames(BuildContext context, {bool isPersian = false, String calendarSystem = 'gregorian'}) {
    final bool isSolarHijri = calendarSystem == 'solar' || calendarSystem == 'shahanshahi';
    
    if (isPersian) {
      // Persian language: Always Saturday start
      return ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه'];
    } else {
      // English language
      if (isSolarHijri) {
        // English + Solar Hijri: Saturday start
        return ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
      } else {
        // English + Gregorian: Monday start
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      }
    }
  }

  /// Get week day names based on device locale
  static List<String> getWeekDayNamesFromLocale(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isPersian = locale.languageCode == 'fa';
    return getWeekDayNames(context, isPersian: isPersian);
  }

  /// Get week start date based on calendar system
  /// 
  /// Rules:
  /// - Gregorian calendar: Monday start (weekday: 1 = Monday)
  /// - Solar Hijri/Shahanshahi calendar: Saturday start
  static DateTime getWeekStart(DateTime date, {String calendarSystem = 'gregorian'}) {
    if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
      // Solar Hijri: week starts on Saturday
      // DateTime.weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
      // To get the Saturday of the week containing 'date':
      int dayOfWeek = date.weekday;
      // Calculate days to subtract to get to the Saturday of the current week:
      // Mon(1) → 2 days back, Tue(2) → 3, Wed(3) → 4, Thu(4) → 5, Fri(5) → 6, Sat(6) → 0, Sun(7) → 1
      int daysToSubtract;
      if (dayOfWeek == 6) {
        daysToSubtract = 0; // Saturday - no subtraction
      } else if (dayOfWeek == 7) {
        daysToSubtract = 1; // Sunday - subtract 1 to get Saturday
      } else {
        daysToSubtract = dayOfWeek + 1; // Monday-Friday: need to go back (dayOfWeek + 1) days
      }
      return date.subtract(Duration(days: daysToSubtract));
    } else {
      // Gregorian: week starts on Monday (standard behavior)
      return _dateConverter.getGregorianWeekStart(date);
    }
  }

  /// Get month dates for calendar grid based on calendar system
  /// For solar/shahanshahi calendar, uses calculations (same as Gregorian)
  static Future<List<DateTime>> getMonthDates(DateTime monthStart, {String calendarSystem = 'gregorian'}) async {
    if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
      // Use calculations for solar/shahanshahi calendar (same approach as Gregorian)
      return _fallbackGetSolarMonthDates(monthStart);
    }
    
    // For Gregorian, use the existing logic
    final dates = <DateTime>[];
    
    // Get the first day of the month
    final firstDayOfMonth = DateTime(monthStart.year, monthStart.month, 1);
    
    // Get the first day of the week containing the first day of month
    final firstWeekStart = getWeekStart(firstDayOfMonth, calendarSystem: calendarSystem);
    
    // Add days from previous month to fill first week
    if (firstWeekStart.isBefore(firstDayOfMonth)) {
      for (int i = 0; i < firstDayOfMonth.difference(firstWeekStart).inDays; i++) {
        dates.add(firstWeekStart.add(Duration(days: i)));
      }
    }
    
    // Add days of current month
    final lastDayOfMonth = DateTime(monthStart.year, monthStart.month + 1, 0);
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      dates.add(DateTime(monthStart.year, monthStart.month, i));
    }
    
    // Add days from next month to fill last week, but only if it doesn't create a full extra week entirely from next month
    final lastDayInCalendar = dates.last;
    final daysToAdd = 7 - ((dates.length) % 7);
    
    // Always complete the last week if it's incomplete (daysToAdd > 0 and < 7)
    if (daysToAdd < 7 && daysToAdd > 0) {
      for (int i = 1; i <= daysToAdd; i++) {
        dates.add(lastDayInCalendar.add(Duration(days: i)));
      }
      
      // Check for extra weeks (6th, 7th, etc.) that are entirely from next month
      // Start checking from week 6 (index 35) onwards
      int weekIndex = 5; // Start from 6th week (0-indexed: 5)
      while (dates.length >= (weekIndex + 1) * 7) {
        final weekStartIndex = weekIndex * 7;
        final weekEndIndex = (weekIndex + 1) * 7;
        if (weekEndIndex > dates.length) break;
        
        final week = dates.sublist(weekStartIndex, weekEndIndex);
        final allDaysFromNextMonth = week.every((date) {
          return date.year != monthStart.year || date.month != monthStart.month;
        });
        
        if (allDaysFromNextMonth) {
          // Remove this week and all subsequent weeks - they're all from next month
          dates.removeRange(weekStartIndex, dates.length);
          break;
        }
        
        weekIndex++;
      }
    }
    
    return dates;
  }

  /// Generate MonthData from calculations (for both Gregorian and Solar calendars)
  static Future<MonthData> getMonthDataFromCalculations({
    required int year,
    required int month,
    required String calendarType,
  }) async {
    // Create a date representing the first day of the target month
    DateTime monthStart;
    if (calendarType == 'solar' || calendarType == 'shahanshahi') {
      // For solar/shahanshahi, convert Jalali year/month to Gregorian
      // For shahanshahi, convert shahanshahi year to jalali year first
      int jalaliYear = calendarType == 'shahanshahi' 
          ? _dateConverter.getJalaliYearFromShahanshahi(year)
          : year;
      monthStart = _dateConverter.jalaliToGregorian(jalaliYear, month, 1);
    } else {
      // For Gregorian, use directly
      monthStart = DateTime(year, month, 1);
    }

    // Get all dates for the month
    final monthDates = await getMonthDates(monthStart, calendarSystem: calendarType);
    
    // Get month info
    final dateConverter = DateConverterService();
    String monthName;
    String? monthNameLatin;
    String? monthNameShort;
    int daysInMonth;
    int weekStartDay; // 0=Saturday for solar, 1=Monday for Gregorian
    
    if (calendarType == 'solar' || calendarType == 'shahanshahi') {
      monthName = dateConverter.getJalaliMonthNameFa(month);
      monthNameLatin = dateConverter.getJalaliMonthNameEn(month);
      // For shahanshahi, convert shahanshahi year to jalali year first
      int jalaliYear = calendarType == 'shahanshahi' 
          ? _dateConverter.getJalaliYearFromShahanshahi(year)
          : year;
      final firstDayJalali = Jalali(jalaliYear, month, 1);
      daysInMonth = firstDayJalali.monthLength;
      weekStartDay = 0; // Saturday start for solar/shahanshahi
    } else {
      monthName = dateConverter.getGregorianMonthName(month);
      monthNameShort = dateConverter.getGregorianMonthNameShortEn(month);
      daysInMonth = DateTime(year, month + 1, 0).day;
      weekStartDay = 1; // Monday start for Gregorian
    }
    
    // Group dates into weeks
    final weeks = <WeekData>[];
    for (int i = 0; i < monthDates.length; i += 7) {
      final weekDates = monthDates.sublist(i, (i + 7 > monthDates.length) ? monthDates.length : i + 7);
      final weekDays = <DayData>[];
      
      for (final date in weekDates) {
        // Determine if this date is in current month
        bool isCurrentMonth;
        if (calendarType == 'solar' || calendarType == 'shahanshahi') {
          final dateJalali = _dateConverter.gregorianToJalali(date);
          // For shahanshahi, compare with jalali year
          int targetYear = calendarType == 'shahanshahi' 
              ? _dateConverter.getJalaliYearFromShahanshahi(year)
              : year;
          isCurrentMonth = dateJalali.year == targetYear && dateJalali.month == month;
        } else {
          isCurrentMonth = date.year == year && date.month == month;
        }
        
        // Get day number based on calendar type
        int dayNumber;
        if (calendarType == 'solar' || calendarType == 'shahanshahi') {
          final dateJalali = _dateConverter.gregorianToJalali(date);
          dayNumber = dateJalali.day;
        } else {
          dayNumber = date.day;
        }
        
        // Calculate day of week
        // For solar/shahanshahi: 0=Saturday, 1=Sunday, ..., 6=Friday
        // For Gregorian: 1=Monday, 2=Tuesday, ..., 7=Sunday
        int dayOfWeek;
        if (calendarType == 'solar' || calendarType == 'shahanshahi') {
          // Convert DateTime.weekday (1=Mon, ..., 7=Sun) to solar (0=Sat, ..., 6=Fri)
          int weekday = date.weekday;
          dayOfWeek = (weekday == 6) ? 0 : (weekday == 7) ? 1 : weekday + 1;
        } else {
          dayOfWeek = date.weekday; // Already 1=Mon, ..., 7=Sun
        }
        
        // Format dates as strings
        final gregorianDateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        String? solarDateStr;
        if (calendarType == 'solar' || calendarType == 'shahanshahi') {
          final dateJalali = _dateConverter.gregorianToJalali(date);
          // For shahanshahi, show shahanshahi year in the date string
          int displayYear = calendarType == 'shahanshahi' 
              ? _dateConverter.getShahanshahiYear(dateJalali.year)
              : dateJalali.year;
          solarDateStr = '${displayYear}-${dateJalali.month.toString().padLeft(2, '0')}-${dateJalali.day.toString().padLeft(2, '0')}';
        }
        
        weekDays.add(DayData(
          date: dayNumber,
          isCurrentMonth: isCurrentMonth,
          gregorianDate: gregorianDateStr,
          solarDate: solarDateStr,
          dayOfWeek: dayOfWeek,
        ));
      }
      
      weeks.add(WeekData(days: weekDays));
    }
    
    return MonthData(
      year: year,
      month: month,
      monthName: monthName,
      monthNameLatin: monthNameLatin,
      monthNameShort: monthNameShort,
      daysInMonth: daysInMonth,
      weekStartDay: weekStartDay,
      weeks: weeks,
    );
  }

  /// Fallback method when solar calendar data is not available
  static List<DateTime> _fallbackGetSolarMonthDates(DateTime monthStart) {
    // Convert to Jalali to get solar month info
    final jalali = _dateConverter.gregorianToJalali(monthStart);
    final solarYear = jalali.year;
    final solarMonth = jalali.month;
    
    // Get first day of solar month
    final firstDaySolar = Jalali(solarYear, solarMonth, 1);
    final firstDayGregorian = _dateConverter.jalaliToGregorian(solarYear, solarMonth, 1);
    
    // Get last day of solar month (31, 30, or 29 for Esfand)
    final daysInSolarMonth = firstDaySolar.monthLength;
    final lastDaySolar = Jalali(solarYear, solarMonth, daysInSolarMonth);
    final lastDayGregorian = _dateConverter.jalaliToGregorian(solarYear, solarMonth, daysInSolarMonth);
    
    // Get week start (Saturday for solar)
    final firstWeekStart = getWeekStart(firstDayGregorian, calendarSystem: 'solar');
    
    final dates = <DateTime>[];
    
    // Add days from previous month to fill first week
    if (firstWeekStart.isBefore(firstDayGregorian)) {
      for (int i = 0; i < firstDayGregorian.difference(firstWeekStart).inDays; i++) {
        dates.add(firstWeekStart.add(Duration(days: i)));
      }
    }
    
    // Add days of current solar month
    for (int day = 1; day <= daysInSolarMonth; day++) {
      dates.add(_dateConverter.jalaliToGregorian(solarYear, solarMonth, day));
    }
    
    // Add days from next month to fill last week, but only if it doesn't create a full extra week entirely from next month
    final daysToAdd = 7 - (dates.length % 7);
    if (daysToAdd < 7 && dates.isNotEmpty) {
      final lastDate = dates.last;
      for (int i = 1; i <= daysToAdd; i++) {
        dates.add(lastDate.add(Duration(days: i)));
      }
      
      // Check for extra weeks (6th, 7th, etc.) that are entirely from next month
      // Start checking from week 6 (index 35) onwards
      int weekIndex = 5; // Start from 6th week (0-indexed: 5)
      while (dates.length >= (weekIndex + 1) * 7) {
        final weekStartIndex = weekIndex * 7;
        final weekEndIndex = (weekIndex + 1) * 7;
        if (weekEndIndex > dates.length) break;
        
        final week = dates.sublist(weekStartIndex, weekEndIndex);
        final allDaysFromNextMonth = week.every((date) {
          final dateJalali = _dateConverter.gregorianToJalali(date);
          return dateJalali.year != solarYear || dateJalali.month != solarMonth;
        });
        
        if (allDaysFromNextMonth) {
          // Remove this week and all subsequent weeks - they're all from next month
          dates.removeRange(weekStartIndex, dates.length);
          break;
        }
        
        weekIndex++;
      }
    }
    
    return dates;
  }

  /// Get week dates for calendar grid
  static List<DateTime> getWeekDates(DateTime weekStart) {
    final dates = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      dates.add(weekStart.add(Duration(days: i)));
    }
    return dates;
  }

  /// Convert Persian digits to English digits
  static String persianToEnglishDigits(String persianNumber) {
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    
    String result = persianNumber;
    for (int i = 0; i < persianDigits.length; i++) {
      result = result.replaceAll(persianDigits[i], englishDigits[i]);
    }
    return result;
  }

  /// Convert English digits to Persian digits
  static String englishToPersianDigits(String englishNumber) {
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    
    String result = englishNumber;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], persianDigits[i]);
    }
    return result;
  }

  /// Format date for display with proper digit conversion
  static String formatDateForDisplay(int day, {bool usePersianDigits = false}) {
    final formatted = day.toString().padLeft(2, '0');
    return usePersianDigits ? englishToPersianDigits(formatted) : formatted;
  }

  /// Convert Solar Hijri years to Shahanshahi years in text
  /// Finds 4-digit years between 1300-1500 (Solar Hijri range) and converts them
  /// Supports both Persian and English digits
  static String convertSolarYearsToShahanshahi(String text) {
    // Pattern to match 4-digit numbers (both Persian and English digits)
    // We'll check if they're in the Solar Hijri range (1300-1500)
    final RegExp yearPattern = RegExp(r'[۱۲۳۴۵۶۷۸۹۰0-9]{4}');
    
    String result = text;
    final matches = yearPattern.allMatches(text).toList();
    
    // Process matches in reverse order to maintain correct indices
    matches.sort((a, b) => b.start.compareTo(a.start));
    
    for (final match in matches) {
      final yearStr = match.group(0)!;
      // Convert Persian digits to English for parsing
      final yearStrEnglish = persianToEnglishDigits(yearStr);
      final year = int.tryParse(yearStrEnglish);
      
      // Check if it's a Solar Hijri year (1300-1500)
      if (year != null && year >= 1300 && year <= 1500) {
        // Convert to Shahanshahi (add 1180)
        final shahanshahiYear = year + 1180;
        final shahanshahiYearStr = shahanshahiYear.toString();
        
        // Convert back to Persian digits if original was Persian
        final isPersian = RegExp(r'[۱۲۳۴۵۶۷۸۹۰]').hasMatch(yearStr);
        final replacement = isPersian 
            ? englishToPersianDigits(shahanshahiYearStr)
            : shahanshahiYearStr;
        
        result = result.replaceRange(match.start, match.end, replacement);
      }
    }
    
    return result;
  }

  /// Convert dates in event descriptions based on language and calendar system
  /// This is the main function that should be called to convert dates in descriptions
  /// 
  /// Examples:
  /// - English + Gregorian: "31 October" -> "31 October", "4 Aban 1346" -> "26 October 1967"
  /// - English + Shahanshahi: "31 October" -> "4 Aban", "4 Aban 1346" -> "4 Aban 2526"
  /// - English + Solar: "31 October" -> "4 Aban", "4 Aban 1346" -> "4 Aban 1346"
  /// - Persian + Gregorian: "۴ آبان ۱۳۴۶" -> "۲۶ اکتبر ۱۹۶۷", "۳۱ اکتبر" -> "۳۱ اکتبر"
  /// - Persian + Shahanshahi: "۴ آبان ۱۳۴۶" -> "۴ آبان ۲۵۲۶", "۳۱ اکتبر" -> "۴ آبان"
  /// - Persian + Solar: "۴ آبان ۱۳۴۶" -> "۴ آبان ۱۳۴۶", "۳۱ اکتبر" -> "۴ آبان"
  static String convertDatesInText(String text, String language, String calendarSystem) {
    if (calendarSystem == 'shahanshahi') {
      return convertDatesToShahanshahi(text, language);
    } else if (calendarSystem == 'solar') {
      return convertDatesToSolar(text, language);
    } else {
      // Gregorian: Convert all dates to Gregorian format
      return convertDatesToGregorian(text, language);
    }
  }

  /// Convert dates in event descriptions to Gregorian format
  /// Handles both Persian and English date formats
  static String convertDatesToGregorian(String text, String language) {
    String result = text;
    final dateConverter = DateConverterService();
    
    if (language == 'fa') {
      // Persian: Convert Solar/Jalali dates to Gregorian
      // Pattern: "۴ آبان ۱۳۴۶" or "۳۱ اکتبر"
      final jalaliMonthNamesFa = [
        'فروردین', 'اردیبهشت', 'خرداد', 'تیر',
        'مرداد', 'شهریور', 'مهر', 'آبان',
        'آذر', 'دی', 'بهمن', 'اسفند'
      ];
      
      for (int i = 0; i < jalaliMonthNamesFa.length; i++) {
        final monthName = jalaliMonthNamesFa[i];
        final monthNum = i + 1;
        
        // Pattern 1: "day monthName year" or "day monthName"
        final pattern1 = RegExp(
          r'([۱۲۳۴۵۶۷۸۹۰]+)\s+' + RegExp.escape(monthName) + r'(?:\s+([۱۲۳۴۵۶۷۸۹۰]{4}))?',
        );
        
        result = result.replaceAllMapped(pattern1, (match) {
          final dayStr = match.group(1)!;
          final yearStr = match.group(2);
          
          final day = int.tryParse(persianToEnglishDigits(dayStr));
          if (day == null) return match.group(0)!;
          
          if (yearStr != null) {
            // Full date with year
            final year = int.tryParse(persianToEnglishDigits(yearStr));
            if (year != null && year >= 1300 && year <= 1500) {
              try {
                final gregorianDate = dateConverter.jalaliToGregorian(year, monthNum, day);
                final monthNameFa = dateConverter.getGregorianMonthNameFa(gregorianDate.month);
                final dayFormatted = englishToPersianDigits(gregorianDate.day.toString());
                final yearFormatted = englishToPersianDigits(gregorianDate.year.toString());
                return '$dayFormatted $monthNameFa $yearFormatted';
              } catch (e) {
                return match.group(0)!;
              }
            }
          } else {
            // Date without year - convert current year's date
            try {
              // Use a reference year to convert (e.g., 1400)
              final referenceYear = 1400;
              final gregorianDate = dateConverter.jalaliToGregorian(referenceYear, monthNum, day);
              final monthNameFa = dateConverter.getGregorianMonthNameFa(gregorianDate.month);
              final dayFormatted = englishToPersianDigits(gregorianDate.day.toString());
              return '$dayFormatted $monthNameFa';
            } catch (e) {
              return match.group(0)!;
            }
          }
          return match.group(0)!;
        });
      }
      
      // Also convert standalone Solar Hijri years (1300-1500) to Gregorian
      // Pattern: 4-digit Persian or English numbers in Solar Hijri range
      final standaloneYearPattern = RegExp(r'[۱۲۳۴۵۶۷۸۹۰]{4}');
      final yearMatches = standaloneYearPattern.allMatches(result).toList();
      yearMatches.sort((a, b) => b.start.compareTo(a.start));
      
      for (final match in yearMatches) {
        final yearStr = match.group(0)!;
        final year = int.tryParse(persianToEnglishDigits(yearStr));
        
        if (year != null && year >= 1300 && year <= 1500) {
          // Check if this year is already part of a converted date
          final start = match.start;
          final end = match.end;
          final before = start > 0 ? result.substring(start - 30, start) : '';
          final after = end < result.length ? result.substring(end, end + 30) : '';
          
          // Skip if it's part of a date we already converted
          final isPartOfDate = RegExp(
            r'(فروردین|اردیبهشت|خرداد|تیر|مرداد|شهریور|مهر|آبان|آذر|دی|بهمن|اسفند|ژانویه|فوریه|مارس|آوریل|می|ژوئن|جولای|اوت|سپتامبر|اکتبر|نوامبر|دسامبر)\s+[۱۲۳۴۵۶۷۸۹۰]+\s+' + RegExp.escape(yearStr)
          ).hasMatch(before + yearStr + after);
          
          if (!isPartOfDate) {
            // Convert Solar Hijri year to approximate Gregorian year
            // Use the middle of the year (around June/July) for conversion
            try {
              final jalaliDate = Jalali(year, 6, 15); // Mid-year date
              final gregorianDate = dateConverter.jalaliToGregorian(jalaliDate.year, jalaliDate.month, jalaliDate.day);
              final yearFormatted = englishToPersianDigits(gregorianDate.year.toString());
              result = result.replaceRange(start, end, yearFormatted);
            } catch (e) {
              // Keep original if conversion fails
            }
          }
        }
      }
      
      // Also handle standalone Gregorian dates in Persian (like "۳۱ اکتبر")
      // These should remain as is
      
    } else {
      // English: Convert Solar/Jalali dates to Gregorian
      final jalaliMonthNamesEn = [
        'Farvardin', 'Ordibehesht', 'Khordad', 'Tir',
        'Mordad', 'Shahrivar', 'Mehr', 'Aban',
        'Azar', 'Dey', 'Bahman', 'Esfand'
      ];
      
      for (int i = 0; i < jalaliMonthNamesEn.length; i++) {
        final monthName = jalaliMonthNamesEn[i];
        final monthNum = i + 1;
        
        // Pattern: "day monthName year" or "day monthName"
        final pattern = RegExp(
          r'(\d{1,2})\s+' + RegExp.escape(monthName) + r'(?:\s+(\d{4}))?',
          caseSensitive: false,
        );
        
        result = result.replaceAllMapped(pattern, (match) {
          final day = int.tryParse(match.group(1)!);
          final yearStr = match.group(2);
          
          if (day == null) return match.group(0)!;
          
          if (yearStr != null) {
            final year = int.tryParse(yearStr);
            if (year != null && year >= 1300 && year <= 1500) {
              try {
                final gregorianDate = dateConverter.jalaliToGregorian(year, monthNum, day);
                final monthNameEn = dateConverter.getGregorianMonthName(gregorianDate.month);
                return '${gregorianDate.day} $monthNameEn ${gregorianDate.year}';
              } catch (e) {
                return match.group(0)!;
              }
            }
          } else {
            // Date without year
            try {
              final referenceYear = 1400;
              final gregorianDate = dateConverter.jalaliToGregorian(referenceYear, monthNum, day);
              final monthNameEn = dateConverter.getGregorianMonthName(gregorianDate.month);
              return '${gregorianDate.day} $monthNameEn';
            } catch (e) {
              return match.group(0)!;
            }
          }
          return match.group(0)!;
        });
      }
      
      // Also convert standalone Solar Hijri years (1300-1500) to Gregorian
      // Pattern: 4-digit numbers in Solar Hijri range
      final standaloneYearPattern = RegExp(r'\b(1[3-4]\d{2}|1500)\b');
      final yearMatches = standaloneYearPattern.allMatches(result).toList();
      yearMatches.sort((a, b) => b.start.compareTo(a.start));
      
      for (final match in yearMatches) {
        final yearStr = match.group(1)!;
        final year = int.tryParse(yearStr);
        
        if (year != null && year >= 1300 && year <= 1500) {
          // Check if this year is already part of a converted date
          final start = match.start;
          final end = match.end;
          final before = start > 0 ? result.substring(start - 30, start) : '';
          final after = end < result.length ? result.substring(end, end + 30) : '';
          
          // Skip if it's part of a date we already converted
          final isPartOfDate = RegExp(
            r'(Farvardin|Ordibehesht|Khordad|Tir|Mordad|Shahrivar|Mehr|Aban|Azar|Dey|Bahman|Esfand|January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2}\s+' + yearStr,
            caseSensitive: false,
          ).hasMatch(before + yearStr + after);
          
          if (!isPartOfDate) {
            // Convert Solar Hijri year to approximate Gregorian year
            // Use the middle of the year (around June/July) for conversion
            try {
              final jalaliDate = Jalali(year, 6, 15); // Mid-year date
              final gregorianDate = dateConverter.jalaliToGregorian(jalaliDate.year, jalaliDate.month, jalaliDate.day);
              result = result.replaceRange(start, end, gregorianDate.year.toString());
            } catch (e) {
              // Keep original if conversion fails
            }
          }
        }
      }
      
      // Also handle standalone Gregorian dates (like "31 October")
      // These should remain as is
    }
    
    return result;
  }

  /// Convert dates in event descriptions to Solar Hijri format
  /// Handles both Persian and English date formats
  static String convertDatesToSolar(String text, String language) {
    String result = text;
    final dateConverter = DateConverterService();
    
    if (language == 'fa') {
      // Persian: Convert Gregorian dates to Solar
      // Pattern: "۳۱ اکتبر" or "۲۶ اکتبر ۱۹۶۷"
      final gregorianMonthNamesFa = [
        'ژانویه', 'فوریه', 'مارس', 'آوریل',
        'می', 'ژوئن', 'جولای', 'اوت',
        'سپتامبر', 'اکتبر', 'نوامبر', 'دسامبر'
      ];
      
      for (int i = 0; i < gregorianMonthNamesFa.length; i++) {
        final monthName = gregorianMonthNamesFa[i];
        final monthNum = i + 1;
        
        // Pattern 1: "day monthName year" or "day monthName"
        final pattern1 = RegExp(
          r'([۱۲۳۴۵۶۷۸۹۰]+)\s+' + RegExp.escape(monthName) + r'(?:\s+([۱۲۳۴۵۶۷۸۹۰]{4}))?',
        );
        
        result = result.replaceAllMapped(pattern1, (match) {
          final dayStr = match.group(1)!;
          final yearStr = match.group(2);
          
          final day = int.tryParse(persianToEnglishDigits(dayStr));
          if (day == null) return match.group(0)!;
          
          if (yearStr != null) {
            final year = int.tryParse(persianToEnglishDigits(yearStr));
            if (year != null && year >= 1900 && year <= 2100) {
              try {
                final gregorianDate = DateTime(year, monthNum, day);
                final jalali = dateConverter.gregorianToJalali(gregorianDate);
                final monthNameFa = dateConverter.getJalaliMonthNameFa(jalali.month);
                final dayFormatted = englishToPersianDigits(jalali.day.toString());
                final yearFormatted = englishToPersianDigits(jalali.year.toString());
                return '$dayFormatted $monthNameFa $yearFormatted';
              } catch (e) {
                return match.group(0)!;
              }
            }
          } else {
            try {
              final referenceYear = 2025;
              final gregorianDate = DateTime(referenceYear, monthNum, day);
              final jalali = dateConverter.gregorianToJalali(gregorianDate);
              final monthNameFa = dateConverter.getJalaliMonthNameFa(jalali.month);
              final dayFormatted = englishToPersianDigits(jalali.day.toString());
              return '$dayFormatted $monthNameFa';
            } catch (e) {
              return match.group(0)!;
            }
          }
          return match.group(0)!;
        });
        
        // Pattern 2: "monthName day year" or "monthName day"
        // This handles formats like "اکتبر ۳۱" or "اکتبر ۳۱ ۲۰۲۵"
        final pattern2 = RegExp(
          RegExp.escape(monthName) + r'\s+([۱۲۳۴۵۶۷۸۹۰]+)(?:\s+([۱۲۳۴۵۶۷۸۹۰]{4}))?',
        );
        
        result = result.replaceAllMapped(pattern2, (match) {
          final dayStr = match.group(1)!;
          final yearStr = match.group(2);
          
          final day = int.tryParse(persianToEnglishDigits(dayStr));
          if (day == null) return match.group(0)!;
          
          if (yearStr != null) {
            final year = int.tryParse(persianToEnglishDigits(yearStr));
            if (year != null && year >= 1900 && year <= 2100) {
              try {
                final gregorianDate = DateTime(year, monthNum, day);
                final jalali = dateConverter.gregorianToJalali(gregorianDate);
                final monthNameFa = dateConverter.getJalaliMonthNameFa(jalali.month);
                final dayFormatted = englishToPersianDigits(jalali.day.toString());
                final yearFormatted = englishToPersianDigits(jalali.year.toString());
                return '$dayFormatted $monthNameFa $yearFormatted';
              } catch (e) {
                return match.group(0)!;
              }
            }
          } else {
            try {
              final referenceYear = 2025;
              final gregorianDate = DateTime(referenceYear, monthNum, day);
              final jalali = dateConverter.gregorianToJalali(gregorianDate);
              final monthNameFa = dateConverter.getJalaliMonthNameFa(jalali.month);
              final dayFormatted = englishToPersianDigits(jalali.day.toString());
              return '$dayFormatted $monthNameFa';
            } catch (e) {
              return match.group(0)!;
            }
          }
          return match.group(0)!;
        });
      }
      
      // Solar dates should remain as is
      
    } else {
      // English: Convert Gregorian dates to Solar
      final gregorianMonthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      for (int i = 0; i < gregorianMonthNames.length; i++) {
        final monthName = gregorianMonthNames[i];
        final monthNum = i + 1;
        
        // Pattern 1: "day monthName year" or "day monthName, year" or "day monthName"
        final pattern1 = RegExp(
          r'(\d{1,2})\s+' + RegExp.escape(monthName) + r'(?:,\s*)?(?:\s+(\d{4}))?',
          caseSensitive: false,
        );
        
        result = result.replaceAllMapped(pattern1, (match) {
          final day = int.tryParse(match.group(1)!);
          final yearStr = match.group(2);
          
          if (day == null) return match.group(0)!;
          
          if (yearStr != null) {
            final year = int.tryParse(yearStr);
            if (year != null && year >= 1900 && year <= 2100) {
              try {
                final gregorianDate = DateTime(year, monthNum, day);
                final jalali = dateConverter.gregorianToJalali(gregorianDate);
                final monthNameEn = dateConverter.getJalaliMonthNameEn(jalali.month);
                return '${jalali.day} $monthNameEn ${jalali.year}';
              } catch (e) {
                return match.group(0)!;
              }
            }
          } else {
            try {
              final referenceYear = 2025;
              final gregorianDate = DateTime(referenceYear, monthNum, day);
              final jalali = dateConverter.gregorianToJalali(gregorianDate);
              final monthNameEn = dateConverter.getJalaliMonthNameEn(jalali.month);
              return '${jalali.day} $monthNameEn';
            } catch (e) {
              return match.group(0)!;
            }
          }
          return match.group(0)!;
        });
        
        // Pattern 2: "monthName day year" or "monthName day, year" or "monthName day"
        // This handles formats like "October 31" or "October 31, 2025"
        final pattern2 = RegExp(
          RegExp.escape(monthName) + r'\s+(\d{1,2})(?:,\s*)?(?:\s+(\d{4}))?',
          caseSensitive: false,
        );
        
        result = result.replaceAllMapped(pattern2, (match) {
          final day = int.tryParse(match.group(1)!);
          final yearStr = match.group(2);
          
          if (day == null) return match.group(0)!;
          
          if (yearStr != null) {
            final year = int.tryParse(yearStr);
            if (year != null && year >= 1900 && year <= 2100) {
              try {
                final gregorianDate = DateTime(year, monthNum, day);
                final jalali = dateConverter.gregorianToJalali(gregorianDate);
                final monthNameEn = dateConverter.getJalaliMonthNameEn(jalali.month);
                return '${jalali.day} $monthNameEn ${jalali.year}';
              } catch (e) {
                return match.group(0)!;
              }
            }
          } else {
            try {
              final referenceYear = 2025;
              final gregorianDate = DateTime(referenceYear, monthNum, day);
              final jalali = dateConverter.gregorianToJalali(gregorianDate);
              final monthNameEn = dateConverter.getJalaliMonthNameEn(jalali.month);
              return '${jalali.day} $monthNameEn';
            } catch (e) {
              return match.group(0)!;
            }
          }
          return match.group(0)!;
        });
      }
      
      // Solar dates should remain as is
    }
    
    return result;
  }

  /// Convert dates in event descriptions to Shahanshahi format
  /// Handles both Persian and English date formats
  /// - Persian: "۴ آبان ۱۳۴۶" -> "۴ آبان ۲۵۲۶", "۳۱ اکتبر" -> "۴ آبان"
  /// - English: "26 November 1967" -> "4 Aban 2526", "31 October" -> "4 Aban"
  /// - English: "4 Aban 1346" -> "4 Aban 2526"
  /// - Standalone years: "1978" -> "3158" (when in Gregorian range)
  static String convertDatesToShahanshahi(String text, String language) {
    String result = text;
    final dateConverter = DateConverterService();
    
    if (language == 'fa') {
      // Persian: Convert Solar Hijri years to Shahanshahi
      result = convertSolarYearsToShahanshahi(result);
      
      // Also convert Gregorian dates to Shahanshahi
      final gregorianMonthNamesFa = [
        'ژانویه', 'فوریه', 'مارس', 'آوریل',
        'می', 'ژوئن', 'جولای', 'اوت',
        'سپتامبر', 'اکتبر', 'نوامبر', 'دسامبر'
      ];
      
      for (int i = 0; i < gregorianMonthNamesFa.length; i++) {
        final monthName = gregorianMonthNamesFa[i];
        final monthNum = i + 1;
        
        // Pattern 1: "day monthName year" or "day monthName"
        final pattern1 = RegExp(
          r'([۱۲۳۴۵۶۷۸۹۰]+)\s+' + RegExp.escape(monthName) + r'(?:\s+([۱۲۳۴۵۶۷۸۹۰]{4}))?',
        );
        
        result = result.replaceAllMapped(pattern1, (match) {
          final dayStr = match.group(1)!;
          final yearStr = match.group(2);
          
          final day = int.tryParse(persianToEnglishDigits(dayStr));
          if (day == null) return match.group(0)!;
          
          if (yearStr != null) {
            final year = int.tryParse(persianToEnglishDigits(yearStr));
            if (year != null && year >= 1900 && year <= 2100) {
              try {
                final gregorianDate = DateTime(year, monthNum, day);
                final jalali = dateConverter.gregorianToJalali(gregorianDate);
                final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
                final monthNameFa = dateConverter.getJalaliMonthNameFa(jalali.month);
                final dayFormatted = englishToPersianDigits(jalali.day.toString());
                final yearFormatted = englishToPersianDigits(shahanshahiYear.toString());
                return '$dayFormatted $monthNameFa $yearFormatted';
              } catch (e) {
                return match.group(0)!;
              }
            }
          } else {
            // Date without year
            try {
              final referenceYear = 2025;
              final gregorianDate = DateTime(referenceYear, monthNum, day);
              final jalali = dateConverter.gregorianToJalali(gregorianDate);
              final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
              final monthNameFa = dateConverter.getJalaliMonthNameFa(jalali.month);
              final dayFormatted = englishToPersianDigits(jalali.day.toString());
              return '$dayFormatted $monthNameFa';
            } catch (e) {
              return match.group(0)!;
            }
          }
          return match.group(0)!;
        });
        
        // Pattern 2: "monthName day year" or "monthName day"
        // This handles formats like "اکتبر ۳۱" or "اکتبر ۳۱ ۲۰۲۵"
        final pattern2 = RegExp(
          RegExp.escape(monthName) + r'\s+([۱۲۳۴۵۶۷۸۹۰]+)(?:\s+([۱۲۳۴۵۶۷۸۹۰]{4}))?',
        );
        
        result = result.replaceAllMapped(pattern2, (match) {
          final dayStr = match.group(1)!;
          final yearStr = match.group(2);
          
          final day = int.tryParse(persianToEnglishDigits(dayStr));
          if (day == null) return match.group(0)!;
          
          if (yearStr != null) {
            final year = int.tryParse(persianToEnglishDigits(yearStr));
            if (year != null && year >= 1900 && year <= 2100) {
              try {
                final gregorianDate = DateTime(year, monthNum, day);
                final jalali = dateConverter.gregorianToJalali(gregorianDate);
                final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
                final monthNameFa = dateConverter.getJalaliMonthNameFa(jalali.month);
                final dayFormatted = englishToPersianDigits(jalali.day.toString());
                final yearFormatted = englishToPersianDigits(shahanshahiYear.toString());
                return '$dayFormatted $monthNameFa $yearFormatted';
              } catch (e) {
                return match.group(0)!;
              }
            }
          } else {
            // Date without year
            try {
              final referenceYear = 2025;
              final gregorianDate = DateTime(referenceYear, monthNum, day);
              final jalali = dateConverter.gregorianToJalali(gregorianDate);
              final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
              final monthNameFa = dateConverter.getJalaliMonthNameFa(jalali.month);
              final dayFormatted = englishToPersianDigits(jalali.day.toString());
              return '$dayFormatted $monthNameFa';
            } catch (e) {
              return match.group(0)!;
            }
          }
          return match.group(0)!;
        });
      }
      
      return result;
    } else {
      // English: Need to handle both Gregorian dates and Solar Hijri dates
      result = text;
      
      // First, convert full Gregorian date formats like "26 November 1967" or "31 October" to Shahanshahi
      // Pattern: day (1-31) + month name + year (4 digits) or just day + month name
      final gregorianMonthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      for (int i = 0; i < gregorianMonthNames.length; i++) {
        final monthName = gregorianMonthNames[i];
        final monthNum = i + 1;
        
        // Pattern 1: "day monthName year" or "day monthName, year" or "day monthName"
        final pattern1 = RegExp(
          r'(\d{1,2})\s+' + RegExp.escape(monthName) + r'(?:,\s*)?(?:\s+(\d{4}))?',
          caseSensitive: false,
        );
        
        result = result.replaceAllMapped(pattern1, (match) {
          final day = int.tryParse(match.group(1)!);
          final yearStr = match.group(2);
          
          if (day == null) return match.group(0)!;
          
          if (yearStr != null) {
            final year = int.tryParse(yearStr);
            if (year != null && year >= 1900 && year <= 2100) {
              // Convert Gregorian to Shahanshahi
              try {
                final gregorianDate = DateTime(year, monthNum, day);
                final jalali = dateConverter.gregorianToJalali(gregorianDate);
                final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
                final monthNameEn = dateConverter.getJalaliMonthNameEn(jalali.month);
                
                return '${jalali.day} $monthNameEn $shahanshahiYear';
              } catch (e) {
                // Invalid date, return original
                return match.group(0)!;
              }
            }
          } else {
            // Date without year
            try {
              final referenceYear = 2025;
              final gregorianDate = DateTime(referenceYear, monthNum, day);
              final jalali = dateConverter.gregorianToJalali(gregorianDate);
              final monthNameEn = dateConverter.getJalaliMonthNameEn(jalali.month);
              return '${jalali.day} $monthNameEn';
            } catch (e) {
              return match.group(0)!;
            }
          }
          return match.group(0)!;
        });
        
        // Pattern 2: "monthName day year" or "monthName day, year" or "monthName day"
        // This handles formats like "October 31" or "October 31, 2025"
        final pattern2 = RegExp(
          RegExp.escape(monthName) + r'\s+(\d{1,2})(?:,\s*)?(?:\s+(\d{4}))?',
          caseSensitive: false,
        );
        
        result = result.replaceAllMapped(pattern2, (match) {
          final day = int.tryParse(match.group(1)!);
          final yearStr = match.group(2);
          
          if (day == null) return match.group(0)!;
          
          if (yearStr != null) {
            final year = int.tryParse(yearStr);
            if (year != null && year >= 1900 && year <= 2100) {
              // Convert Gregorian to Shahanshahi
              try {
                final gregorianDate = DateTime(year, monthNum, day);
                final jalali = dateConverter.gregorianToJalali(gregorianDate);
                final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
                final monthNameEn = dateConverter.getJalaliMonthNameEn(jalali.month);
                
                return '${jalali.day} $monthNameEn $shahanshahiYear';
              } catch (e) {
                // Invalid date, return original
                return match.group(0)!;
              }
            }
          } else {
            // Date without year
            try {
              final referenceYear = 2025;
              final gregorianDate = DateTime(referenceYear, monthNum, day);
              final jalali = dateConverter.gregorianToJalali(gregorianDate);
              final monthNameEn = dateConverter.getJalaliMonthNameEn(jalali.month);
              return '${jalali.day} $monthNameEn';
            } catch (e) {
              return match.group(0)!;
            }
          }
          return match.group(0)!;
        });
      }
      
      // Second, convert standalone Gregorian years (1900-2100) to Shahanshahi
      // But only if they're not part of a date we already converted
      // We need to be careful: check if the year is already part of a converted date
      // by checking if it's preceded by a month name or followed by punctuation that suggests it's standalone
      final standaloneYearPattern = RegExp(r'\b(19\d{2}|20\d{2})\b');
      
      // Get all matches and process in reverse order
      final yearMatches = standaloneYearPattern.allMatches(result).toList();
      yearMatches.sort((a, b) => b.start.compareTo(a.start));
      
      for (final match in yearMatches) {
        final yearStr = match.group(1)!;
        final year = int.tryParse(yearStr);
        
        if (year != null && year >= 1900 && year <= 2100) {
          // Check if this year is already part of a converted date
          // by checking the context around it
          final start = match.start;
          final end = match.end;
          final before = start > 0 ? result.substring(start - 20, start) : '';
          final after = end < result.length ? result.substring(end, end + 20) : '';
          
          // Skip if it looks like it's part of a date we already converted
          // (e.g., if it's preceded by a Jalali month name)
          final jalaliMonthPattern = RegExp(
            r'(Farvardin|Ordibehesht|Khordad|Tir|Mordad|Shahrivar|Mehr|Aban|Azar|Dey|Bahman|Esfand)\s+\d{1,2}\s+' + yearStr,
            caseSensitive: false,
          );
          
          if (jalaliMonthPattern.hasMatch(before + yearStr + after)) {
            continue; // Skip, it's already part of a converted date
          }
          
          // Check if this year appears after "to" or similar words, suggesting it's an end date
          // In that case, convert to end of year in Shahanshahi
          final contextBefore = before.toLowerCase();
          final isEndDate = contextBefore.contains(RegExp(r'\b(to|until|till|by)\b'));
          
          if (isEndDate) {
            // Convert to end of year in Shahanshahi (approximately end of Dey or Bahman)
            try {
              // Use December 31 of the Gregorian year
              final gregorianDate = DateTime(year, 12, 31);
              final jalali = dateConverter.gregorianToJalali(gregorianDate);
              final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
              final monthNameEn = dateConverter.getJalaliMonthNameEn(jalali.month);
              result = result.replaceRange(start, end, '${jalali.day} $monthNameEn $shahanshahiYear');
            } catch (e) {
              // If December 31 fails, try January 1 of next year
              try {
                final gregorianDate = DateTime(year + 1, 1, 1);
                final jalali = dateConverter.gregorianToJalali(gregorianDate);
                final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
                final monthNameEn = dateConverter.getJalaliMonthNameEn(jalali.month);
                result = result.replaceRange(start, end, '${jalali.day} $monthNameEn $shahanshahiYear');
              } catch (e2) {
                // Fallback to just year
                try {
                  final gregorianDate = DateTime(year, 12, 31);
                  final jalali = dateConverter.gregorianToJalali(gregorianDate);
                  final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
                  result = result.replaceRange(start, end, shahanshahiYear.toString());
                } catch (e3) {
                  // Keep original if conversion fails
                }
              }
            }
          } else {
            // Regular year conversion - just convert to Shahanshahi year
            try {
              final gregorianDate = DateTime(year, 12, 31);
              final jalali = dateConverter.gregorianToJalali(gregorianDate);
              final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
              result = result.replaceRange(start, end, shahanshahiYear.toString());
            } catch (e) {
              // If December 31 fails (leap year issue), try January 1
              try {
                final gregorianDate = DateTime(year, 1, 1);
                final jalali = dateConverter.gregorianToJalali(gregorianDate);
                final shahanshahiYear = dateConverter.getShahanshahiYear(jalali.year);
                result = result.replaceRange(start, end, shahanshahiYear.toString());
              } catch (e2) {
                // Keep original if conversion fails
              }
            }
          }
        }
      }
      
      // Third, convert Solar Hijri dates in English format like "4 Aban 1346" to Shahanshahi
      final jalaliMonthNamesEn = [
        'Farvardin', 'Ordibehesht', 'Khordad', 'Tir',
        'Mordad', 'Shahrivar', 'Mehr', 'Aban',
        'Azar', 'Dey', 'Bahman', 'Esfand'
      ];
      
      for (int i = 0; i < jalaliMonthNamesEn.length; i++) {
        final monthName = jalaliMonthNamesEn[i];
        final monthNum = i + 1;
        
        // Pattern: "day monthName year" where year is in Solar Hijri range (1300-1500)
        final pattern = RegExp(
          r'(\d{1,2})\s+' + RegExp.escape(monthName) + r'\s+(\d{4})',
          caseSensitive: false,
        );
        
        result = result.replaceAllMapped(pattern, (match) {
          final day = int.tryParse(match.group(1)!);
          final year = int.tryParse(match.group(2)!);
          
          if (day != null && year != null && year >= 1300 && year <= 1500) {
            // Convert Solar Hijri to Shahanshahi
            final shahanshahiYear = dateConverter.getShahanshahiYear(year);
            return '$day $monthName $shahanshahiYear';
          }
          return match.group(0)!;
        });
      }
      
      // Finally, convert standalone Solar Hijri years (1300-1500) to Shahanshahi
      final solarYearPattern = RegExp(r'\b(1[3-4]\d{2}|1500)\b');
      result = result.replaceAllMapped(solarYearPattern, (match) {
        final year = int.tryParse(match.group(1)!);
        if (year != null && year >= 1300 && year <= 1500) {
          final shahanshahiYear = dateConverter.getShahanshahiYear(year);
          return shahanshahiYear.toString();
        }
        return match.group(0)!;
      });
      
      return result;
    }
  }
}
