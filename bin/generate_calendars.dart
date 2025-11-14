import 'dart:io';
import 'package:shamsi_date/shamsi_date.dart';
import 'dart:convert';

void main() async {
  print('🚀 Starting calendar generation...\n');
  
  // Ensure directories exist
  await Directory('assets/data/calendars').create(recursive: true);
  
  // Generate Gregorian calendars
  print('📅 Generating Gregorian calendars (2024-2026)...');
  for (int year in [2024, 2025, 2026]) {
    await generateGregorianYear(year);
    print('  ✓ $year complete');
  }
  
  print('\n🌙 Generating Solar Hijri calendars (1403-1405)...');
  for (int year in [1403, 1404, 1405]) {
    await generateSolarYear(year);
    print('  ✓ $year complete');
  }
  
  print('\n✅ All calendars generated successfully!');
  print('📁 Files saved in: assets/data/calendars/');
}

Future<void> generateGregorianYear(int year) async {
  final yearData = <String, dynamic>{'year': year, 'months': {}};
  
  final monthNames = {
    1: 'January', 2: 'February', 3: 'March', 4: 'April',
    5: 'May', 6: 'June', 7: 'July', 8: 'August',
    9: 'September', 10: 'October', 11: 'November', 12: 'December'
  };
  
  final monthShort = {
    1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr',
    5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug',
    9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
  };
  
  for (int month = 1; month <= 12; month++) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    // Get Monday before or equal to first day
    DateTime firstDayOfWeek = firstDay;
    while (firstDayOfWeek.weekday != 1) {
      firstDayOfWeek = firstDayOfWeek.subtract(const Duration(days: 1));
    }
    
    final weeks = <Map<String, dynamic>>[];
    DateTime currentDate = firstDayOfWeek;
    
    for (int w = 0; w < 6; w++) {
      final days = <Map<String, dynamic>>[];
      
      for (int d = 0; d < 7; d++) {
        final isCurrentMonth = currentDate.year == year && currentDate.month == month;
        final jalali = Jalali.fromDateTime(currentDate);
        
        days.add({
          'date': currentDate.day,
          'isCurrentMonth': isCurrentMonth,
          'gregorianDate': '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}',
          'solarDate': '${jalali.year}-${jalali.month}-${jalali.day}',
          'dayOfWeek': currentDate.weekday,
        });
        
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      weeks.add({'days': days});
      
      if (w >= 4 && days.every((d) => !d['isCurrentMonth'])) break;
    }
    
    yearData['months'][month.toString()] = {
      'year': year,
      'month': month,
      'monthName': monthNames[month]!,
      'monthNameShort': monthShort[month]!,
      'daysInMonth': lastDay.day,
      'weekStartDay': 1,
      'weeks': weeks,
    };
  }
  
  final file = File('assets/data/calendars/gregorian_$year.json');
  await file.writeAsString(jsonEncode(yearData));
}

Future<void> generateSolarYear(int year) async {
  final yearData = <String, dynamic>{'year': year, 'months': {}};
  
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
    final gregFirst = Jalali(year, month, 1).toDateTime();
    final firstDay = DateTime(gregFirst.year, gregFirst.month, gregFirst.day);
    
    final daysInMonth = Jalali(year, month, 1).monthLength;
    final gregLast = Jalali(year, month, daysInMonth).toDateTime();
    final lastDay = DateTime(gregLast.year, gregLast.month, gregLast.day);
    
    // Get Saturday before or equal to first day
    DateTime firstDayOfWeek = firstDay;
    while (firstDayOfWeek.weekday != 6) {
      firstDayOfWeek = firstDayOfWeek.subtract(const Duration(days: 1));
    }
    
    final weeks = <Map<String, dynamic>>[];
    DateTime currentDate = firstDayOfWeek;
    
    for (int w = 0; w < 6; w++) {
      final days = <Map<String, dynamic>>[];
      
      for (int d = 0; d < 7; d++) {
        final jalali = Jalali.fromDateTime(currentDate);
        final isCurrentMonth = jalali.year == year && jalali.month == month;
        
        days.add({
          'date': _englishToPersianDigits(jalali.day.toString()),
          'isCurrentMonth': isCurrentMonth,
          'gregorianDate': '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}',
          'solarDate': '${jalali.year}-${jalali.month}-${jalali.day}',
          'dayOfWeek': currentDate.weekday == 7 ? 0 : currentDate.weekday,
        });
        
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      weeks.add({'days': days});
      
      if (w >= 4 && days.every((d) => !d['isCurrentMonth'])) break;
    }
    
    yearData['months'][month.toString()] = {
      'year': year,
      'month': month,
      'monthName': monthNamesPersian[month]!,
      'monthNameLatin': monthNamesLatin[month]!,
      'daysInMonth': daysInMonth,
      'weekStartDay': 0,
      'weeks': weeks,
    };
  }
  
  final file = File('assets/data/calendars/solar_$year.json');
  await file.writeAsString(jsonEncode(yearData));
}

String _englishToPersianDigits(String text) {
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  String result = text;
  for (int i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], persian[i]);
  }
  return result;
}

