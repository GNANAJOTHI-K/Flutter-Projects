import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;

  AuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      this.user = user;
      notifyListeners();
    });
  }

  bool get isLoggedIn => user != null;

  // Email & Password Sign In
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'Login failed';
    }
  }

  // Email & Password Sign Up + Save user info in Firestore
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user info in Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Signup failed';
    } catch (e) {
      return 'Signup failed';
    }
  }

  // Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return 'Google sign in aborted';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential cred = await _auth.signInWithCredential(credential);

      // Save user info on first Google sign in
      final userDoc = await _firestore.collection('users').doc(cred.user!.uid).get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'email': cred.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Google sign in failed';
    } catch (e) {
      return 'Google sign in failed';
    }
  }

  // Sign Out (from both Firebase and Google)
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
