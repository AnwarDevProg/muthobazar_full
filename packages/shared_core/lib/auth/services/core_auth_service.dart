import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static FirebaseAuth get instance => FirebaseAuth.instance;

  static User? get currentUser => instance.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static String? get userId => currentUser?.uid;

  static String? get phoneNumber => currentUser?.phoneNumber;

  static Future<void> signOut() async {
    await instance.signOut();
  }
}











