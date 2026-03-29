import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static FirebaseAuth get instance => FirebaseAuth.instance;

  static User? get currentUser => instance.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static String? get userId => currentUser?.uid;

  static String? get phoneNumber => currentUser?.phoneNumber;

  static Stream<User?> get authStateChanges => instance.authStateChanges();

  static Stream<User?> get idTokenChanges => instance.idTokenChanges();

  static Future<User?> reloadCurrentUser() async {
    final User? user = currentUser;
    if (user == null) return null;

    await user.reload();
    return instance.currentUser;
  }

  static Future<void> signOut() async {
    await instance.signOut();
  }
}









