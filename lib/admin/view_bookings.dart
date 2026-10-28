import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'assign_provider.dart';

class ViewBookings extends StatefulWidget {
  const ViewBookings({super.key});

  @override
  State<ViewBookings> createState() => _ViewBookingsState();
}

class _ViewBookingsState extends State<ViewBookings> {
  List   bookings    = [];
  bool   isLoading   = false;
  String _filterStatus = "All";

  final String baseUrl =
      "https://maddie-prejournalistic-unconvincedly.ngrok-free.dev/service_api/";

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        // ✅ FIX: correct PHP file for ALL bookings
        Uri.parse("${baseUrl}get_all_bookings.php"),
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
        setState(() => bookings = data["bookings"] ?? []);
      } else {
        _showSnackBar(data["message"] ?? "Failed to load bookings");
      }
    } catch (e) {
      _showSnackBar("Connection error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List get _filtered {
    if (_filterStatus == "All") return bookings;
    return bookings.where((b) => b['status'] == _filterStatus).toList();
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'accepted':    return Colors.blue;
      case 'pending':     return Colors.orange;
      case 'cancelled':   return Colors.red;
      case 'completed':   return Colors.green;
      case 'in progress': return Colors.purple;
      default:            return Colors.grey;
    }
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookings (${bookings.length})"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadBookings),
        ],
      ),
      body: Column(
        children: [
          // ── Filter bar ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: ["All", "Pending", "Accepted", "In Progress", "Completed", "Cancelled"]
                  .map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(s),
                  selected: _filterStatus == s,
                  onSelected: (_) => setState(() => _filterStatus = s),
                  selectedColor: Colors.lightBlueAccent,
                ),
              ))
                  .toList(),
            ),
          ),

          // ── List ──
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? const Center(child: Text("No bookings found"))
                : RefreshIndicator(
              onRefresh: loadBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final b      = _filtered[i];
                  final status = b['status'] ?? 'Pending';
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ID + Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Booking #${b['booking_id']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _statusColor(status)),
                                ),
                                child: Text(status,
                                    style: TextStyle(
                                        color: _statusColor(status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Service
                          _infoRow(Icons.build, b['service_name'] ?? 'N/A'),
                          _infoRow(Icons.person, "Customer: ${b['customer_name'] ?? 'N/A'}"),
                          _infoRow(Icons.handyman,
                              "Provider: ${b['provider_name'] ?? 'Not Assigned'}"),
                          _infoRow(Icons.calendar_today,
                              "${b['booking_date'] ?? ''} ${b['booking_time'] ?? ''}"),
                          _infoRow(Icons.location_on, b['address'] ?? ''),
                          _infoRow(Icons.currency_rupee,
                              "₹${b['total_amount'] ?? '0'}"),
                          const SizedBox(height: 8),
                          // Assign button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AssignProvider(
                                    bookingId: int.tryParse(
                                        b['booking_id'].toString()) ??
                                        0,
                                  ),
                                ),
                              ).then((_) => loadBookings()),
                              icon: const Icon(Icons.assignment_ind, size: 16),
                              label: const Text("Assign Provider"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.lightBlueAccent),
                              ),
                            ),
                          ),
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

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}