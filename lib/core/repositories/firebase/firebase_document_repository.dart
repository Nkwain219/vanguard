import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../models/employee_document.dart';
import '../../services/firestore_service.dart';
import '../document_repository.dart';

class FirebaseDocumentRepository implements DocumentRepository {
  final _firestore = FirestoreService.instance;
  final _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  @override
  Future<List<EmployeeDocument>> getDocumentsByEmployee(
      String employeeId) async {
    final snapshot = await _firestore.employeeDocumentsCollection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('uploadedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => EmployeeDocument.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<EmployeeDocument> uploadDocument({
    required File file,
    required String employeeId,
    required String name,
    required DocumentType type,
    required String uploadedBy,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final fileName = path.basename(file.path);
    final extension = path.extension(file.path).toLowerCase();

    final storageRef = _storage
        .ref()
        .child('documents')
        .child(employeeId)
        .child('${id}_$fileName');

    final uploadTask = await storageRef.putFile(file);
    final fileUrl = await uploadTask.ref.getDownloadURL();
    final metadata = await uploadTask.ref.getMetadata();

    final document = EmployeeDocument(
      id: id,
      employeeId: employeeId,
      name: name,
      type: type,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: metadata.size ?? 0,
      mimeType: metadata.contentType ?? 'application/octet-stream',
      uploadedBy: uploadedBy,
      uploadedAt: DateTime.now(),
      notes: notes,
    );

    await _firestore.employeeDocumentsCollection.doc(id).set(document.toJson());

    return document;
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    final docSnapshot =
        await _firestore.employeeDocumentsCollection.doc(documentId).get();

    if (!docSnapshot.exists) {
      throw Exception('Document not found');
    }

    final document = EmployeeDocument.fromJson(docSnapshot.data()!);

    try {
      final ref = _storage.refFromURL(document.fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file from storage: $e');
    }

    await _firestore.employeeDocumentsCollection.doc(documentId).delete();
  }
}
