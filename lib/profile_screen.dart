import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'loginScreen.dart';
import 'aboutUs.dart';
import 'editprofileScreen.dart';
import 'helpCenterScreen.dart';
import 'userExp.dart';
import 'settingScreen.dart';
import 'privacyPage.dart';
import 'provider/provider_registration_form.dart';
import 'provider/provider_dashboard.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName   = 'User Name';
  bool _isProvider   = false;
  bool _checkingProvider = true;
  int  _providerId   = 0;

  final String baseUrl =
      "https://maddie-prejournalistic-unconvincedly.ngrok-free.dev/service_api/";

  @override
  void initState() {
    super.initState();
    _loadName();
    _checkProviderStatus();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('profile_name') ?? 'User Name';
    });
  }

  // ✅ Check if this user is already a registered provider
  Future<void> _checkProviderStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Check local first (fast)
    bool localProvider = prefs.getBool("isProvider") ?? false;
    int localProviderId = prefs.getInt("provider_id") ?? 0;

    if (localProvider && localProviderId != 0) {
      setState(() {
        _isProvider = true;
        _providerId = localProviderId;
        _checkingProvider = false;
      });
      return;
    }

    // Verify with server
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}check_provider.php"),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {"user_id": widget.userId.toString()},
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        setState(() => _checkingProvider = false);
        return;
      }

      if (data["success"] == true && data["is_provider"] == true) {
        final pid = int.parse(data["provider_id"].toString());
        await prefs.setBool("isProvider", true);
        await prefs.setInt("provider_id", pid);
        setState(() {
          _isProvider  = true;
          _providerId  = pid;
        });
      }
    } catch (_) {
      // silently fail — just show "Become a Provider"
    } finally {
      if (mounted) setState(() => _checkingProvider = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ✅ Clears ALL — isLogin, userId, isProvider, etc.
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void _goToProviderDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderDashboard(
          providerId: _providerId,
          userId: widget.userId,
        ),
      ),
    );
  }

  void _goToProviderRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderRegistrationForm(userId: widget.userId),
      ),
    ).then((_) => _checkProviderStatus()); // Recheck after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: ListView(
        children: [
          // ── User info header ──
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const CircleAvatar(
                radius: 28,
                child: Icon(Icons.person, size: 30),
              ),
              title: Text(
                _userName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final updatedName = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen()),
                );
                if (updatedName != null) {
                  setState(() => _userName = updatedName);
                }
              },
            ),
          ),

          // ── SERVICE PROVIDER SECTION ──
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text("Service Provider",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
          ),

          _checkingProvider
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
              : _isProvider
          // ✅ Already a provider → show "Go to Provider Dashboard"
              ? ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.lightBlueAccent,
              child: Icon(Icons.dashboard, color: Colors.white, size: 20),
            ),
            title: const Text("Provider Dashboard",
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("View your bookings & earnings"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _goToProviderDashboard,
          )
          // ✅ Not yet a provider → show "Become a Service Provider"
              : ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.handyman, color: Colors.white, size: 20),
            ),
            title: const Text("Become a Service Provider",
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Register and start accepting jobs"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _goToProviderRegistration,
          ),

          const Divider(),

          // ── Regular profile items ──
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Help Centre"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HelpCenterScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text("Bookings"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text("Rate Us"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const UserExperienceScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy & Policy"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About Us"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen())),
          ),
          const Divider(),

          // ── Logout ──
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
            const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}