import 'package:flutter/material.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/models/trail.dart';
import 'package:ambulo/models/trail_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTrailPage extends StatefulWidget {
  final String trailId;
  final User user;

  const EditTrailPage({
    super.key,
    required this.trailId,
    required this.user,
  });

  @override
  State<EditTrailPage> createState() => _EditTrailPageState();
}

class _EditTrailPageState extends State<EditTrailPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isSaving = false;

  // Form values
  String name = '';
  String description = '';
  double distance = 0;
  String difficulty = '';
  String region = '';
  bool loop = false;
  bool hasWaterSections = false;
  int nights = 0;
  String trailType = '';
  String startingPoint = '';
  String endingPoint = '';
  bool requiresPayment = false;
  String recommendedSeason = '';
  String surfaceType = '';
  int estimatedTime = 0;

  List<String> trailPhotoUrls = [];

  @override
  void initState() {
    super.initState();
    _loadTrail();
    _loadTrailImages();
  }

  Future<void> _loadTrail() async {
    final snapshot = await Trail.stream(widget.user.db, widget.trailId).first;
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) return;

    final details = Map<String, dynamic>.from(data['trailDetails'] ?? {});
    setState(() {
      name = details[TrailKeys.name] ?? '';
      description = details[TrailKeys.description] ?? '';
      distance = (details[TrailKeys.distance] ?? 0).toDouble();
      difficulty = details[TrailKeys.difficulty] ?? '';
      region = details[TrailKeys.region] ?? '';
      loop = details[TrailKeys.loop] ?? false;
      hasWaterSections = details[TrailKeys.hasWaterSections] ?? false;
      nights = details[TrailKeys.nights] ?? 0;
      trailType = details[TrailKeys.trailType] ?? '';
      startingPoint = details[TrailKeys.startingPoint] ?? '';
      endingPoint = details[TrailKeys.endingPoint] ?? '';
      requiresPayment = details[TrailKeys.requiresPayment] ?? false;
      recommendedSeason = details[TrailKeys.recommendedSeason] ?? '';
      surfaceType = details[TrailKeys.surfaceType] ?? '';
      estimatedTime = details[TrailKeys.estimatedTime] ?? 0;
      isLoading = false;
    });
  }

  Future<void> _loadTrailImages() async {
    final photos = await widget.user.db.loadTrailPhotos(widget.trailId);
    setState(() {
      trailPhotoUrls = photos;
    });
  }

  Future<void> _uploadTrailImage() async {
    final imageUrl =
        await widget.user.db.uploadTrailImageManual(widget.trailId);
    if (imageUrl != null) {
      final photos = await widget.user.db.loadTrailPhotos(widget.trailId);
      setState(() {
        trailPhotoUrls = photos;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  Future<void> _deleteTrailImage(String imageUrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Image"),
        content: const Text("Are you sure you want to delete this image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.user.db.deleteTrailImage(widget.trailId, imageUrl);
      final photos = await widget.user.db.loadTrailPhotos(widget.trailId);
      setState(() {
        trailPhotoUrls = photos;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    final updates = {
      TrailKeys.name: name,
      TrailKeys.description: description,
      TrailKeys.distance: distance,
      TrailKeys.difficulty: difficulty,
      TrailKeys.region: region,
      TrailKeys.loop: loop,
      TrailKeys.hasWaterSections: hasWaterSections,
      TrailKeys.nights: nights,
      TrailKeys.trailType: trailType,
      TrailKeys.startingPoint: startingPoint,
      TrailKeys.endingPoint: endingPoint,
      TrailKeys.requiresPayment: requiresPayment,
      TrailKeys.recommendedSeason: recommendedSeason,
      TrailKeys.surfaceType: surfaceType,
      TrailKeys.estimatedTime: estimatedTime,
    };

    for (final entry in updates.entries) {
      await Trail.editDetails(
        widget.user.db,
        widget.trailId,
        entry.key,
        entry.value,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trail updated')),
    );
    Navigator.pop(context);
    Navigator.pop(context); // Perform pop twice
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async => false, // Disable back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Trail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous page
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Trail Name'),
                  onChanged: (val) => name = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  onChanged: (val) => description = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: distance.toString(),
                  decoration: const InputDecoration(labelText: 'Distance (km)'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => distance = double.tryParse(val) ?? 0,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: difficulty.isNotEmpty ? difficulty : null,
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  items: TrailDifficulty.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => difficulty = val ?? ''),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: region.isNotEmpty ? region : null,
                  decoration: const InputDecoration(labelText: 'Region'),
                  items: TrailRegion.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => region = val ?? ''),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: trailType.isNotEmpty ? trailType : null,
                  decoration: const InputDecoration(labelText: 'Trail Type'),
                  items: TrailType.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => trailType = val ?? ''),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: surfaceType.isNotEmpty ? surfaceType : null,
                  decoration: const InputDecoration(labelText: 'Surface Type'),
                  items: TrailSurface.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => surfaceType = val ?? ''),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: estimatedTime.toString(),
                  decoration: const InputDecoration(
                      labelText: 'Estimated Time (minutes)'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => estimatedTime = int.tryParse(val) ?? 0,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value:
                      recommendedSeason.isNotEmpty ? recommendedSeason : null,
                  decoration:
                      const InputDecoration(labelText: 'Recommended Season'),
                  items: TrailSeason.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => recommendedSeason = val ?? ''),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: startingPoint,
                  decoration:
                      const InputDecoration(labelText: 'Starting Point'),
                  onChanged: (val) => startingPoint = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: endingPoint,
                  decoration: const InputDecoration(labelText: 'Ending Point'),
                  onChanged: (val) => endingPoint = val,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: loop,
                  onChanged: (val) => setState(() => loop = val),
                  title: const Text('Loop Trail'),
                ),
                SwitchListTile(
                  value: hasWaterSections,
                  onChanged: (val) => setState(() => hasWaterSections = val),
                  title: const Text('Has Water Sections'),
                ),
                SwitchListTile(
                  value: requiresPayment,
                  onChanged: (val) => setState(() => requiresPayment = val),
                  title: const Text('Requires Payment'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: nights.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Number of Nights'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => nights = int.tryParse(val) ?? 0,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Trail Photos",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                trailPhotoUrls.isNotEmpty
                    ? SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: trailPhotoUrls.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () =>
                                  _deleteTrailImage(trailPhotoUrls[index]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Image.network(
                                    trailPhotoUrls[index],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        height: 120,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Text("No images available"),
                      ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text("Upload Image"),
                  onPressed: _uploadTrailImage,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: isSaving
                      ? const Text("Saving...")
                      : const Text("Save Changes"),
                  onPressed: isSaving ? null : _saveChanges,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
