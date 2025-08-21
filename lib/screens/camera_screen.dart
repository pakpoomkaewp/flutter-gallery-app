import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    // IMPORTANT: Dispose of the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null || !_controller!.value.isInitialized) {
      // Show a loading indicator while the camera is initializing
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Gallery',
        ),
        title: const Text('Camera'),
        actions: [
          IconButton(
            icon: Icon(_getFlashIcon()),
            onPressed: _toggleFlash,
            tooltip: 'Toggle Flash',
          ),
        ],
      ),
      body: CameraPreview(_controller!),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      // Handle case where no cameras are available
      print("No cameras found");
      return;
    }

    _controller = CameraController(
      _cameras![0], // Use the first available camera (usually the back one)
      ResolutionPreset.high,
    );

    await _controller!.initialize();
    if (!mounted) return;

    setState(() {
      _isReady = true;
    });
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      return;
    }
    try {
      final XFile picture = await _controller!.takePicture();
      print('Picture saved to ${picture.path}');

      // 1. Get the application's private documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();

      // 2. Create a unique filename
      final String filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = path.join(appDir.path, filename);

      // 3. Copy the file to the new path
      await picture.saveTo(newPath);

      print('Picture saved permanently to $newPath');

      // Optional: Show a confirmation to the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Photo saved!')));
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      // Cycle through flash modes: off -> auto -> always -> torch -> off
      FlashMode newFlashMode;
      switch (_flashMode) {
        case FlashMode.off:
          newFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newFlashMode = FlashMode.always;
          break;
        case FlashMode.always:
          newFlashMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          newFlashMode = FlashMode.off;
          break;
      }

      await _controller!.setFlashMode(newFlashMode);

      setState(() {
        _flashMode = newFlashMode;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.flashlight_on;
    }
  }
}
