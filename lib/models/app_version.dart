/// Model for app version information from remote
class AppVersion {
  final String version;
  final int buildNumber;
  final String updateType; // 'normal', 'critical', 'major', 'feature'
  final String? releaseNotes;
  final String? releaseNotesFa;
  final String? downloadUrl;
  final bool forceUpdate;

  AppVersion({
    required this.version,
    required this.buildNumber,
    required this.updateType,
    this.releaseNotes,
    this.releaseNotesFa,
    this.downloadUrl,
    this.forceUpdate = false,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      version: json['version'] as String,
      buildNumber: json['build_number'] as int,
      updateType: json['update_type'] as String? ?? 'normal',
      releaseNotes: json['release_notes'] as String?,
      releaseNotesFa: json['release_notes_fa'] as String?,
      downloadUrl: json['download_url'] as String?,
      forceUpdate: json['force_update'] as bool? ?? false,
    );
  }

  /// Compare with current version
  /// Returns true if this version is newer than the current version
  bool isNewerThan(String currentVersion, int currentBuildNumber) {
    final currentParts = currentVersion.split('.');
    final newParts = version.split('.');

    // Ensure we have at least major version
    if (currentParts.isEmpty || newParts.isEmpty) {
      return buildNumber > currentBuildNumber;
    }

    // Compare major version
    final currentMajor = int.tryParse(currentParts[0]) ?? 0;
    final newMajor = int.tryParse(newParts[0]) ?? 0;

    if (newMajor > currentMajor) {
      return true;
    }
    if (newMajor < currentMajor) {
      return false;
    }

    // Compare minor version
    if (newParts.length > 1 && currentParts.length > 1) {
      final currentMinor = int.tryParse(currentParts[1]) ?? 0;
      final newMinor = int.tryParse(newParts[1]) ?? 0;

      if (newMinor > currentMinor) {
        return true;
      }
      if (newMinor < currentMinor) {
        return false;
      }
    }

    // Compare patch version
    if (newParts.length > 2 && currentParts.length > 2) {
      final currentPatch = int.tryParse(currentParts[2]) ?? 0;
      final newPatch = int.tryParse(newParts[2]) ?? 0;

      if (newPatch > currentPatch) {
        return true;
      }
      if (newPatch < currentPatch) {
        return false;
      }
    }

    // If versions are equal, compare build numbers
    return buildNumber > currentBuildNumber;
  }

  /// Check if this is a critical update
  bool get isCritical => updateType == 'critical' || forceUpdate;

  /// Check if this is a major update
  bool get isMajor => updateType == 'major';

  /// Check if this is a feature update
  bool get isFeature => updateType == 'feature';

  /// Get release notes based on language
  String? getReleaseNotes(String language) {
    return language == 'fa' ? releaseNotesFa : releaseNotes;
  }
}

