import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/themes.dart';
import 'package:ambulo/main.dart';
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
          _buildItemCard('Ambulo +', 'Wheather alerts', '✅'),
          AppConstants.kSizedBoxMedium,
          _buildItemCard('PrimeBulo', 'Wheather + maps', '🗺️'),
          AppConstants.kSizedBoxMedium,
          _buildItemCard('Ambulo premium +', 'Wheather, demograph alerts + maps', '⚜️'),
        ],
      ),
    );
  }

  Widget _buildItemCard(String title, String subtitle, String emoji) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: globalUser.isLightTheme ? AppTheme.lightTheme.cardColor : AppTheme.darkTheme.cardColor,
      shadowColor: globalUser.isLightTheme ? AppTheme.lightTheme.shadowColor : AppTheme.darkTheme.shadowColor,
      elevation: 4,
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          //Demo action
        },
      ),
    );
  }
}
