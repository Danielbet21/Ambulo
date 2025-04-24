import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildItemCard('Hiking Boots', 'Comfortable boots for long trails', '🥾'),
          const SizedBox(height: 16),
          _buildItemCard('Trail Map Pack', 'Set of offline topographic maps', '🗺️'),
          const SizedBox(height: 16),
          _buildItemCard('Water Bottle', 'Keeps water cool for 12 hours', '💧'),
        ],
      ),
    );
  }

  Widget _buildItemCard(String title, String subtitle, String emoji) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: handle item tap
        },
      ),
    );
  }
}
