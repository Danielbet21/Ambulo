import 'package:ambulo/views/widgets/trail_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ambulo/models/user.dart';

class MyTrailsPage extends StatelessWidget {
  final User user;

  const MyTrailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Trails"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: user.db.getAllTrails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final trails = snapshot.data!.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .where(
                  (trail) => trail['trailDetails']?['userUid'] == user.userUid)
              .toList();

          if (trails.isEmpty) {
            return const Center(child: Text("No trails found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trails.length,
            itemBuilder: (context, index) {
              final trail = trails[index];
              return TrailCard(
                fullTrailData: trail,
                onTap: () {
                  Navigator.pushNamed(context, '/trail', arguments: {
                    'trailData': trail,
                    'user': user,
                    'isEditable': true,
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
