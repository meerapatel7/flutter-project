import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageServices extends StatefulWidget {
  const ManageServices({Key? key}) : super(key: key);

  @override
  State<ManageServices> createState() => _ManageServicesState();
}

class _ManageServicesState extends State<ManageServices> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  static const String baseUrl =
      "https://maddie-prejournalistic-unconvincedly.ngrok-free.dev/service_api";

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "ngrok-skip-browser-warning": "true",
  };

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/category"), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> list = data['category'] ?? [];
        setState(() {
          _categories = list
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      } else {
        _showSnackBar("Failed to load data (${res.statusCode})");
      }
    } catch (e) {
      _showSnackBar("Error loading: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── CATEGORY CRUD ─────────────────────────────────────────────────────────

  Future<void> _addCategory(String categoryName) async {
    try {
      final res = await http
          .post(
        Uri.parse("$baseUrl/category"),
        headers: _headers,
        body: jsonEncode({"category_name": categoryName}),
      )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 201) {
        _showSnackBar("✅ Category added");
        _loadAll(); // ✅ refreshes list so new category appears immediately
      } else {
        _showSnackBar("Failed to add category (${res.statusCode})");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  Future<void> _editCategory(int categoryId, String categoryName) async {
    try {
      final res = await http
          .put(
        Uri.parse("$baseUrl/category/$categoryId"),
        headers: _headers,
        body: jsonEncode({"category_name": categoryName}),
      )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        _showSnackBar("✅ Category updated");
        _loadAll();
      } else {
        _showSnackBar("Failed to update category (${res.statusCode})");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  Future<void> _deleteCategory(int categoryId) async {
    try {
      final res = await http
          .delete(
        Uri.parse("$baseUrl/category/$categoryId"),
        headers: _headers,
      )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        _showSnackBar("Category deleted");
        _loadAll();
      } else {
        _showSnackBar("Failed to delete category (${res.statusCode})");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // ─── SERVICE CRUD ──────────────────────────────────────────────────────────

  Future<void> _addService(
      String name, String price, int categoryId) async {
    try {
      final res = await http
          .post(
        // ✅ FIXED: was /service, correct endpoint is /services
        Uri.parse("$baseUrl/services"),
        headers: _headers,
        body: jsonEncode({
          "service_name": name,
          "price": double.tryParse(price) ?? 0,
          "category_id": categoryId,
        }),
      )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 201) {
        _showSnackBar("✅ Service added");
        _loadAll();
      } else {
        final body = jsonDecode(res.body);
        _showSnackBar("Failed to add service: ${body['error'] ?? res.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  Future<void> _editService(
      int serviceId, String name, String price, int categoryId) async {
    try {
      final res = await http
          .put(
        // ✅ FIXED: was /service/$id, correct endpoint is /services/$id
        Uri.parse("$baseUrl/services/$serviceId"),
        headers: _headers,
        body: jsonEncode({
          "service_name": name,
          "price": double.tryParse(price) ?? 0,
          "category_id": categoryId,
        }),
      )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        _showSnackBar("✅ Service updated");
        _loadAll();
      } else {
        _showSnackBar("Failed to update service (${res.statusCode})");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  Future<void> _deleteService(int serviceId) async {
    try {
      final res = await http
          .delete(
        // ✅ FIXED: was /service/$id, correct endpoint is /services/$id
        Uri.parse("$baseUrl/services/$serviceId"),
        headers: _headers,
      )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        _showSnackBar("Service deleted");
        _loadAll();
      } else {
        _showSnackBar("Failed to delete service (${res.statusCode})");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // ─── DIALOGS ───────────────────────────────────────────────────────────────

  void _showAddCategoryDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Add Category",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: _buildField(ctrl, "Category Name", Icons.category),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: _btnStyle(),
            onPressed: () {
              final name = ctrl.text.trim();
              Navigator.pop(context);
              if (name.isNotEmpty) _addCategory(name);
            },
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> cat) {
    final ctrl =
    TextEditingController(text: cat['category_name']?.toString() ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Category",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: _buildField(ctrl, "Category Name", Icons.category),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: _btnStyle(),
            onPressed: () {
              final name = ctrl.text.trim();
              Navigator.pop(context);
              if (name.isNotEmpty) {
                _editCategory(cat['category_id'] as int, name);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog(int categoryId) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Add Service",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(nameCtrl, "Service Name", Icons.build),
            const SizedBox(height: 12),
            _buildField(priceCtrl, "Price (₹)", Icons.currency_rupee,
                isNumber: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: _btnStyle(),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = priceCtrl.text.trim();
              Navigator.pop(context);
              if (name.isNotEmpty && price.isNotEmpty) {
                _addService(name, price, categoryId);
              }
            },
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> svc, int categoryId) {
    final nameCtrl =
    TextEditingController(text: svc['service_name']?.toString() ?? '');
    final priceCtrl =
    TextEditingController(text: svc['price']?.toString() ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Service",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(nameCtrl, "Service Name", Icons.build),
            const SizedBox(height: 12),
            _buildField(priceCtrl, "Price (₹)", Icons.currency_rupee,
                isNumber: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: _btnStyle(),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = priceCtrl.text.trim();
              Navigator.pop(context);
              if (name.isNotEmpty && price.isNotEmpty) {
                _editService(
                    svc['service_id'] as int, name, price, categoryId);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String name, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Delete",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child:
            const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _buildField(
      TextEditingController ctrl, String label, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
    backgroundColor: Colors.lightBlueAccent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Services"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add Category",
                style: TextStyle(color: Colors.white)),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAll,
        child: _categories.isEmpty
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category_outlined,
                  size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text("No categories yet",
                  style:
                  TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: _btnStyle(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Add Category",
                    style: TextStyle(color: Colors.white)),
                onPressed: _showAddCategoryDialog,
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _categories.length,
          itemBuilder: (context, i) {
            final cat = _categories[i];
            final catId = cat['category_id'] as int;
            final subServices =
            List<Map<String, dynamic>>.from(
                cat['services'] ?? []);

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 3,
              child: Column(
                children: [
                  // Category header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent
                          .withOpacity(0.15),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14)),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.lightBlueAccent,
                        child: Icon(Icons.category,
                            color: Colors.white, size: 18),
                      ),
                      title: Text(
                        cat['category_name'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      subtitle: Text(
                        "${subServices.length} service${subServices.length == 1 ? '' : 's'}",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✅ Add service button always visible
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.green),
                            tooltip: "Add service",
                            onPressed: () =>
                                _showAddServiceDialog(catId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blueAccent,
                                size: 20),
                            tooltip: "Edit category",
                            onPressed: () =>
                                _showEditCategoryDialog(cat),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            tooltip: "Delete category",
                            onPressed: () => _confirmDelete(
                              cat['category_name'] ?? '',
                                  () => _deleteCategory(catId),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Empty state for no services
                  if (subServices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16,
                              color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text(
                            "No services yet — tap + to add",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  else
                  // Services list
                    ...subServices.map((svc) {
                      final svcId = svc['service_id'];
                      final price = double.tryParse(
                          svc['price']?.toString() ?? '0') ??
                          0.0;
                      final priceStr =
                      price == price.truncateToDouble()
                          ? "₹${price.toInt()}"
                          : "₹$price";

                      return ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 2),
                        leading: const Icon(Icons.build,
                            size: 18, color: Colors.blueGrey),
                        title: Text(
                          svc['service_name'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.lightBlue.shade50,
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                              child: Text(
                                priceStr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors
                                        .lightBlue.shade700),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent,
                                  size: 18),
                              onPressed: () =>
                                  _showEditServiceDialog(
                                      svc, catId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 18),
                              onPressed: () => _confirmDelete(
                                svc['service_name'] ?? '',
                                    () => _deleteService(
                                    svcId as int),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 4),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}