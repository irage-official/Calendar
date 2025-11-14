import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../config/constants.dart';

/// Service for loading and managing calendar events
class EventService {
  static EventService? _instance;
  List<Event>? _cachedEvents;

  EventService._();

  static EventService get instance {
    _instance ??= EventService._();
    return _instance!;
  }

  /// Load all events from JSON file
  Future<List<Event>> loadEvents() async {
    if (_cachedEvents != null) {
      return _cachedEvents!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/events.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      
      _cachedEvents = jsonList
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .where((event) => event.isActive)
          .toList();

      return _cachedEvents!;
    } catch (e) {
      // Error loading events - return empty list
      return [];
    }
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

