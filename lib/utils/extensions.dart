import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/toast_widget.dart';

extension DateTimeExtension on DateTime {
  /// Check if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if this date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Get the start of the day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get the end of the day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Get the start of the week
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday));
  }

  /// Get the end of the week
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday));
  }

  /// Get the start of the month
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Get the end of the month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0);
  }

  /// Get the start of the year
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  /// Get the end of the year
  DateTime get endOfYear {
    return DateTime(year, 12, 31);
  }

  /// Format date as string
  String format(String pattern) {
    return DateFormat(pattern).format(this);
  }

  /// Get relative time string (e.g., "2 days ago", "in 3 hours")
  String get relativeTimeString {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get days until this date
  int get daysUntil {
    final now = DateTime.now();
    return difference(now).inDays;
  }

  /// Get days since this date
  int get daysSince {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }

  /// Check if this date is in the same week as another date
  bool isSameWeek(DateTime other) {
    return startOfWeek.isAtSameMomentAs(other.startOfWeek);
  }

  /// Check if this date is in the same month as another date
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// Check if this date is in the same year as another date
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  /// Add days to this date
  DateTime addDays(int days) {
    return add(Duration(days: days));
  }

  /// Subtract days from this date
  DateTime subtractDays(int days) {
    return subtract(Duration(days: days));
  }

  /// Add months to this date
  DateTime addMonths(int months) {
    int newYear = year;
    int newMonth = month + months;
    
    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }
    
    return DateTime(newYear, newMonth, day);
  }

  /// Subtract months from this date
  DateTime subtractMonths(int months) {
    return addMonths(-months);
  }

  /// Add years to this date
  DateTime addYears(int years) {
    return DateTime(year + years, month, day);
  }

  /// Subtract years from this date
  DateTime subtractYears(int years) {
    return DateTime(year - years, month, day);
  }
}

extension StringExtension on String {
  /// Check if string is empty or null
  bool get isNullOrEmpty {
    return isEmpty;
  }

  /// Check if string is not empty
  bool get isNotEmpty {
    return !isEmpty;
  }

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Remove all whitespace
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if string is a valid email
  bool get isEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool get isPhoneNumber {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(this);
  }

  /// Truncate string to specified length
  String truncate(int length, {String suffix = '...'}) {
    if (this.length <= length) return this;
    return '${substring(0, length)}$suffix';
  }
}

extension ListExtension<T> on List<T> {
  /// Get first element or null if empty
  T? get firstOrNull {
    return isEmpty ? null : first;
  }

  /// Get last element or null if empty
  T? get lastOrNull {
    return isEmpty ? null : last;
  }

  /// Get element at index or null if out of bounds
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Add element if it doesn't exist
  void addIfNotExists(T element) {
    if (!contains(element)) {
      add(element);
    }
  }

  /// Remove duplicates while preserving order
  List<T> get unique {
    final seen = <T>{};
    return where((element) => seen.add(element)).toList();
  }

  /// Chunk list into smaller lists of specified size
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

extension BuildContextExtension on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Get safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;
  
  /// Get safe area insets
  EdgeInsets get safeAreaInsets => MediaQuery.of(this).viewInsets;
  
  /// Check if device is in landscape mode
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  
  /// Check if device is in portrait mode
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  
  /// Get theme
  ThemeData get theme => Theme.of(this);
  
  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Show snackbar
  void showSnackBar(String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }
  
  /// Show error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(this).colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show floating toast (bottom, with side margins)
  void showToast(String message, {Duration duration = const Duration(seconds: 3)}) {
    AppToast.show(this, message: message, duration: duration, sideMargin: 36, bottomMargin: 36);
  }
}
