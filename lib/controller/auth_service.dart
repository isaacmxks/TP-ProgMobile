import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Google sign-in (Web)
  Future<User?> signInWithGoogle() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // Twitter sign-in (Web)
  Future<User?> signInWithTwitter() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithPopup(TwitterAuthProvider());
      return userCredential.user;
    } catch (e) {
      print("Twitter Sign-In Error: $e");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
