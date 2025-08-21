import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'camera_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  Future<List<File>>? _imageFiles;

  @override
  void initState() {
    super.initState();
    _imageFiles = _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _imageFiles = _loadImages();
              });
            },
            tooltip: 'Refresh Gallery',
          ),
        ],
      ),
      body: FutureBuilder<List<File>>(
        future: _imageFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No photos yet. Go take some!'));
          }

          final List<File> images = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.file(images[index], fit: BoxFit.cover);
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const CameraScreen()));
        },
        tooltip: 'Take a Photo',
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<List<File>> _loadImages() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> entities = appDir.listSync();
    final List<File> imageFiles = entities
        .where((entity) => entity is File && entity.path.endsWith('.jpg'))
        .map((entity) => entity as File)
        .toList();

    // Sort by date, newest first
    imageFiles.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );

    return imageFiles;
  }
}
