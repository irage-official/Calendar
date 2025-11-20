import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 4)
class UserPreferences extends HiveObject {
  @HiveField(0)
  final String language;

  @HiveField(1)
  final bool isDarkMode;

  @HiveField(2)
  final bool showGregorianDates;

  @HiveField(3)
  final String calendarSystem;

  @HiveField(4)
  final bool showNotifications;

  @HiveField(5)
  final bool showWeekends;

  @HiveField(6)
  final String defaultCalendarView;

  @HiveField(7)
  final bool autoSync;

  @HiveField(8)
  final String notificationTime;

  @HiveField(9)
  final List<String> enabledEventTypes;

  @HiveField(10)
  final DateTime lastSyncDate;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final String? themeMode;

  @HiveField(14)
  final String? startWeekOn; // 'saturday', 'sunday', 'monday'

  @HiveField(15)
  final List<String>? daysOff; // ['saturday', 'sunday', 'friday', 'thursday']

  @HiveField(16)
  final List<String>?
      enabledOrigins; // ['iranian', 'international', 'mixed', 'local']

  UserPreferences({
    this.language = 'system',
    this.isDarkMode = false,
    this.showGregorianDates = true,
    this.calendarSystem = 'shahanshahi',
    this.showNotifications = true,
    this.showWeekends = true,
    this.defaultCalendarView = 'month',
    this.autoSync = true,
    this.notificationTime = '09:00',
    this.enabledEventTypes = const ['celebration', 'historical', 'anniversary', 'memorial', 'awareness'],
    required this.lastSyncDate,
    required this.createdAt,
    required this.updatedAt,
    this.themeMode,
    this.startWeekOn,
    this.daysOff,
    this.enabledOrigins,
  });

  UserPreferences copyWith({
    String? language,
    bool? isDarkMode,
    bool? showGregorianDates,
    String? calendarSystem,
    bool? showNotifications,
    bool? showWeekends,
    String? defaultCalendarView,
    bool? autoSync,
    String? notificationTime,
    List<String>? enabledEventTypes,
    DateTime? lastSyncDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? themeMode,
    String? startWeekOn,
    List<String>? daysOff,
    List<String>? enabledOrigins,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      showGregorianDates: showGregorianDates ?? this.showGregorianDates,
      calendarSystem: calendarSystem ?? this.calendarSystem,
      showNotifications: showNotifications ?? this.showNotifications,
      showWeekends: showWeekends ?? this.showWeekends,
      defaultCalendarView: defaultCalendarView ?? this.defaultCalendarView,
      autoSync: autoSync ?? this.autoSync,
      notificationTime: notificationTime ?? this.notificationTime,
      enabledEventTypes: enabledEventTypes ?? this.enabledEventTypes,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      themeMode: themeMode ?? this.themeMode,
      startWeekOn: startWeekOn ?? this.startWeekOn,
      daysOff: daysOff ?? this.daysOff,
      enabledOrigins: enabledOrigins ?? this.enabledOrigins,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'isDarkMode': isDarkMode,
      'showGregorianDates': showGregorianDates,
      'calendarSystem': calendarSystem,
      'showNotifications': showNotifications,
      'showWeekends': showWeekends,
      'defaultCalendarView': defaultCalendarView,
      'autoSync': autoSync,
      'notificationTime': notificationTime,
      'enabledEventTypes': enabledEventTypes,
      'lastSyncDate': lastSyncDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'themeMode': themeMode,
      'startWeekOn': startWeekOn,
      'daysOff': daysOff,
      'enabledOrigins': enabledOrigins,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'system',
      isDarkMode: json['isDarkMode'] ?? false,
      showGregorianDates: json['showGregorianDates'] ?? true,
      calendarSystem: json['calendarSystem'] ?? 'gregorian',
      showNotifications: json['showNotifications'] ?? true,
      showWeekends: json['showWeekends'] ?? true,
      defaultCalendarView: json['defaultCalendarView'] ?? 'week',
      autoSync: json['autoSync'] ?? true,
      notificationTime: json['notificationTime'] ?? '09:00',
      enabledEventTypes: List<String>.from(json['enabledEventTypes'] ??
          ['celebration', 'historical', 'anniversary', 'memorial', 'awareness']),
      lastSyncDate: DateTime.parse(json['lastSyncDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      themeMode: json['themeMode'],
      startWeekOn: json['startWeekOn'],
      daysOff:
          json['daysOff'] != null ? List<String>.from(json['daysOff']) : null,
      enabledOrigins: json['enabledOrigins'] != null
          ? List<String>.from(json['enabledOrigins'])
          : null,
    );
  }
}
