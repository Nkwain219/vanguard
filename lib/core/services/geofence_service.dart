import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/work_location.dart';
import '../models/attendance_event.dart';
import 'location_service.dart';
import 'device_service.dart';
import 'offline_attendance_service.dart';

typedef GeofenceCallback = void Function(GeofenceEvent event);

enum GeofenceEventType {
  entered,
  exited,
}

class GeofenceEvent {
  final GeofenceEventType type;
  final WorkLocation? location;
  final Position position;
  final DateTime timestamp;

  const GeofenceEvent({
    required this.type,
    this.location,
    required this.position,
    required this.timestamp,
  });
}

class GeofenceService {
  static GeofenceService? _instance;
  static GeofenceService get instance => _instance ??= GeofenceService._();
  GeofenceService._();

  final LocationService _locationService = LocationService.instance;
  final DeviceService _deviceService = DeviceService.instance;
  final OfflineAttendanceService _offlineService =
      OfflineAttendanceService.instance;

  StreamSubscription<Position>? _positionSubscription;
  List<WorkLocation> _workLocations = [];
  WorkLocation? _currentLocation;
  bool _isMonitoring = false;
  String? _employeeId;

  final _eventController = StreamController<GeofenceEvent>.broadcast();
  Stream<GeofenceEvent> get events => _eventController.stream;

  Future<bool> startMonitoring({
    required String employeeId,
    required List<WorkLocation> workLocations,
  }) async {
    if (_isMonitoring) return true;

    final hasPermission = await _locationService.ensurePermissions();
    if (!hasPermission) return false;

    _employeeId = employeeId;
    _workLocations = workLocations.where((l) => l.isActive).toList();

    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      _currentLocation =
          await _locationService.getCurrentWorkLocation(_workLocations);
    }

    _positionSubscription =
        _locationService.positionStream(distanceFilter: 20).listen(
              _onPositionUpdate,
              onError: (e) {},
            );

    _isMonitoring = true;
    return true;
  }

  void stopMonitoring() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isMonitoring = false;
    _currentLocation = null;
  }

  void _onPositionUpdate(Position position) {
    WorkLocation? newLocation;

    for (final location in _workLocations) {
      final distance = _locationService.distanceBetween(
        position.latitude,
        position.longitude,
        location.latitude,
        location.longitude,
      );

      if (distance <= location.radiusMeters) {
        newLocation = location;
        break;
      }
    }

    if (_currentLocation == null && newLocation != null) {
      _onEntered(newLocation, position);
    } else if (_currentLocation != null && newLocation == null) {
      _onExited(_currentLocation!, position);
    } else if (_currentLocation != null &&
        newLocation != null &&
        _currentLocation!.id != newLocation.id) {
      _onExited(_currentLocation!, position);
      _onEntered(newLocation, position);
    }

    _currentLocation = newLocation;
  }

  void _onEntered(WorkLocation location, Position position) {
    final event = GeofenceEvent(
      type: GeofenceEventType.entered,
      location: location,
      position: position,
      timestamp: DateTime.now(),
    );

    _eventController.add(event);
  }

  Future<void> _onExited(WorkLocation location, Position position) async {
    final event = GeofenceEvent(
      type: GeofenceEventType.exited,
      location: location,
      position: position,
      timestamp: DateTime.now(),
    );

    _eventController.add(event);

    if (_employeeId != null && _offlineService.isCurrentlyClockedIn()) {
      final deviceId = await _deviceService.getDeviceId();
      final clockOutEvent = AttendanceEvent(
        id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
        type: AttendanceEventType.clockOut,
        timestamp: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: location.name,
        clockOutReason: ClockOutReason.leftPerimeter,
        deviceId: deviceId,
        isSynced: false,
      );

      await _offlineService.storeEvent(clockOutEvent);
    }
  }

  bool get isWithinPerimeter => _currentLocation != null;

  WorkLocation? get currentLocation => _currentLocation;

  bool get isMonitoring => _isMonitoring;

  void dispose() {
    stopMonitoring();
    _eventController.close();
  }
}
