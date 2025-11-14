import 'package:shamsi_date/shamsi_date.dart';
import 'package:intl/intl.dart';

class DateConverterService {
  static final DateConverterService _instance = DateConverterService._internal();
  factory DateConverterService() => _instance;
  DateConverterService._internal();

  /// Convert Jalali date to Gregorian
  DateTime jalaliToGregorian(int year, int month, int day) {
    final jalali = Jalali(year, month, day);
    return jalali.toDateTime();
  }

  /// Convert Gregorian date to Jalali
  Jalali gregorianToJalali(DateTime dateTime) {
    return Jalali.fromDateTime(dateTime);
  }

  /// Get current Jalali date
  Jalali getCurrentJalaliDate() {
    return Jalali.now();
  }

  /// Get current Gregorian date
  DateTime getCurrentGregorianDate() {
    return DateTime.now();
  }

  /// Format Jalali date for display
  String formatJalaliDate(Jalali date, {String pattern = 'yyyy/MM/dd'}) {
    return DateFormat(pattern).format(date.toDateTime());
  }

  /// Format Gregorian date for display
  String formatGregorianDate(DateTime date, {String pattern = 'yyyy/MM/dd'}) {
    return DateFormat(pattern).format(date);
  }

  /// Get Gregorian month name
  String getGregorianMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  /// Check if a Gregorian date is today
  bool isGregorianToday(DateTime date) {
    final today = getCurrentGregorianDate();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  /// Get week start date for Gregorian calendar
  DateTime getGregorianWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  /// Get month start date for Gregorian calendar
  DateTime getGregorianMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Add months to Gregorian date
  DateTime addMonthsToGregorian(DateTime date, int months) {
    int newYear = date.year;
    int newMonth = date.month + months;
    
    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }
    
    return DateTime(newYear, newMonth, date.day);
  }

  /// Get Jalali month name in English
  String getJalaliMonthNameEn(int month) {
    const monthNames = [
      'Farvardin', 'Ordibehesht', 'Khordad', 'Tir',
      'Mordad', 'Shahrivar', 'Mehr', 'Aban',
      'Azar', 'Dey', 'Bahman', 'Esfand'
    ];
    return monthNames[month - 1];
  }

  /// Get Jalali month name (Persian)
  String getJalaliMonthNameFa(int month) {
    const monthNames = [
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر',
      'مرداد', 'شهریور', 'مهر', 'آبان',
      'آذر', 'دی', 'بهمن', 'اسفند'
    ];
    return monthNames[month - 1];
  }

  /// Get Gregorian month name in English (short)
  String getGregorianMonthNameShortEn(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }

  /// Get Gregorian month name in Persian
  String getGregorianMonthNameFa(int month) {
    const monthNames = [
      'ژانویه', 'فوریه', 'مارس', 'آوریل',
      'می', 'ژوئن', 'جولای', 'اوت',
      'سپتامبر', 'اکتبر', 'نوامبر', 'دسامبر'
    ];
    return monthNames[month - 1];
  }

  // Shahanshahi calendar conversion methods
  // Shahanshahi is identical to Solar (Jalali) but with year offset of +1180
  // Year 1355 Shamsi = Year 2535 Shahanshahi
  // Difference: 2535 - 1355 = 1180

  /// Convert Jalali (Solar) date to Shahanshahi
  /// Shahanshahi year = Jalali year + 1180
  Jalali jalaliToShahanshahi(Jalali jalali) {
    return Jalali(jalali.year + 1180, jalali.month, jalali.day);
  }

  /// Convert Shahanshahi date to Jalali (Solar)
  /// Jalali year = Shahanshahi year - 1180
  Jalali shahanshahiToJalali(Jalali shahanshahi) {
    return Jalali(shahanshahi.year - 1180, shahanshahi.month, shahanshahi.day);
  }

  /// Convert Gregorian date to Shahanshahi
  Jalali gregorianToShahanshahi(DateTime dateTime) {
    final jalali = gregorianToJalali(dateTime);
    return jalaliToShahanshahi(jalali);
  }

  /// Convert Shahanshahi date to Gregorian
  DateTime shahanshahiToGregorian(Jalali shahanshahi) {
    final jalali = shahanshahiToJalali(shahanshahi);
    return jalaliToGregorian(jalali.year, jalali.month, jalali.day);
  }

  /// Get current Shahanshahi date
  Jalali getCurrentShahanshahiDate() {
    final jalali = getCurrentJalaliDate();
    return jalaliToShahanshahi(jalali);
  }

  /// Get Shahanshahi year from Jalali year
  int getShahanshahiYear(int jalaliYear) {
    return jalaliYear + 1180;
  }

  /// Get Jalali year from Shahanshahi year
  int getJalaliYearFromShahanshahi(int shahanshahiYear) {
    return shahanshahiYear - 1180;
  }
}
