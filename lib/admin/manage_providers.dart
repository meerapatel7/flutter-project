import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageProviders extends StatefulWidget {
  const ManageProviders({Key? key}) : super(key: key);

  @override
  State<ManageProviders> createState() => _ManageProvidersState();
}

class _ManageProvidersState extends State<ManageProviders> {
  List providers = [];
  bool isLoading = false;
  String _filter = "All"; // All, Approved, Pending

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

  Future<void> _approveReject(int providerId, int approve) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}approve_provider.php"),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "provider_id": providerId.toString(),
          "is_approved": approve.toString(),
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
        _showSnackBar(data["message"] ?? "Done");
        loadProviders();
      } else {
        _showSnackBar(data["message"] ?? "Failed");
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  List get _filtered {
    if (_filter == "Approved")
      return providers.where((p) => p['is_approved'].toString() == '1').toList();
    if (_filter == "Pending")
      return providers.where((p) => p['is_approved'].toString() == '0').toList();
    return providers;
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Providers (${providers.length})"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadProviders),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: ["All", "Approved", "Pending"].map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: Colors.lightBlueAccent,
                ),
              )).toList(),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? const Center(child: Text("No providers found"))
                : RefreshIndicator(
              onRefresh: loadProviders,
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final p = _filtered[i];
                  final isApproved = p['is_approved'].toString() == '1';
                  final pid = int.tryParse(p['provider_id'].toString()) ?? 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p['name'] ?? 'N/A',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isApproved
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isApproved ? "Approved" : "Pending",
                                  style: TextStyle(
                                      color: isApproved
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text("📧 ${p['email'] ?? ''}",
                              style: const TextStyle(fontSize: 13)),
                          Text("📞 ${p['phone'] ?? ''}",
                              style: const TextStyle(fontSize: 13)),
                          Text("🔧 ${p['service_type'] ?? ''}",
                              style: const TextStyle(fontSize: 13)),
                          Text("📍 ${p['service_area'] ?? ''}",
                              style: const TextStyle(fontSize: 13)),
                          Text("⏳ ${p['experience_years'] ?? '0'} years experience",
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 10),
                          Row(children: [
                            if (!isApproved) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _approveReject(pid, 1),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text("Approve"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (isApproved)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _approveReject(pid, 0),
                                  icon: const Icon(Icons.block, size: 16),
                                  label: const Text("Revoke"),
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red)),
                                ),
                              ),
                          ]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}