import 'package:examedge/screens/logged_in_user_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? getCurrentUser() => _firebaseAuth.currentUser;

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  Future<void> signInWithGoogleAccountPicker(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Force picker
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoggedInUserInfo(),
        ),
      );
    } catch (e) {
      showError(context, e.toString());
    }
  }

  Future<void> signInSilentlyWithLastUsedAccount(
      BuildContext context, GoogleSignInAccount? _previousUser) async {
    try {
      final googleUser = _previousUser ?? await GoogleSignIn().signInSilently();

      if (googleUser == null) {
        showError(context, 'No previously signed-in account found.');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoggedInUserInfo(),
        ),
      );
    } catch (e) {
      showError(context, e.toString());
    }
  }

  void showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
