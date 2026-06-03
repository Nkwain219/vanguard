import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../repositories/auth_repository.dart';
import '../services/push_notification_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final UserRole selectedRole;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.selectedRole = UserRole.admin,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    UserRole? selectedRole,
    bool clearError = false,
    bool clearUser = false,
  }) {
    final newUser = clearUser ? null : (user ?? this.user);
    final newError = clearError ? null : (error ?? this.error);

    if (newUser == this.user &&
        (isLoading ?? this.isLoading) == this.isLoading &&
        (isAuthenticated ?? this.isAuthenticated) == this.isAuthenticated &&
        newError == this.error &&
        (selectedRole ?? this.selectedRole) == this.selectedRole) {
      return this;
    }

    return AuthState(
      user: newUser,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: newError,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.user?.id == user?.id &&
        other.isLoading == isLoading &&
        other.isAuthenticated == isAuthenticated &&
        other.error == error &&
        other.selectedRole == selectedRole;
  }

  @override
  int get hashCode => Object.hash(
        user?.id,
        isLoading,
        isAuthenticated,
        error,
        selectedRole,
      );
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  StreamSubscription<User?>? _authSubscription;

  AuthViewModel(this._repository) : super(const AuthState()) {
    _subscribeToAuthChanges();
  }

  void _subscribeToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = _repository.authStateChanges().listen((user) async {
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          selectedRole: user.role,
          isLoading: false,
        );

        try {
          await PushNotificationService.instance.initialize(
            userId: user.id,
            userRole: user.role.name,
          );
        } catch (e) {
          debugPrint('Failed to initialize push notifications: $e');
        }
      } else {
        state = const AuthState();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<bool> signIn(String email, String password) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.signIn(email, password);
      if (user != null) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
          selectedRole: user.role,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid credentials',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      await _repository.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> checkAuthState() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
          selectedRole: user.role,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (user != null) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
          selectedRole: user.role,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> refreshToken() async {
    try {
      await _repository.refreshIdToken();
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
  }

  Future<bool> resetPassword(String email) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void switchRole(UserRole role) {
    if (role == state.selectedRole) return;

    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(role: role),
        selectedRole: role,
      );
    } else {
      state = state.copyWith(selectedRole: role);
    }
  }

  void clearError() {
    if (state.error == null) return;
    state = state.copyWith(clearError: true);
  }
}
