import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class GalleryProvider extends ChangeNotifier {
  List<File> _images = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<File> get images => _images;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasImages => _images.isNotEmpty;

  GalleryProvider() {
    _loadImages();
  }

  Future<void> refreshGallery() async {
    await _loadImages();
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
