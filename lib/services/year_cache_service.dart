import 'package:flutter/material.dart';
import '../utils/calendar_utils.dart';

/// Service for caching year data to improve performance
/// Caches year structure (just marks years as ready, actual data loaded on demand)
class YearCacheService {
  static final YearCacheService _instance = YearCacheService._internal();
  factory YearCacheService() => _instance;
  YearCacheService._internal();

  // Cache for year readiness: Set of years that are preloaded
  final Set<int> _gregorianCachedYears = {};
  final Set<int> _solarCachedYears = {};

  // Track which years are being loaded
  final Set<int> _loadingYears = {};

  /// Preload years around current year (10 before, 10 after)
  /// This just marks years as ready - actual data will be loaded on demand
  Future<void> preloadYears(int currentYear, {String calendarSystem = 'gregorian'}) async {
    final cache = calendarSystem == 'solar' ? _solarCachedYears : _gregorianCachedYears;
    
    // Mark 10 years before and 10 after as ready
    for (int i = -10; i <= 10; i++) {
      final year = currentYear + i;
      if (!cache.contains(year)) {
        cache.add(year);
      }
    }

    // Preload in background without blocking
    unawaited(_preloadYearDataInBackground(currentYear, calendarSystem: calendarSystem));
  }

  /// Preload year data in background (non-blocking)
  Future<void> _preloadYearDataInBackground(int currentYear, {String calendarSystem = 'gregorian'}) async {
    // Load first month of each year to warm up the cache
    final cache = calendarSystem == 'solar' ? _solarCachedYears : _gregorianCachedYears;
    
    for (int i = -10; i <= 10; i++) {
      final year = currentYear + i;
      if (cache.contains(year) && !_loadingYears.contains(year)) {
        _loadingYears.add(year);
        unawaited(
          CalendarUtils.getMonthDataFromCalculations(
            year: year,
            month: 1,
            calendarType: calendarSystem,
          ).then((_) {
            _loadingYears.remove(year);
          }).catchError((e) {
            _loadingYears.remove(year);
            debugPrint('Error preloading year $year: $e');
          }),
        );
      }
    }
  }

  /// Preload years in a range (for lazy loading)
  Future<void> preloadYearRange(int startYear, int endYear, {String calendarSystem = 'gregorian'}) async {
    final cache = calendarSystem == 'solar' ? _solarCachedYears : _gregorianCachedYears;
    final yearsToLoad = <int>[];

    for (int year = startYear; year <= endYear; year++) {
      if (!cache.contains(year) && !_loadingYears.contains(year)) {
        cache.add(year);
        yearsToLoad.add(year);
      }
    }

    // Load in background without blocking
    if (yearsToLoad.isNotEmpty) {
      unawaited(_loadYearRangeInBackground(yearsToLoad, calendarSystem: calendarSystem));
    }
  }

  /// Load year range in background
  Future<void> _loadYearRangeInBackground(List<int> years, {String calendarSystem = 'gregorian'}) async {
    // Load in batches to avoid blocking
    const batchSize = 5;
    for (int i = 0; i < years.length; i += batchSize) {
      final batch = years.skip(i).take(batchSize).toList();
      
      for (final year in batch) {
        if (!_loadingYears.contains(year)) {
          _loadingYears.add(year);
          unawaited(
            CalendarUtils.getMonthDataFromCalculations(
              year: year,
              month: 1,
              calendarType: calendarSystem,
            ).then((_) {
              _loadingYears.remove(year);
            }).catchError((e) {
              _loadingYears.remove(year);
              debugPrint('Error loading year $year: $e');
            }),
          );
        }
      }
      
      // Small delay between batches to keep UI responsive
      if (i + batchSize < years.length) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
  }

  /// Check if year is cached (ready to display)
  bool isYearCached(int year, {String calendarSystem = 'gregorian'}) {
    final cache = calendarSystem == 'solar' ? _solarCachedYears : _gregorianCachedYears;
    return cache.contains(year);
  }

  /// Clear cache (useful for memory management)
  void clearCache({String? calendarSystem}) {
    if (calendarSystem == null) {
      _gregorianCachedYears.clear();
      _solarCachedYears.clear();
    } else {
      final cache = calendarSystem == 'solar' ? _solarCachedYears : _gregorianCachedYears;
      cache.clear();
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'gregorian_years': _gregorianCachedYears.length,
      'solar_years': _solarCachedYears.length,
      'loading': _loadingYears.length,
    };
  }
}

// Helper function to run async code without awaiting
void unawaited(Future<void> future) {
  future.catchError((error) {
    debugPrint('Unawaited future error: $error');
  });
}
