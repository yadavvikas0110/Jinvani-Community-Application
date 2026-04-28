import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Returns a Google ID token to send to our backend for verification
  Future<String?> signIn() async {
    try {
      final googleUser = await _googleSignIn.authenticate();

      // `authentication` is a property in v7, not a Future
      final googleAuth = googleUser.authentication;

      // Return the Google ID token directly — our backend verifies it
      // using google-auth-library, NOT Firebase Admin SDK
      return googleAuth.idToken;
    } catch (e, st) {
      print('[GoogleAuthService] Error: $e');
      print(st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

final googleAuthServiceProvider = Provider<GoogleAuthService>(
  (_) => GoogleAuthService(),
);
