import 'dart:math';
import 'package:computer_store/database/save_login.dart';
import 'package:computer_store/service/auth_service.dart';
import 'package:computer_store/theme/colors.dart';
import 'package:computer_store/screen/view/auth/register_sreen.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  SaveLogin s = SaveLogin();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/logoShoes.png",
                  width: 200,
                  height: 200,
                ),
                Container(
                  margin: EdgeInsets.only(right: 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(Colorr.primaryColorLitter),
                        ),
                      ),
                      Text(
                        "Login your account",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(Colorr.primaryColorLitter),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: email,
                  style: TextStyle(color: Color(Colorr.primaryColorLitter)),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 62, 62, 62),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Color(Colorr.primaryColorLitter),
                    ),
                    hintText: "Email",
                    focusColor: Color(Colorr.primaryColorLitter),
                    hintStyle: TextStyle(
                      color: Color(Colorr.primaryColorLitter),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    fillColor: const Color(0x88120388),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(175, 255, 255, 255),
                        width: sqrt1_2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: password,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: Color(Colorr.primaryColorLitter)),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 62, 62, 62),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Color(Colorr.primaryColorLitter),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color(Colorr.primaryColorLitter),
                      ),
                    ),
                    hintText: "Password",
                    focusColor: Color(Colorr.primaryColorLitter),
                    hintStyle: TextStyle(
                      color: Color(Colorr.primaryColorLitter),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    fillColor: const Color.fromARGB(137, 18, 3, 136),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(175, 255, 255, 255),
                        width: sqrt1_2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: Color(Colorr.primaryColorLitter),
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
                          Text(
                            "Remember me",
                            style: TextStyle(
                              color: Color(Colorr.primaryColorLitter),
                            ),
                          ),
                        ],
                      ),

                      Text(
                        "Forgotten Password?",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 60, 49, 255),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                InkWell(
                  onTap: () async {
                    bool success = await AuthService.signin(
                      context,
                      email.text,
                      password.text,
                      rememberMe: _rememberMe, // use checkbox
                    );

                    if (!success) {
                      // handle login failure if needed
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(194, 20, 0, 236),
                    ),
                    child: Center(
                      child: Text(
                        "Log in",
                        style: TextStyle(
                          color: Color(Colorr.primaryColorLitter),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Or Login with",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(Colorr.primaryColorLitter),
                  ),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    AuthService.signInWithGoogle(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(Colorr.primaryColorBtn),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logogoogle.png",
                          width: 50,
                          height: 50,
                        ),
                        Center(
                          child: Text(
                            "Login With Google",
                            style: TextStyle(
                              color: Color(Colorr.primaryColorLitter),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(Colorr.primaryColorBtn),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logofacebook.png",
                          width: 35,
                          height: 35,
                        ),
                        SizedBox(width: 10),
                        Center(
                          child: Text(
                            "Login With Facebook",
                            style: TextStyle(
                              color: Color(Colorr.primaryColorLitter),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Do you have an account? ",
                      style: TextStyle(color: Color(Colorr.primaryColorLitter)),
                    ),
                    SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterSreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Create an account",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 60, 49, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
