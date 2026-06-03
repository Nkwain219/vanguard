import 'dart:io';
import '../models/employee_document.dart';

abstract class DocumentRepository {
  Future<List<EmployeeDocument>> getDocumentsByEmployee(String employeeId);

  Future<EmployeeDocument> uploadDocument({
    required File file,
    required String employeeId,
    required String name,
    required DocumentType type,
    required String uploadedBy,
    String? notes,
  });

  Future<void> deleteDocument(String documentId);
}
