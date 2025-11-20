// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 4;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      language: fields[0] as String,
      isDarkMode: fields[1] as bool,
      showGregorianDates: fields[2] as bool,
      calendarSystem: fields[3] as String,
      showNotifications: fields[4] as bool,
      showWeekends: fields[5] as bool,
      defaultCalendarView: fields[6] as String,
      autoSync: fields[7] as bool,
      notificationTime: fields[8] as String,
      enabledEventTypes: (fields[9] as List).cast<String>(),
      lastSyncDate: fields[10] as DateTime,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      themeMode: fields[13] as String?,
      startWeekOn: fields[14] as String?,
      daysOff: (fields[15] as List?)?.cast<String>(),
      enabledOrigins: (fields[16] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.isDarkMode)
      ..writeByte(2)
      ..write(obj.showGregorianDates)
      ..writeByte(3)
      ..write(obj.calendarSystem)
      ..writeByte(4)
      ..write(obj.showNotifications)
      ..writeByte(5)
      ..write(obj.showWeekends)
      ..writeByte(6)
      ..write(obj.defaultCalendarView)
      ..writeByte(7)
      ..write(obj.autoSync)
      ..writeByte(8)
      ..write(obj.notificationTime)
      ..writeByte(9)
      ..write(obj.enabledEventTypes)
      ..writeByte(10)
      ..write(obj.lastSyncDate)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.themeMode)
      ..writeByte(14)
      ..write(obj.startWeekOn)
      ..writeByte(15)
      ..write(obj.daysOff)
      ..writeByte(16)
      ..write(obj.enabledOrigins);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
