import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Sign in with google account picker
  Future<void> signInWithGoogleAccountPicker(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Force picker
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } catch (e) {
      _error = e.toString();
      showError(context, e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInSilentlyWithLastUsedAccount(
      BuildContext context, GoogleSignInAccount? _previousUser) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
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

      await _auth.signInWithCredential(credential);
    } catch (e) {
      _error = e.toString();
      showError(context, e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Future.wait([_auth.signOut()]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
