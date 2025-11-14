import '../services/date_converter_service.dart';
import '../utils/calendar_utils.dart';

/// Utility functions for formatting header displays
class HeaderFormatter {
  static final DateConverterService _dateConverter = DateConverterService();

  /// Format page header (top header showing today's date)
  static String formatPageHeader({
    required DateTime date,
    required String language,
    required String calendarType,
  }) {
    final isSolarHijri = calendarType == 'solar' || calendarType == 'shahanshahi';
    final isPersianLang = language == 'fa';

    if (isSolarHijri) {
      final jalali = _dateConverter.gregorianToJalali(date);
      if (isPersianLang) {
        // Persian: "۵ آبان ۱۴۰۴"
        return '${CalendarUtils.englishToPersianDigits(jalali.day.toString())} ${_dateConverter.getJalaliMonthNameFa(jalali.month)} ${CalendarUtils.englishToPersianDigits(jalali.year.toString())}';
      } else {
        // English: "5 Aban 1404" (day month year) with thin space between day and month
        return '${jalali.day}\u2009${_dateConverter.getJalaliMonthNameEn(jalali.month)} ${jalali.year}';
      }
    } else {
      if (isPersianLang) {
        // Persian: "۲۷ اکتبر ۲۰۲۵"
        return '${CalendarUtils.englishToPersianDigits(date.day.toString())} ${_dateConverter.getGregorianMonthNameFa(date.month)} ${CalendarUtils.englishToPersianDigits(date.year.toString())}';
      } else {
        // English: "Oct 27 2025"
        return '${_dateConverter.getGregorianMonthNameShortEn(date.month)} ${date.day} ${date.year}';
      }
    }
  }

  /// Format calendar header (month and year display)
  static String formatCalendarHeader({
    required int year,
    required String monthName,
    required String language,
    required String calendarType,
  }) {
    final isPersianLang = language == 'fa';
    
    // Convert year based on language
    final yearString = isPersianLang 
        ? CalendarUtils.englishToPersianDigits(year.toString())
        : year.toString();

    return '$monthName $yearString';
  }

  /// Get month name for display based on language and calendar type
  static String getMonthName({
    required int year,
    required int month,
    required String language,
    required String calendarType,
  }) {
    final isSolarHijri = calendarType == 'solar' || calendarType == 'shahanshahi';
    final isPersianLang = language == 'fa';

    if (isSolarHijri) {
      if (isPersianLang) {
        return _dateConverter.getJalaliMonthNameFa(month);
      } else {
        return _dateConverter.getJalaliMonthNameEn(month);
      }
    } else {
      if (isPersianLang) {
        return _dateConverter.getGregorianMonthNameFa(month);
      } else {
        // Get full month name, not short
        final monthNames = {
          1: 'January', 2: 'February', 3: 'March', 4: 'April',
          5: 'May', 6: 'June', 7: 'July', 8: 'August',
          9: 'September', 10: 'October', 11: 'November', 12: 'December'
        };
        return monthNames[month] ?? 'Month';
      }
    }
  }

  /// Get today label
  static String getTodayLabel(String language) {
    return language == 'fa' ? 'امروز' : 'Today';
  }

  /// Get day and month for page header
  static String getDayMonth({
    required DateTime date,
    required String language,
    required String calendarType,
  }) {
    final isSolarHijri = calendarType == 'solar' || calendarType == 'shahanshahi';
    final isPersianLang = language == 'fa';

    if (isSolarHijri) {
      final jalali = _dateConverter.gregorianToJalali(date);
      if (isPersianLang) {
        return '${CalendarUtils.englishToPersianDigits(jalali.day.toString())} ${_dateConverter.getJalaliMonthNameFa(jalali.month)}';
      } else {
        // English: format "23 Aban" (day month) with thin space
        return '${jalali.day}\u2009${_dateConverter.getJalaliMonthNameEn(jalali.month)}';
      }
    } else {
      if (isPersianLang) {
        return '${CalendarUtils.englishToPersianDigits(date.day.toString())} ${_dateConverter.getGregorianMonthNameFa(date.month)}';
      } else {
        return '${_dateConverter.getGregorianMonthNameShortEn(date.month)} ${date.day}';
      }
    }
  }

  /// Get year for page header
  static String getYearDisplay({
    required DateTime date,
    required String language,
    required String calendarType,
  }) {
    final isSolarHijri = calendarType == 'solar';
    final isPersianLang = language == 'fa';

    if (isSolarHijri) {
      final jalali = _dateConverter.gregorianToJalali(date);
      if (isPersianLang) {
        return CalendarUtils.englishToPersianDigits(jalali.year.toString());
      } else {
        return jalali.year.toString();
      }
    } else {
      if (isPersianLang) {
        return CalendarUtils.englishToPersianDigits(date.year.toString());
      } else {
        return date.year.toString();
      }
    }
  }
}

