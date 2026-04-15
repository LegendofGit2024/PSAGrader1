import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

// ---------------------------------------------------------------------------
// Low-level auth service
// ---------------------------------------------------------------------------

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _auth.signOut();

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) =>
    AuthService(ref.watch(firebaseAuthProvider));

/// Exposes the current [User?] as a live stream for guards/redirects
@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) =>
    ref.watch(authServiceProvider).authStateChanges;

/// Convenience: the UID of the signed-in user, throws if not authenticated
@riverpod
String currentUid(Ref ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) throw StateError('User is not authenticated');
  return user.uid;
}
