import 'package:ambulo/views/pages/trail_page.dart';
import 'package:ambulo/views/widgets/trail_card.dart';
import 'package:flutter/material.dart';
import 'package:ambulo/models/user.dart';

class SavedRoutesPage extends StatefulWidget {
  final User user;

  const SavedRoutesPage({super.key, required this.user});

  @override
  State<SavedRoutesPage> createState() => _SavedRoutesPageState();
}

class _SavedRoutesPageState extends State<SavedRoutesPage> {
  late Future<List<Map<String, dynamic>>> _savedRoutesFuture;

  @override
  void initState() {
    super.initState();
    _fetchSavedRoutes();
  }

  void _fetchSavedRoutes() {
    _savedRoutesFuture =
        widget.user.db.getTrailsFromSavedHikes(widget.user.userUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Routes"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _savedRoutesFuture,
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
                        user: widget.user,
                      ),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_outlined, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirm Removal"),
                        content: const Text(
                            "Are you sure you want to remove this trail from saved routes?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Remove"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await widget.user.db.removeTrailFromSavedHikes(
                          widget.user.userUid, trail['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Trail removed from saved routes.")),
                      );
                      setState(() {
                        _fetchSavedRoutes(); // Refresh the data
                      });
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
