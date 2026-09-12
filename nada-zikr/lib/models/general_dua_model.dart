import 'azkar_model.dart';

class GeneralDuaItem {
  final int id;
  final String category;
  final String title;
  final String arabic;
  final String easyTajweed;
  final String kurdishMeaning;
  final String englishMeaning;
  final String hadithSource;

  const GeneralDuaItem({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.easyTajweed,
    required this.kurdishMeaning,
    required this.englishMeaning,
    required this.hadithSource,
  });

  factory GeneralDuaItem.fromJson(Map<String, dynamic> json) {
    return GeneralDuaItem(
      id: json['id'] as int? ?? 0,
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      easyTajweed: json['easy_tajweed'] as String? ?? '',
      kurdishMeaning: json['kurdish_meaning'] as String? ?? '',
      englishMeaning: json['english_meaning'] as String? ?? '',
      hadithSource: json['hadith_source'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'arabic': arabic,
        'easy_tajweed': easyTajweed,
        'kurdish_meaning': kurdishMeaning,
        'english_meaning': englishMeaning,
        'hadith_source': hadithSource,
      };

  /// Returns clean localized category title
  String getCategoryTitle(String lang) {
    if (category.isEmpty) return lang == 'ku' ? 'دوعای گشتی' : 'General Dua';
    if (category.contains('(') && category.contains(')')) {
      final parts = category.split('(');
      final enPart = parts[0].trim();
      final kuPart = parts[1].replaceAll(')', '').trim();
      if (lang == 'ku') return kuPart.isNotEmpty ? kuPart : enPart;
      return enPart.isNotEmpty ? enPart : kuPart;
    }
    return category;
  }

  /// Returns clean localized title
  String getDisplayTitle(String lang) {
    if (title.isEmpty) return lang == 'ku' ? 'دوعای پێغەمبەر ﷺ' : 'Prophetic Dua ﷺ';
    if (title.contains('(') && title.contains(')')) {
      final parts = title.split('(');
      final enPart = parts[0].trim();
      final kuPart = parts[1].replaceAll(')', '').trim();
      if (lang == 'ku') return kuPart.isNotEmpty ? kuPart : enPart;
      return enPart.isNotEmpty ? enPart : kuPart;
    }
    return title;
  }

  /// Convert to Azkar object for player, cards, or legacy interfaces
  Azkar toAzkar({int repeat = 1}) {
    return Azkar(
      id: id,
      arabic: arabic,
      translation: englishMeaning,
      kurdishTranslation: kurdishMeaning,
      repeat: repeat,
      source: hadithSource,
    );
  }
}
