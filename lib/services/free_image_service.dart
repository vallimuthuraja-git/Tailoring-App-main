import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreeImageService {
  static const String _imgurClientId = 'your_imgur_client_id'; // Replace with your Imgur client ID
  static const String _imgurUploadUrl = 'https://api.imgur.com/3/upload';

  // For demo purposes - using placeholder images
  static const Map<String, String> _demoImages = {
    'suit': 'https://via.placeholder.com/400x400/667eea/ffffff?text=Custom+Suit',
    'lehenga': 'https://via.placeholder.com/400x400/764ba2/ffffff?text=Wedding+Lehenga',
    'shirt': 'https://via.placeholder.com/400x400/667eea/ffffff?text=Business+Shirt',
    'gown': 'https://via.placeholder.com/400x400/764ba2/ffffff?text=Evening+Gown',
    'alteration': 'https://via.placeholder.com/400x400/667eea/ffffff?text=Suit+Alteration',
  };

  /// Get demo image URL for a product type
  static String getDemoImageUrl(String productType) {
    final key = productType.toLowerCase();
    if (_demoImages.containsKey(key)) {
      return _demoImages[key]!;
    }
    // Return a default placeholder
    return 'https://via.placeholder.com/400x400/667eea/ffffff?text=Tailoring+Service';
  }

  /// Upload image to free service (Imgur - requires API key)
  static Future<String?> uploadToImgur(File imageFile) async {
    try {
      if (_imgurClientId == 'your_imgur_client_id') {
        // If no API key, return demo image
        return getDemoImageUrl('default');
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_imgurUploadUrl),
        headers: {
          'Authorization': 'Client-ID $_imgurClientId',
        },
        body: {
          'image': base64Image,
          'type': 'base64',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data']['link'];
        }
      }

      return null;
    } catch (e) {
      debugdebugPrint('Error uploading to Imgur: $e');
      return null;
    }
  }

  /// Save image locally (for demo purposes)
  static Future<String?> saveLocally(File imageFile, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/images';
      final localDir = Directory(localPath);

      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }

      final newFile = File('$localPath/$fileName');
      await imageFile.copy(newFile.path);

      // For demo, return a placeholder URL since we can't serve local files
      return getDemoImageUrl('default');
    } catch (e) {
      debugdebugPrint('Error saving locally: $e');
      return null;
    }
  }

  /// Store image URL mapping locally
  static Future<void> storeImageMapping(String imageId, String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('image_$imageId', imageUrl);
    } catch (e) {
      debugdebugPrint('Error storing image mapping: $e');
    }
  }

  /// Get stored image URL
  static Future<String?> getStoredImageUrl(String imageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('image_$imageId');
    } catch (e) {
      debugdebugPrint('Error getting stored image: $e');
      return null;
    }
  }

  /// Delete stored image mapping
  static Future<void> deleteImageMapping(String imageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('image_$imageId');
    } catch (e) {
      debugdebugPrint('Error deleting image mapping: $e');
    }
  }

  /// Get all stored image mappings
  static Future<Map<String, String>> getAllImageMappings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPrefs = prefs.getKeys();
      final imageMappings = <String, String>{};

      for (final key in allPrefs) {
        if (key.startsWith('image_')) {
          final imageId = key.replaceFirst('image_', '');
          final url = prefs.getString(key);
          if (url != null) {
            imageMappings[imageId] = url;
          }
        }
      }

      return imageMappings;
    } catch (e) {
      debugdebugPrint('Error getting all image mappings: $e');
      return {};
    }
  }

  /// Clean up old image mappings
  static Future<void> cleanupOldImages(List<String> keepImageIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPrefs = prefs.getKeys();

      for (final key in allPrefs) {
        if (key.startsWith('image_')) {
          final imageId = key.replaceFirst('image_', '');
          if (!keepImageIds.contains(imageId)) {
            await prefs.remove(key);
          }
        }
      }
    } catch (e) {
      debugdebugPrint('Error cleaning up images: $e');
    }
  }

  /// Get optimized image URL (for different sizes)
  static String getOptimizedImageUrl(String baseUrl, {int width = 400, int height = 400}) {
    // For placeholder images, we can modify the URL to get different sizes
    if (baseUrl.contains('via.placeholder.com')) {
      return baseUrl.replaceAll(
        RegExp(r'\d+x\d+'),
        '${width}x$height'
      );
    }

    // For other services, return the original URL
    return baseUrl;
  }

  /// Check if image URL is valid
  static Future<bool> isImageUrlValid(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get fallback image URL if original fails
  static String getFallbackImageUrl(String productType) {
    return getDemoImageUrl(productType);
  }

  /// Batch upload images (for multiple product images)
  static Future<List<String>> uploadMultipleImages(List<File> images) async {
    final uploadedUrls = <String>[];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final fileName = 'product_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

      // Try Imgur first, then local storage, then demo image
      String? imageUrl = await uploadToImgur(file);

      imageUrl ??= await saveLocally(file, fileName);

      if (imageUrl != null) {
        uploadedUrls.add(imageUrl);
      } else {
        // Use demo image as fallback
        uploadedUrls.add(getDemoImageUrl('default'));
      }
    }

    return uploadedUrls;
  }

  /// Delete image from storage
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      // For demo purposes, we can't actually delete from remote services
      // But we can remove from local storage
      if (imageUrl.contains('placeholder.com')) {
        return true; // Demo images are always "available"
      }

      // Remove from local mappings
      final prefs = await SharedPreferences.getInstance();
      final allPrefs = prefs.getKeys();

      for (final key in allPrefs) {
        if (key.startsWith('image_')) {
          final storedUrl = prefs.getString(key);
          if (storedUrl == imageUrl) {
            await prefs.remove(key);
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      debugdebugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Get storage usage statistics
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final mappings = await getAllImageMappings();

      return {
        'totalImages': mappings.length,
        'usingDemoImages': mappings.values.where((url) => url.contains('placeholder.com')).length,
        'usingLocalImages': mappings.values.where((url) => !url.contains('placeholder.com') && !url.contains('imgur.com')).length,
        'usingRemoteImages': mappings.values.where((url) => url.contains('imgur.com')).length,
        'imageMappings': mappings,
      };
    } catch (e) {
      debugdebugPrint('Error getting storage stats: $e');
      return {
        'totalImages': 0,
        'usingDemoImages': 0,
        'usingLocalImages': 0,
        'usingRemoteImages': 0,
        'imageMappings': {},
      };
    }
  }
}

