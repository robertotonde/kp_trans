import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kp_trans/authentication/login_screen.dart';
import 'package:kp_trans/authentication/signup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kp trans',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: SignupScreen(),
    );
  }
}
