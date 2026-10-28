import 'dart:io';
import 'package:flutter/material.dart';
import 'service_detailScreen.dart';
import 'userExp.dart';
import 'profile_screen.dart';
import 'serviceCart.dart';
import 'api_service.dart';

class HomeTab extends StatefulWidget {
  final int userId;
  const HomeTab({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allCategories = [];
  List<Map<String, dynamic>> _filteredCategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  static const Map<String, IconData> _iconMap = {
    "beauty salon": Icons.face_retouching_natural,
    "ac repair": Icons.ac_unit,
    "shipping": Icons.local_shipping,
    "home cleaning": Icons.cleaning_services,
    "electrician": Icons.electrical_services,
    "plumber": Icons.plumbing,
    "plumbing": Icons.plumbing,
    "home security": Icons.security,
    "laundry service": Icons.local_laundry_service,
    "gardening": Icons.grass,
  };

  IconData _iconFor(String name) =>
      _iconMap[name.toLowerCase()] ?? Icons.miscellaneous_services;

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ Uses ApiService.getCategories() → calls /category endpoint
      final List<Map<String, dynamic>> parsed = await ApiService.getCategories();

      if (!mounted) return;
      setState(() {
        _allCategories = parsed;
        _filteredCategories = parsed;
      });
    } on SocketException {
      if (!mounted) return;
      setState(() => _errorMessage = "No internet connection.");
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredCategories = query.isEmpty
          ? List.from(_allCategories)
          : _allCategories.where((cat) {
        return cat['category_name']
            ?.toString()
            .toLowerCase()
            .contains(query) ==
            true;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Hub"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CartScreen(userId: widget.userId)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: widget.userId)),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadCategories,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search services",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: isSearching
                        ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _searchController.clear(),
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Error banner
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: _loadCategories,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),

              if (isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _filteredCategories.isEmpty
                        ? 'No services found for "${_searchController.text}"'
                        : '${_filteredCategories.length} service${_filteredCategories.length == 1 ? '' : 's'} found',
                    style: TextStyle(
                      fontSize: 13,
                      color: _filteredCategories.isEmpty
                          ? Colors.red
                          : Colors.grey[600],
                    ),
                  ),
                ),

              // Category grid
              Padding(
                padding: const EdgeInsets.all(12),
                child: _filteredCategories.isEmpty && _errorMessage == null
                    ? _buildEmptyState(isSearching)
                    : _filteredCategories.isEmpty
                    ? const SizedBox.shrink()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredCategories.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final cat = _filteredCategories[index];
                    final String categoryName =
                        cat['category_name']?.toString() ?? '';
                    final int categoryId = int.tryParse(
                        cat['category_id']?.toString() ??
                            '0') ??
                        0;
                    // ✅ Services already nested in response
                    final List<Map<String, dynamic>> services =
                    (cat['services'] as List<dynamic>? ?? [])
                        .map((e) => Map<String,
                        dynamic>.from(e as Map))
                        .toList();

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceDetailScreen(
                            category: categoryName,
                            categoryId: categoryId,
                            preloadedServices: services,
                          ),
                        ),
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(_iconFor(categoryName),
                                  size: 32,
                                  color:
                                  Colors.lightBlueAccent),
                              const SizedBox(height: 6),
                              Text(
                                categoryName,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (!isSearching) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Text(
                    "Customer Experience",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading:
                  const Icon(Icons.star, color: Colors.orange),
                  title: const Text("Rate your experience"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UserExperienceScreen()),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.miscellaneous_services,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'No services match your search'
                  : 'No services available',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              isSearching ? 'Try a different keyword' : 'Pull down to refresh',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}