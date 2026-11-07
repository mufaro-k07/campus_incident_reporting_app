import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    await user.sendEmailVerification();
  }

  Future<void> logIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<User?> reloadUser() async {
    await _auth.currentUser?.reload();
    final user = _auth.currentUser;
    if (user != null && user.emailVerified) {
      // The security rules read email_verified from the ID token, and the old
      // token still says false, so ask for a fresh one.
      await user.getIdToken(true);
    }
    return user;
  }

  // The security rules only let verified users write, so the profile is
  // created the first time a verified user opens the app, not at sign-up.
  Future<void> createProfileIfMissing(User user) async {
    final profileRef = _users.doc(user.uid);
    final snapshot = await profileRef.get();
    if (snapshot.exists) return;

    final email = user.email ?? '';
    await profileRef.set({
      'name': user.displayName ?? email.split('@').first,
      'email': email,
      'role': UserRole.student.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<AppUser?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : AppUser.fromMap(snapshot.id, data);
    });
  }

  Future<void> signOut() => _auth.signOut();
}
