import 'azkar_model.dart';

/// Model representing a Quranic Supplication (Dua) from the Holy Quran
class QuranDuaItem {
  final int id;
  final String surah;
  final String ayah;
  final String arabic;
  final String easyTajweed;
  final String kurdishMeaning;
  final String englishMeaning;

  const QuranDuaItem({
    required this.id,
    required this.surah,
    required this.ayah,
    required this.arabic,
    required this.easyTajweed,
    required this.kurdishMeaning,
    this.englishMeaning = '',
  });

  factory QuranDuaItem.fromJson(Map<String, dynamic> json) {
    return QuranDuaItem(
      id: json['id'] as int? ?? 0,
      surah: json['surah'] as String? ?? '',
      ayah: json['ayah'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      easyTajweed: json['easy_tajweed'] as String? ?? '',
      kurdishMeaning:
          (json['asan_tafsir'] ?? json['kurdish_meaning'] ?? '') as String,
      englishMeaning:
          (json['english'] ?? json['english_meaning'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'surah': surah,
        'ayah': ayah,
        'arabic': arabic,
        'easy_tajweed': easyTajweed,
        'kurdish_meaning': kurdishMeaning,
        'english': englishMeaning,
      };

  /// Returns Kurdish formatted Surah title
  String get surahNameKu {
    final map = {
      'Al-Fatihah': 'سوورەتی الفاتحة',
      'Al-Baqarah': 'سوورەتی البقرة',
      "Ali 'Imran": 'سوورەتی آل عمران',
      'An-Nisa': 'سوورەتی النساء',
      "Al-Ma'idah": 'سوورەتی المائدة',
      "Al-A'raf": 'سوورەتی الأعراف',
      'Yunus': 'سوورەتی یونس',
      'Hud': 'سوورەتی هود',
      'Yusuf': 'سوورەتی یوسف',
      'Ibrahim': 'سوورەتی إبراهیم',
      'Al-Isra': 'سوورەتی الإسراء',
      'Al-Kahf': 'سوورەتی الكهف',
      'Maryam': 'سوورەتی مریم',
      'Ta-Ha': 'سوورەتی طه',
      'Al-Anbiya': 'سوورەتی الأنبیاء',
      "Al-Mu'minun": 'سوورەتی المؤمنون',
      'Al-Furqan': 'سوورەتی الفرقان',
      "Ash-Shu'ara": 'سوورەتی الشعراء',
      'An-Naml': 'سوورەتی النمل',
      'Al-Qasas': 'سوورەتی القصص',
      'Al-Ankabut': 'سوورەتی العنكبوت',
      'As-Saffat': 'سوورەتی الصافات',
      'Sad': 'سوورەتی ص',
      'Ghafir': 'سوورەتی غافر',
      'Al-Ahqaf': 'سوورەتی الأحقاف',
      'Al-Qamar': 'سوورەتی القمر',
      'Al-Hashr': 'سوورەتی الحشر',
      'Al-Mumtahanah': 'سوورەتی الممتحنة',
      'At-Tahrim': 'سوورەتی التحریم',
      'Nuh': 'سوورەتی نوح',
    };
    return map[surah] ?? 'سوورەتی $surah';
  }

  /// Returns Arabic formatted Surah title
  String get surahNameAr {
    final map = {
      'Al-Fatihah': 'سورة الفاتحة',
      'Al-Baqarah': 'سورة البقرة',
      "Ali 'Imran": 'سورة آل عمران',
      'An-Nisa': 'سورة النساء',
      "Al-Ma'idah": 'سورة المائدة',
      "Al-A'raf": 'سورة الأعراف',
      'Yunus': 'سورة يونس',
      'Hud': 'سورة هود',
      'Yusuf': 'سورة يوسف',
      'Ibrahim': 'سورة إبراهيم',
      'Al-Isra': 'سورة الإسراء',
      'Al-Kahf': 'سورة الكهف',
      'Maryam': 'سورة مريم',
      'Ta-Ha': 'سورة طه',
      'Al-Anbiya': 'سورة الأنبياء',
      "Al-Mu'minun": 'سورة المؤمنون',
      'Al-Furqan': 'سورة الفرقان',
      "Ash-Shu'ara": 'سورة الشعراء',
      'An-Naml': 'سورة النمل',
      'Al-Qasas': 'سورة القصص',
      'Al-Ankabut': 'سورة العنكبوت',
      'As-Saffat': 'سورة الصافات',
      'Sad': 'سورة ص',
      'Ghafir': 'سورة غافر',
      'Al-Ahqaf': 'سورة الأحقاف',
      'Al-Qamar': 'سورة القمر',
      'Al-Hashr': 'سورة الحشر',
      'Al-Mumtahanah': 'سورة الممتحنة',
      'At-Tahrim': 'سورة التحريم',
      'Nuh': 'سورة نوح',
    };
    return map[surah] ?? 'سورة $surah';
  }

  /// Surah index number in the Holy Quran (1 to 114)
  int get surahNumber {
    if (ayah.contains(':')) {
      final parts = ayah.split(':');
      final sNum = int.tryParse(parts[0].trim());
      if (sNum != null && sNum > 0) return sNum;
    }
    final map = {
      'Al-Fatihah': 1,
      'Al-Baqarah': 2,
      "Ali 'Imran": 3,
      'An-Nisa': 4,
      "Al-Ma'idah": 5,
      "Al-A'raf": 7,
      'Yunus': 10,
      'Hud': 11,
      'Yusuf': 12,
      'Ibrahim': 14,
      'Al-Isra': 17,
      'Al-Kahf': 18,
      'Maryam': 19,
      'Ta-Ha': 20,
      'Al-Anbiya': 21,
      "Al-Mu'minun": 23,
      'Al-Furqan': 25,
      "Ash-Shu'ara": 26,
      'An-Naml': 27,
      'Al-Qasas': 28,
      'Al-Ankabut': 29,
      'As-Saffat': 37,
      'Sad': 38,
      'Ghafir': 40,
      'Al-Ahqaf': 46,
      'Al-Qamar': 54,
      'Al-Hashr': 59,
      'Al-Mumtahanah': 60,
      'At-Tahrim': 66,
      'Nuh': 71,
    };
    return map[surah] ?? 1;
  }

  /// Initial Ayah index number in the Surah
  int get ayahNumber {
    if (ayah.contains(':')) {
      final parts = ayah.split(':');
      if (parts.length > 1) {
        final ayahPart = parts[1].trim();
        final cleanAyah = ayahPart.split('-')[0].trim();
        final aNum = int.tryParse(cleanAyah);
        if (aNum != null && aNum > 0) return aNum;
      }
    }
    return 1;
  }

  /// Convert to Azkar item for reading screens and visual card generator
  Azkar toAzkar() {
    return Azkar(
      id: id,
      arabic: arabic,
      translation: englishMeaning,
      kurdishTranslation: kurdishMeaning,
      repeat: 1,
      source: '$surahNameKu • ئایەتی $ayah',
    );
  }
}
