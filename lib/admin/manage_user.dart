import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageUsers extends StatefulWidget {
  const ManageUsers({Key? key}) : super(key: key);

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  List users     = [];
  bool isLoading = false;

  final String baseUrl =
      "https://maddie-prejournalistic-unconvincedly.ngrok-free.dev/service_api/";

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        // ✅ FIX: correct .php URL
        Uri.parse("${baseUrl}get_all_users.php"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        _showSnackBar("Server error. Check PHP.");
        return;
      }

      if (data["success"] == true) {
        setState(() => users = data["users"] ?? []);
      } else {
        _showSnackBar(data["message"] ?? "Failed to load users");
      }
    } catch (e) {
      _showSnackBar("Connection error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Users (${users.length})"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadUsers),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text("No users found"))
          : RefreshIndicator(
        onRefresh: loadUsers,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: users.length,
          itemBuilder: (_, i) {
            final u = users[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    (u['name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                title: Text(u['name'] ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u['email'] ?? ''),
                    if ((u['phone'] ?? '').isNotEmpty)
                      Text(u['phone'],
                          style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                isThreeLine: true,
                trailing: Text(
                  "#${u['user_id']}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}