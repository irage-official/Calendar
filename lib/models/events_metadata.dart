/// Model for events metadata to check if events need update
class EventsMetadata {
  final String version;
  final String updatedAt;
  final int? totalEvents;
  final String? checksum;

  EventsMetadata({
    required this.version,
    required this.updatedAt,
    this.totalEvents,
    this.checksum,
  });

  factory EventsMetadata.fromJson(Map<String, dynamic> json) {
    return EventsMetadata(
      version: json['version'] as String,
      updatedAt: json['updated_at'] as String,
      totalEvents: json['total_events'] as int?,
      checksum: json['checksum'] as String?,
    );
  }

  /// Compare versions (simple string comparison for now)
  /// Returns true if this version is different/newer
  bool isDifferentFrom(String? otherVersion) {
    if (otherVersion == null) return true;
    return version != otherVersion;
  }
}

