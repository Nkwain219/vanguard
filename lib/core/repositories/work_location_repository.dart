import '../models/work_location.dart';

abstract class WorkLocationRepository {
  Future<List<WorkLocation>> getAllLocations();

  Future<List<WorkLocation>> getActiveLocations();

  Future<WorkLocation?> getLocationById(String id);

  Future<void> createLocation(WorkLocation location);

  Future<void> updateLocation(WorkLocation location);

  Future<void> deleteLocation(String id);

  Stream<List<WorkLocation>> watchLocations();
}
