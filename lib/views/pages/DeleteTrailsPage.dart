import 'package:flutter/material.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/models/trail.dart';
import 'package:ambulo/views/widgets/trail_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteTrailsPage extends StatefulWidget {
  final User user;

  const DeleteTrailsPage({super.key, required this.user});

  @override
  State<DeleteTrailsPage> createState() => _DeleteTrailsPageState();
}

class _DeleteTrailsPageState extends State<DeleteTrailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Trails"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.user.db.getAllTrails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No trails found."));
          }

          final trails = snapshot.data!.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trails.length,
            itemBuilder: (context, index) {
              final trail = trails[index];
              return TrailCard(
                fullTrailData: trail,
                onTap: () {
                  // Navigate to trail details page if needed
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(context, trail),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> trail) {
    final trailName = trail['trailDetails']?['name'] ?? 'Unnamed Trail';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Trail"),
        content: Text(
          "Are you sure you want to delete '$trailName'?\n\n"
          "This will remove all trail data and references from users' saved lists and hiking history.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              _deleteTrail(trail['id']);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTrail(String trailId) async {
    try {
      final scaffold = ScaffoldMessenger.of(context);

      scaffold.showSnackBar(
        const SnackBar(
          content: Text("Deleting trail..."),
          duration: Duration(seconds: 2),
        ),
      );

      await Trail.delete(widget.user.db, trailId);

      if (mounted) {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text("Trail deleted successfully."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting trail: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
