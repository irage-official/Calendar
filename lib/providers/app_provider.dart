import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import '../services/local_storage_service.dart';
import '../utils/logger.dart';

class AppProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  
  UserPreferences? _userPreferences;
  bool _isInitialized = false;

  UserPreferences? get userPreferences => _userPreferences;
  bool get isInitialized => _isInitialized;

  // Getters for easy access
  String get language => _userPreferences?.language ?? 'system';
  bool get isDarkMode => _userPreferences?.isDarkMode ?? false;
  bool get showGregorianDates => _userPreferences?.showGregorianDates ?? true;
  String get calendarSystem => _userPreferences?.calendarSystem ?? 'gregorian';
  bool get showNotifications => _userPreferences?.showNotifications ?? true;
  bool get showWeekends => _userPreferences?.showWeekends ?? true;
  String get defaultCalendarView => _userPreferences?.defaultCalendarView ?? 'week';
  bool get autoSync => _userPreferences?.autoSync ?? true;
  String get notificationTime => _userPreferences?.notificationTime ?? '09:00';
  List<String> get enabledEventTypes => _userPreferences?.enabledEventTypes ?? ['festival', 'remembrance', 'gregorian'];
  String? get themeModeString => _userPreferences?.themeMode;

  ThemeMode get themeMode {
    final mode = _userPreferences?.themeMode;
    if (mode == 'system') {
      return ThemeMode.system;
    } else if (mode == 'dark') {
      return ThemeMode.dark;
    } else if (mode == 'light') {
      return ThemeMode.light;
    }
    // Fallback to isDarkMode for backward compatibility
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
  Locale get locale => Locale(language);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _storage.initializeDefaultPreferences();
      _userPreferences = _storage.userPreferences;
      
      // If language is 'system' and system language is Persian, set default calendar to shahanshahi
      if (_userPreferences != null && _userPreferences!.language == 'system') {
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        if (systemLocale.languageCode == 'fa' && _userPreferences!.calendarSystem == 'gregorian') {
          // Only change if it's still the default gregorian (user hasn't changed it)
          final updated = _userPreferences!.copyWith(
            calendarSystem: 'shahanshahi',
            updatedAt: DateTime.now(),
          );
          await _storage.saveUserPreferences(updated);
          _userPreferences = updated;
        }
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error initializing AppProvider', error: e);
    }
  }

  Future<void> setLanguage(String language) async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      language: language,
      updatedAt: DateTime.now(),
    );
    
    // Auto-switch calendar based on language
    String newCalendarSystem = updated.calendarSystem;
    if (language == 'en') {
      newCalendarSystem = 'gregorian';
    } else if (language == 'fa') {
      newCalendarSystem = 'shahanshahi';
    } else if (language == 'system') {
      // If language is 'system', check system locale and set calendar accordingly
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (systemLocale.languageCode == 'fa') {
        newCalendarSystem = 'shahanshahi';
      } else {
        newCalendarSystem = 'gregorian';
      }
    }
    
    final finalUpdated = updated.copyWith(
      calendarSystem: newCalendarSystem,
    );
    
    await _storage.saveUserPreferences(finalUpdated);
    _userPreferences = finalUpdated;
    notifyListeners();
  }

  Future<void> setThemeMode(bool isDarkMode) async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      isDarkMode: isDarkMode,
      themeMode: isDarkMode ? 'dark' : 'light',
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  Future<void> setThemeModeToSystem() async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      themeMode: 'system',
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  Future<void> setThemeModeFromString(String themeMode) async {
    if (_userPreferences == null) return;
    
    bool isDarkMode = false;
    if (themeMode == 'dark') {
      isDarkMode = true;
    } else if (themeMode == 'light') {
      isDarkMode = false;
    } else {
      // System mode - we'll handle this differently
      isDarkMode = false; // Default to light for now
    }
    
    final updated = _userPreferences!.copyWith(
      isDarkMode: isDarkMode,
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  Future<void> setShowGregorianDates(bool showGregorianDates) async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      showGregorianDates: showGregorianDates,
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  Future<void> setCalendarSystem(String calendarSystem) async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      calendarSystem: calendarSystem,
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  Future<void> setShowNotifications(bool showNotifications) async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      showNotifications: showNotifications,
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  Future<void> setShowWeekends(bool showWeekends) async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      showWeekends: showWeekends,
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  Future<void> setDefaultCalendarView(String view) async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      defaultCalendarView: view,
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  Future<void> setAutoSync(bool autoSync) async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      autoSync: autoSync,
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  Future<void> setNotificationTime(String time) async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      notificationTime: time,
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  Future<void> setEnabledEventTypes(List<String> eventTypes) async {
    if (_userPreferences == null) return;
    
    final updated = _userPreferences!.copyWith(
      enabledEventTypes: eventTypes,
      updatedAt: DateTime.now(),
    );
    
    await _storage.saveUserPreferences(updated);
    _userPreferences = updated;
    notifyListeners();
  }

  // Helper method to check if language is Persian
  bool get isLanguagePersian => language == 'fa';

  // Helper method to check if calendar is Solar or Shahanshahi
  bool get isCalendarSolar => calendarSystem == 'solar' || calendarSystem == 'shahanshahi';

  /// Get the actual language being used (resolves 'system' to actual system language)
  String get effectiveLanguage {
    if (language == 'system') {
      // Get system locale from Flutter
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      return systemLocale.languageCode == 'fa' ? 'fa' : 'en';
    }
    return language;
  }
}
