import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/work_location.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  Future<bool> ensurePermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await ensurePermissions();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  double distanceBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  Future<bool> isWithinPerimeter(WorkLocation location) async {
    final position = await getCurrentPosition();
    if (position == null) return false;

    final distance = distanceBetween(
      position.latitude,
      position.longitude,
      location.latitude,
      location.longitude,
    );

    return distance <= location.radiusMeters;
  }

  Future<WorkLocation?> getCurrentWorkLocation(
      List<WorkLocation> locations) async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    for (final location in locations) {
      if (!location.isActive) continue;

      final distance = distanceBetween(
        position.latitude,
        position.longitude,
        location.latitude,
        location.longitude,
      );

      if (distance <= location.radiusMeters) {
        return location;
      }
    }

    return null;
  }

  Stream<Position> positionStream({int distanceFilter = 10}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
