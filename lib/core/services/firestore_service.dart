import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreService {
  static FirestoreService? _instance;
  late final FirebaseFirestore _firestore;

  FirestoreService._();

  static FirestoreService get instance {
    if (_instance == null) {
      throw StateError(
        'FirestoreService not initialized. Call FirestoreService.initialize() first.',
      );
    }
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_instance != null) return;

    _instance = FirestoreService._();

    _instance!._firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'vanguard-db',
    );

    _instance!._firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  FirebaseFirestore get firestore => _firestore;

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('vanguard_users');

  CollectionReference<Map<String, dynamic>> get employeesCollection =>
      _firestore.collection('vanguard_employees');

  CollectionReference<Map<String, dynamic>> get volunteersCollection =>
      _firestore.collection('vanguard_volunteers');

  CollectionReference<Map<String, dynamic>> get tasksCollection =>
      _firestore.collection('vanguard_tasks');

  CollectionReference<Map<String, dynamic>> get projectsCollection =>
      _firestore.collection('vanguard_projects');

  CollectionReference<Map<String, dynamic>> get attendanceCollection =>
      _firestore.collection('vanguard_attendance');

  CollectionReference<Map<String, dynamic>> get leaveRequestsCollection =>
      _firestore.collection('vanguard_leave_requests');

  CollectionReference<Map<String, dynamic>> get salaryRequestsCollection =>
      _firestore.collection('vanguard_salary_requests');

  CollectionReference<Map<String, dynamic>> get depositsCollection =>
      _firestore.collection('vanguard_deposits');

  CollectionReference<Map<String, dynamic>> get notificationsCollection =>
      _firestore.collection('vanguard_notifications');

  CollectionReference<Map<String, dynamic>> get workLocationsCollection =>
      _firestore.collection('vanguard_work_locations');

  CollectionReference<Map<String, dynamic>> get attendanceEventsCollection =>
      _firestore.collection('vanguard_attendance_events');

  CollectionReference<Map<String, dynamic>> get employeeDocumentsCollection =>
      _firestore.collection('vanguard_employee_documents');
}
