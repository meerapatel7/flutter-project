import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy & Policy"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              "Your privacy is important to us. This application collects "
                  "user information only to provide better services. "
                  "We do not share your personal data with any third party.",
            ),

            SizedBox(height: 15),

            Text(
              "Information We Collect",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "- Name\n"
                  "- Phone Number\n"
                  "- Service Address\n"
                  "- Booking Details",
            ),

            SizedBox(height: 15),

            Text(
              "Data Usage",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "The collected data is used only for service booking, "
                  "customer support, and improving user experience.",
            ),

            SizedBox(height: 15),

            Text(
              "Security",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "We take reasonable measures to protect your personal data "
                  "from unauthorized access.",
            ),

            SizedBox(height: 20),

            Text(
              "By using this app, you agree to our Privacy Policy.",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}