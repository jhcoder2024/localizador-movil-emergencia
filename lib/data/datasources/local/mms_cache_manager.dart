import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class MmsCacheManager {
  static const _cacheDir = 'mms_cache';

  static Future<Directory> _getCacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_cacheDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static String _extensionFor(String contentType) {
    switch (contentType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/gif':
        return 'gif';
      case 'image/webp':
        return 'webp';
      default:
        return 'jpg';
    }
  }

  static Future<String> saveImage(int mmsId, int partIndex, String base64Data, String contentType) async {
    try {
      final dir = await _getCacheDir();
      final ext = _extensionFor(contentType);
      final file = File('${dir.path}/${mmsId}_$partIndex.$ext');
      final bytes = base64Decode(base64Data);
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('[MmsCache] Error saving image: $e');
      return '';
    }
  }

  static Future<List<File>> getImages(int mmsId) async {
    try {
      final dir = await _getCacheDir();
      final pattern = '${mmsId}_';
      final files = await dir.list().toList();
      final matching = files.whereType<File>().where((f) => f.path.contains(pattern)).toList();
      matching.sort((a, b) => a.path.compareTo(b.path));
      return matching;
    } catch (e) {
      debugPrint('[MmsCache] Error loading images: $e');
      return [];
    }
  }

  static Future<void> clearAll() async {
    try {
      final dir = await _getCacheDir();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[MmsCache] Error clearing cache: $e');
    }
  }
}
