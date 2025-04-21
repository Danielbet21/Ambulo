import 'package:ambulo/views/pages/trail_page.dart';
import 'package:ambulo/views/widgets/trail_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ambulo/models/user.dart';

class SavedRoutesPage extends StatelessWidget {
  final User user;

  const SavedRoutesPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Routes"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: user.db.getTrailsFromSavedHikes(user.userUid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final savedRoutes = snapshot.data!;

          if (savedRoutes.isEmpty) {
            return const Center(child: Text("No saved routes found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: savedRoutes.length,
            itemBuilder: (context, index) {
              final trail = savedRoutes[index];
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
