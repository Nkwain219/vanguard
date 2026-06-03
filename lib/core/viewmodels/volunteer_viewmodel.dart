import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/volunteer.dart';
import '../repositories/volunteer_repository.dart';

class VolunteerState {
  final List<Volunteer> volunteers;
  final Volunteer? selectedVolunteer;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  const VolunteerState({
    this.volunteers = const [],
    this.selectedVolunteer,
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  List<Volunteer> get filteredVolunteers {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return volunteers;
    }
    final query = searchQuery!.toLowerCase();
    return volunteers.where((v) {
      final name = '${v.firstName} ${v.lastName}'.toLowerCase();
      return name.contains(query) ||
          v.email.toLowerCase().contains(query) ||
          v.department.toLowerCase().contains(query);
    }).toList();
  }

  int get activeCount => volunteers.where((v) => v.isActive).length;

  VolunteerState copyWith({
    List<Volunteer>? volunteers,
    Volunteer? selectedVolunteer,
    bool? isLoading,
    String? error,
    String? searchQuery,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return VolunteerState(
      volunteers: volunteers ?? this.volunteers,
      selectedVolunteer:
          clearSelection ? null : (selectedVolunteer ?? this.selectedVolunteer),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class VolunteerViewModel extends StateNotifier<VolunteerState> {
  final VolunteerRepository _repository;
  StreamSubscription<List<Volunteer>>? _volunteerSubscription;

  VolunteerViewModel(this._repository) : super(const VolunteerState()) {
    _startWatchingVolunteers();
  }

  @override
  void dispose() {
    _volunteerSubscription?.cancel();
    super.dispose();
  }

  void _startWatchingVolunteers() {
    state = state.copyWith(isLoading: true);
    _volunteerSubscription = _repository.watchVolunteers().listen(
      (volunteers) {
        state = state.copyWith(
          volunteers: volunteers,
          isLoading: false,
          clearError: true,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load volunteers: ${error.toString()}',
        );
      },
    );
  }

  Future<void> loadVolunteers({bool forceRefresh = false}) async {
    if (state.volunteers.isNotEmpty && !forceRefresh && !state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final volunteers = await _repository.getAllVolunteers();
      state = state.copyWith(
        volunteers: volunteers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load volunteers: ${e.toString()}',
      );
    }
  }

  Future<void> selectVolunteer(String id) async {
    try {
      final volunteer = await _repository.getVolunteerById(id);
      if (volunteer != null) {
        state = state.copyWith(selectedVolunteer: volunteer);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load volunteer details: ${e.toString()}',
      );
    }
  }

  void clearSelection() {
    state = state.copyWith(clearSelection: true);
  }

  Future<bool> createVolunteer(Volunteer volunteer) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.createVolunteer(volunteer);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create volunteer: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateVolunteer(Volunteer volunteer) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.updateVolunteer(volunteer);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update volunteer: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> deleteVolunteer(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.deleteVolunteer(id);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete volunteer: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> toggleStatus(String id, bool isActive) async {
    try {
      await _repository.toggleVolunteerStatus(id, isActive);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update status: ${e.toString()}',
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = state.copyWith(searchQuery: '');
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
