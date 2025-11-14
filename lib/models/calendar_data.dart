/// Pre-generated calendar data structures

class CalendarData {
  final int year;
  final Map<int, MonthData> months;

  CalendarData({
    required this.year,
    required this.months,
  });

  factory CalendarData.fromJson(Map<String, dynamic> json) {
    final monthsMap = <int, MonthData>{};
    if (json['months'] != null) {
      json['months'].forEach((key, value) {
        monthsMap[int.parse(key)] = MonthData.fromJson(value);
      });
    }
    return CalendarData(
      year: json['year'] as int,
      months: monthsMap,
    );
  }
}

class MonthData {
  final int year;
  final int month;
  final String monthName;
  final String? monthNameLatin;
  final String? monthNameShort;
  final int daysInMonth;
  final int weekStartDay; // 0=Saturday (for Solar), 1=Monday (for Gregorian)
  final List<WeekData> weeks;

  MonthData({
    required this.year,
    required this.month,
    required this.monthName,
    this.monthNameLatin,
    this.monthNameShort,
    required this.daysInMonth,
    required this.weekStartDay,
    required this.weeks,
  });

  factory MonthData.fromJson(Map<String, dynamic> json) {
    final weeksList = (json['weeks'] as List?)
            ?.map((w) => WeekData.fromJson(w as Map<String, dynamic>))
            .toList() ??
        [];
    
    return MonthData(
      year: json['year'] as int,
      month: json['month'] as int,
      monthName: json['monthName'] as String,
      monthNameLatin: json['monthNameLatin'] as String?,
      monthNameShort: json['monthNameShort'] as String?,
      daysInMonth: json['daysInMonth'] as int,
      weekStartDay: json['weekStartDay'] as int,
      weeks: weeksList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'monthName': monthName,
      'monthNameLatin': monthNameLatin,
      'monthNameShort': monthNameShort,
      'daysInMonth': daysInMonth,
      'weekStartDay': weekStartDay,
      'weeks': weeks.map((w) => w.toJson()).toList(),
    };
  }
}

class WeekData {
  final List<DayData> days;

  WeekData({required this.days});

  factory WeekData.fromJson(Map<String, dynamic> json) {
    final daysList = (json['days'] as List?)
            ?.map((d) => DayData.fromJson(d as Map<String, dynamic>))
            .toList() ??
        [];
    return WeekData(days: daysList);
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days.map((d) => d.toJson()).toList(),
    };
  }
}

class DayData {
  final int date; // Day number (۱, ۲, ۳... for Persian or 1, 2, 3... for English)
  final bool isCurrentMonth;
  final String? gregorianDate; // Format: "2024-10-15"
  final String? solarDate; // Format: "1403-07-24"
  final int dayOfWeek; // 0=Saturday, 1=Sunday, 2=Monday, etc. for Solar | 1=Monday, 2=Tuesday, etc. for Gregorian

  DayData({
    required this.date,
    required this.isCurrentMonth,
    this.gregorianDate,
    this.solarDate,
    required this.dayOfWeek,
  });

  factory DayData.fromJson(Map<String, dynamic> json) {
    // Handle date field - it might be a string with Persian digits or an int
    int dateValue;
    if (json['date'] is String) {
      // Convert Persian digits to English and parse
      final dateStr = json['date'] as String;
      final persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
      final englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      String converted = dateStr;
      for (int i = 0; i < persianDigits.length; i++) {
        converted = converted.replaceAll(persianDigits[i], englishDigits[i]);
      }
      dateValue = int.parse(converted);
    } else {
      dateValue = json['date'] as int;
    }
    
    return DayData(
      date: dateValue,
      isCurrentMonth: json['isCurrentMonth'] as bool,
      gregorianDate: json['gregorianDate'] as String?,
      solarDate: json['solarDate'] as String?,
      dayOfWeek: json['dayOfWeek'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'isCurrentMonth': isCurrentMonth,
      'gregorianDate': gregorianDate,
      'solarDate': solarDate,
      'dayOfWeek': dayOfWeek,
    };
  }
}

/// Week header data
class WeekDayHeader {
  final String english; // "Mon"
  final String persian; // "دوشنبه"

  WeekDayHeader({required this.english, required this.persian});

  factory WeekDayHeader.fromJson(Map<String, dynamic> json) {
    return WeekDayHeader(
      english: json['en'] as String,
      persian: json['fa'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': english,
      'fa': persian,
    };
  }
}

/// Transformation-ready month data for display
class DisplayMonthData {
  final int year;
  final int month;
  final String monthName;
  final String? monthNameShort;
  final int daysInMonth;
  final int weekStartDay;
  final List<String> weekDayHeaders;
  final List<WeekData> weeks;

  DisplayMonthData({
    required this.year,
    required this.month,
    required this.monthName,
    this.monthNameShort,
    required this.daysInMonth,
    required this.weekStartDay,
    required this.weekDayHeaders,
    required this.weeks,
  });
}

