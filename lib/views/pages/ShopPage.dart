import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulo Plans'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SubscriptionCard(
            title: 'Ambulo +',
            description:
                'Weather alerts + offline maps for smoother, safer hikes.',
            price: '\$5.00 / month',
            color: Color(0xFF3C8D40),
          ),
          SizedBox(height: 16),
          SubscriptionCard(
            title: 'PrimeBulo',
            description:
                'All maps unlocked + weather alerts wherever you go.',
            price: '\$10.00 / month',
            color: Color(0xFF2F5E4E),
          ),
          SizedBox(height: 16),
          SubscriptionCard(
            title: 'Ambulo Premium +',
            description:
                'Includes everything: maps, weather, and demographic alerts.',
            price: '\$15.00 / month',
            color: Color(0xFF2B2B2B),
          ),
        ],
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final Color color;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Implement your purchase logic here
                },
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
