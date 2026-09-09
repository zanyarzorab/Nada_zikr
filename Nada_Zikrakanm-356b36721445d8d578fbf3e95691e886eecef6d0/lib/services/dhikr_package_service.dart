
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/azkar_model.dart';
import '../models/app_data.dart';
import 'quran_dua_service.dart';

class DhikrPackageService {
  DhikrPackageService._();

  static final DhikrPackageService instance = DhikrPackageService._();
  Map<int, List<Azkar>>? _categories;

  Future<List<Azkar>> loadCategory(String categoryId) async {
    if (categoryId == 'quran') {
      try {
        final duas = await QuranDuaService.loadAllDuas();
        return duas.map((d) => d.toAzkar()).toList();
      } catch (_) {
        return AppData.quranAzkar;
      }
    }

    if (categoryId == 'prayer') {
      try {
        final raw =
            await rootBundle.loadString('assets/dhikr/after_prayer.json');
        final data = json.decode(raw) as Map<String, dynamic>;
        final items = (data['adhkar'] ?? data['items']) as List<dynamic>;
        final result = <Azkar>[];

        for (final item in items) {
          final map = item as Map<String, dynamic>;
          if (map.containsKey('items') && map['items'] is List) {
            final subItems = map['items'] as List<dynamic>;
            for (int s = 0; s < subItems.length; s++) {
              final subMap = subItems[s] as Map<String, dynamic>;
              result.add(
                Azkar(
                  id: (map['id'] is int ? (map['id'] as int) * 100 : 1200) + s,
                  arabic: subMap['arabic']?.toString() ?? '',
                  translation: subMap['translation_en']?.toString() ??
                      subMap['transliteration']?.toString() ??
                      '',
                  kurdishTranslation: subMap['translation_ku']?.toString() ?? '',
                  repeat: subMap['count_regular'] is int
                      ? subMap['count_regular']
                      : int.tryParse(subMap['count_regular']?.toString() ?? '1') ?? 1,
                  source: subMap['surah']?.toString() ?? map['title_ku']?.toString() ?? 'سوورەت',
                ),
              );
            }
          } else {
            result.add(
              Azkar(
                id: map['id'] is int
                    ? map['id']
                    : int.tryParse(map['id']?.toString() ?? '0'),
                arabic: map['arabic']?.toString() ?? '',
                translation: map['translation_en']?.toString() ??
                    map['transliteration']?.toString() ??
                    '',
                kurdishTranslation: map['translation_ku']?.toString() ?? '',
                repeat: map['count'] is int
                    ? map['count']
                    : int.tryParse(map['count']?.toString() ?? '1') ?? 1,
                source: map['title_ku']?.toString() ?? map['title_ar']?.toString() ?? 'دوای نوێژ',
              ),
            );
          }
        }
        return result;
      } catch (_) {
        return AppData.prayerAzkar;
      }
    }

    final fallback =
        categoryId == 'evening' ? AppData.eveningAzkar : AppData.morningAzkar;
    try {
      final categories = await _loadCategories();
      final packageCategoryId = categoryId == 'evening' ? 28 : 27;
      return categories[packageCategoryId] ?? fallback;
    } on Exception {
      return fallback;
    }
  }

  Future<Map<int, List<Azkar>>> _loadCategories() async {
    if (_categories != null) return _categories!;

    final raw =
        await rootBundle.loadString('node_modules/imanikurd/data/dhikr.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final grouped = <int, List<Azkar>>{};

    for (final item in (data['items'] as List<dynamic>)) {
      final map = item as Map<String, dynamic>;
      final categoryId = int.tryParse(map['categoryId'].toString());
      if (categoryId != 27 && categoryId != 28) continue;

      final safeCategoryId = categoryId!;
      final id = int.tryParse(map['id'].toString());
      final arabic = map['arabic']?.toString().trim() ?? '';
      final kurdish = map['kurdish']?.toString().trim() ?? '';
      if (id == null || arabic.isEmpty || kurdish.isEmpty) continue;

      // Avoid duplicate morning card for "La ilaha illallah..." (ID 92 and 93 are duplicate narrations)
      if (safeCategoryId == 27 && id == 92) continue;

      final entries = _buildEntries(
        id: id,
        categoryId: safeCategoryId,
        arabic: arabic,
        kurdish: kurdish,
        rawCount: map['count'],
      );

      (grouped[safeCategoryId] ??= []).addAll(entries);
    }

    _categories = grouped;
    return grouped;
  }

  List<Azkar> _buildEntries({
    required int id,
    required int categoryId,
    required String arabic,
    required String kurdish,
    required dynamic rawCount,
  }) {
    final splitSurahs = _extractThreeSurahBlocks(arabic);
    if (splitSurahs.isNotEmpty) {
      return List.generate(splitSurahs.length, (index) {
        final itemArabic = splitSurahs[index];
        final surahMeaning = _surahMeaningFor(itemArabic);

        return Azkar(
          id: _splitEntryId(id, index),
          arabic: itemArabic,
          translation: surahMeaning['en'] ?? '',
          kurdishTranslation: surahMeaning['ku'] ?? '',
          repeat: 3,
          source: 'imanikurd',
        );
      });
    }

    final repeat = _normalizeRepeatCount(
      arabic,
      int.tryParse(rawCount?.toString() ?? '') ?? 1,
    );

    final isAyatKursi = arabic.contains('الْحَيُّ الْقَيُّومُ') && arabic.contains('سِنَةٌ');
    final finalKurdish = isAyatKursi
        ? 'خوا ئه‌و خوایه‌یه‌ که هیچ په‌رستراوێکی ڕاسته‌قینه‌ نییه‌ بێجگه له‌و، هه‌میشه‌ زیندووه‌ و ڕاگری هه‌موو بوونه‌وه‌ره، نه‌ وه‌نه‌وز و خه‌واڵوویی ده‌یگرێت و نه‌ خه‌و. هه‌رچی له‌ ئاسمانه‌کان و هه‌رچی له‌ زه‌ویدایه‌ هه‌ر هی ئه‌وه‌. کێیه ئه‌و که‌سه‌ی بتوانێت تکا و شه‌فاعه‌ت له‌لای ئه‌و بکات مه‌گه‌ر به‌ مۆڵه‌تی خۆی؟ ئاگاداره به هه‌موو ئه‌وه‌ی له‌به‌رده‌میانه‌ و ئه‌وه‌ی له‌پشتیانه‌، و که‌س هیچ شتێک له زانستی ئه‌و نازانێت مه‌گه‌ر به‌وه‌ی خۆی بیه‌وێت. کورسییه‌که‌ی هه‌موو ئاسمانه‌کان و زه‌وی گرتۆته‌وه و پاراستنی ئاسمانه‌کان و زه‌وی هیچ ماندووی ناکات؛ و هه‌ر ئه‌وه‌ پله‌به‌رز و گه‌وره‌ و پایه‌دار. [البقرة: 255]'
        : kurdish;

    final enTranslation = isAyatKursi
        ? 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is [presently] before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great. [Al-Baqarah: 255]'
        : _findEnglishTranslation(arabic, categoryId);

    return [
      Azkar(
        id: id,
        arabic: arabic,
        translation: enTranslation,
        kurdishTranslation: finalKurdish,
        repeat: repeat,
        source: isAyatKursi ? 'ئایەتی کورسی [البقرة: 255]' : 'imanikurd',
      ),
    ];
  }

  String _findEnglishTranslation(String arabic, int categoryId) {
    final cleanArabic = _stripArabicDiacritics(arabic);
    if (cleanArabic.isEmpty) return '';

    final searchList = categoryId == 28
        ? [...AppData.eveningAzkar, ...AppData.morningAzkar, ...AppData.sleepAzkar]
        : [...AppData.morningAzkar, ...AppData.eveningAzkar, ...AppData.sleepAzkar];

    for (final item in searchList) {
      if (item.translation.trim().isEmpty) continue;
      final cleanItem = _stripArabicDiacritics(item.arabic);
      if (cleanItem.isEmpty) continue;

      final len = cleanItem.length > 20 ? 20 : cleanItem.length;
      final prefix = cleanItem.substring(0, len);
      if (cleanArabic.contains(prefix)) {
        return item.translation;
      }
    }
    return '';
  }

  static String _stripArabicDiacritics(String input) {
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
  }

  List<String> _extractThreeSurahBlocks(String arabic) {
    final normalized = arabic.replaceAll('\u00A0', ' ');
    final surahBlocks = RegExp(r'﴿.*?﴾')
        .allMatches(normalized)
        .map((match) => match.group(0) ?? '')
        .where((text) => text.isNotEmpty)
        .toList();

    if (surahBlocks.length < 3) return const [];

    final hasEkhlas = normalized.contains('قُلْ هُوَ اللَّهُ أَحَدٌ');
    final hasFalaq = normalized.contains('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ');
    final hasNas = normalized.contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ');

    if (hasEkhlas && hasFalaq && hasNas) {
      return surahBlocks;
    }

    return const [];
  }

  int _splitEntryId(int baseId, int index) {
    return baseId * 10 + index;
  }

  Map<String, String> _surahMeaningFor(String arabic) {
    final normalized = arabic.replaceAll(RegExp(r'\s+'), ' ');

    if (normalized.contains('قُلْ هُوَ اللَّهُ أَحَدٌ') || normalized.contains('الإخلاص')) {
      return {
        'en': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.\nSay: He is Allah, [who is] One. Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent. [Al-Ikhlas: 1-4]',
        'ku': 'بە ناوی خوای بەخشندەی میهرەبان.\nبڵێ: ئه‌و خوایه‌ی که ناوی الله‌ خوایه‌کی تاک و ته‌نهایه‌ (بێ هاوه‌ڵ و هاوتایه‌). خوا زاتێکی پایه‌دار و ده‌سه‌ڵاتداره، بێ‌نیازه و هه‌موو دروستکراوان پێویستیان پێیه‌تی. نه‌ که‌سی لێ بووه‌ و نه‌ خۆشی له که‌س بووه‌. و هه‌رگیز هیچ هاوتا و هاوشێوه‌یه‌کی بۆ نه‌بووه و نییه‌. [الإخلاص: 1-4]',
      };
    }

    if (normalized.contains('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ') || normalized.contains('الفلق')) {
      return {
        'en': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.\nSay: I seek refuge in the Lord of daybreak From the evil of that which He created, And from the evil of darkness when it settles, And from the evil of the blowers in knots, And from the evil of an envier when he envies. [Al-Falaq: 1-5]',
        'ku': 'بە ناوی خوای بەخشندەی میهرەبان.\nبڵێ: په‌نا ده‌گرم به په‌روه‌ردگاری به‌ره‌به‌یان، له شه‌ڕ و خراپه‌ی هه‌موو ئه‌و شتانه‌ی دروستی کردوون، و له شه‌ڕ و خراپه‌ی تاریکی شه‌و کاتێک دادێت، و له شه‌ڕ و خراپه‌ی ئه‌و جادووگه‌رانه‌ی پف ده‌که‌ن له گرێیه‌کاندا، و له شه‌ڕ و خراپه‌ی حه‌سوود کاتێک حه‌سوودی ده‌بات. [الفلق: 1-5]',
      };
    }

    if (normalized.contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ') || normalized.contains('الناس')) {
      return {
        'en': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.\nSay: I seek refuge in the Lord of mankind, The Sovereign of mankind, The God of mankind, From the evil of the retreating whisperer - Who whispers into the breasts of mankind - From among the jinn and mankind. [An-Nas: 1-6]',
        'ku': 'بە ناوی خوای بەخشندەی میهرەبان.\nبڵێ: په‌نا ده‌گرم به په‌روه‌ردگاری خه‌ڵکی، پادشا و خاوه‌نداری خه‌ڵکی، په‌رستراوی حه‌قیقی خه‌ڵکی، له شه‌ڕ و خراپه‌ی وه‌سوه‌سه‌ده‌ری پاشه‌کشه‌که‌ری خۆشاره‌وه‌ (شه‌یتان)، ئه‌وه‌ی که وه‌سوه‌سه ده‌خاته دڵ و سینه‌ی خه‌ڵکییه‌وه‌، چ له جنۆکه‌ بێت یان له مرۆڤ. [الناس: 1-6]',
      };
    }

    return {'en': '', 'ku': ''};
  }

  int _normalizeRepeatCount(String arabic, int fallback) {
    final normalized = arabic.replaceAll(RegExp(r'\s+'), ' ');

    if (normalized.contains('قُلْ هُوَ اللَّهُ أَحَدٌ') ||
        normalized.contains('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ') ||
        normalized.contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ')) {
      return 3;
    }

    if (normalized.contains('ثلاث مرات') ||
        normalized.contains('سێ جار') ||
        normalized.contains('three times')) {
      return 3;
    }

    if (normalized.contains('سبع مرات') ||
        normalized.contains('حەوت جار') ||
        normalized.contains('seven times')) {
      return 7;
    }

    if (normalized.contains('مائة مرة') ||
        normalized.contains('سەد جار') ||
        normalized.contains('hundred times')) {
      return 100;
    }

    if (normalized.contains('أربع مرات') ||
        normalized.contains('چوار جار') ||
        normalized.contains('four times')) {
      return 4;
    }

    if (normalized.contains('عشر مرات') ||
        normalized.contains('دە جار') ||
        normalized.contains('ten times')) {
      return 10;
    }

    return fallback;
  }
}
