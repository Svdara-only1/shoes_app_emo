import 'package:shared_preferences/shared_preferences.dart';

class SaveLogin {
    // Save login state
  Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLogin", true);
  }

  // Logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLogin", false);
  }

  // Check user already login and not already login
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLogin") ?? false;
  }
}