import 'package:computer_store/bloc/bottom_navbar_bloc.dart';
import 'package:computer_store/bloc/cart_bloc.dart';
import 'package:computer_store/bloc/counter_bloc.dart';
import 'package:computer_store/bloc/favorite_bloc.dart';
import 'package:computer_store/database/save_login.dart';
import 'package:computer_store/screen/view/auth/login_screen.dart';
import 'package:computer_store/screen/view/auth/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SaveLogin s = SaveLogin();
  bool? isLogin;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    final status = await s.isLoggedIn();
    setState(() {
      isLogin = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin == null) {
      // Loading while checking login
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BottomNavbarBloc()),
        BlocProvider(create: (context) => CounterBloc()),
        BlocProvider(create: (context) => CartBloc()),
        BlocProvider(create: (context) => FavoriteBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isLogin! ? SplashScreen() : LoginScreen(),
      ),
    );
  }
}
