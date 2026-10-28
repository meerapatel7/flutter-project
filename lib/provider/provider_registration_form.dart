import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'provider_dashboard.dart';

class ProviderRegistrationForm extends StatefulWidget {
  final int userId;
  const ProviderRegistrationForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProviderRegistrationForm> createState() => _ProviderRegistrationFormState();
}

class _ProviderRegistrationFormState extends State<ProviderRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final fullNameController    = TextEditingController();
  final phoneController       = TextEditingController();
  final serviceAreaController = TextEditingController();
  final experienceController  = TextEditingController();

  String? _selectedCategory;

  final List<String> _categories = [
    'Plumber',
    'Electrician',
    'Carpenter',
    'Painter',
    'Cleaner',
    'AC Technician',
    'Appliance Repair',
    'Pest Control',
    'Gardener',
    'Other',
  ];

  final String baseUrl =
      "https://maddie-prejournalistic-unconvincedly.ngrok-free.dev/service_api/";

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    serviceAreaController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showSnackBar("Please select a service category");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}register_provider.php"),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "user_id":          widget.userId.toString(),
          "full_name":        fullNameController.text.trim(),
          "phone":            phoneController.text.trim(),
          "service_category": _selectedCategory!,
          "service_area":     serviceAreaController.text.trim(),
          "experience_years": experienceController.text.trim(),
        },
      );

      // Safe JSON decode
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        _showSnackBar("Server error. Please try again.");
        return;
      }

      if (data["success"] == true) {
        final int providerId = int.parse(data["provider_id"].toString());

        // Save provider info locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("provider_id", providerId);
        await prefs.setBool("isProvider", true);

        if (!mounted) return;

        _showSnackBar("Registered! Awaiting admin approval.");

        // Go to provider dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderDashboard(
              providerId: providerId,
              userId: widget.userId,
            ),
          ),
        );
      } else {
        _showSnackBar(data["message"] ?? "Registration failed");
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Become a Service Provider"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Join as a Service Provider",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Fill in your details to start getting jobs on QuickServe.",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full Name
              _buildLabel("Full Name *"),
              TextFormField(
                controller: fullNameController,
                decoration: _inputDecoration("Enter your full name", Icons.person),
                validator: (v) => (v == null || v.isEmpty) ? "Full name is required" : null,
              ),
              const SizedBox(height: 16),

              // Phone
              _buildLabel("Phone Number *"),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: _inputDecoration("10-digit mobile number", Icons.phone),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Phone is required";
                  if (v.length != 10) return "Enter valid 10-digit number";
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Service Category
              _buildLabel("Service Category *"),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration("Select your service", Icons.build),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (v) => v == null ? "Please select a category" : null,
              ),
              const SizedBox(height: 16),

              // Service Area
              _buildLabel("Service Area / City *"),
              TextFormField(
                controller: serviceAreaController,
                decoration: _inputDecoration("e.g. Rajkot, Surat", Icons.location_on),
                validator: (v) => (v == null || v.isEmpty) ? "Service area is required" : null,
              ),
              const SizedBox(height: 16),

              // Experience
              _buildLabel("Years of Experience *"),
              TextFormField(
                controller: experienceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("e.g. 3", Icons.workspace_premium),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Experience is required";
                  if (int.tryParse(v) == null) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Application",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Your profile will be reviewed by admin before activation.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}