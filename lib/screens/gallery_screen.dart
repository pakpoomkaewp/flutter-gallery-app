import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gallery_app/providers/gallery_provider.dart';
import 'package:provider/provider.dart';

import 'camera_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

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
            itemBuilder: (context, index) => _ImageBox(images[index]),
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

class _ImageBox extends StatelessWidget {
  const _ImageBox(this.image);

  final File image;

  @override
  Widget build(BuildContext context) {
    final galleryProvider = context.watch<GalleryProvider>();
    final isSelected = galleryProvider.isImageSelected(image);
    final isSelecting = galleryProvider.isSelecting;
    return GestureDetector(
      onTap: () {
        if (galleryProvider.isSelecting) {
          galleryProvider.toggleImageSelection(image);
        }
      },
      onLongPress: () {
        if (!galleryProvider.isSelecting) {
          galleryProvider.enterSelectionMode();
        }
        galleryProvider.toggleImageSelection(image);
      },
      child: Stack(
        children: [
          Positioned.fill(child: Image.file(image, fit: BoxFit.cover)),
          if (isSelecting)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  border: isSelected
                      ? Border.all(color: Colors.blue, width: 3)
                      : null,
                ),
              ),
            ),
          if (isSelecting)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue
                      : Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check : null,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
