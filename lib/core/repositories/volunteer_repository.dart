import '../models/volunteer.dart';

abstract class VolunteerRepository {
  Future<List<Volunteer>> getAllVolunteers();

  Future<Volunteer?> getVolunteerById(String id);

  Future<List<Volunteer>> getVolunteersByDepartment(String department);

  Future<List<Volunteer>> getActiveVolunteers();

  Future<void> createVolunteer(Volunteer volunteer);

  Future<void> updateVolunteer(Volunteer volunteer);

  Future<void> deleteVolunteer(String id);

  Future<void> toggleVolunteerStatus(String id, bool isActive);

  Stream<List<Volunteer>> watchVolunteers();
}
