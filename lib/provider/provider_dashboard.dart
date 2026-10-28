import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../loginScreen.dart';

class ProviderDashboard extends StatefulWidget {
  final int providerId;
  final int userId;
  const ProviderDashboard({
    super.key,
    required this.providerId,
    required this.userId,
  });

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  List _bookings = [];
  bool _isLoading = false;
  String _selectedTab = "all";

  final String baseUrl =
      "https://maddie-prejournalistic-unconvincedly.ngrok-free.dev/service_api/";

  // Status values must match what your booking PHP uses
  final List<String> _statuses = [
    'Accepted',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}get_provider_bookings.php"),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {"provider_id": widget.providerId.toString()},
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        _showSnackBar("Server error. Check your PHP.");
        return;
      }

      if (data["success"] == true) {
        setState(() => _bookings = data["bookings"] ?? []);
      } else {
        _showSnackBar(data["message"] ?? "Failed to load bookings");
      }
    } catch (e) {
      _showSnackBar("Connection error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int bookingId, String newStatus) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}update_booking_status.php"),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "booking_id": bookingId.toString(),
          "provider_id": widget.providerId.toString(),
          "status": newStatus,
        },
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        _showSnackBar("Server error");
        return;
      }

      if (data["success"] == true) {
        _showSnackBar("Status updated to $newStatus");
        loadBookings();
      } else {
        _showSnackBar(data["message"] ?? "Update failed");
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ── Filtered list ──
  List get _filteredBookings {
    if (_selectedTab == "all") return _bookings;
    return _bookings
        .where(
          (b) =>
              (b['status'] ?? '').toLowerCase() == _selectedTab.toLowerCase(),
        )
        .toList();
  }

  // ── Summary counts ──
  int get _totalBookings => _bookings.length;
  int get _pendingCount =>
      _bookings.where((b) => b['status'] == 'Pending').length;
  int get _completedCount =>
      _bookings.where((b) => b['status'] == 'Completed').length;
  double get _totalEarnings => _bookings
      .where((b) => b['status'] == 'Completed')
      .fold(
        0.0,
        (sum, b) =>
            sum + (double.tryParse(b['total_amount'].toString()) ?? 0.0),
      );

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey; // pending
    }
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _showStatusDialog(int bookingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Booking Status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statuses
              .map(
                (s) => ListTile(
                  leading: CircleAvatar(
                    radius: 8,
                    backgroundColor: _statusColor(s),
                  ),
                  title: Text(s),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(bookingId, s);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Provider Dashboard"),
        backgroundColor: Colors.lightBlueAccent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadBookings),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadBookings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ── Summary Cards ──
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _summaryCard(
                            "Total",
                            _totalBookings.toString(),
                            Icons.work,
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _summaryCard(
                            "Pending",
                            _pendingCount.toString(),
                            Icons.hourglass_empty,
                            Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _summaryCard(
                            "Done",
                            _completedCount.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                          const SizedBox(width: 8),
                          _summaryCard(
                            "Earned",
                            "₹${_totalEarnings.toStringAsFixed(0)}",
                            Icons.currency_rupee,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ),

                    // ── Filter Tabs ──
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children:
                            [
                                  'all',
                                  'Pending',
                                  'Accepted',
                                  'In Progress',
                                  'Completed',
                                  'Cancelled',
                                ]
                                .map(
                                  (tab) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(tab),
                                      selected: _selectedTab == tab,
                                      onSelected: (_) =>
                                          setState(() => _selectedTab = tab),
                                      selectedColor: Colors.lightBlueAccent,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Bookings List ──
                    _filteredBookings.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No bookings found",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            itemCount: _filteredBookings.length,
                            itemBuilder: (_, i) =>
                                _bookingCard(_filteredBookings[i]),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingCard(Map booking) {
    final int bookingId = int.tryParse(booking['booking_id'].toString()) ?? 0;
    final String status = booking['status'] ?? 'Pending';
    final String services = booking['services'] ?? 'N/A'; // GROUP_CONCAT result
    final String amount = "₹${booking['total_amount'] ?? '0'}";
    final String date = booking['booking_date'] ?? '';
    final String time = booking['booking_time'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Booking #$bookingId",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _statusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Services
            Row(
              children: [
                const Icon(Icons.build, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(services, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Customer
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  booking['customer_name'] ?? '',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Phone
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  booking['customer_phone'] ?? '',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Address
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking['address'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Date + Time + Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$date  $time",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      size: 14,
                      color: Colors.green,
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Update Status Button
            if (status != 'Completed' && status != 'Cancelled') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showStatusDialog(bookingId),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Update Status"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.lightBlue,
                    side: const BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
