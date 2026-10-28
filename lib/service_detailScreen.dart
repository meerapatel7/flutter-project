import 'package:flutter/material.dart';
import 'api_service.dart';
import 'cart_data.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String category;
  final int categoryId;
  final List<Map<String, dynamic>> preloadedServices;

  const ServiceDetailScreen({
    Key? key,
    required this.category,
    required this.categoryId,
    required this.preloadedServices,
  }) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedServices.isNotEmpty) {
      // ✅ Already loaded from home screen — no network call needed
      _services = widget.preloadedServices;
    } else {
      _loadServices();
    }
  }

  Future<void> _loadServices() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // ✅ Uses ApiService → /category/{id} endpoint
      final svcs = await ApiService.getServicesByCategory(widget.categoryId);
      if (!mounted) return;
      setState(() => _services = svcs);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> service) {
    final String serviceId = service['service_id']?.toString() ?? '0';
    final String serviceName =
        service['service_name']?.toString() ?? 'Service';
    final double price =
        double.tryParse(service['price']?.toString() ?? '0') ?? 0.0;

    final alreadyAdded =
    cartItems.any((item) => item['service_id'].toString() == serviceId);
    if (alreadyAdded) {
      _showSnackBar("$serviceName is already in cart");
      return;
    }

    cartItems.add({
      "service_id": serviceId,
      "service_name": serviceName,
      "category": widget.category,
      "price": price,
    });
    _showSnackBar("✅ $serviceName added to cart");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _loadServices,
                  child: const Text("Retry")),
            ],
          ),
        ),
      )
          : _services.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build_circle_outlined,
                size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text("No services in this category",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadServices,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final service = _services[index];
            final String serviceName =
                service['service_name']?.toString() ?? 'Service';
            final double price = double.tryParse(
                service['price']?.toString() ?? '0') ??
                0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.lightBlueAccent,
                      radius: 20,
                      child: Icon(Icons.build,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(serviceName,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            price == price.truncateToDouble()
                                ? "₹ ${price.toInt()}"
                                : "₹ $price",
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                      onPressed: () => _addToCart(service),
                      child: const Text("Add"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}