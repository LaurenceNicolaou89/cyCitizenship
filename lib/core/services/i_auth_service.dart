import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  bool get isSignedIn;

  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> signUpWithEmail(String email, String password);
  Future<UserCredential?> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
