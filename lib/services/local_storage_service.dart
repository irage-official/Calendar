import 'package:hive/hive.dart';
import '../models/user_preferences.dart';
import '../config/app_config.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late Box<UserPreferences> _userPreferencesBox;

  static Future<void> init() async {
    final instance = LocalStorageService();
    await instance._init();
  }

  Future<void> _init() async {
    // Register adapters only if not already registered
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(UserPreferencesAdapter());
    }
    
    // Open boxes
    _userPreferencesBox = await Hive.openBox<UserPreferences>(AppConfig.userPreferencesBox);
  }

  // User Preferences
  UserPreferences? get userPreferences {
    return _userPreferencesBox.get('preferences');
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _userPreferencesBox.put('preferences', preferences);
  }

  Future<void> updateUserPreferences(UserPreferences Function(UserPreferences) updater) async {
    final current = userPreferences;
    if (current != null) {
      final updated = updater(current);
      await saveUserPreferences(updated);
    }
  }


  // Initialize default preferences if none exist
  Future<void> initializeDefaultPreferences() async {
    if (userPreferences == null) {
      final now = DateTime.now();
      final defaultPrefs = UserPreferences(
        language: 'system',
        isDarkMode: false,
        showGregorianDates: true,
        calendarSystem: 'shahanshahi',
        showNotifications: true,
        showWeekends: true,
        defaultCalendarView: 'month',
        autoSync: true,
        notificationTime: '09:00',
        enabledEventTypes: const ['celebration', 'historical', 'anniversary', 'memorial', 'awareness'],
        lastSyncDate: now,
        createdAt: now,
        updatedAt: now,
        themeMode: 'system',
      );
      await saveUserPreferences(defaultPrefs);
    }
  }

  // Cleanup
  Future<void> dispose() async {
    await _userPreferencesBox.close();
  }
}
