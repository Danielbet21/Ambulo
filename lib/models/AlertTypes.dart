import 'package:flutter/material.dart';

class AlertTypes {
  static const List<Map<String, dynamic>> all = [
    {
      'type': 'Blocked Trail',
      'icon': Icons.block,
      'color': Colors.red,
    },
    {
      'type': 'Flooded Path',
      'icon': Icons.water,
      'color': Colors.blue,
    },
    {
      'type': 'Stray Dog',
      'icon': Icons.pets,
      'color': Colors.orange,
    },
    {
      'type': 'Scenic View',
      'icon': Icons.landscape,
      'color': Colors.green,
    },
    {
      'type': 'Stream',
      'icon': Icons.waves,
      'color': Colors.cyan,
    },
    {
      'type': 'Spring',
      'icon': Icons.water_drop,
      'color': Colors.lightBlue,
    },
  ];
}
