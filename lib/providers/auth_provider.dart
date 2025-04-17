import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'dart:io';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  Future<void> updateProfile({
    String? displayName,
    File? profileImage,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) throw 'No user logged in';

      String? photoURL = _user!.photoURL;

      if (profileImage != null) {
        // Convert image to base64
        List<int> imageBytes = await profileImage.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        // Store image in Firestore
        await _firestore.collection('user_profiles').doc(_user!.uid).set({
          'profileImage': base64Image,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Create a data URL for the image
        String imageType = profileImage.path.split('.').last.toLowerCase();
        photoURL = 'data:image/$imageType;base64,$base64Image';
      }

      // Update user profile in Firebase Auth
      await _user!.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Refresh the user object
      await _user!.reload();
      _user = _auth.currentUser;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add method to load profile image from Firestore
  Future<String?> loadProfileImage() async {
    try {
      if (_user == null) return null;

      final doc =
          await _firestore.collection('user_profiles').doc(_user!.uid).get();

      if (!doc.exists || !doc.data()!.containsKey('profileImage')) {
        return null;
      }

      final base64Image = doc.data()!['profileImage'] as String;
      return base64Image;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  void showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
