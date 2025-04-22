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
            itemCount: trails.length,
            itemBuilder: (context, index) {
              final trailData = trails[index].data() as Map<String, dynamic>;
              return TrailCard(
                fullTrailData: trailData,
                onTap: () {
                  // TODO FIXED only when a global user will be
                },
              );
            },
          );
        },
      ),
    );
  }
}
