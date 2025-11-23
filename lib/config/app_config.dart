class AppConfig {
  static const String appName = 'Irage';
  static const String appVersion = '0.9.0'; // Current app version (until final release)
  
  // GitHub Raw URLs for updates (replace with your actual repository)
  // Format: https://raw.githubusercontent.com/username/repo/branch/path
  static const String githubRawBase = 'https://raw.githubusercontent.com/irage-official/Calendar/main/data';
  
  // Update endpoints
  static const String eventsUrl = '$githubRawBase/events.json';
  static const String eventsMetadataUrl = '$githubRawBase/events-metadata.json';
  static const String versionUrl = '$githubRawBase/version.json';
  
  // API Configuration (for future use)
  static const String baseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String userPreferencesBox = 'user_preferences';
  static const String eventsBox = 'events';
  static const String calendarBox = 'calendar';
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double bottomSheetHeight = 0.4; // 40% of screen height
  static const double bottomSheetMinHeight = 0.25; // 25% of screen height
}
