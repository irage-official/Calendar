import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

/// Custom FileServiceResponse implementation for compressed images
class CompressedFileServiceResponse implements FileServiceResponse {
  final File _file;
  final DateTime _validTill;
  final int _contentLength;

  CompressedFileServiceResponse(
    this._file,
    this._validTill,
    this._contentLength,
  );

  @override
  Stream<List<int>> get content => _file.openRead();

  @override
  int? get contentLength => _contentLength;

  @override
  DateTime get validTill => _validTill;

  @override
  String? get eTag => null;

  @override
  int get statusCode => 200;

  @override
  String get fileExtension => 'jpg';
}

/// Custom file service that compresses images before caching
class CompressedImageFileService extends HttpFileService {
  // Target dimensions for compressed images
  static const int _maxWidth = 800;
  static const int _maxHeight = 600;
  static const int _quality = 85; // JPEG quality (0-100, 85 is good balance)

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    try {
      // Download image
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode != 200) {
        throw HttpException('Failed to download image: ${response.statusCode}');
      }

      // Decode and compress image
      final originalBytes = response.bodyBytes;
      final originalImage = img.decodeImage(originalBytes);
      
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if needed
      img.Image resizedImage = originalImage;
      if (originalImage.width > _maxWidth || originalImage.height > _maxHeight) {
        resizedImage = img.copyResize(
          originalImage,
          width: originalImage.width > _maxWidth ? _maxWidth : null,
          height: originalImage.height > _maxHeight ? _maxHeight : null,
          maintainAspect: true,
        );
      }

      // Compress as JPEG (smaller than PNG for photos)
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: _quality),
      );

      // Create temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        path.join(
          tempDir.path,
          'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      await tempFile.writeAsBytes(compressedBytes);

      return CompressedFileServiceResponse(
        tempFile,
        DateTime.now().add(const Duration(days: 7)),
        compressedBytes.length,
      );
    } catch (e) {
      debugPrint('Error compressing image in FileService: $e');
      // Fallback to default behavior
      return await super.get(url, headers: headers);
    }
  }
}

/// Custom cache manager with image compression
/// Compresses images to reduce cache size while maintaining acceptable quality
class CompressedImageCacheManager {
  static const String _cacheKey = 'compressedImageCache';
  static const int _maxCacheObjects = 50; // Maximum 50 images in cache
  static const Duration _stalePeriod = Duration(days: 7); // Images expire after 7 days

  static CacheManager? _instance;

  /// Get singleton instance of compressed cache manager
  static CacheManager getInstance() {
    _instance ??= CacheManager(
      Config(
        _cacheKey,
        maxNrOfCacheObjects: _maxCacheObjects,
        stalePeriod: _stalePeriod,
        repo: JsonCacheInfoRepository(databaseName: _cacheKey),
        fileService: CompressedImageFileService(),
      ),
    );
    return _instance!;
  }

  /// Download and compress image, then cache it
  /// Note: This method is kept for backward compatibility but compression
  /// is now handled automatically by CompressedImageFileService
  static Future<File?> getCompressedImageFile(String url) async {
    try {
      final cacheManager = getInstance();
      final fileInfo = await cacheManager.getFileFromCache(url);
      
      if (fileInfo != null && await fileInfo.file.exists()) {
        return fileInfo.file;
      }

      // Use cache manager to download and compress (handled by FileService)
      final file = await cacheManager.getSingleFile(url);
      return file;
    } catch (e) {
      debugPrint('Error getting compressed image: $e');
      return null;
    }
  }

  /// Get file name from URL
  static String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    final fileName = path.basename(uri.path);
    if (fileName.isEmpty || !fileName.contains('.')) {
      return '${uri.hashCode}.jpg';
    }
    return '${path.basenameWithoutExtension(fileName)}.jpg';
  }

  /// Clear all cached images
  static Future<void> clearCache() async {
    try {
      final cacheManager = getInstance();
      await cacheManager.emptyCache();
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }
  }

  /// Get cache size in bytes
  static Future<int> getCacheSize() async {
    try {
      final cacheManager = getInstance();
      final cacheDir = await getTemporaryDirectory();
      final cachePath = path.join(cacheDir.path, _cacheKey);
      final cacheDirectory = Directory(cachePath);
      
      if (!await cacheDirectory.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in cacheDirectory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('Error getting cache size: $e');
      return 0;
    }
  }

  /// Get formatted cache size string (e.g., "15.2 MB")
  static Future<String> getFormattedCacheSize() async {
    final size = await getCacheSize();
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

