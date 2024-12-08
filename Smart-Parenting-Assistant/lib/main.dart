import 'package:flutter/material.dart';
//import './UI/dashboard.dart';
import 'UI/Registration/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Parenting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const Dashboard(),
      home: const LoginScreen(),
    );
  }
}
