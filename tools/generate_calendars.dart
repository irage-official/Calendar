import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Script to generate pre-built calendar JSON files
/// This script generates both Gregorian and Solar Hijri calendars
/// Run this with: dart run tools/generate_calendars.dart

void main() async {
  print('Generating calendar data...');
  
  // Create output directory
  final outputDir = Directory('assets/data/calendars');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  // Generate Gregorian calendars (2024-2026)
  print('Generating Gregorian calendars...');
  for (int year in [2024, 2025, 2026]) {
    final calendarData = await generateGregorianCalendar(year);
    final jsonString = jsonEncode(calendarData);
    final file = File(path.join(outputDir.path, 'gregorian_$year.json'));
    await file.writeAsString(jsonString);
    print('Generated: gregorian_$year.json');
  }

  // Generate Solar Hijri calendars (1403-1405)
  print('Generating Solar Hijri calendars...');
  for (int year in [1403, 1404, 1405]) {
    final calendarData = await generateSolarHijriCalendar(year);
    final jsonString = jsonEncode(calendarData);
    final file = File(path.join(outputDir.path, 'solar_$year.json'));
    await file.writeAsString(jsonString);
    print('Generated: solar_$year.json');
  }

  print('Calendar generation complete!');
  print('Files saved in: ${outputDir.path}');
}

/// Generate Gregorian calendar for a specific year
Future<Map<String, dynamic>> generateGregorianCalendar(int year) async {
  final months = <String, dynamic>{};
  
  final monthNames = {
    1: 'January', 2: 'February', 3: 'March', 4: 'April',
    5: 'May', 6: 'June', 7: 'July', 8: 'August',
    9: 'September', 10: 'October', 11: 'November', 12: 'December'
  };

  final monthShortNames = {
    1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr',
    5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug',
    9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
  };

  for (int month = 1; month <= 12; month++) {
    final monthData = await generateGregorianMonth(year, month, monthNames[month]!, monthShortNames[month]!);
    months[month.toString()] = monthData;
  }

  return {
    'year': year,
    'months': months,
  };
}

/// Generate a single Gregorian month
Future<Map<String, dynamic>> generateGregorianMonth(int year, int month, String monthName, String monthShortName) async {
  final firstDay = DateTime(year, month, 1);
  final lastDay = DateTime(year, month + 1, 0);
  final daysInMonth = lastDay.day;
  
  // Week starts on Monday (dayOfWeek: 1 = Monday)
  final weekStartDay = 1;
  
  // Get the first day of the week for this month (Monday before or equal to first day)
  final firstDayOfWeek = firstDay.subtract(Duration(days: firstDay.weekday - 1));
  
  // Calculate weeks needed (always 5-6 weeks)
  final weeks = <Map<String, dynamic>>[];
  DateTime currentDate = firstDayOfWeek;
  
  while (currentDate.isBefore(lastDay) || 
         currentDate.month == month || 
         weeks.length < 6) {
    final weekDays = <Map<String, dynamic>>[];
    
    for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
      final isCurrentMonth = currentDate.year == year && currentDate.month == month;
      
      // Convert to Solar Hijri equivalent
      final solarDate = gregorianToJalali(currentDate);
      final solarDateString = '${solarDate['year']}-${solarDate['month']}-${solarDate['day']}';
      final gregorianDateString = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      
      weekDays.add({
        'date': currentDate.day,
        'isCurrentMonth': isCurrentMonth,
        'gregorianDate': gregorianDateString,
        'solarDate': solarDateString,
        'dayOfWeek': currentDate.weekday, // 1=Monday, 2=Tuesday, ...
      });
      
      currentDate = currentDate.add(const Duration(days: 1));
      
      // Stop if we've gone too far and have at least 6 weeks
      if (!isCurrentMonth && weekDays.last['isCurrentMonth'] == false && weeks.length >= 5) {
        break;
      }
    }
    
    weeks.add({'days': weekDays});
    
    // Stop after 6 weeks
    if (weeks.length >= 6) break;
  }

  return {
    'year': year,
    'month': month,
    'monthName': monthName,
    'monthNameShort': monthShortName,
    'daysInMonth': daysInMonth,
    'weekStartDay': weekStartDay,
    'weeks': weeks,
  };
}

/// Generate Solar Hijri calendar for a specific year
Future<Map<String, dynamic>> generateSolarHijriCalendar(int year) async {
  final months = <String, dynamic>{};
  
  final monthNamesPersian = {
    1: 'فروردین', 2: 'اردیبهشت', 3: 'خرداد', 4: 'تیر',
    5: 'مرداد', 6: 'شهریور', 7: 'مهر', 8: 'آبان',
    9: 'آذر', 10: 'دی', 11: 'بهمن', 12: 'اسفند'
  };
  
  final monthNamesLatin = {
    1: 'Farvardin', 2: 'Ordibehesht', 3: 'Khordad', 4: 'Tir',
    5: 'Mordad', 6: 'Shahrivar', 7: 'Mehr', 8: 'Aban',
    9: 'Azar', 10: 'Dey', 11: 'Bahman', 12: 'Esfand'
  };

  for (int month = 1; month <= 12; month++) {
    final monthData = await generateSolarHijriMonth(
      year, 
      month, 
      monthNamesPersian[month]!, 
      monthNamesLatin[month]!
    );
    months[month.toString()] = monthData;
  }

  return {
    'year': year,
    'months': months,
  };
}

/// Generate a single Solar Hijri month
Future<Map<String, dynamic>> generateSolarHijriMonth(int year, int month, String monthNamePersian, String monthNameLatin) async {
  final gregorianStart = jalaliToGregorian(year, month, 1);
  final firstDay = DateTime(gregorianStart['year'] as int, gregorianStart['month'] as int, gregorianStart['day'] as int);
  
  // Calculate last day
  final daysInSolarMonth = getSolarHijriDaysInMonth(year, month);
  final gregorianEnd = jalaliToGregorian(year, month, daysInSolarMonth);
  final lastDay = DateTime(gregorianEnd['year'] as int, gregorianEnd['month'] as int, gregorianEnd['day'] as int);
  
  // Week starts on Saturday (dayOfWeek: 6 = Saturday)
  // We need to find the Saturday before or equal to first day
  final weekStartDay = 0; // 0=Saturday for consistency with our data structure
  
  // Find the Saturday of the week containing the first day
  DateTime firstDayOfWeek = firstDay;
  while (firstDayOfWeek.weekday != 6) { // 6 = Saturday
    firstDayOfWeek = firstDayOfWeek.subtract(const Duration(days: 1));
  }
  
  // Calculate weeks needed (5-6 weeks)
  final weeks = <Map<String, dynamic>>[];
  DateTime currentDate = firstDayOfWeek;
  
  while (currentDate.isBefore(lastDay) || 
         isDateInSolarMonth(currentDate, year, month) || 
         weeks.length < 6) {
    final weekDays = <Map<String, dynamic>>[];
    
    for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
      final gregorianDate = currentDate;
      final solarConverted = gregorianToJalali(gregorianDate);
      final isCurrentMonth = solarConverted['year'] == year && solarConverted['month'] == month;
      
      final gregorianDateString = '${gregorianDate.year}-${gregorianDate.month.toString().padLeft(2, '0')}-${gregorianDate.day.toString().padLeft(2, '0')}';
      final solarDateString = '${solarConverted['year']}-${solarConverted['month']}-${solarConverted['day']}';
      
      // Convert day number to Persian numeral
      final dayNumber = int.parse(solarConverted['day'].toString());
      final persianDayNumber = englishToPersianDigits(solarConverted['day'].toString());
      
      weekDays.add({
        'date': persianDayNumber, // Store as Persian numeral string for Persian calendar
        'isCurrentMonth': isCurrentMonth,
        'gregorianDate': gregorianDateString,
        'solarDate': solarDateString,
        'dayOfWeek': gregorianDate.weekday == 7 ? 0 : gregorianDate.weekday, // Adjust: Saturday = 0
      });
      
      currentDate = currentDate.add(const Duration(days: 1));
      
      if (!isCurrentMonth && weekDays.isNotEmpty && weekDays.last['isCurrentMonth'] == false && weeks.length >= 5) {
        break;
      }
    }
    
    weeks.add({'days': weekDays});
    
    if (weeks.length >= 6) break;
  }

  return {
    'year': year,
    'month': month,
    'monthName': monthNamePersian,
    'monthNameLatin': monthNameLatin,
    'daysInMonth': daysInSolarMonth,
    'weekStartDay': weekStartDay,
    'weeks': weeks,
  };
}

// Helper functions

Map<String, int> gregorianToJalali(DateTime gregorianDate) {
  // Simplified Jalali conversion
  // For production, use proper Jalali conversion library
  int gy = gregorianDate.year;
  int gm = gregorianDate.month;
  int gd = gregorianDate.day;
  
  int g_d_m = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
  int jy = (gy <= 1600) ? 0 : 979;
  int gy2 = (gy <= 1600) ? 621 : 1600;
  
  int days = (365 * gy + ((gy + 3) ~/ 4) - ((gy + 99) ~/ 100) + ((gy + 399) ~/ 400) - 80 + gd + g_d_m[gm - 1]);
  jy += 33 * ((days + 3) ~/ 146097);
  days = days % 146097;
  
  if (days > 36524) {
    jy++;
    days--;
  }
  
  jy += 4 * (days ~/ 1461);
  days = days % 1461;
  
  if (days > 364) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }
  
  int jd = (days < 186) ? 1 + (days ~/ 31) : 7 + ((days - 186) ~/ 30);
  int jm = jd;
  int jday = (days < 186) ? (1 + (days % 31)) : (1 + ((days - 186) % 30));
  
  return {'year': jy, 'month': jm, 'day': jday};
}

Map<String, int> jalaliToGregorian(int jy, int jm, int jd) {
  // Simplified Gregorian conversion
  // For production, use proper Jalali conversion library
  int gy = (jy <= 979) ? 621 : 1600;
  int jy2 = (jy <= 979) ? 0 : 979;
  
  int days = (365 * jy + (jy ~/ 33) * 8 + (jy % 33 + 3) ~/ 4 + 78 + jd);
  if (jy != jy2) {
    days += (jy2 < jy) ? (365 + (jy2 % 4 == 0 ? 1 : 0)) : 365;
  }
  
  int gd = 0;
  int gm = 0;
  int gy_adj = 0;
  
  // This is a simplified conversion - in production use a library
  return {'year': gy, 'month': 1, 'day': 1}; // Simplified
}

int getSolarHijriDaysInMonth(int year, int month) {
  if (month >= 1 && month <= 6) return 31;
  if (month >= 7 && month <= 11) return 30;
  // Esfand (month 12) - check for leap year
  return isSolarHijriLeapYear(year) ? 30 : 29;
}

bool isSolarHijriLeapYear(int year) {
  // Simplified leap year calculation
  // Jalali leap year occurs every 4 years, except in certain cycles
  return (year % 4 == 3);
}

bool isDateInSolarMonth(DateTime date, int solarYear, int solarMonth) {
  final converted = gregorianToJalali(date);
  return converted['year'] == solarYear && converted['month'] == solarMonth;
}

String englishToPersianDigits(String text) {
  const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  
  String result = text;
  for (int i = 0; i < englishDigits.length; i++) {
    result = result.replaceAll(englishDigits[i], persianDigits[i]);
  }
  return result;
}

