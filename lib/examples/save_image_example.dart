import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';

class SaveImageExample extends StatefulWidget {
  const SaveImageExample({super.key});

  @override
  State<SaveImageExample> createState() => _SaveImageExampleState();
}

class _SaveImageExampleState extends State<SaveImageExample> {
  final StorageService _storageService = StorageService();
  String? _savedFilePath;
  String? _statusMessage;
  bool _isLoading = false;

  Future<void> _pickAndSaveImage() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Picking image...';
    });

    try {
      // Pick an image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        setState(() {
          _statusMessage = 'No image selected';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _statusMessage = 'Saving image...';
      });

      // Create a unique filename
      final String fileName =
          'gallery_app_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Save to app-specific directory (works on all Android versions)
      final String appDirPath = await _storageService.saveFileToAppDirectory(
        File(image.path),
        fileName,
      );

      // Try to save to public directory (behavior varies by Android version)
      final String? publicPath = await _storageService
          .saveFileToPublicDirectory(
            File(image.path),
            fileName,
            folderName: 'Pictures/GalleryApp',
          );

      setState(() {
        _savedFilePath = publicPath ?? appDirPath;
        _statusMessage = 'Image saved successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save Image Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _pickAndSaveImage,
                child: const Text('Pick and Save Image'),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(_statusMessage!),
                ),
              if (_savedFilePath != null) ...[
                const SizedBox(height: 20),
                const Text('Saved Image:'),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_savedFilePath!),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Path: $_savedFilePath',
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
