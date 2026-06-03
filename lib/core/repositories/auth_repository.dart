import '../models/user.dart';
import '../models/user_role.dart';

abstract class AuthRepository {
  Future<User?> signIn(String email, String password);

  Future<void> signOut();

  Future<User?> getCurrentUser();

  Stream<User?> authStateChanges();

  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<User?> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    required String department,
    required String position,
    String? phone,
  });

  Future<List<User>> getAllUsers();

  Future<void> updateUserProfile(User user);

  Future<void> deactivateUser(String userId);

  Future<void> reactivateUser(String userId);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> resetPassword(String email);

  Future<void> refreshIdToken();
}
