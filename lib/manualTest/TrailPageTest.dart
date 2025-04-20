// trail_page_test.dart

import 'package:flutter/material.dart';
import 'package:ambulo/views/pages/trail_page.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/main.dart';

// just for testing purposes
class TrailPageTest extends StatelessWidget {
  final String trailId;
  final User testUser;

  const TrailPageTest({
    super.key,
    required this.trailId,
    required this.testUser,
  });

  @override
  Widget build(BuildContext context) {
    return TrailPage(
      trailId: trailId,
      user: testUser,
    );
  }
}
