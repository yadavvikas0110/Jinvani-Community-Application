import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Returns a Firebase ID token after Google sign-in
  Future<String?> signIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Get Firebase ID token to send to our backend
      final idToken = await userCredential.user?.getIdToken();
      return idToken;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}

final googleAuthServiceProvider = Provider<GoogleAuthService>(
  (_) => GoogleAuthService(),
);
