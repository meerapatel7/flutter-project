import 'package:flutter/material.dart';
import 'cart_data.dart';
import 'booking_screen.dart';

class CartScreen extends StatefulWidget {
  final int userId;
  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  int getTotalPrice() {
    double total = 0;

    for (var item in cartItems) {
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      total += price;
    }

    return total.toInt();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.lightBlueAccent,
      ),

      body: cartItems.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {

                final item = cartItems[index];

                final serviceName =
                    item['service_name'] ??
                        item['service'] ??
                        "Service";

                final price = double.tryParse(item['price'].toString()) ?? 0.0;
                final priceDisplay = price == price.truncateToDouble()
                    ? price.toInt().toString()
                    : price.toString();

                return Card(
                  child: ListTile(
                    title: Text(serviceName),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Text(
                          "₹ $priceDisplay",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeItem(index),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                Text(
                  "Total: ₹ ${getTotalPrice()}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text("Proceed to Booking"),

                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingScreen(userId: widget.userId),
                        ),
                      );

                    },
                  ),
                )

              ],
            ),
          )

        ],
      ),
    );
  }
}