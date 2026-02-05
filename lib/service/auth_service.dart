import 'dart:developer';
import 'package:computer_store/database/save_login.dart';
import 'package:computer_store/screen/view/auth/login_screen.dart';
import 'package:computer_store/screen/view/bottom_navbar_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static SaveLogin saveLogin = SaveLogin();

  // Sign up
  static Future<bool> signup(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await saveLogin.login();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavbarScreen()),
      );
      return true;
    } catch (e) {
      log("Signup Error: ${e.toString()}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup failed: ${e.toString()}")));
      return false;
    }
  }

  // Sign in
  static Future<bool> signin(
    BuildContext context,
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      if (rememberMe) {
        await saveLogin.login();
      } else {
        await saveLogin.logout();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavbarScreen()),
      );
      return true;
    } catch (e) {
      log("Login Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: ${e.toString()}")));
      return false;
    }
  }

  // Sign out
  static Future<void> signout(BuildContext context) async {
    await googleSignIn.signOut(); // Google
    await auth.signOut(); // Firebase
    await saveLogin.logout(); // SharedPreferences

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  static GoogleSignIn googleSignIn = GoogleSignIn();
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);

      await saveLogin.login();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavbarScreen()),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signed in with Google")));
    } catch (e) {
      log("Google Sign-In Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Google Sign-In failed")));
    }
  }
}
