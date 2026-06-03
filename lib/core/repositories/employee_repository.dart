import '../models/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getAllEmployees();

  Future<Employee?> getEmployeeById(String id);

  Future<List<Employee>> getEmployeesByDepartment(String department);

  Future<void> createEmployee(Employee employee);

  Future<void> updateEmployee(Employee employee);

  Future<void> deleteEmployee(String id);

  Future<void> toggleEmployeeStatus(String id, bool isActive);

  Stream<List<Employee>> watchEmployees();

  Stream<Employee?> watchEmployee(String id);
}
