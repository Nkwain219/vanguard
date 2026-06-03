import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../models/user.dart';
import '../../models/user_role.dart';
import '../../services/firestore_service.dart';
import '../auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      FirestoreService.instance.usersCollection;

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return await _getUserProfile(credential.user!.uid);
      }
      return null;
    } on fb_auth.FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    return await _getUserProfile(fbUser.uid);
  }

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return await _getUserProfile(fbUser.uid);
    });
  }

  @override
  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return createUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: UserRole.employee,
      department: 'General',
      position: 'Staff',
    );
  }

  String? _adminEmail;
  String? _adminPassword;

  void setAdminCredentials(String email, String password) {
    _adminEmail = email;
    _adminPassword = password;
  }

  @override
  Future<User?> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    required String department,
    required String position,
    String? phone,
  }) async {
    final currentAdmin = _auth.currentUser;
    final adminEmail = _adminEmail;
    final adminPassword = _adminPassword;

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = User(
          id: credential.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone ?? '',
          role: role,
          department: department,
          position: position,
          joinDate: DateTime.now(),
          isActive: true,
        );

        await _usersCollection.doc(user.id).set(user.toJson());

        await _auth.signOut();

        if (adminEmail != null && adminPassword != null) {
          await _auth.signInWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
        }

        return user;
      }
      return null;
    } on fb_auth.FirebaseAuthException {
      if (currentAdmin == null && adminEmail != null && adminPassword != null) {
        try {
          await _auth.signInWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
        } catch (_) {}
      }
      rethrow;
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    final snapshot = await _usersCollection.get();
    return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
  }

  @override
  Future<void> updateUserProfile(User user) async {
    await _usersCollection.doc(user.id).update(user.toJson());
  }

  @override
  Future<void> deactivateUser(String userId) async {
    await _usersCollection.doc(userId).update({'isActive': false});
  }

  @override
  Future<void> reactivateUser(String userId) async {
    await _usersCollection.doc(userId).update({'isActive': true});
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user is currently signed in');
    }

    final credential = fb_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    await user.updatePassword(newPassword);

    if (_adminEmail == user.email) {
      _adminPassword = newPassword;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> refreshIdToken() async {
    final fbUser = _auth.currentUser;
    if (fbUser != null) {
      await fbUser.getIdToken(true);
    }
  }

  Future<User?> _getUserProfile(String uid) async {
    print('DEBUG: Fetching user profile for UID: $uid');
    final doc = await _usersCollection.doc(uid).get();
    print('DEBUG: Document exists: ${doc.exists}');
    print('DEBUG: Document data: ${doc.data()}');
    if (doc.exists && doc.data() != null) {
      return User.fromJson(doc.data()!);
    }
    return null;
  }
}
