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
        title: Consumer<GalleryProvider>(
          builder: (context, galleryProvider, child) {
            return galleryProvider.isSelecting
                ? Text('${galleryProvider.selectedCount} selected')
                : const Text('My Gallery');
          },
        ),
        leading: Consumer<GalleryProvider>(
          builder: (context, galleryProvider, child) {
            if (galleryProvider.isSelecting) {
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => galleryProvider.exitSelectionMode(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        actions: [
          Consumer<GalleryProvider>(
            builder: (context, galleryProvider, child) {
              if (galleryProvider.isSelecting) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.select_all),
                      onPressed: () => galleryProvider.selectAllImages(),
                      tooltip: 'Select All',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: galleryProvider.selectedCount > 0
                          ? () {
                              // TODO: Implement delete functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Delete functionality not implemented yet',
                                  ),
                                ),
                              );
                            }
                          : null,
                      tooltip: 'Delete Selected',
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: galleryProvider.selectedCount > 0
                          ? () {
                              // TODO: Implement share functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Share functionality not implemented yet',
                                  ),
                                ),
                              );
                            }
                          : null,
                      tooltip: 'Share Selected',
                    ),
                  ],
                );
              } else {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.select_all),
                      onPressed: () => galleryProvider.enterSelectionMode(),
                      tooltip: 'Select Images',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => galleryProvider.refreshGallery(),
                      tooltip: 'Refresh Gallery',
                    ),
                  ],
                );
              }
            },
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
              final isSelected = galleryProvider.isImageSelected(images[index]);

              return GestureDetector(
                onTap: () {
                  if (galleryProvider.isSelecting) {
                    galleryProvider.toggleImageSelection(images[index]);
                  } else {
                    // Handle normal tap (e.g., view full image)
                    // TODO: Navigator.push to full image view
                  }
                },
                onLongPress: () {
                  // Enter selection mode on long press if not already selecting
                  if (!galleryProvider.isSelecting) {
                    galleryProvider.enterSelectionMode();
                  }
                  galleryProvider.toggleImageSelection(images[index]);
                },
                child: Stack(
                  children: [
                    // Main image
                    Positioned.fill(
                      child: Image.file(images[index], fit: BoxFit.cover),
                    ),

                    // Selection overlay
                    if (galleryProvider.isSelecting)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            border: isSelected
                                ? Border.all(color: Colors.blue, width: 3)
                                : null,
                          ),
                        ),
                      ),

                    // Checkmark icon
                    if (galleryProvider.isSelecting)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue
                                : Colors.white.withOpacity(0.7),
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
