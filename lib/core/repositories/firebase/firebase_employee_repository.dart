import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/employee.dart';
import '../../services/firestore_service.dart';
import '../employee_repository.dart';

class FirebaseEmployeeRepository implements EmployeeRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.employeesCollection;

  @override
  Future<List<Employee>> getAllEmployees() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Employee.fromJson(doc.data())).toList();
  }

  @override
  Future<Employee?> getEmployeeById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Employee.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<Employee>> getEmployeesByDepartment(String department) async {
    final snapshot =
        await _collection.where('department', isEqualTo: department).get();
    return snapshot.docs.map((doc) => Employee.fromJson(doc.data())).toList();
  }

  @override
  Future<void> createEmployee(Employee employee) async {
    await _collection.doc(employee.id).set(employee.toJson());
  }

  @override
  Future<void> updateEmployee(Employee employee) async {
    await _collection.doc(employee.id).update(employee.toJson());
  }

  @override
  Future<void> deleteEmployee(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> toggleEmployeeStatus(String id, bool isActive) async {
    await _collection.doc(id).update({'isActive': isActive});
  }

  @override
  Stream<List<Employee>> watchEmployees() {
    return _collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Employee.fromJson(doc.data())).toList());
  }

  @override
  Stream<Employee?> watchEmployee(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        print('FIRESTORE_DEBUG: Fetching employee $id');
        print('FIRESTORE_DEBUG: Raw data: $data');
        print('FIRESTORE_DEBUG: bankAccount: ${data['bankAccount']}');
        print('FIRESTORE_DEBUG: idCard: ${data['idCard']}');
        return Employee.fromJson(data);
      }
      print('FIRESTORE_DEBUG: No employee found for id: $id');
      return null;
    });
  }
}
