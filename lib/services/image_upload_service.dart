import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class ImageUploadService {
  static const String _imgurClientId = 'your_imgur_client_id'; // Replace with your Imgur client ID
  static const String _imgurUploadUrl = 'https://api.imgur.com/3/upload';

  // Demo images for fallback
  static const Map<String, String> _demoImages = {
    'suit': 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400&h=400&fit=crop&crop=center',
    'lehenga': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&h=400&fit=crop&crop=center',
    'shirt': 'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=400&h=400&fit=crop&crop=center',
    'gown': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&h=400&fit=crop&crop=center',
    'alteration': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=400&fit=crop&crop=center',
    'default': 'https://images.unsplash.com/photo-1595341888016-a392ef81b7de?w=400&h=400&fit=crop&crop=center',
  };

  /// Pick image from gallery or camera
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugdebugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<XFile>?> pickMultipleImages({int maxImages = 5}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      // Limit the number of images
      if (images.length > maxImages) {
        return images.sublist(0, maxImages);
      }

      return images;
    } catch (e) {
      debugdebugPrint('Error picking multiple images: $e');
      return null;
    }
  }

  /// Upload single image to service
  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      // For web, we need to handle the file differently
      if (kIsWeb) {
        return await _uploadToWebService(imageFile);
      } else {
        return await _uploadToMobileService(imageFile);
      }
    } catch (e) {
      debugdebugPrint('Error uploading image: $e');
      return getDemoImageUrl('default');
    }
  }

  /// Upload multiple images
  static Future<List<String>> uploadMultipleImages(List<XFile> images) async {
    final uploadedUrls = <String>[];

    for (final image in images) {
      final url = await uploadImage(image);
      if (url != null) {
        uploadedUrls.add(url);
      } else {
        // Add demo image as fallback
        uploadedUrls.add(getDemoImageUrl('default'));
      }
    }

    return uploadedUrls;
  }

  /// Upload to web-compatible service
  static Future<String?> _uploadToWebService(XFile imageFile) async {
    try {
      // Try Imgur first (requires API key)
      if (_imgurClientId != 'your_imgur_client_id') {
        final imgurUrl = await _uploadToImgurWeb(imageFile);
        if (imgurUrl != null) {
          return imgurUrl;
        }
      }

      // Fallback to demo images
      return getDemoImageUrl('default');
    } catch (e) {
      debugdebugPrint('Error uploading to web service: $e');
      return getDemoImageUrl('default');
    }
  }

  /// Upload to mobile-compatible service
  static Future<String?> _uploadToMobileService(XFile imageFile) async {
    try {
      // Try Imgur first
      if (_imgurClientId != 'your_imgur_client_id') {
        final imgurUrl = await _uploadToImgurMobile(imageFile);
        if (imgurUrl != null) {
          return imgurUrl;
        }
      }

      // Fallback to demo images
      return getDemoImageUrl('default');
    } catch (e) {
      debugdebugPrint('Error uploading to mobile service: $e');
      return getDemoImageUrl('default');
    }
  }

  /// Upload to Imgur for web
  static Future<String?> _uploadToImgurWeb(XFile imageFile) async {
    try {
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
      debugdebugPrint('Error uploading to Imgur web: $e');
      return null;
    }
  }

  /// Upload to Imgur for mobile
  static Future<String?> _uploadToImgurMobile(XFile imageFile) async {
    try {
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
      debugdebugPrint('Error uploading to Imgur mobile: $e');
      return null;
    }
  }

  /// Get demo image URL for a product type
  static String getDemoImageUrl(String productType) {
    final key = productType.toLowerCase();
    if (_demoImages.containsKey(key)) {
      return _demoImages[key]!;
    }
    return _demoImages['default']!;
  }

  /// Get optimized image URL for different sizes
  static String getOptimizedImageUrl(String baseUrl, {int width = 400, int height = 400}) {
    // For Unsplash images, we can modify the URL parameters
    if (baseUrl.contains('unsplash.com')) {
      final uri = Uri.parse(baseUrl);
      final params = Map<String, String>.from(uri.queryParameters);
      params['w'] = width.toString();
      params['h'] = height.toString();
      params['fit'] = 'crop';
      params['crop'] = 'center';

      final newUri = uri.replace(queryParameters: params);
      return newUri.toString();
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

  /// Get image file size in MB
  static Future<double> getImageFileSize(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return bytes.lengthInBytes / (1024 * 1024); // Convert to MB
    } catch (e) {
      return 0.0;
    }
  }

  /// Validate image before upload
  static Future<String?> validateImage(XFile imageFile) async {
    try {
      // Check file size (max 10MB)
      final fileSize = await getImageFileSize(imageFile);
      if (fileSize > 10.0) {
        return 'Image size too large. Please select an image under 10MB.';
      }

      // Check file extension
      final fileName = imageFile.name.toLowerCase();
      if (!fileName.endsWith('.jpg') &&
          !fileName.endsWith('.jpeg') &&
          !fileName.endsWith('.png') &&
          !fileName.endsWith('.gif') &&
          !fileName.endsWith('.webp')) {
        return 'Please select a valid image file (JPG, PNG, GIF, WebP).';
      }

      return null; // No errors
    } catch (e) {
      return 'Error validating image: $e';
    }
  }
}

