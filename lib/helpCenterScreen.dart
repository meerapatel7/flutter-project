import 'package:flutter/material.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 🎨 THEME COLORS (FIXED)
  static const Color _primaryBlue = Colors.lightBlueAccent;
  static const Color _brandBlue = Color(0xFF0288D1); // darker blue
  static const Color _accentBlue = Color(0xFF03A9F4); // medium blue
  static const Color _lightBlue = Color(0xFFF0F8FF); // background (your color)

  final Map<String, bool> _expanded = {
    'Getting Started': false,
    'My Orders': false,
    'Payments & Billing': false,
    'Account & Profile': false,
    'Delivery Issues': false,
    'Refunds & Cancellations': false,
  };

  final Map<String, List<String>> _topics = {
    'Getting Started': [
      'How to place your first order',
      'Browsing services near you',
      'Understanding service categories',
      'Setting your location',
    ],
    'My Orders': [
      'Track your current order',
      'View order history',
      'Reschedule a service',
      'Cancel an order',
    ],
    'Payments & Billing': [
      'Accepted payment methods',
      'Adding a new payment method',
      'Understanding your invoice',
      'Payment failed – what to do',
    ],
    'Account & Profile': [
      'Update personal information',
      'Change your password',
      'Manage notifications',
      'Delete your account',
    ],
    'Delivery Issues': [
      'Provider is late',
      'Provider did not show up',
      'Wrong service delivered',
      'Report a quality issue',
    ],
    'Refunds & Cancellations': [
      'Refund eligibility policy',
      'How to request a refund',
      'Cancellation charges explained',
      'Refund status & timeline',
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBlue,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Help Centre',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined, color: Colors.white),
            onPressed: () => _showContactSheet(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Browse help topics',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _brandBlue,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final key = _expanded.keys.elementAt(index);
                  return _buildAccordionTile(key);
                },
                childCount: _expanded.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryBlue, _accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.bolt_rounded, color: _brandBlue, size: 38),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'How can we help you?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // Search
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Describe your issue',
                prefixIcon: const Icon(Icons.search, color: _brandBlue),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (_, val, __) => val.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _searchController.clear(),
                  )
                      : const SizedBox(),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionTile(String title) {
    final isOpen = _expanded[title] ?? false;
    final items = _topics[title] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded[title] = !isOpen),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isOpen ? _brandBlue : Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: _accentBlue,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Container(
              color: _lightBlue,
              child: Column(
                children: items
                    .map(
                      (item) => ListTile(
                    title: Text(item),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _contactRow(Icons.phone, 'Call us', '1800-123-456', _brandBlue),
            _contactRow(Icons.email, 'Email', 'support@quickserve.com', _accentBlue),
            _contactRow(Icons.chat, 'Live Chat', '9 AM – 9 PM', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(
      IconData icon, String label, String value, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}