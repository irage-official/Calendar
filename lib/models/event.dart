/// Event model representing a calendar event
class Event {
  final String id;
  final String source;
  final String type;
  final String origin;
  final String? image;
  final EventTitle title;
  final EventDescription description;
  final EventSignificance? significance;
  final EventTags tags;
  final EventLocation location;
  final EventDate date;
  final EventTime time;
  final EventRepeat repeat;
  final EventVisibility visibility;
  final EventReminder reminder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.source,
    required this.type,
    required this.origin,
    this.image,
    required this.title,
    required this.description,
    this.significance,
    required this.tags,
    required this.location,
    required this.date,
    required this.time,
    required this.repeat,
    required this.visibility,
    required this.reminder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      source: json['source'] as String,
      type: json['type'] as String,
      origin: json['origin'] as String,
      image: json['image'] as String?,
      title: EventTitle.fromJson(json['title'] as Map<String, dynamic>),
      description: EventDescription.fromJson(json['description'] as Map<String, dynamic>),
      significance: json['significance'] != null
          ? EventSignificance.fromJson(json['significance'] as Map<String, dynamic>)
          : null,
      tags: EventTags.fromJson(json['tags'] as Map<String, dynamic>),
      location: EventLocation.fromJson(json['location'] as Map<String, dynamic>),
      date: EventDate.fromJson(json['date'] as Map<String, dynamic>),
      time: EventTime.fromJson(json['time'] as Map<String, dynamic>),
      repeat: EventRepeat.fromJson(json['repeat'] as Map<String, dynamic>),
      visibility: EventVisibility.fromJson(json['visibility'] as Map<String, dynamic>),
      reminder: EventReminder.fromJson(json['reminder'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Get the Gregorian date as DateTime
  DateTime get gregorianDate {
    final parts = date.gregorian.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Get the Solar date parts
  Map<String, int> get solarDate {
    final parts = date.solar.split('-');
    return {
      'year': int.parse(parts[0]),
      'month': int.parse(parts[1]),
      'day': int.parse(parts[2]),
    };
  }

  /// Check if event is active (should be shown)
  bool get isActive {
    return visibility.showInCalendar;
  }
}

class EventTitle {
  final String en;
  final String fa;

  EventTitle({required this.en, required this.fa});

  factory EventTitle.fromJson(Map<String, dynamic> json) {
    return EventTitle(
      en: json['en'] as String,
      fa: json['fa'] as String,
    );
  }

  String getText(String language) => language == 'fa' ? fa : en;
}

class EventDescription {
  final String fa;
  final String en;

  EventDescription({required this.fa, required this.en});

  factory EventDescription.fromJson(Map<String, dynamic> json) {
    return EventDescription(
      fa: json['fa'] as String,
      en: json['en'] as String,
    );
  }

  String getText(String language) => language == 'fa' ? fa : en;
}

class EventSignificance {
  final String? fa;
  final String? en;

  EventSignificance({this.fa, this.en});

  factory EventSignificance.fromJson(Map<String, dynamic> json) {
    return EventSignificance(
      fa: json['fa'] as String?,
      en: json['en'] as String?,
    );
  }

  String? getText(String language) => language == 'fa' ? fa : en;
}

class EventTags {
  final List<String> en;
  final List<String> fa;

  EventTags({required this.en, required this.fa});

  factory EventTags.fromJson(Map<String, dynamic> json) {
    return EventTags(
      en: (json['en'] as List).cast<String>(),
      fa: (json['fa'] as List).cast<String>(),
    );
  }

  List<String> getTags(String language) => language == 'fa' ? fa : en;
}

class EventLocation {
  final String en;
  final String fa;

  EventLocation({required this.en, required this.fa});

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    return EventLocation(
      en: json['en'] as String,
      fa: json['fa'] as String,
    );
  }

  String getText(String language) => language == 'fa' ? fa : en;
}

class EventDate {
  final String solar; // Format: "1404-07-10"
  final String gregorian; // Format: "2025-10-01"

  EventDate({required this.solar, required this.gregorian});

  factory EventDate.fromJson(Map<String, dynamic> json) {
    return EventDate(
      solar: json['solar'] as String,
      gregorian: json['gregorian'] as String,
    );
  }
}

class EventTime {
  final bool isActive;
  final String? start;
  final String? end;

  EventTime({required this.isActive, this.start, this.end});

  factory EventTime.fromJson(Map<String, dynamic> json) {
    return EventTime(
      isActive: json['isActive'] as bool,
      start: json['start'] as String?,
      end: json['end'] as String?,
    );
  }
}

class EventRepeat {
  final bool isActive;
  final String interval; // "yearly", "monthly", etc.

  EventRepeat({required this.isActive, required this.interval});

  factory EventRepeat.fromJson(Map<String, dynamic> json) {
    return EventRepeat(
      isActive: json['isActive'] as bool,
      interval: json['interval'] as String,
    );
  }
}

class EventVisibility {
  final bool showInCalendar;
  final bool showInFeed;

  EventVisibility({required this.showInCalendar, required this.showInFeed});

  factory EventVisibility.fromJson(Map<String, dynamic> json) {
    return EventVisibility(
      showInCalendar: json['showInCalendar'] as bool,
      showInFeed: json['showInFeed'] as bool,
    );
  }
}

class EventReminder {
  final bool enabled;
  final int? offsetMinutes;

  EventReminder({required this.enabled, this.offsetMinutes});

  factory EventReminder.fromJson(Map<String, dynamic> json) {
    return EventReminder(
      enabled: json['enabled'] as bool,
      offsetMinutes: json['offset_minutes'] as int?,
    );
  }
}

