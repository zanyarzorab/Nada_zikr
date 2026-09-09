import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quran_dua_model.dart';
import 'storage_service.dart';

/// Service for loading, searching, and managing Quranic Duas
class QuranDuaService {
  static List<QuranDuaItem>? _cachedDuas;
  static const String _favoritePrefKey = 'quran_duas_favorites';

  /// Loads all 70 Quranic Duas from bundled assets
  static Future<List<QuranDuaItem>> loadAllDuas() async {
    if (_cachedDuas != null && _cachedDuas!.isNotEmpty) {
      return _cachedDuas!;
    }
    try {
      final jsonString =
          await rootBundle.loadString('assets/quran/quran_duas.json');
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic> && decoded['duas'] is List) {
        final list = decoded['duas'] as List<dynamic>;
        _cachedDuas = list
            .map((item) => QuranDuaItem.fromJson(item as Map<String, dynamic>))
            .toList();
        return _cachedDuas!;
      }
    } catch (_) {}
    return [];
  }

  /// Selects a daily Quranic Dua rotated deterministically by day-of-year
  static QuranDuaItem? getDuaOfTheDay(List<QuranDuaItem> duas) {
    if (duas.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear =
        int.parse("${now.difference(DateTime(now.year, 1, 1)).inDays}");
    final index = dayOfYear % duas.length;
    return duas[index];
  }

  /// Get set of favorite dua IDs
  static Future<Set<int>> getFavoriteIds() async {
    try {
      final raw = await StorageService.readSetting(_favoritePrefKey, defaultValue: <dynamic>[]);
      if (raw is List) {
        return raw.map((e) => int.tryParse(e.toString()) ?? 0).where((id) => id > 0).toSet();
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Toggle favorite status for a dua
  static Future<bool> toggleFavorite(int duaId) async {
    try {
      final favs = await getFavoriteIds();
      final isFav = favs.contains(duaId);
      if (isFav) {
        favs.remove(duaId);
      } else {
        favs.add(duaId);
      }
      await StorageService.saveSetting(_favoritePrefKey, favs.toList());
      return !isFav;
    } catch (_) {
      return false;
    }
  }
}
