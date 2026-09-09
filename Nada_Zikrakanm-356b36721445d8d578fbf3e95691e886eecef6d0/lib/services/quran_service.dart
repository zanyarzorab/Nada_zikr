import 'dart:convert';
import 'package:flutter/services.dart';

class QuranSurahMeta {
  final int number;
  final String arabicName;
  final String kurdishName;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  QuranSurahMeta({
    required this.number,
    required this.arabicName,
    required this.kurdishName,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory QuranSurahMeta.fromJson(Map<String, dynamic> json) {
    return QuranSurahMeta(
      number: json['number'] as int,
      arabicName: json['name'] as String? ?? '',
      kurdishName: json['kurdishName'] as String? ?? '',
      englishName: json['englishName'] as String? ?? '',
      englishNameTranslation: json['englishNameTranslation'] as String? ?? '',
      numberOfAyahs: json['numberOfAyahs'] as int? ?? 0,
      revelationType: json['revelationType'] as String? ?? '',
    );
  }
}

class QuranAyah {
  final int surah;
  final int ayah;
  final String text;

  const QuranAyah({required this.surah, required this.ayah, required this.text});
}

class TafsirOption {
  final String id;
  final String label;

  const TafsirOption({required this.id, required this.label});
}

/// Curated Sorani-friendly sources, ordered for everyday reading.
const List<TafsirOption> kQuranTafsirOptions = [
  TafsirOption(id: 'hazhar',    label: 'هەژار'),
  TafsirOption(id: 'maisar',    label: 'مویەسسەر'),
  TafsirOption(id: 'roshn',     label: 'ڕۆشن'),
  TafsirOption(id: 'mokhtasar', label: 'موختەسەر'),
  TafsirOption(id: 'rebar',     label: 'ڕێبەر'),
  TafsirOption(id: 'tawhid',    label: 'تەوحید'),
  TafsirOption(id: 'asan',      label: 'ئاسان'),
  TafsirOption(id: 'puxta',     label: 'پۆختە'),
  TafsirOption(id: 'raman',     label: 'ڕامان'),
  TafsirOption(id: 'zhin',      label: 'ژین'),
  TafsirOption(id: 'runahi',    label: 'ڕوناهی'),
  TafsirOption(id: 'sanahi',    label: 'سەنەهی'),
  TafsirOption(id: 'krd',       label: 'کوردی'),
  TafsirOption(id: 'sign',      label: 'زمانی ئاماژە 🤟'),
];

/// Parses a bundled tafsir JSON array into a surah -> ayah -> text index.
/// Strips HTML, ZWNJ (disconnected-letter encoding), and embedded Arabic markers.
Map<int, Map<int, String>> parseTafsirIndex(String raw) {
  final List<dynamic> list = json.decode(raw) as List<dynamic>;
  final Map<int, Map<int, String>> index = {};
  for (final dynamic item in list) {
    final map = item as Map<String, dynamic>;
    final surah = int.tryParse(map['s'].toString()) ?? 0;
    final ayah = map['a'] is int ? map['a'] as int : int.tryParse(map['a'].toString()) ?? 0;
    final raw = map['t'] as String? ?? '';
    (index[surah] ??= {})[ayah] = _cleanTafsirText(raw);
  }
  return index;
}

// Remove HTML tags, ZWNJ, and [Arabic (n)] / {Arabic} markers embedded in some tafsirs.
String _cleanTafsirText(String t) {
  // strip HTML tags
  t = t.replaceAll(RegExp(r'<[^>]*>'), '');
  // strip embedded Arabic ayah markers like [بِسْمِ (1)] and {Arabic}
  t = t.replaceAll(RegExp(r'[\[\{][\u0600-\u06FF\s\u064B-\u065F()٠-٩0-9]+[\]\}]'), '');
  // Convert legacy Kurdish characters before removing their joiner markers.
  t = t.replaceAll('ك', 'ک').replaceAll('ي', 'ی').replaceAll('ى', 'ی');
  t = t.replaceAll('ه‌', 'ە');
  // strip zero-width non-joiner (causes disconnected Hawar letters)
  t = t.replaceAll('\u200C', '');
  t = t.replaceAll('ئەوکەسانە', 'ئەو کەسانە').replaceAll('خواو', 'خوا و');
  // collapse multiple spaces/newlines
  t = t.replaceAll(RegExp(r'[ \t]{2,}'), ' ').trim();
  return t;
}

class QuranService {
  QuranService._();
  static final QuranService instance = QuranService._();

  List<QuranSurahMeta>? _surahs;
  Map<int, List<QuranAyah>>? _ayahsBySurah;

  final Map<String, Map<int, Map<int, String>>> _tafsirCache = {};
  final List<String> _tafsirLoadOrder = [];
  static const int _maxCachedTafsirs = 3;

  Future<void> _ensureQuranLoaded() async {
    if (_surahs != null && _ayahsBySurah != null) return;

    final raw = await rootBundle.loadString('assets/quran/quran.json');
    final data = json.decode(raw) as Map<String, dynamic>;

    final surahsJson = data['surahs'] as List<dynamic>;
    _surahs = surahsJson
        .map((s) => QuranSurahMeta.fromJson(s as Map<String, dynamic>))
        .toList(growable: false);

    final ayahsJson = data['ayahs'] as List<dynamic>;
    final grouped = <int, List<QuranAyah>>{};
    for (final dynamic a in ayahsJson) {
      final map = a as Map<String, dynamic>;
      final ayah = QuranAyah(
        surah: map['surah'] as int,
        ayah: map['ayah'] as int,
        text: map['text'] as String? ?? '',
      );
      (grouped[ayah.surah] ??= []).add(ayah);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => a.ayah.compareTo(b.ayah));
    }
    _ayahsBySurah = grouped;
  }

  Future<List<QuranSurahMeta>> loadSurahs() async {
    await _ensureQuranLoaded();
    return _surahs!;
  }

  Future<List<QuranAyah>> loadAyahsForSurah(int surahNumber) async {
    await _ensureQuranLoaded();
    return _ayahsBySurah![surahNumber] ?? const [];
  }

  Future<Map<int, String>?> _loadTafsirIndexForSurah(String tafsirId, int surahNumber) async {
    Map<int, Map<int, String>>? cached = _tafsirCache[tafsirId];
    if (cached == null) {
      final raw = await rootBundle.loadString('assets/quran/tafsir/tafsir_$tafsirId.json');
      final Map<int, Map<int, String>> parsed = parseTafsirIndex(raw);
      _tafsirCache[tafsirId] = parsed;
      cached = parsed;

      _tafsirLoadOrder.remove(tafsirId);
      _tafsirLoadOrder.add(tafsirId);
      while (_tafsirLoadOrder.length > _maxCachedTafsirs) {
        final evicted = _tafsirLoadOrder.removeAt(0);
        _tafsirCache.remove(evicted);
      }
    } else {
      _tafsirLoadOrder.remove(tafsirId);
      _tafsirLoadOrder.add(tafsirId);
    }
    return cached[surahNumber];
  }

  Future<String?> getTafsir(String tafsirId, int surahNumber, int ayahNumber) async {
    if (tafsirId == 'sign') {
      return '__SIGN_LANGUAGE_MODE__';
    }
    final surahIndex = await _loadTafsirIndexForSurah(tafsirId, surahNumber);
    return surahIndex?[ayahNumber];
  }
}
