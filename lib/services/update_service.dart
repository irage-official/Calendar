import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/app_version.dart';
import '../models/events_metadata.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// Service for checking and downloading updates (events and app version)
class UpdateService {
  static UpdateService? _instance;
  static UpdateService get instance {
    _instance ??= UpdateService._();
    return _instance!;
  }

  UpdateService._();

  static const String _lastEventsCheckKey = 'last_events_check';
  static const String _lastEventsVersionKey = 'last_events_version';
  static const String _lastEventsUpdatedAtKey = 'last_events_updated_at';

  Future<bool> _hasNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        AppLogger.info('UpdateService: No network connection, skipping remote calls');
        return false;
      }
      return true;
    } catch (e) {
      AppLogger.error('UpdateService: Error checking connectivity', error: e);
      return false;
    }
  }

  /// Check if events need update by comparing metadata version
  /// Returns true if events need to be updated
  Future<bool> checkEventsUpdate() async {
    if (!await _hasNetworkConnection()) {
      AppLogger.info('UpdateService: No network connection, skipping update check');
      return false;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastVersion = prefs.getString(_lastEventsVersionKey);
      final lastUpdatedAt = prefs.getString(_lastEventsUpdatedAtKey);
      AppLogger.info('UpdateService: Checking events update (last version: $lastVersion, last updated_at: $lastUpdatedAt)');

      // Fetch events metadata from server with cache-busting headers
      final uri = Uri.parse(AppConfig.eventsMetadataUrl);
      // Add timestamp query parameter to prevent caching
      final cacheBustUri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      
      final response = await http
          .get(
            cacheBustUri,
            headers: {
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
              'Expires': '0',
            },
          )
          .timeout(const Duration(seconds: 10));

      AppLogger.info('UpdateService: Metadata response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final metadata = EventsMetadata.fromJson(data);

        AppLogger.info('UpdateService: Fetched metadata - version: ${metadata.version}, total_events: ${metadata.totalEvents}, updated_at: ${metadata.updatedAt}');

        // Update last check time
        await prefs.setString(_lastEventsCheckKey, DateTime.now().toIso8601String());

        // Check if version changed OR updated_at changed (even if version is same, updated_at change means content changed)
        final versionChanged = metadata.isDifferentFrom(lastVersion);
        final updatedAtChanged = lastUpdatedAt != null && lastUpdatedAt != metadata.updatedAt;
        
        if (versionChanged || updatedAtChanged) {
          if (versionChanged) {
            AppLogger.info('UpdateService: Version changed from "$lastVersion" to "${metadata.version}"');
          }
          if (updatedAtChanged) {
            AppLogger.info('UpdateService: Updated_at changed from "$lastUpdatedAt" to "${metadata.updatedAt}"');
          }
          // Don't update version/updated_at here - only update after successful download
          AppLogger.info('UpdateService: Events update available (version: ${metadata.version}, updated_at: ${metadata.updatedAt})');
          return true;
        }

        AppLogger.info('UpdateService: Events are up to date (version: ${metadata.version}, updated_at: ${metadata.updatedAt})');
        return false;
      } else {
        AppLogger.warning('UpdateService: Failed to fetch events metadata (status: ${response.statusCode})');
        return false;
      }
    } catch (e) {
      AppLogger.error('UpdateService: Error checking events update', error: e);
      // If network error, don't block app startup - return false
      return false;
    }
  }

  /// Download updated events from remote
  /// Returns list of events or empty list if download fails
  Future<List<Event>> downloadEvents() async {
    if (!await _hasNetworkConnection()) {
      AppLogger.warning('UpdateService: No network connection, cannot download events');
      return [];
    }
    try {
      AppLogger.info('UpdateService: Downloading events from ${AppConfig.eventsUrl}');
      
      // Add cache-busting to events URL as well
      final uri = Uri.parse(AppConfig.eventsUrl);
      final cacheBustUri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      
      final response = await http
          .get(
            cacheBustUri,
            headers: {
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
              'Expires': '0',
            },
          )
          .timeout(const Duration(seconds: 30));

      AppLogger.info('UpdateService: Events download response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
        final events = jsonList
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .where((event) => event.isActive)
            .toList();

        AppLogger.info('UpdateService: Downloaded ${events.length} active events');
        
        // Update version only after successful download
        if (events.isNotEmpty) {
          try {
            // Get the latest metadata version to save
            final metadataResponse = await http
                .get(
                  Uri.parse(AppConfig.eventsMetadataUrl).replace(queryParameters: {
                    '_t': DateTime.now().millisecondsSinceEpoch.toString(),
                  }),
                  headers: {
                    'Cache-Control': 'no-cache, no-store, must-revalidate',
                    'Pragma': 'no-cache',
                    'Expires': '0',
                  },
                )
                .timeout(const Duration(seconds: 10));
            
            if (metadataResponse.statusCode == 200) {
              final prefs = await SharedPreferences.getInstance();
              final metadataData = json.decode(metadataResponse.body) as Map<String, dynamic>;
              final metadata = EventsMetadata.fromJson(metadataData);
              await prefs.setString(_lastEventsVersionKey, metadata.version);
              await prefs.setString(_lastEventsUpdatedAtKey, metadata.updatedAt);
              AppLogger.info('UpdateService: Updated stored version to ${metadata.version} and updated_at to ${metadata.updatedAt}');
            }
          } catch (e) {
            AppLogger.error('UpdateService: Could not update version after download', error: e);
          }
        }
        
        return events;
      } else {
        AppLogger.error('UpdateService: Failed to download events (status: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      AppLogger.error('UpdateService: Error downloading events', error: e);
      return [];
    }
  }

  /// Check app version update
  /// Returns AppVersion if update is available, null otherwise
  Future<AppVersion?> checkAppVersion() async {
    if (!await _hasNetworkConnection()) {
      return null;
    }
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      AppLogger.info('UpdateService: Checking app version (current: $currentVersion+$currentBuildNumber)');

      // Add cache-busting to version URL as well
      final uri = Uri.parse(AppConfig.versionUrl);
      final cacheBustUri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      final response = await http
          .get(
            cacheBustUri,
            headers: {
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
              'Expires': '0',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final remoteVersion = AppVersion.fromJson(data);

        if (remoteVersion.isNewerThan(currentVersion, currentBuildNumber)) {
          AppLogger.info('UpdateService: App update available (remote: ${remoteVersion.version}+${remoteVersion.buildNumber})');
          return remoteVersion;
        } else {
          AppLogger.info('UpdateService: App is up to date');
          return null;
        }
      } else {
        AppLogger.warning('UpdateService: Failed to fetch app version (status: ${response.statusCode})');
        return null;
      }
    } catch (e) {
      AppLogger.error('UpdateService: Error checking app version', error: e);
      // If network error, don't block app startup - return null
      return null;
    }
  }

  /// Force check for events update (used by manual check in settings)
  Future<bool> forceCheckEventsUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear last check, version, and updated_at to force update
    await prefs.remove(_lastEventsCheckKey);
    await prefs.remove(_lastEventsVersionKey);
    await prefs.remove(_lastEventsUpdatedAtKey);
    AppLogger.info('UpdateService: Force check - cleared cached version and updated_at');
    return await checkEventsUpdate();
  }
}

