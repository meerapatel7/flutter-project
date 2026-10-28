import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginScreen.dart';
import 'main_screen.dart';
import 'provider/provider_dashboard.dart';
import 'admin/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final bool isLogin = prefs.getBool("isLogin") ?? false;
    final int userId = prefs.getInt("userId") ?? 0;
    final bool isProvider = prefs.getBool("isProvider") ?? false;
    final int providerId = prefs.getInt("provider_id") ?? 0;
    final bool isAdmin = prefs.getBool("isAdmin") ?? false;

    if (!mounted) return;

    if (!isLogin || userId == 0) {
      _goTo(const LoginScreen());
      return;
    }

    if (isAdmin) {
      _goTo(AdminDashboard());
      return;
    }

    if (isProvider && providerId != 0) {
      _goTo(ProviderDashboard(providerId: providerId, userId: userId));
      return;
    }

    _goTo(MainScreen(userId: userId));
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/quickserve.jpg', height: 100),
            const SizedBox(height: 25),
            const Text(
              "QuickServe",
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}