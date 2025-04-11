import 'package:ambulo/data/styles/theme_extentions.dart';
import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 200,
        child: Column(
          children: [
            Text(title, textAlign: TextAlign.center, 
                style: context.textTheme.titleMedium),
            Text(
              value,
              style: context.textTheme.titleLarge,
            ),
           
          ],
        ),
      ),
    );
  }
}
