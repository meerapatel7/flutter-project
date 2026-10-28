import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'paymentScreen.dart';
import 'cart_data.dart';
import 'api_service.dart';

class BookingScreen extends StatefulWidget {
  final int userId;
  const BookingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedServiceDate;

  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserPhone();
  }

  Future<void> _loadUserPhone() async {
    try {
      final data = await ApiService.getUserProfile(widget.userId);
      if (data["success"] == true) {
        final user = data["user"];
        if (mounted) {
          setState(() {
            if (phoneController.text.isEmpty) {
              phoneController.text = user["phone"] ?? "";
              savedPhone = user["phone"] ?? "";
            }
            if (addressController.text.isEmpty) {
              addressController.text = user["address"] ?? "";
              savedAddress = user["address"] ?? "";
            }
          });
        }
      }
    } catch (e) {}
  }

  int getTotalAmount() {
    double total = 0;
    for (var item in cartItems) {
      total += double.tryParse(item["price"].toString()) ?? 0;
    }
    return total.toInt();
  }

  String getServiceName(Map item) {
    return item["service_name"] ?? item["service"] ?? "Service";
  }

  Future<void> selectServiceDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => selectedServiceDate = picked);
    }
  }

  Future<void> _confirmBooking() async {
    if (phoneController.text.isEmpty ||
        phoneController.text.length != 10 ||
        addressController.text.isEmpty ||
        selectedServiceDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all details")));
      return;
    }

    savedPhone = phoneController.text;
    savedAddress = addressController.text;

    final List<Map<String, dynamic>> services = cartItems
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    var response = await ApiService.createBooking(
      userId: widget.userId,
      bookingDate: selectedServiceDate!.toIso8601String().split('T')[0],
      bookingTime: TimeOfDay.now().format(context),
      phone: phoneController.text,
      address: addressController.text,
      totalAmount: getTotalAmount().toDouble(),
      services: services,
    );

    if (response["success"] == true) {
      double total = getTotalAmount().toDouble();
      cartItems.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PaymentScreen(totalAmount: total, userId: widget.userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Booking failed")),
      );
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: cartItems.isEmpty
          ? Center(child: Text("No services selected"))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (val) => savedPhone = val,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      counterText: "",
                    ),
                  ),
                  SizedBox(height: 10),

                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    onChanged: (val) => savedAddress = val,
                    decoration: InputDecoration(
                      labelText: "Service Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    "Selected Services",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final serviceName = getServiceName(item);
                      final double priceDouble =
                          double.tryParse(item["price"].toString()) ?? 0.0;
                      final String priceDisplay =
                          priceDouble == priceDouble.truncateToDouble()
                          ? priceDouble.toInt().toString()
                          : priceDouble.toString();
                      return Card(
                        child: ListTile(
                          title: Text(serviceName),
                          trailing: Text(
                            "₹ $priceDisplay",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 15),

                  InkWell(
                    onTap: selectServiceDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Service Date",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        selectedServiceDate == null
                            ? "Select service date"
                            : "${selectedServiceDate!.day}-${selectedServiceDate!.month}-${selectedServiceDate!.year}",
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  Text(
                    "Total Amount: ₹ ${getTotalAmount()}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _confirmBooking,
                      child: Text("Confirm & Proceed to Payment"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
