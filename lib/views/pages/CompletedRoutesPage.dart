import 'package:ambulo/views/pages/trail_page.dart';
import 'package:ambulo/views/widgets/trail_card.dart';
import 'package:flutter/material.dart';
import 'package:ambulo/models/user.dart';

class CompletedRoutesPage extends StatelessWidget {
  final User user;

  const CompletedRoutesPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed Routes"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: user.db.getTrailsFromHikingHistory(user.userUid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final completedRoutes = snapshot.data!;

          if (completedRoutes.isEmpty) {
            return const Center(child: Text("No completed routes found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completedRoutes.length,
            itemBuilder: (context, index) {
              final trail = completedRoutes[index];
              return TrailCard(
                fullTrailData: trail,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrailPage(
                        trailId: trail['id'],
                        user: user,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
