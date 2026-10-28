import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.home_repair_service,
                    size: 90,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Service Hub",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "About Service Hub",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "Service Hub is a user-friendly service booking application "
                  "designed to connect customers with trusted service professionals. "
                  "Our platform allows users to easily book services such as beauty salon, "
                  "cleaning, electrician, plumbing, appliance repair, and more — all from "
                  "the comfort of their home.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),

            const Text(
              "Our Mission",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              "Our mission is to simplify the process of finding reliable "
                  "home services by providing a secure, fast, and transparent "
                  "booking experience for users.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),

            const Text(
              "Why Choose Us?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _featureItem("Verified & trained professionals"),
            _featureItem("Easy service booking"),
            _featureItem("Transparent pricing"),
            _featureItem("Secure payment process"),
            _featureItem("Customer satisfaction focused"),

            const SizedBox(height: 20),

            const Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              "Email: support@servicehub.com\n"
                  "Phone: +91 98765 43210",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            const Center(
              child: Text(
                "© 2026 Service Hub. All rights reserved.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
