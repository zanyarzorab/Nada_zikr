class QuranReciter {
  final String id;
  final String nameAr;
  final String nameEn;
  final String nameKu;
  final String cdnKey;
  final String style;
  final String audioUrlPattern;

  const QuranReciter({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameKu,
    required this.cdnKey,
    this.style = 'Murattal',
    required this.audioUrlPattern,
  });

  String localizedName(String lang) {
    if (lang == 'ku') return nameKu;
    if (lang == 'ar') return nameAr;
    return nameEn;
  }

  String getSurahUrl(int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    return audioUrlPattern
        .replaceAll('{padded}', padded)
        .replaceAll('{num}', surahNumber.toString());
  }
}

/// The first seven reciters have matching QuranCDN timing data for highlighting.
/// The remaining reciters have full-surah audio but no matching ayah timings.
const List<QuranReciter> kQuranReciters = [
  // Reciters with matching QuranCDN audio and ayah timestamps
  QuranReciter(
    id: 'alafasy',
    nameAr: 'مشاري راشد العفاسي',
    nameEn: 'Mishary Rashid Alafasy',
    nameKu: 'میشاری ڕەشید عەفاسی',
    cdnKey: 'ar.alafasy',
    audioUrlPattern: 'https://server8.mp3quran.net/afs/{padded}.mp3',
  ),
  QuranReciter(
    id: 'abdulbasit',
    nameAr: 'عبد الباسط عبد الصمد',
    nameEn: 'Abdul Basit Abdul Samad',
    nameKu: 'عەبدولباسیت عەبدولسەمەد',
    cdnKey: 'ar.abdulbasitmurattal',
    audioUrlPattern: 'https://server7.mp3quran.net/basit/{padded}.mp3',
  ),
  QuranReciter(
    id: 'sudais',
    nameAr: 'عبد الرحمن السديس',
    nameEn: 'Abdur-Rahman As-Sudais',
    nameKu: 'عەبدولڕەحمان ئەلسودەیس',
    cdnKey: 'ar.sudais',
    audioUrlPattern: 'https://server11.mp3quran.net/sds/{padded}.mp3',
  ),
  QuranReciter(
    id: 'husary',
    nameAr: 'محمود خليل الحصري',
    nameEn: 'Mahmoud Khalil Al-Husary',
    nameKu: 'مەحمود خەلیل حوسەری',
    cdnKey: 'ar.husary',
    audioUrlPattern: 'https://server13.mp3quran.net/husr/{padded}.mp3',
  ),
  QuranReciter(
    id: 'shatri',
    nameAr: 'أبو بكر الشاطري',
    nameEn: 'Abu Bakr Al-Shatri',
    nameKu: 'ئەبوبەکر ئەلشاتری',
    cdnKey: 'ar.shaatree',
    audioUrlPattern: 'https://server11.mp3quran.net/shatri/{padded}.mp3',
  ),
  QuranReciter(
    id: 'minshawi',
    nameAr: 'محمد صديق المنشاوي',
    nameEn: 'Muhammad Siddiq Al-Minshawi',
    nameKu: 'مەمەد سدیق ئەلمنشاوی',
    cdnKey: 'ar.minshawi',
    audioUrlPattern: 'https://server10.mp3quran.net/minsh/{padded}.mp3',
  ),
  QuranReciter(
    id: 'dosari',
    nameAr: 'ياسر الدوسري',
    nameEn: 'Yasser Al-Dosari',
    nameKu: 'یاسر ئەلدۆسەری',
    cdnKey: 'ar.yasserdossari',
    audioUrlPattern: 'https://server11.mp3quran.net/yasser/{padded}.mp3',
  ),
  QuranReciter(
    id: 'raad_kurdi',
    nameAr: 'رعد محمد الكردي',
    nameEn: 'Raad Al-Kurdi',
    nameKu: 'ڕەعد محەمەد کوردی',
    cdnKey: 'ar.kurdi',
    audioUrlPattern: 'https://server6.mp3quran.net/kurdi/{padded}.mp3',
  ),
  QuranReciter(
    id: 'peshawa_kurdi',
    nameAr: 'پیشەوا قادر الكردي',
    nameEn: 'Peshawa Qadr Al-Kurdi',
    nameKu: 'پێشەوا قادر کوردی',
    cdnKey: 'ar.peshawa',
    audioUrlPattern:
        'https://server16.mp3quran.net/peshawa/Rewayat-Hafs-A-n-Assem/{padded}.mp3',
  ),
  QuranReciter(
    id: 'maher_meaqli',
    nameAr: 'ماهر المعيقلي',
    nameEn: 'Maher Al-Muaiqly',
    nameKu: 'ماهر ئەلموعەیقلی',
    cdnKey: 'ar.maher',
    audioUrlPattern: 'https://server12.mp3quran.net/maher/{padded}.mp3',
  ),
  QuranReciter(
    id: 'saad_ghamdi',
    nameAr: 'سعد الغامدي',
    nameEn: 'Saad Al-Ghamdi',
    nameKu: 'سەعد ئەلغامدی',
    cdnKey: 'ar.s_gmd',
    audioUrlPattern: 'https://server7.mp3quran.net/s_gmd/{padded}.mp3',
  ),
  QuranReciter(
    id: 'shuraim',
    nameAr: 'سعود الشريم',
    nameEn: 'Saud Al-Shuraim',
    nameKu: 'سعود ئەلشورەیم',
    cdnKey: 'ar.shur',
    audioUrlPattern: 'https://server7.mp3quran.net/shur/{padded}.mp3',
  ),
  QuranReciter(
    id: 'ajmy',
    nameAr: 'أحمد العجمي',
    nameEn: 'Ahmad Al-Ajmy',
    nameKu: 'ئەحمەد ئەلعەجەمی',
    cdnKey: 'ar.ajmi',
    audioUrlPattern: 'https://server10.mp3quran.net/ajm/{padded}.mp3',
  ),
  QuranReciter(
    id: 'nauina',
    nameAr: 'أحمد نعينع',
    nameEn: 'Ahmad Al-Nauina',
    nameKu: 'ئەحمەد نەعینەع',
    cdnKey: 'ar.ahmad_nu',
    audioUrlPattern: 'https://server11.mp3quran.net/ahmad_nu/{padded}.mp3',
  ),
  QuranReciter(
    id: 'ali_jaber',
    nameAr: 'علي جابر',
    nameEn: 'Ali Jaber',
    nameKu: 'عەلی جابەر',
    cdnKey: 'ar.a_jbr',
    audioUrlPattern: 'https://server11.mp3quran.net/a_jbr/{padded}.mp3',
  ),
  QuranReciter(
    id: 'fares_abbad',
    nameAr: 'فارس عباد',
    nameEn: 'Fares Abbad',
    nameKu: 'فارس عەباد',
    cdnKey: 'ar.frs_a',
    audioUrlPattern: 'https://server8.mp3quran.net/frs_a/{padded}.mp3',
  ),
  QuranReciter(
    id: 'nasser_qatami',
    nameAr: 'ناصر القطامي',
    nameEn: 'Nasser Al-Qatami',
    nameKu: 'ناسەر ئەلقەتامی',
    cdnKey: 'ar.qtm',
    audioUrlPattern: 'https://server6.mp3quran.net/qtm/{padded}.mp3',
  ),
  QuranReciter(
    id: 'islam_sobhi',
    nameAr: 'إسلام صبحي',
    nameEn: 'Islam Sobhi',
    nameKu: 'ئیسلام سوبحی',
    cdnKey: 'ar.islam',
    audioUrlPattern:
        'https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem/{padded}.mp3',
  ),
  QuranReciter(
    id: 'mustafa_ismail',
    nameAr: 'مصطفى إسماعيل',
    nameEn: 'Mustafa Ismail',
    nameKu: 'موستەفا ئیسماعیل',
    cdnKey: 'ar.mustafa',
    audioUrlPattern: 'https://server8.mp3quran.net/mustafa/{padded}.mp3',
  ),
];
