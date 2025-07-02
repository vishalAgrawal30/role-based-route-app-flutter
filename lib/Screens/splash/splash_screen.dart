// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:role_based_auth_app/Screens/Dashboard/dashboard_view.dart';
import 'package:role_based_auth_app/Screens/Login/login_view.dart';
import 'package:role_based_auth_app/utils/constants.dart';
import 'package:role_based_auth_app/utils/shared_pref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
    // Future.delayed(const Duration(seconds: 2), () {
    //   whereGo();
    // });
    Timer(const Duration(seconds: 3), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    final token = await SharedPref.getToken();
    final role = await SharedPref.getRole();
    final id = await SharedPref.getUserId();

    print("Saved Token: $token");
    print("Saved Role: $role");
    print("Saved ID: $id");
    print("UserId:$id");
    if (token != null && role != null && id != null) {
      print("token is:$token");
      if (role == Constants.ROLE_ADMIN) {
        print("Admin Token:$token \nRole is:$role\nUser id:$id");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        print("Employee Token:$token \nRole is:$role\nUser id:$id");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                "Fuzion HR",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Role-Based Employee Manager",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
