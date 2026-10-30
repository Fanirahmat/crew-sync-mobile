import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

/// Service managing camera capture and client-side image compression.
class ImageService {
  final ImagePicker _picker;

  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Captures selfie using front camera and compresses to lightweight JPEG
  Future<File?> captureSelfie() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (pickedFile == null) return null;

      final compressedFile = await compressImage(File(pickedFile.path));
      return compressedFile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ImageService] Error capturing selfie: $e');
      }
      return null;
    }
  }

  /// Captures logistics/evidence photo using rear camera and compresses to lightweight JPEG
  Future<File?> captureEvidence() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (pickedFile == null) return null;

      final compressedFile = await compressImage(File(pickedFile.path));
      return compressedFile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ImageService] Error capturing evidence: $e');
      }
      return null;
    }
  }

  /// Compresses image to JPEG with quality 75% targeting max ~300KB
  Future<File> compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: AppConstants.imageCompressionQuality,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        if (kDebugMode) {
          final originalSize = await file.length();
          final compressedSize = await compressedFile.length();
          debugPrint(
            '[ImageService] Compressed from ${(originalSize / 1024).round()}KB to ${(compressedSize / 1024).round()}KB',
          );
        }
        return compressedFile;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ImageService] Compression failed, returning original file: $e');
      }
    }
    return file;
  }
}
