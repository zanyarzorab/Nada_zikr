import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

/// Maps our local reciter IDs to QuranCDN chapter-reciter IDs.
/// Only reciters available on api.qurancdn.com are mapped here.
/// Others will fall back to proportional estimation.
const Map<String, int> kQuranCdnReciterIds = {
  'alafasy': 7,
  'abdulbasit': 2,
  'sudais': 3,
  'shatri': 4, // Abu Bakr al-Shatri
  'husary': 6,
  'minshawi': 9,
  'dosari': 97,
};

const String _kBaseUrl = 'https://api.qurancdn.com/api/qdc/audio/reciters';

/// Service to fetch exact per-ayah timestamps from the QuranCDN API.
/// Timestamps are cached in memory and Hive to avoid redundant network calls.
class QuranTimingService {
  QuranTimingService._();
  static final QuranTimingService instance = QuranTimingService._();

  /// Fast in-memory cache: "timing_${reciterId}_${surahNumber}_${ayahNumber}" -> ms
  final Map<String, int> _memoryCache = {};

  int? _timestampFrom(Map<String, dynamic> json) {
    final value = json['timestamp_from'] ?? json['result']?['timestamp_from'];
    return value is int ? value : int.tryParse(value?.toString() ?? '');
  }

  /// Returns the exact start time in milliseconds for a given ayah
  /// within the full-chapter audio file for the given reciter.
  ///
  /// Returns null if the reciter is not supported or the fetch fails.
  Future<int?> getAyahTimestampMs({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final cdnId = kQuranCdnReciterIds[reciterId];
    if (cdnId == null) return null; // Reciter not on QuranCDN

    // 1. Fast in-memory lookup
    final cacheKey = 'timing_${reciterId}_${surahNumber}_$ayahNumber';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey];
    }

    // 2. Persistent storage lookup
    final cached = await StorageService.readSetting(cacheKey);
    if (cached is int) {
      _memoryCache[cacheKey] = cached;
      return cached;
    }

    // 3. Fetch from API
    try {
      final url = Uri.parse(
        '$_kBaseUrl/$cdnId/timestamp?chapter_number=$surahNumber&verse_key=$surahNumber:$ayahNumber',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final tsFrom = _timestampFrom(json as Map<String, dynamic>);
        if (tsFrom != null) {
          _memoryCache[cacheKey] = tsFrom;
          await StorageService.saveSetting(cacheKey, tsFrom);
          return tsFrom;
        }
      }
    } catch (_) {
      // Network failure — fall through to null
    }
    return null;
  }

  /// Returns the chapter audio file used by QuranCDN's ayah timestamps.
  Future<String?> getMatchingAudioUrl({
    required String reciterId,
    required int surahNumber,
  }) async {
    final cdnId = kQuranCdnReciterIds[reciterId];
    if (cdnId == null) return null;

    final cacheKey = 'audio_url_${reciterId}_$surahNumber';
    final cached = await StorageService.readSetting(cacheKey);
    if (cached is String && cached.isNotEmpty) return cached;

    try {
      final url = Uri.parse(
        '$_kBaseUrl/$cdnId/audio_files?chapter_number=$surahNumber',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final files = json['audio_files'] as List?;
        final audioUrl = files?.firstWhere(
          (item) => item is Map && item['audio_url'] is String,
          orElse: () => null,
        );
        if (audioUrl is Map && audioUrl['audio_url'] is String) {
          final value = audioUrl['audio_url'] as String;
          await StorageService.saveSetting(cacheKey, value);
          return value;
        }
      }
    } catch (_) {
      // Network failure: caller falls back to the configured chapter URL.
    }
    return null;
  }

  /// Fetches ALL ayah timestamps for a surah in a single batch API call.
  /// Returns Map<ayahNumber, timestampMs>. Empty map if unavailable.
  ///
  /// The QuranCDN batch endpoint returns all verses at once:
  /// GET /api/qdc/audio/reciters/{id}/timestamp?chapter_number=N
  Future<Map<int, int>> getAllTimestamps({
    required String reciterId,
    required int surahNumber,
    required int totalAyahs,
  }) async {
    final cdnId = kQuranCdnReciterIds[reciterId];
    if (cdnId == null) return {};

    // Check if we already have all ayahs cached
    final batchKey = 'timing_batch_${reciterId}_$surahNumber';
    final cachedBatch = await StorageService.readSetting(batchKey);
    if (cachedBatch is Map) {
      final result = <int, int>{};
      cachedBatch.forEach((k, v) {
        final ayahNum = int.tryParse(k.toString());
        final ms = v is int ? v : int.tryParse(v.toString());
        if (ayahNum != null && ms != null) {
          result[ayahNum] = ms;
          _memoryCache['timing_${reciterId}_${surahNumber}_$ayahNum'] = ms;
        }
      });
      if (result.length >= totalAyahs) return result;
    }

    // Try batch endpoint
    try {
      final url = Uri.parse(
        '$_kBaseUrl/$cdnId/timestamp?chapter_number=$surahNumber',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = <int, int>{};

        // Format 1 & 2: check verse_timings in result, audio_files, or root
        final verseTimings = (json['result']?['verse_timings'] ??
            json['verse_timings'] ??
            json['audio_files']) as List?;
        if (verseTimings != null) {
          for (final item in verseTimings) {
            if (item is Map) {
              final key = (item['verse_key'] ?? item['verseKey'])?.toString();
              final ts = item['timestamp_from'] ?? item['timestampFrom'];
              final tsInt = ts is int ? ts : int.tryParse(ts?.toString() ?? '');
              if (key != null && tsInt != null) {
                final parts = key.split(':');
                if (parts.length == 2) {
                  final ayahNum = int.tryParse(parts[1]);
                  if (ayahNum != null) {
                    result[ayahNum] = tsInt;
                    _memoryCache['timing_${reciterId}_${surahNumber}_$ayahNum'] = tsInt;
                  }
                }
              }
            }
          }
        }

        if (result.isNotEmpty) {
          // Cache as map of "ayahNum" -> ms
          final cacheMap = <String, int>{};
          result.forEach((k, v) => cacheMap[k.toString()] = v);
          await StorageService.saveSetting(batchKey, cacheMap);
          // Also cache individual keys
          for (final entry in result.entries) {
            final cacheKey = 'timing_${reciterId}_${surahNumber}_${entry.key}';
            await StorageService.saveSetting(cacheKey, entry.value);
          }
          return result;
        }
      }
    } catch (_) {
      // Batch failed — fall through to individual fetching
    }

    final result = <int, int>{};
    const batchSize = 8;
    for (var start = 1; start <= totalAyahs; start += batchSize) {
      final end = (start + batchSize - 1).clamp(1, totalAyahs);
      final fetched = await Future.wait(
        List.generate(end - start + 1, (index) async {
          final ayah = start + index;
          final timestamp = await getAyahTimestampMs(
            reciterId: reciterId,
            surahNumber: surahNumber,
            ayahNumber: ayah,
          );
          return MapEntry(ayah, timestamp);
        }),
      );
      for (final entry in fetched) {
        if (entry.value != null) result[entry.key] = entry.value!;
      }
    }
    if (result.length >= totalAyahs) {
      final cacheMap = <String, int>{};
      result.forEach((key, value) => cacheMap[key.toString()] = value);
      await StorageService.saveSetting(batchKey, cacheMap);
    }
    return result;
  }

  /// Pre-fetches and caches all ayah timestamps for an entire surah.
  /// Calls are batched with small delays to be kind to the server.
  /// This is called in the background after a surah loads.
  Future<void> prefetchSurahTimings({
    required String reciterId,
    required int surahNumber,
    required int totalAyahs,
  }) async {
    final cdnId = kQuranCdnReciterIds[reciterId];
    if (cdnId == null) return;

    // Try batch first
    final batch = await getAllTimestamps(
      reciterId: reciterId,
      surahNumber: surahNumber,
      totalAyahs: totalAyahs,
    );
    if (batch.length >= totalAyahs) return; // All ayahs are cached

    for (int ayah = 1; ayah <= totalAyahs; ayah++) {
      final cacheKey = 'timing_${reciterId}_${surahNumber}_$ayah';
      final cached = await StorageService.readSetting(cacheKey);
      if (cached is int) continue; // Already cached

      try {
        final url = Uri.parse(
          '$_kBaseUrl/$cdnId/timestamp?chapter_number=$surahNumber&verse_key=$surahNumber:$ayah',
        );
        final response =
            await http.get(url).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final tsFrom = _timestampFrom(json as Map<String, dynamic>);
          if (tsFrom != null) {
            await StorageService.saveSetting(cacheKey, tsFrom);
          }
        }
        // Small delay to avoid hammering the API
        await Future.delayed(const Duration(milliseconds: 80));
      } catch (_) {
        // Skip this ayah on failure
      }
    }
  }

  /// Whether this reciter has API-based timing support.
  bool supportsExactTiming(String reciterId) {
    return kQuranCdnReciterIds.containsKey(reciterId);
  }
}
