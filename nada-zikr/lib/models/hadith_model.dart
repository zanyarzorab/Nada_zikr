/// Model representing an authentic Prophetic Hadith
class HadithItem {
  final int id;
  final String chapter;
  final String chapterEn;
  final String narratorAr;
  final String textAr;
  final String textKu;
  final String textEn;
  final String source;
  final String grade;

  const HadithItem({
    required this.id,
    required this.chapter,
    this.chapterEn = '',
    required this.narratorAr,
    required this.textAr,
    required this.textKu,
    this.textEn = '',
    required this.source,
    required this.grade,
  });

  factory HadithItem.fromJson(Map<String, dynamic> json) {
    return HadithItem(
      id: json['id'] as int? ?? 0,
      chapter: json['chapter'] as String? ?? '',
      chapterEn: json['chapter_en'] as String? ?? '',
      narratorAr: json['narrator_ar'] as String? ?? '',
      textAr: json['text_ar'] as String? ?? '',
      textKu: json['text_ku'] as String? ?? '',
      textEn: json['text_en'] as String? ?? '',
      source: json['source'] as String? ?? '',
      grade: json['grade'] as String? ?? 'صحيح',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapter': chapter,
        'chapter_en': chapterEn,
        'narrator_ar': narratorAr,
        'text_ar': textAr,
        'text_ku': textKu,
        'text_en': textEn,
        'source': source,
        'grade': grade,
      };

  String getChapter(String lang) {
    if (lang == 'en' && chapterEn.isNotEmpty) return chapterEn;
    return chapter;
  }

  String getText(String lang) {
    if (lang == 'en' && textEn.isNotEmpty) return textEn;
    return textKu;
  }
}
