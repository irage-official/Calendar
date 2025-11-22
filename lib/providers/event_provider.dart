import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/logger.dart';

/// Provider for managing calendar events
class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService.instance;
  
  List<Event>? _events;
  bool _isLoading = false;
  bool _isInitialized = false;

  List<Event>? get events => _events;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Initialize and load events
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      notifyListeners();

      _events = await _eventService.loadEvents();
      _isInitialized = true;

      AppLogger.info('EventProvider: Loaded ${_events?.length ?? 0} events');
    } catch (e) {
      AppLogger.error('EventProvider: Error loading events', error: e);
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get events for a specific Gregorian date
  List<Event> getEventsForDate(DateTime date) {
    if (_events == null) return [];
    return _eventService.getEventsForGregorianDate(date, events: _events!);
  }

  /// Get events for a specific Solar date
  List<Event> getEventsForSolarDate(int year, int month, int day) {
    if (_events == null) return [];
    return _eventService.getEventsForSolarDate(year, month, day, events: _events!);
  }

  /// Get event colors for a specific Gregorian date
  List<Color> getEventColorsForDate(DateTime date) {
    if (_events == null) return [];
    return _eventService.getEventColorsForGregorianDate(date, events: _events!);
  }

  /// Get event colors for a specific Solar date
  List<Color> getEventColorsForSolarDate(int year, int month, int day) {
    if (_events == null) return [];
    return _eventService.getEventColorsForSolarDate(year, month, day, events: _events!);
  }

  /// Reload events (clear cache and reload)
  Future<void> reload() async {
    await _eventService.clearAllCache();
    _isInitialized = false;
    await initialize();
  }
}

