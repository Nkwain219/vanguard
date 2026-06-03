import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance_event.dart';

class OfflineAttendanceService {
  static OfflineAttendanceService? _instance;
  static OfflineAttendanceService get instance =>
      _instance ??= OfflineAttendanceService._();
  OfflineAttendanceService._();

  static const String _boxName = 'offline_attendance';
  Box<String>? _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> storeEvent(AttendanceEvent event) async {
    if (_box == null) await initialize();
    await _box!.put(event.id, jsonEncode(event.toJson()));
  }

  List<AttendanceEvent> getPendingEvents() {
    if (_box == null) return [];

    final events = <AttendanceEvent>[];
    for (final key in _box!.keys) {
      final json = _box!.get(key);
      if (json != null) {
        try {
          final event = AttendanceEvent.fromJson(jsonDecode(json));
          if (!event.isSynced) {
            events.add(event);
          }
        } catch (_) {}
      }
    }

    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return events;
  }

  Future<void> markSynced(String eventId) async {
    if (_box == null) return;

    final json = _box!.get(eventId);
    if (json != null) {
      final event = AttendanceEvent.fromJson(jsonDecode(json));
      final syncedEvent = event.copyWith(isSynced: true);
      await _box!.put(eventId, jsonEncode(syncedEvent.toJson()));
    }
  }

  Future<void> cleanupOldEvents() async {
    if (_box == null) return;

    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final keysToRemove = <String>[];

    for (final key in _box!.keys) {
      final json = _box!.get(key);
      if (json != null) {
        try {
          final event = AttendanceEvent.fromJson(jsonDecode(json));
          if (event.isSynced && event.timestamp.isBefore(cutoff)) {
            keysToRemove.add(key as String);
          }
        } catch (_) {}
      }
    }

    for (final key in keysToRemove) {
      await _box!.delete(key);
    }
  }

  List<AttendanceEvent> getTodayEvents() {
    if (_box == null) return [];

    final today = DateTime.now();
    final events = <AttendanceEvent>[];

    for (final key in _box!.keys) {
      final json = _box!.get(key);
      if (json != null) {
        try {
          final event = AttendanceEvent.fromJson(jsonDecode(json));
          if (event.timestamp.year == today.year &&
              event.timestamp.month == today.month &&
              event.timestamp.day == today.day) {
            events.add(event);
          }
        } catch (_) {}
      }
    }

    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return events;
  }

  bool isCurrentlyClockedIn() {
    final events = getTodayEvents();
    if (events.isEmpty) return false;

    final lastEvent = events.last;
    return lastEvent.type == AttendanceEventType.clockIn;
  }
}
