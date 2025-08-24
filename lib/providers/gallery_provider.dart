import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryProvider extends ChangeNotifier {
  List<File> _images = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSelecting = false;
  final Set<File> _selectedImages = {};

  List<File> get images => _images;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasImages => _images.isNotEmpty;
  bool get isSelecting => _isSelecting;
  List<File> get selectedImages => _selectedImages.toList();
  int get selectedCount => _selectedImages.length;

  GalleryProvider() {
    _loadImages();
  }

  Future<void> refreshGallery() async {
    await _loadImages();
  }

  void enterSelectionMode() {
    _isSelecting = true;
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelecting = false;
    _selectedImages.clear();
    notifyListeners();
  }

  void toggleImageSelection(File image) {
    if (_selectedImages.contains(image)) {
      _selectedImages.remove(image);
      if (_selectedImages.isEmpty) {
        exitSelectionMode();
      }
    } else {
      _selectedImages.add(image);
    }
    notifyListeners();
  }

  bool isImageSelected(File image) {
    return _selectedImages.contains(image);
  }

  Future<void> deleteSelectedImages() async {
    for (final image in _selectedImages) {
      try {
        if (await image.exists()) {
          await image.delete();
        }
      } catch (e) {
        _errorMessage = 'Failed to delete image: $e';
      }
    }
    _selectedImages.clear();
    exitSelectionMode();
    await _loadImages();
  }

  Future<PermissionState> requestPhotoPermission() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    return state;
  }

  Future<Map<String, String>> saveImages() async {
    final Map<String, String> results = {};
    for (final image in _selectedImages) {
      try {
        final bytes = await image.readAsBytes();
        final result = await ImageGallerySaver.saveImage(bytes);
        if (result['isSuccess']) {
          results[image.path] = 'success';
        } else {
          results[image.path] = result['errorMessage'] ?? 'Failed to save';
        }
      } catch (e) {
        results[image.path] = 'Failed to save image: $e';
      }
    }
    _selectedImages.clear();
    exitSelectionMode();
    return results;
  }

  Future<void> _loadImages() async {
    _setLoading(true);
    _errorMessage = null;

    try {
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

      _images = imageFiles;
    } catch (e) {
      _errorMessage = 'Failed to load images: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
