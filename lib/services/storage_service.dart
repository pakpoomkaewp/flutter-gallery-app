import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageService {
  // Check if the app has storage permission
  Future<bool> requestStoragePermission() async {
    // Permission is automatically granted on iOS and newer Android versions
    // For Android < Q (Android 10, API 29), we need to request permission
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        return result == PermissionStatus.granted;
      }
      return true;
    }
    return true; // iOS or other platforms
  }

  // Save a file to app-specific directory (works on all Android versions)
  Future<String> saveFileToAppDirectory(File file, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName';
      final savedFile = await file.copy(path);
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving file to app directory: $e');
      rethrow;
    }
  }

  // Save a file to public directory (needs different handling across Android versions)
  Future<String?> saveFileToPublicDirectory(
    File file,
    String fileName, {
    required String folderName,
  }) async {
    // On all Android versions, first check permission
    bool hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      return null;
    }

    try {
      if (Platform.isAndroid) {
        if (await _isAndroid10OrAbove()) {
          // Use the SAF or MediaStore approach for Android 10+
          // This is a simplified implementation - for a complete solution,
          // you would need to use a method channel or a plugin that supports MediaStore

          // For demonstration, we'll save to app-specific external storage
          final directory = await getExternalStorageDirectory();
          if (directory != null) {
            final path = '${directory.path}/$folderName/$fileName';

            // Create the directory if it doesn't exist
            final folder = Directory('${directory.path}/$folderName');
            if (!(await folder.exists())) {
              await folder.create(recursive: true);
            }

            final savedFile = await file.copy(path);
            return savedFile.path;
          }
        } else {
          // Traditional approach for Android 9 and below
          final directory = await getExternalStorageDirectory();
          if (directory != null) {
            // This path is typically /storage/emulated/0/Android/data/your.package.name/files
            // To save to public directories like Pictures, you'd use a different path
            final publicPath = directory.path.replaceAll(
              RegExp(r'Android/data/.*?/files'),
              folderName,
            );

            final folder = Directory(publicPath);
            if (!(await folder.exists())) {
              await folder.create(recursive: true);
            }

            final path = '$publicPath/$fileName';
            final savedFile = await file.copy(path);
            return savedFile.path;
          }
        }
      } else if (Platform.isIOS) {
        // iOS implementation
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final savedFile = await file.copy(path);
        return savedFile.path;
      }
    } catch (e) {
      debugPrint('Error saving file to public directory: $e');
    }
    return null;
  }

  // Helper method to determine if running on Android 10 or above
  Future<bool> _isAndroid10OrAbove() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      return sdkInt >= 29; // Android 10 is API level 29
    }
    return false;
  }

  // Get Android SDK version
  Future<int> _getAndroidSdkVersion() async {
    // This is a placeholder - in a real app, you would use a method channel
    // to get the actual SDK version from the Android platform

    // For demonstration purposes only:
    try {
      // You can implement a method channel here to get the actual SDK version
      // For now, we'll just return a value based on the build.gradle.kts minSdk
      return 30; // This is just a placeholder - replace with actual logic
    } catch (e) {
      debugPrint('Error getting Android SDK version: $e');
      return 21; // Fallback to minimum SDK version
    }
  }
}
