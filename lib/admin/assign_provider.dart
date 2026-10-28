import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssignProvider extends StatefulWidget {
  final int bookingId;
  const AssignProvider({super.key, required this.bookingId});

  @override
  State<AssignProvider> createState() => _AssignProviderState();
}

class _AssignProviderState extends State<AssignProvider> {
  List providers = [];
  bool isLoading = false;

  final String baseUrl =
      "https://maddie-prejournalistic-unconvincedly.ngrok-free.dev/service_api/";

  @override
  void initState() {
    super.initState();
    loadProviders();
  }

  Future<void> loadProviders() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        // ✅ FIX: correct PHP URL
        Uri.parse("${baseUrl}get_all_providers.php"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        _showSnackBar("Server error.");
        return;
      }

      if (data["success"] == true) {
        setState(() => providers = data["providers"] ?? []);
      } else {
        _showSnackBar(data["message"] ?? "Failed to load providers");
      }
    } catch (e) {
      _showSnackBar("Connection error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> assign(int providerId) async {
    try {
      final response = await http.post(
        // ✅ FIX: correct PHP URL with POST
        Uri.parse("${baseUrl}assign_provider.php"),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "booking_id":  widget.bookingId.toString(),
          "provider_id": providerId.toString(),
        },
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        _showSnackBar("Server error.");
        return;
      }

      if (data["success"] == true) {
        _showSnackBar("Provider assigned successfully!");
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar(data["message"] ?? "Failed to assign");
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assign Provider — Booking #${widget.bookingId}"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : providers.isEmpty
          ? const Center(child: Text("No approved providers found"))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: providers.length,
        itemBuilder: (_, i) {
          final p = providers[i];
          final isApproved = p['is_approved'].toString() == '1';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                isApproved ? Colors.green.shade100 : Colors.grey.shade200,
                child: Icon(Icons.handyman,
                    color: isApproved ? Colors.green : Colors.grey),
              ),
              title: Text(p['name'] ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['service_type'] ?? ''),
                  Text(p['service_area'] ?? '',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              isThreeLine: true,
              trailing: isApproved
                  ? ElevatedButton(
                onPressed: () => assign(
                    int.tryParse(p['provider_id'].toString()) ?? 0),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent),
                child: const Text("Assign",
                    style: TextStyle(color: Colors.white)),
              )
                  : Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Pending",
                    style: TextStyle(
                        color: Colors.orange, fontSize: 12)),
              ),
            ),
          );
        },
      ),
    );
  }
}