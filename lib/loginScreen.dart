import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
import 'registerScreen.dart';
import 'admin/admin_login.dart';
import 'provider/provider_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final String baseUrl =
      "https://maddie-prejournalistic-unconvincedly.ngrok-free.dev/service_api/";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}login.php"),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final int userId     = int.parse(data["user_id"].toString());
        final String role    = data["role"] ?? "user";
        final int providerId = int.tryParse(data["provider_id"]?.toString() ?? "0") ?? 0;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLogin", true);
        await prefs.setInt("userId", userId);
        await prefs.setString("role", role);
        await prefs.setInt("providerId", providerId);

        if (!mounted) return;

        if (role == "provider") {
          // ✅ Approved provider → goes to provider dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProviderDashboard(
                providerId: providerId,
                userId: userId,
              ),
            ),
          );
        } else if (role == "provider_pending") {
          // ✅ Registered but not yet approved
          _showSnackBar("Your provider account is pending admin approval.");
        } else {
          // ✅ Regular user → goes to main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen(userId: userId)),
          );
        }
      } else {
        _showSnackBar(data["message"] ?? "Invalid email or password");
      }
    } catch (e) {
      _showSnackBar("Login error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Email is required";
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) return "Enter valid email";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Password is required";
                  if (value.length < 6)
                    return "Password must be at least 6 characters";
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminLoginScreen()),
                  );
                },
                child: const Text("Login as Admin"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}