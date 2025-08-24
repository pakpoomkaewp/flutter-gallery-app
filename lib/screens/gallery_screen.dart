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
      appBar: AppBar(title: _Title(), actions: [_Actions()]),
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

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final galleryProvider = context.watch<GalleryProvider>();
    if (galleryProvider.isSelecting) {
      return Text('${galleryProvider.selectedCount} selected');
    }
    return const Text('My Gallery');
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    final galleryProvider = context.watch<GalleryProvider>();
    return Row(
      children: [
        if (galleryProvider.isSelecting) ...[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final results = await galleryProvider.saveSelectedImages();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      results.containsKey('permission')
                          ? 'Permission denied.'
                          : 'Saved ${results.length} images.',
                    ),
                  ),
                );
              }
            },
            tooltip: 'Save Selected Images',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Selected Images'),
                  content: const Text(
                    'Are you sure you want to delete the selected images? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await galleryProvider.deleteSelectedImages();
              }
            },
            tooltip: 'Delete Selected Images',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<GalleryProvider>().refreshGallery(),
          tooltip: 'Refresh Gallery',
        ),
      ],
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
