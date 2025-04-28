import 'package:ambulo/main.dart';
import 'package:ambulo/views/pages/trail_page.dart';
import 'package:ambulo/views/widgets/trail_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllTrailsWidget extends StatelessWidget {
  const AllTrailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Trails'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('trails').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load trails.'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No trails available.'));
          }

          final trails = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: trails.length,
            itemBuilder: (context, index) {
              final trailData = trails[index].data() as Map<String, dynamic>;
              return TrailCard(
                fullTrailData: trailData,
                onTap: () {
                  final trailId = trails[index].id; // Get the trail ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrailPage(
                        trailId: trailId,
                        user: globalUser, // Pass the global user
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
