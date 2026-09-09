import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hadith_model.dart';

/// Service for loading and querying authentic Hadiths
class HadithService {
  static List<HadithItem>? _cachedHadiths;

  /// Loads all 100 authentic hadiths from bundled asset
  static Future<List<HadithItem>> loadAllHadiths() async {
    if (_cachedHadiths != null && _cachedHadiths!.isNotEmpty) {
      return _cachedHadiths!;
    }
    try {
      final jsonString = await rootBundle.loadString('assets/hadith/hadiths.json');
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        _cachedHadiths = decoded
            .map((item) => HadithItem.fromJson(item as Map<String, dynamic>))
            .toList();
        return _cachedHadiths!;
      }
    } catch (e) {
      // Fallback
    }
    return [];
  }

  /// Returns list of distinct chapters present in the dataset
  static Future<List<String>> getChapters() async {
    final list = await loadAllHadiths();
    final chapters = <String>{};
    for (final h in list) {
      if (h.chapter.isNotEmpty) {
        chapters.add(h.chapter);
      }
    }
    return chapters.toList();
  }

  /// Selects a daily Hadith rotated by day-of-year
  static HadithItem? getHadithOfTheDay(List<HadithItem> hadiths) {
    if (hadiths.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = int.parse("${now.difference(DateTime(now.year, 1, 1)).inDays}");
    final index = dayOfYear % hadiths.length;
    return hadiths[index];
  }
}
