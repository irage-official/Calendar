import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../config/constants.dart';
import '../utils/logger.dart';

/// Service for loading and managing calendar events
class EventService {
  static EventService? _instance;
  List<Event>? _cachedEvents;

  EventService._();

  static EventService get instance {
    _instance ??= EventService._();
    return _instance!;
  }

  /// Load all events from local storage (cached remote) or assets
  /// If forceRemote is true, it will try to load from remote first
  Future<List<Event>> loadEvents({bool forceRemote = false}) async {
    // Return cached events if available and not forcing remote
    if (!forceRemote && _cachedEvents != null) {
      return _cachedEvents!;
    }

    // Try to load from local storage (saved remote events)
    if (!forceRemote) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedEventsJson = prefs.getString('cached_events');

        if (savedEventsJson != null && savedEventsJson.isNotEmpty) {
          final List<dynamic> jsonList = json.decode(savedEventsJson) as List<dynamic>;
          _cachedEvents = jsonList
              .map((json) => Event.fromJson(json as Map<String, dynamic>))
              .where((event) => event.isActive)
              .toList();

          AppLogger.info('EventService: Loaded ${_cachedEvents!.length} events from local cache');
          return _cachedEvents!;
        }
      } catch (e) {
        AppLogger.error('EventService: Error loading cached events', error: e);
        // Continue to fallback
      }
    }

    // Fallback to assets
    try {
      final String jsonString = await rootBundle.loadString('assets/data/events.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      _cachedEvents = jsonList
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .where((event) => event.isActive)
          .toList();

      AppLogger.info('EventService: Loaded ${_cachedEvents!.length} events from assets');
      return _cachedEvents!;
    } catch (e) {
      AppLogger.error('EventService: Error loading events from assets', error: e);
      return [];
    }
  }

  /// Save events to local storage (for remote events)
  Future<void> saveEvents(List<Event> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = events.map((e) => _eventToJson(e)).toList();
      await prefs.setString('cached_events', json.encode(jsonList));
      _cachedEvents = events;
      AppLogger.info('EventService: Saved ${events.length} events to local storage');
    } catch (e) {
      AppLogger.error('EventService: Error saving events', error: e);
    }
  }

  /// Convert Event to JSON (helper method)
  Map<String, dynamic> _eventToJson(Event event) {
    return {
      'id': event.id,
      'source': event.source,
      'type': event.type,
      'origin': event.origin,
      'image': event.image,
      'title': {'en': event.title.en, 'fa': event.title.fa},
      'description': {'en': event.description.en, 'fa': event.description.fa},
      'significance': event.significance != null
          ? {'en': event.significance!.en, 'fa': event.significance!.fa}
          : null,
      'tags': {'en': event.tags.en, 'fa': event.tags.fa},
      'location': {'en': event.location.en, 'fa': event.location.fa},
      'date': {'solar': event.date.solar, 'gregorian': event.date.gregorian},
      'time': {
        'isActive': event.time.isActive,
        'start': event.time.start,
        'end': event.time.end,
      },
      'repeat': {'isActive': event.repeat.isActive, 'interval': event.repeat.interval},
      'visibility': {
        'showInCalendar': event.visibility.showInCalendar,
        'showInFeed': event.visibility.showInFeed,
      },
      'reminder': {
        'enabled': event.reminder.enabled,
        'offset_minutes': event.reminder.offsetMinutes,
      },
      'created_at': event.createdAt.toIso8601String(),
      'updated_at': event.updatedAt.toIso8601String(),
    };
  }

  /// Get events for a specific Gregorian date
  List<Event> getEventsForGregorianDate(DateTime date, {List<Event>? events}) {
    final allEvents = events ?? _cachedEvents ?? [];
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    return allEvents.where((event) {
      final eventDate = event.gregorianDate;
      final normalizedEventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
      
      // Check if exact match (for non-repeating events or current year for repeating events)
      if (normalizedEventDate.year == normalizedDate.year &&
          normalizedEventDate.month == normalizedDate.month &&
          normalizedEventDate.day == normalizedDate.day) {
        return true;
      }

      // For repeating events, check if it should repeat on this date
      if (event.repeat.isActive) {
        if (event.repeat.interval == 'yearly') {
          // Check if same month and day (different year)
          if (normalizedEventDate.month == normalizedDate.month &&
              normalizedEventDate.day == normalizedDate.day) {
            return true;
          }
        }
        // Add other repeat intervals if needed (monthly, weekly, etc.)
      }

      return false;
    }).toList();
  }

  /// Get events for a specific Solar date
  List<Event> getEventsForSolarDate(int year, int month, int day, {List<Event>? events}) {
    final allEvents = events ?? _cachedEvents ?? [];
    
    return allEvents.where((event) {
      final solarDate = event.solarDate;
      
      // Check if exact match
      if (solarDate['year'] == year &&
          solarDate['month'] == month &&
          solarDate['day'] == day) {
        return true;
      }

      // For repeating events, check if it should repeat on this date
      if (event.repeat.isActive) {
        if (event.repeat.interval == 'yearly') {
          // For solar calendar yearly repeats, check same month and day
          if (solarDate['month'] == month && solarDate['day'] == day) {
            return true;
          }
        }
      }

      return false;
    }).toList();
  }

  /// Get event origin colors for a specific date
  /// Returns a list of unique colors based on event origins
  List<Color> getEventColorsForGregorianDate(DateTime date, {List<Event>? events}) {
    final dateEvents = getEventsForGregorianDate(date, events: events);
    final originColors = <Color>{};
    
    for (final event in dateEvents) {
      final color = AppColors.getEventTypeColor(event.origin);
      originColors.add(color);
    }
    
    return originColors.toList();
  }

  /// Get event origin colors for a specific Solar date
  List<Color> getEventColorsForSolarDate(int year, int month, int day, {List<Event>? events}) {
    final dateEvents = getEventsForSolarDate(year, month, day, events: events);
    final originColors = <Color>{};
    
    for (final event in dateEvents) {
      final color = AppColors.getEventTypeColor(event.origin);
      originColors.add(color);
    }
    
    return originColors.toList();
  }

  /// Clear cache (useful for testing or when data needs to be reloaded)
  void clearCache() {
    _cachedEvents = null;
  }
}

