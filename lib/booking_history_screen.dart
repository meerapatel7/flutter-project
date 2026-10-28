import 'package:flutter/material.dart';
import 'api_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  final int userId;
  const BookingHistoryScreen({super.key, required this.userId});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getBookingHistory(widget.userId);
      setState(() => bookings = data);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await ApiService.cancelBooking(bookingId);
      if (response["success"] == true) {
        _showSnackBar("Booking cancelled successfully");
        fetchBookings();
      } else {
        _showSnackBar(response["message"] ?? "Failed to cancel booking");
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(
        child: Text("No bookings found", style: TextStyle(fontSize: 18)),
      )
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          var booking = bookings[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['service_name'] ?? 'Service',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text("Provider: ${booking['provider_name'] ?? 'Not assigned'}"),
                  Text("Phone: ${booking['provider_phone'] ?? 'N/A'}"),
                  const SizedBox(height: 5),
                  Text(
                    "Status: ${booking['status'] ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Total: ₹${booking['total_amount'] ?? '0'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (booking['status'] == "Pending")
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () =>
                          cancelBooking(booking['booking_id'].toString()),
                      child: const Text(
                        "Cancel Booking",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}