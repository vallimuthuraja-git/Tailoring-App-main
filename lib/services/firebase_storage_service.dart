// Firebase Storage Service for image uploads
// Handles secure image uploads with progress tracking and error handling

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload single image to Firebase Storage with progress tracking
  Future<String?> uploadImage(
    dynamic imageFile, {
    // Using dynamic to avoid XFile import issues on web
    String folder = 'services',
    Function(double)? onProgress,
    required String serviceId,
  }) async {
    try {
      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.name.split('.').last;
      final fileName = '${timestamp}_${imageFile.name.hashCode}.$extension';
      final path = '$folder/$serviceId/$fileName';

      final ref = _storage.ref().child(path);

      // Upload task for progress tracking
      UploadTask uploadTask;

      // Web-only implementation - since we disabled mobile packages
      final bytes = await imageFile.readAsBytes();
      uploadTask = ref.putData(bytes);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() => null);

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Image uploaded successfully: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  /// Upload multiple images with progress tracking
  Future<List<String>> uploadMultipleImages(
    List<dynamic> imageFiles, {
    // Using dynamic to avoid XFile import issues on web
    String folder = 'services',
    Function(double)? onProgress,
    Function(int, int)? onImageComplete,
    required String serviceId,
  }) async {
    final uploadedUrls = <String>[];
    int completedCount = 0;
    double totalProgress = 0.0;

    for (int i = 0; i < imageFiles.length; i++) {
      final imageFile = imageFiles[i];

      final url = await uploadImage(
        imageFile,
        folder: folder,
        serviceId: serviceId,
        onProgress: (progress) {
          // Calculate overall progress
          final currentTotal = totalProgress + progress;
          final overallProgress = currentTotal / imageFiles.length;
          onProgress?.call(overallProgress);
        },
      );

      if (url != null) {
        uploadedUrls.add(url);
      }

      completedCount++;
      totalProgress += 1.0; // Each completed upload counts as 1.0 progress unit
      onImageComplete?.call(completedCount, imageFiles.length);
    }

    return uploadedUrls;
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract path from download URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the 'o/' segment which comes before the actual path
      int oIndex = pathSegments.indexOf('o');
      if (oIndex == -1) return false;

      // The remaining segments form the storage path
      final storagePath = pathSegments.sublist(oIndex + 1).join('/');

      // Decode the URL-encoded path
      final decodedPath = Uri.decodeFull(storagePath);

      await _storage.ref().child(decodedPath).delete();
      debugPrint('Image deleted successfully: $decodedPath');

      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Delete multiple images from Firebase Storage
  Future<bool> deleteMultipleImages(List<String> imageUrls) async {
    bool allDeleted = true;

    for (final url in imageUrls) {
      final deleted = await deleteImage(url);
      if (!deleted) {
        allDeleted = false;
      }
    }

    return allDeleted;
  }

  /// Get optimized download URL for different sizes
  Future<String?> getOptimizedUrl(
    String downloadUrl, {
    int? width,
    int? height,
    int? quality,
  }) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);

      // Create download URL with parameters
      final params = <String>[];
      if (width != null) params.add('w=$width');
      if (height != null) params.add('h=$height');
      if (quality != null && quality > 0 && quality <= 100) {
        params.add('q=$quality');
      }

      if (params.isNotEmpty) {
        return '$downloadUrl${params.isNotEmpty ? '?' : ''}${params.join('&')}';
      }

      return downloadUrl;
    } catch (e) {
      debugPrint('Error creating optimized URL: $e');
      return downloadUrl;
    }
  }

  /// Check if image URL is valid and accessible
  Future<bool> isImageUrlValid(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.getDownloadURL(); // This will throw if invalid
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get image metadata
  Future<Map<String, dynamic>?> getImageMetadata(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      final metadata = await ref.getMetadata();

      return {
        'size': metadata.size,
        'contentType': metadata.contentType,
        'updated': metadata.updated,
        'bucket': metadata.bucket,
        'generation': metadata.generation,
        'metageneration': metadata.metageneration,
      };
    } catch (e) {
      debugPrint('Error getting image metadata: $e');
      return null;
    }
  }

  /// Create a reference from URL for advanced operations
  Reference? getReferenceFromUrl(String url) {
    try {
      return _storage.refFromURL(url);
    } catch (e) {
      debugPrint('Error creating reference from URL: $e');
      return null;
    }
  }

  /// List all files in a folder
  Future<List<Reference>> listFilesInFolder(String folderPath) async {
    try {
      final result = await _storage.ref().child(folderPath).listAll();
      return result.items;
    } catch (e) {
      debugPrint('Error listing files in folder: $e');
      return [];
    }
  }

  /// Move/copy image to different location
  Future<String?> moveImage(String sourceUrl, String destinationPath) async {
    try {
      final sourceRef = _storage.refFromURL(sourceUrl);
      final destinationRef = _storage.ref().child(destinationPath);

      // Get data from source
      final data = await sourceRef.getData();

      // Upload to destination
      await destinationRef.putData(data!);

      // Delete the original
      await sourceRef.delete();

      // Get new download URL
      final newUrl = await destinationRef.getDownloadURL();
      return newUrl;
    } catch (e) {
      debugPrint('Error moving image: $e');
      return null;
    }
  }

  /// Batch upload with concurrent operations for better performance
  Future<List<String>> batchUploadImages(
    List<dynamic> imageFiles, {
    // Using dynamic to avoid XFile import issues on web
    String folder = 'services',
    int maxConcurrent = 3,
    Function(double)? onProgress,
    Function(int, int)? onImageComplete,
    required String serviceId,
  }) async {
    final results = <Future<String?>>[];
    final uploadedUrls = <String>[];

    // Process images in batches
    for (int i = 0; i < imageFiles.length; i += maxConcurrent) {
      final batch = imageFiles.sublist(
        i,
        i + maxConcurrent > imageFiles.length
            ? imageFiles.length
            : i + maxConcurrent,
      );

      final batchFutures = batch
          .map((imageFile) => uploadImage(
                imageFile,
                folder: folder,
                serviceId: serviceId,
              ))
          .toList();

      final batchResults = await Future.wait(batchFutures);

      for (final url in batchResults) {
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      onProgress?.call((uploadedUrls.length / imageFiles.length));
      onImageComplete?.call(uploadedUrls.length, imageFiles.length);
    }

    return uploadedUrls;
  }
}
