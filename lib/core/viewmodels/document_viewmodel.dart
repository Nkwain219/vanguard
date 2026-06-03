import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee_document.dart';
import '../repositories/document_repository.dart';

class DocumentState {
  final List<EmployeeDocument> documents;
  final bool isLoading;
  final String? error;

  DocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
  });

  DocumentState copyWith({
    List<EmployeeDocument>? documents,
    bool? isLoading,
    String? error,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DocumentViewModel extends StateNotifier<DocumentState> {
  final DocumentRepository _repository;
  final String employeeId;

  DocumentViewModel(this._repository, this.employeeId) : super(DocumentState());

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final documents = await _repository.getDocumentsByEmployee(employeeId);
      state = state.copyWith(documents: documents, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> uploadDocument({
    required File file,
    required String name,
    required DocumentType type,
    required String uploadedBy,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.uploadDocument(
        file: file,
        employeeId: employeeId,
        name: name,
        type: type,
        uploadedBy: uploadedBy,
        notes: notes,
      );

      await loadDocuments();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteDocument(String documentId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteDocument(documentId);
      await loadDocuments();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
