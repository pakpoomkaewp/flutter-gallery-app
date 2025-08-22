import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gallery_app/providers/gallery_provider.dart';
import 'package:provider/provider.dart';

import 'camera_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GalleryProvider>().refreshGallery(),
            tooltip: 'Refresh Gallery',
          ),
        ],
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, galleryProvider, child) {
          if (galleryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (galleryProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${galleryProvider.errorMessage}'),
            );
          }
          if (!galleryProvider.hasImages) {
            return const Center(child: Text('No photos yet. Go take some!'));
          }

          final List<File> images = galleryProvider.images;
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
}
