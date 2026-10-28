import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manage_service.dart';
import 'manage_user.dart';
import 'view_bookings.dart';
import 'manage_providers.dart';
import 'reports_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.lightBlueAccent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Welcome, Admin 👋\nManage your QuickServe platform below.",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              _adminCard(
                context,
                "Manage Services",
                Icons.build,
                Colors.blue,
                const ManageServices(),
              ),
              _adminCard(
                context,
                "Manage Users",
                Icons.people,
                Colors.green,
                const ManageUsers(),
              ),
              _adminCard(
                context,
                "View Bookings",
                Icons.book_online,
                Colors.orange,
                const ViewBookings(),
              ),
              _adminCard(
                context,
                "Manage Providers",
                Icons.handyman,
                Colors.purple,
                const ManageProviders(),
              ),
              _adminCard(
                context,
                "Reports",
                Icons.bar_chart,
                Colors.red,
                const ReportsPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
