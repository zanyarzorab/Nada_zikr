import 'azkar_model.dart';

class AppData {
  static const String goldColor = '#C9A84C';
  static const String creamColor = '#F0EBE0';
  static const String darkColor = '#071A12';
  static const String darkPanelColor = '#0D3527';

  static final List<Mood> moods = [
    Mood(
        id: 'grateful',
        label: 'شاكر',
        english: 'Grateful',
        kurdish: 'سوپاسگوزار',
        emoji: '🌿'),
    Mood(
        id: 'anxious',
        label: 'قلق',
        english: 'Anxious',
        kurdish: 'دڵەڕاوکێ',
        emoji: '☁️'),
    Mood(
        id: 'hopeful',
        label: 'متفائل',
        english: 'Hopeful',
        kurdish: 'بەهیوای باشە',
        emoji: '✨'),
    Mood(
        id: 'tired',
        label: 'متعب',
        english: 'Tired',
        kurdish: 'ماندوو',
        emoji: '🌙'),
    Mood(
        id: 'joyful',
        label: 'سعيد',
        english: 'Joyful',
        kurdish: 'دڵخۆش',
        emoji: '☀️'),
    Mood(
        id: 'sad',
        label: 'حزين',
        english: 'Sad',
        kurdish: 'خەمبار',
        emoji: '💧'),
  ];

  static final List<AzkarCategory> azkarCategories = [
    AzkarCategory(
      id: 'morning',
      label: 'أذكار الصباح',
      english: 'Morning Azkar',
      kurdish: 'زیکری بەیانیان',
      icon: '🌅',
      count: 24,
      color: '#C9A84C',
    ),
    AzkarCategory(
      id: 'evening',
      label: 'أذكار المساء',
      english: 'Evening Azkar',
      kurdish: 'زیکری ئێواران',
      icon: '🌆',
      count: 23,
      color: '#14B8A6',
    ),
    AzkarCategory(
      id: 'sleep',
      label: 'أذكار النوم',
      english: 'Before Sleep',
      kurdish: 'زیکری پێش خەوتن',
      icon: '🌙',
      count: 17,
      color: '#7C3AED',
    ),
    AzkarCategory(
      id: 'wakeup',
      label: 'أذكار الاستيقاظ',
      english: 'Waking Up',
      kurdish: 'زیکری هەستان لەخەو',
      icon: '🌄',
      count: 4,
      color: '#F59E0B',
    ),
    AzkarCategory(
      id: 'prayer',
      label: 'أذكار الصلاة',
      english: 'After Prayer',
      kurdish: 'زیکری دوای نوێژ',
      icon: '🕌',
      count: 14,
      color: '#059669',
    ),
    AzkarCategory(
      id: 'quran',
      label: 'أذكار القرآن',
      english: 'Quran Azkar',
      kurdish: 'دوعاکانی قورئانی پیرۆز',
      icon: '📖',
      count: 70,
      color: '#10B981',
    ),
    AzkarCategory(
      id: 'ayat_kursi',
      label: 'آية الكرسي',
      english: 'Ayat Al-Kursi',
      kurdish: 'ئایەتی کورسی',
      icon: '👑',
      count: 1,
      color: '#D97706',
    ),
    AzkarCategory(
      id: 'surah_mulk',
      label: 'سورة الملك',
      english: 'Surah Al-Mulk',
      kurdish: 'سوورەتی الملک (تبارك)',
      icon: '✨',
      count: 30,
      color: '#7C3AED',
    ),
    AzkarCategory(
      id: 'surah_kahf',
      label: 'سورة الكهف',
      english: 'Surah Al-Kahf',
      kurdish: 'سوورەتی الکهف (ڕۆژی هەینی)',
      icon: '📖',
      count: 110,
      color: '#059669',
    ),
    AzkarCategory(
      id: 'hadith',
      label: 'الأحاديث النبوية',
      english: 'Noble Hadiths',
      kurdish: 'فەرموودە پیرۆزەکان',
      icon: '📜',
      count: 100,
      color: '#D97706',
    ),
    AzkarCategory(
      id: 'general',
      label: 'أذكار وأدعية عامة ونبوية',
      english: 'General & Prophetic Duas',
      kurdish: 'زیکر و دوعای گشتی و فەرموودە',
      icon: '💫',
      count: 110,
      color: '#0D9488',
    ),
  ];

  static final List<NameOfAllah> namesOfAllah = [
    NameOfAllah(
        id: 1,
        arabic: 'الرَّحْمَنُ',
        transliteration: 'Ar-Rahman',
        english: 'The Most Gracious',
        kurdish: 'بەخشندەترین'),
    NameOfAllah(
        id: 2,
        arabic: 'الرَّحِيمُ',
        transliteration: 'Ar-Rahim',
        english: 'The Most Merciful',
        kurdish: 'میهرەبانترین'),
    NameOfAllah(
        id: 3,
        arabic: 'الْمَلِكُ',
        transliteration: 'Al-Malik',
        english: 'The King',
        kurdish: 'پاشا و خاوەنی هەموو شتێک'),
    NameOfAllah(
        id: 4,
        arabic: 'الْقُدُّوسُ',
        transliteration: 'Al-Quddus',
        english: 'The Most Sacred',
        kurdish: 'پاک و بێگەرد لە هەموو کەموکوڕییەک'),
    NameOfAllah(
        id: 5,
        arabic: 'السَّلَامُ',
        transliteration: 'As-Salam',
        english: 'The Source of Peace',
        kurdish: 'سەرچاوەی ئاشتی و سەلامەتی'),
    NameOfAllah(
        id: 6,
        arabic: 'الْمُؤْمِنُ',
        transliteration: 'Al-Mumin',
        english: 'The Guardian of Faith',
        kurdish: 'بەخشەری ئاسایش و دڵنیایی'),
    NameOfAllah(
        id: 7,
        arabic: 'الْمُهَيْمِنُ',
        transliteration: 'Al-Muhaymin',
        english: 'The Protector',
        kurdish: 'چاودێر و پارێزەر'),
    NameOfAllah(
        id: 8,
        arabic: 'الْعَزِيزُ',
        transliteration: 'Al-Aziz',
        english: 'The Almighty',
        kurdish: 'باڵادەست و باڵادەستتر لە هەمووان'),
    NameOfAllah(
        id: 9,
        arabic: 'الْجَبَّارُ',
        transliteration: 'Al-Jabbar',
        english: 'The Compeller',
        kurdish: 'بەرپەرچدەرەوە و چاککەرەوەی شکاوەکان'),
    NameOfAllah(
        id: 10,
        arabic: 'الْمُتَكَبِّرُ',
        transliteration: 'Al-Mutakabbir',
        english: 'The Majestic',
        kurdish: 'خاوەنی گەورەیی و مەیلیت'),
    NameOfAllah(
        id: 11,
        arabic: 'الْخَالِقُ',
        transliteration: 'Al-Khaliq',
        english: 'The Creator',
        kurdish: 'بەدیهێنەر و دروستکەری هەموو شتێک'),
    NameOfAllah(
        id: 12,
        arabic: 'الْبَارِئُ',
        transliteration: 'Al-Bari',
        english: 'The Maker',
      kurdish: 'بەدیهێنەر بەبێ نموونەی پێشوو'),
    NameOfAllah(
      id: 13,
      arabic: 'الْمُصَوِّرُ',
      transliteration: 'Al-Musawwir',
      english: 'The Fashioner',
      kurdish: 'شێوەبەخش بە دروستکراوەکان'),
    NameOfAllah(
      id: 14,
      arabic: 'الْغَفَّارُ',
      transliteration: 'Al-Ghaffar',
      english: 'The Constant Forgiver',
      kurdish: 'زۆر لێخۆشبوو'),
    NameOfAllah(
      id: 15,
      arabic: 'الْقَهَّارُ',
      transliteration: 'Al-Qahhar',
      english: 'The Subduer',
      kurdish: 'زاڵ و دەسەڵاتدار بەسەر هەموو شتێکدا'),
    NameOfAllah(
      id: 16,
      arabic: 'الْوَهَّابُ',
      transliteration: 'Al-Wahhab',
      english: 'The Bestower',
      kurdish: 'بەخشەری بەردەوام'),
    NameOfAllah(
      id: 17,
      arabic: 'الرَّزَّاقُ',
      transliteration: 'Ar-Razzaq',
      english: 'The Provider',
      kurdish: 'ڕۆزیدەر و بەخێوکەر'),
    NameOfAllah(
      id: 18,
      arabic: 'الْفَتَّاحُ',
      transliteration: 'Al-Fattah',
      english: 'The Opener',
      kurdish: 'فراوانکەری ڕۆزی و بەخشین'),
    NameOfAllah(
      id: 19,
      arabic: 'الْعَلِيمُ',
      transliteration: 'Al-Alim',
      english: 'The All-Knowing',
      kurdish: 'زانا بە هەموو نهێنی و ئاشکرایەک'),
    NameOfAllah(
      id: 20,
      arabic: 'الْقَابِضُ',
      transliteration: 'Al-Qabid',
      english: 'The Withholder',
      kurdish: 'تەسککەرەوە و گرتنەوەی ڕۆزی بە حیکمەت'),
    NameOfAllah(
      id: 21,
      arabic: 'الْبَاسِطُ',
      transliteration: 'Al-Basit',
      english: 'The Expander',
      kurdish: 'فراوانکەری ڕۆزی'),
    NameOfAllah(
      id: 22,
      arabic: 'اللَّطِيفُ',
      transliteration: 'Al-Latif',
      english: 'The Subtle One',
      kurdish: 'نەرم و بە ئاگاداریی ورد'),
    NameOfAllah(
      id: 23,
      arabic: 'الْخَبِيرُ',
      transliteration: 'Al-Khabir',
      english: 'The All-Aware',
      kurdish: 'ئاگادار لە هەموو شتێک'),
    NameOfAllah(
      id: 24,
      arabic: 'الْعَلِيُّ',
      transliteration: 'Al-Ali',
      english: 'The Most High',
      kurdish: 'گەورەترین لە هەموو شتێک'),
    NameOfAllah(
      id: 25,
      arabic: 'الْعَظِيمُ',
      transliteration: 'Al-Azim',
      english: 'The Magnificent',
      kurdish: 'مەزن و گەورە'),
    NameOfAllah(
      id: 26,
      arabic: 'الْحَفِيظُ',
      transliteration: 'Al-Hafiz',
      english: 'The Preserver',
      kurdish: 'پارێزەر و چاودێر'),
    NameOfAllah(
      id: 27,
      arabic: 'الْمُقِيتُ',
      transliteration: 'Al-Muqit',
      english: 'The Sustainer',
      kurdish: 'بەخێوکەر و دەسەڵاتدار بەسەر ڕۆزیدا'),
    /*
            arabic: 'رَبَّنَا تَقَبَّلْ مِنَّا ۖ إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ',
            translation: 'Our Lord, accept this from us. Indeed, You are the All-Hearing, the All-Knowing.',
            kurdishTranslation: 'پەروەردگارمان، ئەمەمان لێ وەرگرە؛ بەڕاستی تۆ بیسەر و زانایت.',
        arabic: 'الْمُصَوِّرُ',
            source: 'Quran 2:127',
        english: 'The Fashioner',
        kurdish: 'شێوەبەخش بە دروستکراوەکان'),
            arabic: 'رَبَّنَا وَاجْعَلْنَا مُسْلِمَيْنِ لَكَ وَمِن ذُرِّيَّتِنَا أُمَّةً مُّسْلِمَةً لَّكَ وَأَرِنَا مَنَاسِكَنَا وَتُبْ عَلَيْنَا ۖ إِنَّكَ أَنتَ التَّوَّابُ الرَّحِيمُ',
            translation: 'Our Lord, make us submissive to You, and from our descendants make a nation submissive to You. Show us our rites and accept our repentance. Indeed, You are the Accepting of repentance, the Most Merciful.',
            kurdishTranslation: 'پەروەردگارمان، ئێمە بکە بە موسڵمان و ملکەچی خۆت، و لە نەوەکانمانەوە کۆمەڵێک دروست بکە کە ملکەچی تۆ بن. شوێنەکانی عیبەدەتمان پیشان بدە و تۆبەمان لێ وەرگرە؛ بەڕاستی تۆ زۆر تۆبەوەرگر و میهرەبانیت.',
            repeat: 1,
            source: 'Quran 2:128',
        kurdish: 'لێخۆشبووی تاوانەکان بە بەردەوامی'),
    NameOfAllah(
            arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
            translation: 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
            kurdishTranslation: 'پەروەردگارمان، لە دنیا چاکیمان پێ ببەخشە و لە دواڕۆژیش چاکیمان پێ ببەخشە، و لە سزای ئاگرمان بپارێزە.',
            repeat: 1,
            source: 'Quran 2:201',
    NameOfAllah(
        id: 16,
            arabic: 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَتَوَفَّنَا مُسْلِمِينَ',
            translation: 'Our Lord, pour upon us patience and let us die as Muslims in submission to You.',
            kurdishTranslation: 'پەروەردگارمان، ئارامی و خۆڕاگریمان بەسەردا ببارێنە و بە موسڵمانی و ملکەچی خۆت بمێرێنەوە.',
            repeat: 1,
            source: 'Quran 7:126',
        id: 17,
        arabic: 'الرَّزَّاقُ',
            arabic: 'رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
            translation: 'Our Lord, do not hold us accountable if we forget or make a mistake. Our Lord, do not place upon us a burden like that placed upon those before us. Our Lord, do not burden us with what we cannot bear. Pardon us, forgive us, and have mercy on us. You are our Protector, so help us against the disbelieving people.',
            kurdishTranslation: 'پەروەردگارمان، ئەگەر لەبیرمان چوو یان هەڵەمان کرد، لێمان مەپرسە. پەروەردگارمان، بارێکی گرانمان لەسەر مەخە وەک ئەوەی لەسەر پێشینان خستت. پەروەردگارمان، ئەوەمان بار مەکە کە توانای هەڵگرتنی نییە. لێمان خۆش ببە، بیبورە و ڕەحممان پێ بکە؛ تۆ سەرپەرشتیاری ئێمەیت، کەواتە یارمەتیمان بدە بەرامبەر گەلێکی بێباوەڕ.',
        id: 18,
            source: 'Quran 2:286',
        transliteration: 'Al-Fattah',
        english: 'The Opener',
            arabic: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ',
            translation: 'Our Lord, do not let our hearts deviate after You have guided us, and grant us mercy from You. Indeed, You are the Bestower.',
            kurdishTranslation: 'پەروەردگارمان، دڵەکانمان لە دوای ئەوەی ڕێنموونیت کردین لادەر مەکە، و لەلای خۆتەوە ڕەحمەتێکمان پێ ببەخشە؛ بەڕاستی تۆ بەخشەرترینی.',
        arabic: 'الْعَلِيمُ',
            source: 'Quran 3:8',
        english: 'The All-Knowing',
        kurdish: 'زانا بە هەموو نهێنی و ئاشکرایەک'),
            arabic: 'رَبَّنَا إِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوبَنَا وَقِنَا عَذَابَ النَّارِ',
            translation: 'Our Lord, indeed we have believed, so forgive us our sins and protect us from the punishment of the Fire.',
            kurdishTranslation: 'پەروەردگارمان، بەڕاستی ئێمە باوەڕمان هێناوە، کەواتە گوناهەکانمان ببورە و لە سزای ئاگرمان بپارێزە.',
        transliteration: 'Al-Qabid',
            source: 'Quran 3:16',
        kurdish: 'تەسککەرەوە و گرتنەوەی ڕۆزی بە حیکمەت'),
    NameOfAllah(
            arabic: 'رَبَّنَا إِنَّنَا سَمِعْنَا مُنَادِيًا يُنَادِي لِلْإِيمَانِ أَنْ آمِنُوا بِرَبِّكُمْ فَآمَنَّا ۚ رَبَّنَا فَاغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا وَتَوَفَّنَا مَعَ الْأَبْرَارِ',
            translation: 'Our Lord, we have heard a caller calling to faith: Believe in your Lord, and we have believed. Our Lord, forgive us our sins, remove our misdeeds, and let us die among the righteous.',
            kurdishTranslation: 'پەروەردگارمان، گوێمان لە بانگەوازکەرێک بوو کە بانگەوازی باوەڕ دەکرد: باوەڕ بە پەروەردگارتان بهێنن، ئێمەش باوەڕمان هێنا. پەروەردگارمان، گوناهەکانمان ببورە، خراپەکانمان بسڕەوە و لەگەڵ چاکان بمێرێنەوە.',
        kurdish: 'فراوانکەری ڕۆزی و بەخشین'),
            source: 'Quran 3:193',
        id: 22,
        arabic: 'اللَّطِيفُ',
            arabic: 'رَبَّنَا وَآتِنَا مَا وَعَدتَّنَا عَلَىٰ رُسُلِكَ وَلَا تُخْزِنَا يَوْمَ الْقِيَامَةِ ۗ إِنَّكَ لَا تُخْلِفُ الْمِيعَادَ',
            translation: 'Our Lord, grant us what You promised us through Your messengers and do not disgrace us on the Day of Resurrection. Indeed, You never break Your promise.',
            kurdishTranslation: 'پەروەردگارمان، ئەوەمان پێ ببەخشە کە بە ڕێگەی پێغەمبەرەکانت بەڵێنت پێداوین، و لە ڕۆژی قیامەت ڕیسوایمان مەکە؛ بەڕاستی تۆ پەیمان ناشکێنیت.',
    NameOfAllah(
            source: 'Quran 3:194',
        arabic: 'الرَّافِعُ',
        transliteration: 'Ar-Rafi',
            arabic: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
            translation: 'My Lord, make me an establisher of prayer, and many from my descendants. Our Lord, accept my supplication.',
            kurdishTranslation: 'پەروەردگارم، من و نەوەکانم بکە بە دامەزرێنەری نوێژ؛ پەروەردگارمان، دوعاکەم وەرگرە.',
        id: 24,
            source: 'Quran 14:40',
        transliteration: 'Al-Ali',
        english: 'The Most High',
            arabic: 'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
            translation: 'Our Lord, forgive me, my parents, and the believers on the Day the account is established.',
            kurdishTranslation: 'پەروەردگارمان، لە ڕۆژی دامەزرانی حیسابدا من و دایک و باوکم و هەموو باوەڕداران ببورە.',
        kurdish: 'گەورەترین لە هەموو شتێک'),
            source: 'Quran 14:41',
        id: 26,
        arabic: 'الْحَفِيظُ',
            arabic: 'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ وَأَصْلِحْ لِي فِي ذُرِّيَّتِي ۖ إِنِّي تُبْتُ إِلَيْكَ وَإِنِّي مِنَ الْمُسْلِمِينَ',
            translation: 'My Lord, enable me to be grateful for Your favor which You have bestowed upon me and my parents, and to do righteous deeds that please You. Make my offspring righteous for me. Indeed, I have repented to You, and I am of the Muslims.',
            kurdishTranslation: 'پەروەردگارم، توانام پێ بدە سوپاسی ئەو نیعمەتە بکەم کە بە من و دایک و باوکم بەخشیت، و کاری چاک بکەم کە ڕازیت بکات. نەوەکانم بۆ چاک بکە؛ بەڕاستی من تۆبەتم بۆ تۆ کردووە و لە موسڵمانانم.',
        transliteration: 'Al-Muqit',
            source: 'Quran 46:15',
          ),
          Azkar(
            arabic: 'رَبِّ أَنزِلْنِي مُنزَلًا مُّبَارَكًا وَأَنتَ خَيْرُ الْمُنزِلِينَ',
            translation: 'My Lord, let me land at a blessed landing place, and You are the best to accommodate us.',
            kurdishTranslation: 'پەروەردگارم، لە شوێنێکی پڕ لە بەرەکەت جێگیرم بکە، و تۆ باشترینی جێگیرکەرانی.',
            repeat: 1,
            source: 'Quran 23:29',
          ),
          Azkar(
            arabic: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
            translation: 'Our Lord, grant us from our spouses and offspring comfort to our eyes and make us an example for the righteous.',
            kurdishTranslation: 'پەروەردگارمان، لە هاوسەر و نەوەکانمانەوە خۆشی و ڕووناکیی چاومان پێ ببەخشە، و ئێمە بکە بە نموونە بۆ پارێزگاران.',
            repeat: 1,
            source: 'Quran 25:74',
          ),
          Azkar(
            arabic: 'رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ ۝ وَأَعُوذُ بِكَ رَبِّ أَنْ يَحْضُرُونِ',
            translation: 'My Lord, I seek refuge in You from the incitements of the devils, and I seek refuge in You, my Lord, lest they be present with me.',
            kurdishTranslation: 'پەروەردگارم، پەنا دەگرم بە تۆ لە وسووسە و هاندانی شەیتانەکان، و پەنا دەگرم بە تۆ، پەروەردگارم، کە لەلای من ئامادە بن.',
            repeat: 1,
            source: 'Quran 23:97-98',
          ),
          Azkar(
            arabic: 'لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
            translation: 'There is no deity except You; glory be to You. Indeed, I have been among the wrongdoers.',
            kurdishTranslation: 'هیچ پەرستراوێک نییە جگە لە تۆ؛ پاک و بێگەردیت. بەڕاستی من لە ستەمکاران بووم.',
            repeat: 1,
            source: 'Quran 21:87',
          ),
          Azkar(
            arabic: 'رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنتَ خَيْرُ الْوَارِثِينَ',
            translation: 'My Lord, do not leave me alone, while You are the best of inheritors.',
            kurdishTranslation: 'پەروەردگارم، بە تەنیا بەجێم مەهێڵە، و تۆ باشترینی میراتگرانیت.',
            repeat: 1,
            source: 'Quran 21:89',
          ),
          Azkar(
            arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي ۝ وَيَسِّرْ لِي أَمْرِي ۝ وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي ۝ يَفْقَهُوا قَوْلِي',
            translation: 'My Lord, expand for me my chest, ease for me my task, and untie the knot from my tongue so that they may understand my speech.',
            kurdishTranslation: 'پەروەردگارم، سینگم فراوان بکە، کارەکەم ئاسان بکە، گرێی زمانم بکەرەوە تا قسەکەم تێبگەن.',
            repeat: 1,
            source: 'Quran 20:25-28',
          ),
          Azkar(
            arabic: 'رَبِّ زِدْنِي عِلْمًا',
            translation: 'My Lord, increase me in knowledge.',
            kurdishTranslation: 'پەروەردگارم، زانستم زیاد بکە.',
            repeat: 1,
            source: 'Quran 20:114',
          ),
          Azkar(
            arabic: 'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
            translation: 'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers.',
            kurdishTranslation: 'پەروەردگارمان، خۆمان ستەم لە خۆمان کردووە؛ ئەگەر لێمان خۆش نەبیت و ڕەحممان پێ نەکەیت، بەدڵنیایی لە زیانکاران دەبین.',
            repeat: 1,
            source: 'Quran 7:23',
        kurdish: 'بەخێوکەر و دەسەڵاتدار بەسەر ڕۆزیدا'),
    NameOfAllah(
      */
      NameOfAllah(
        id: 28,
        arabic: 'الْحَسِيبُ',
        transliteration: 'Al-Hasib',
        english: 'The Reckoner',
        kurdish: 'بەسبوو و حیسابکەری کردارەکان'),
    NameOfAllah(
        id: 29,
        arabic: 'الْجَلِيلُ',
        transliteration: 'Al-Jalil',
        english: 'The Majestic One',
        kurdish: 'خاوەن شکۆ و بەهەیبەت'),
    NameOfAllah(
        id: 30,
        arabic: 'الْكَرِيمُ',
        transliteration: 'Al-Karim',
        english: 'The Most Generous',
        kurdish: 'سەخاوەتمەند و بەخشندە'),
    NameOfAllah(
        id: 31,
        arabic: 'الرَّقِيبُ',
        transliteration: 'Ar-Raqib',
        english: 'The Watchful One',
        kurdish: 'ئاگادار و چاودێر بەسەر هەموو شتێکدا'),
    NameOfAllah(
        id: 32,
        arabic: 'الْمُجِيبُ',
        transliteration: 'Al-Mujib',
        english: 'The Responsive One',
        kurdish: 'وەڵامده‌ره‌وەی دوعاو نزا'),
    NameOfAllah(
        id: 33,
        arabic: 'الْوَاسِعُ',
        transliteration: 'Al-Wasi',
        english: 'The All-Embracing',
        kurdish: 'فراوان لە بەخشین و ڕەحمەتدا'),
    NameOfAllah(
        id: 34,
        arabic: 'الْحَكِيمُ',
        transliteration: 'Al-Hakim',
        english: 'The All-Wise',
        kurdish: 'خاوەن حیکمەت لە هەموو بڕیارێکدا'),
    NameOfAllah(
        id: 35,
        arabic: 'الْوَدُودُ',
        transliteration: 'Al-Wadud',
        english: 'The Loving One',
        kurdish: 'خۆشەویست بەرامبەر بڕواداران'),
    NameOfAllah(
        id: 36,
        arabic: 'الْمَجِيدُ',
        transliteration: 'Al-Majid',
        english: 'The Glorious One',
        kurdish: 'خاوەن مەزنترینی ڕێز و شکۆ'),
  ];

  static final List<Azkar> morningAzkar = [
    Azkar(
      arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ',
      translation:
          'We have entered the morning, and all sovereignty belongs to Allah, and all praise is for Allah.',
      kurdishTranslation:
          'بەیانیمان بەسەردا هات، هەموو دەسەڵات و سوپاس بۆ خوای گەورەیە.',
      repeat: 1,
      source: 'Sunan Abi Dawud',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
      translation:
          'O Allah, by Your leave we have reached the morning, and by Your leave we have reached the evening; by You we live, by You we die, and to You is the return.',
      kurdishTranslation:
          'خوایە، بە تۆوە بەیانمان هێنا، بە تۆوە ئێوارەمان هێنا، بە تۆوە دەژین و دەمرین، و گەڕانەوەمان بۆ تۆیە.',
      repeat: 1,
      source: 'Sunan al-Tirmidhi',
    ),
    Azkar(
      arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      translation: 'Glory is to Allah and with His praise.',
      kurdishTranslation: 'پاک و بێگەردی و سوپاس بۆ خوای گەورەیە.',
      repeat: 100,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic:
          'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      translation:
          'There is no god worthy of worship except Allah alone, without partner. To Him belongs the dominion and the praise, and He is able to do all things.',
      kurdishTranslation:
          'هیچ پەرستراوێک بەحەق نییە جگە لە خوای تاک، بێ هاوبەش، هەموو دەسەڵات و سوپاس بۆ ئەوە، و ئەو بەسەر هەموو شتێکدا توانا بێت.',
      repeat: 10,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      translation:
          'O Allah, You are my Lord; there is no god but You. You created me and I am Your servant, and I am upon Your covenant and promise as much as I am able.',
      kurdishTranslation:
          'خوایە، تۆ پەروەردگارم، هیچ پەرستراوێک جگە لە تۆ نییە؛ تۆ منت دروستکردووە و من بەندەی تۆم، و لەسەر پەیمان و بەڵێنی تۆم تا توانام هەبێت.',
      repeat: 1,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ',
      translation:
          'O Allah, I have reached the morning and bear witness to You, to the bearers of Your Throne, to Your angels, and all of Your creation, that You are Allah; there is no god but You, alone, without partner.',
      kurdishTranslation:
          'خوایە، بەیانم هێنا و بۆ تۆ، بۆ هەڵگرتنەکانی عەرشی تۆ، بۆ فریشتەکانت و هەموو درووستکراوەکانت شایەتی دەدەم، کە تۆ خوایە، هیچ پەرستراوێک جگە لە تۆ نییە، تاک و بێ هاوبەش.',
      repeat: 1,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      translation:
          'I seek refuge in Allah’s perfect words from the evil of what He has created.',
      kurdishTranslation:
          'پەنا دەگرم بە وشە تەواوەکانی خوای گەورە لە خراپەی هەر شتێک دروستی کردووە.',
      repeat: 3,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic:
          'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      translation:
          'Allah is sufficient for me; there is no god but Him. I place my trust in Him, and He is the Lord of the Great Throne.',
      kurdishTranslation:
          'خوای گەورە بەسە بۆ من، هیچ پەرستراوێک جگە لە ئەو نییە؛ بۆ ئەو پشت دەبەستم و ئەو پەروەردگاری عەرشە گەورەیە.',
      repeat: 7,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      translation:
          'O Allah, I ask You for well-being in this life and the Hereafter.',
      kurdishTranslation:
          'خوایە، داوای پارێزگاری و سەلامەتی لە دونیا و دواڕۆژ دەکەم.',
      repeat: 1,
      source: 'Sunan Abi Dawud',
    ),
    Azkar(
      arabic:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      translation:
          'Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is [presently] before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great. [Al-Baqarah: 255]',
      kurdishTranslation:
          'خوا ئه‌و خوایه‌یه‌ که هیچ په‌رستراوێکی ڕاسته‌قینه‌ نییه‌ بێجگه له‌و، هه‌میشه‌ زیندووه‌ و ڕاگری هه‌موو بوونه‌وه‌ره، نه‌ وه‌نه‌وز و خه‌واڵوویی ده‌یگرێت و نه‌ خه‌و. هه‌رچی له‌ ئاسمانه‌کان و هه‌رچی له‌ زه‌ویدایه‌ هه‌ر هی ئه‌وه‌. کێیه ئه‌و که‌سه‌ی بتوانێت تکا و شه‌فاعه‌ت له‌لای ئه‌و بکات مه‌گه‌ر به‌ مۆڵه‌تی خۆی؟ ئاگاداره به هه‌موو ئه‌وه‌ی له‌به‌رده‌میانه‌ و ئه‌وه‌ی له‌پشتیانه‌، و که‌س هیچ شتێک له زانستی ئه‌و نازانێت مه‌گه‌ر به‌وه‌ی خۆی بیه‌وێت. کورسییه‌که‌ی هه‌موو ئاسمانه‌کان و زه‌وی گرتۆته‌وه و پاراستنی ئاسمانه‌کان و زه‌وی هیچ ماندووی ناکات؛ و هه‌ر ئه‌وه‌ پله‌به‌رز و گه‌وره‌ و پایه‌دار. [البقرة: 255]',
      repeat: 1,
      source: 'ئایەتی کورسی [البقرة: 255]',
    ),
    Azkar(
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: He is Allah, [who is] One. Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent. [Al-Ikhlas: 1-4]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: ئه‌و خوایه‌ی که ناوی الله‌ خوایه‌کی تاک و ته‌نهایه‌ (بێ هاوه‌ڵ و هاوتایه‌). خوا زاتێکی پایه‌دار و ده‌سه‌ڵاتداره، بێ‌نیازه و هه‌موو دروستکراوان پێویستیان پێیه‌تی. نه‌ که‌سی لێ بووه‌ و نه‌ خۆشی له که‌س بووه‌. و هه‌رگیز هیچ هاوتا و هاوشێوه‌یه‌کی بۆ نه‌بووه و نییه‌. [الإخلاص: 1-4]',
      repeat: 3,
      source: 'سوورەتی ئیخڵاس [112: 1-4]',
    ),
    Azkar(
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: I seek refuge in the Lord of daybreak From the evil of that which He created, And from the evil of darkness when it settles, And from the evil of the blowers in knots, And from the evil of an envier when he envies. [Al-Falaq: 1-5]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: په‌نا ده‌گرم به په‌روه‌ردگاری به‌ره‌به‌یان، له شه‌ڕ و خراپه‌ی هه‌موو ئه‌و شتانه‌ی دروستی کردوون، و له شه‌ڕ و خراپه‌ی تاریکی شه‌و کاتێک دادێت، و له شه‌ڕ و خراپه‌ی ئه‌و جادووگه‌رانه‌ی پف ده‌که‌ن له گرێیه‌کاندا، و له شه‌ڕ و خراپه‌ی حه‌سوود کاتێک حه‌سوودی ده‌بات. [الفلق: 1-5]',
      repeat: 3,
      source: 'سوورەتی فەلەق [113: 1-5]',
    ),
    Azkar(
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: I seek refuge in the Lord of mankind, The Sovereign of mankind, The God of mankind, From the evil of the retreating whisperer - Who whispers into the breasts of mankind - From among the jinn and mankind. [An-Nas: 1-6]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: په‌نا ده‌گرم به په‌روه‌ردگاری خه‌ڵکی، پادشا و خاوه‌نداری خه‌ڵکی، په‌رستراوی حه‌قیقی خه‌ڵکی، له شه‌ڕ و خراپه‌ی وه‌سوه‌سه‌ده‌ری پاشه‌کشه‌که‌ری خۆشاره‌وه‌ (شه‌یتان)، ئه‌وه‌ی که وه‌سوه‌سه ده‌خاته دڵ و سینه‌ی خه‌ڵکییه‌وه‌، چ له جنۆکه‌ بێت یان له مرۆڤ. [الناس: 1-6]',
      repeat: 3,
      source: 'سوورەتی ناس [114: 1-6]',
    ),
    Azkar(
      arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      translation: 'I seek forgiveness from Allah and repent to Him.',
      kurdishTranslation:
          'لە خوای گەورە داوای لێخۆشبوون دەکەم و دەگەڕێمەوە بۆ لای بە تۆبەکردن.',
      repeat: 100,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
      translation: 'O Allah, bless Muhammad and the family of Muhammad.',
      kurdishTranslation:
          'خودایە، دروود و ڕەحمەت بڕژێنە بەسەر پێغەمبەر موحەممەد و خێزان و بنەماڵەی موحەممەددا.',
      repeat: 10,
      source: 'Sahih Muslim',
    ),
  ];

  static final List<Azkar> eveningAzkar = [
    Azkar(
      arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ',
      translation:
          'We have entered the evening, and all sovereignty belongs to Allah, and all praise is for Allah.',
      kurdishTranslation:
          'ئێوارەمان بەسەردا هات، هەموو دەسەڵات و سوپاس بۆ خوای گەورەیە.',
      repeat: 1,
      source: 'Sunan Abi Dawud',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
      translation:
          'O Allah, by Your leave we have entered the evening, and by Your leave we enter the morning; by You we live, by You we die, and to You is the return.',
      kurdishTranslation:
          'خوایە، بە تۆوە ئێوارەمان هێنا، بە تۆوە بەیانمان دەهێنێت، بە تۆوە دەژین و دەمرین، و گەڕانەوەمان بۆ تۆیە.',
      repeat: 1,
      source: 'Sunan al-Tirmidhi',
    ),
    Azkar(
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      translation:
          'I seek refuge in Allah’s perfect words from the evil of what He has created.',
      kurdishTranslation:
          'پەنا دەگرم بە وشە تەواوەکانی خوای گەورە لە خراپەی هەر شتێک دروستی کردووە.',
      repeat: 3,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      translation:
          'Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is [presently] before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great. [Al-Baqarah: 255]',
      kurdishTranslation:
          'خوا ئه‌و خوایه‌یه‌ که هیچ په‌رستراوێکی ڕاسته‌قینه‌ نییه‌ بێجگه له‌و، هه‌میشه‌ زیندووه‌ و ڕاگری هه‌موو بوونه‌وه‌ره، نه‌ وه‌نه‌وز و خه‌واڵوویی ده‌یگرێت و نه‌ خه‌و. هه‌رچی له‌ ئاسمانه‌کان و هه‌رچی له‌ زه‌ویدایه‌ هه‌ر هی ئه‌وه‌. کێیه ئه‌و که‌سه‌ی بتوانێت تکا و شه‌فاعه‌ت له‌لای ئه‌و بکات مه‌گه‌ر به‌ مۆڵه‌تی خۆی؟ ئاگاداره به هه‌موو ئه‌وه‌ی له‌به‌رده‌میانه‌ و ئه‌وه‌ی له‌پشتیانه‌، و که‌س هیچ شتێک له زانستی ئه‌و نازانێت مه‌گه‌ر به‌وه‌ی خۆی بیه‌وێت. کورسییه‌که‌ی هه‌موو ئاسمانه‌کان و زه‌وی گرتۆته‌وه و پاراستنی ئاسمانه‌کان و زه‌وی هیچ ماندووی ناکات؛ و هه‌ر ئه‌وه‌ پله‌به‌رز و گه‌وره‌ و پایه‌دار. [البقرة: 255]',
      repeat: 1,
      source: 'ئایەتی کورسی [البقرة: 255]',
    ),
    Azkar(
      arabic:
          'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ نَبِيًّا',
      translation:
          'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad as my Prophet.',
      kurdishTranslation:
          'ڕازی بووم بە خوای گەورە وەک پەروەردگار، بە ئیسلام وەک ئایین، و بە موحەممەد وەک پێغەمبەر.',
      repeat: 3,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic:
          'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      translation:
          'In the name of Allah with Whose name nothing on earth or in heaven can cause harm; He is the All-Hearing, All-Knowing.',
      kurdishTranslation:
          'بە ناوی ئەو خودایەی کە لەگەڵ ناوی ئەودا هیچ شتێک زیان ناگەیەنێت لە زەوی و لە ئاسماندا، و ئەو زۆر بیسەر و زانایە.',
      repeat: 3,
      source: 'Sunan Abi Dawud',
    ),
    Azkar(
      arabic:
          'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      translation:
          'Allah is sufficient for me; there is no god but Him. I place my trust in Him, and He is the Lord of the Great Throne.',
      kurdishTranslation:
          'خوای گەورە بەسە بۆ من، هیچ پەرستراوێک جگە لە ئەو نییە؛ بۆ ئەو پشت دەبەستم و ئەو پەروەردگاری عەرشە گەورەیە.',
      repeat: 7,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      translation:
          'O Allah, I ask You for well-being in this world and the Hereafter.',
      kurdishTranslation:
          'خوایە، داوای پارێزگاری و سەلامەتی لە دونیا و دواڕۆژ دەکەم.',
      repeat: 1,
      source: 'Sunan Abi Dawud',
    ),
    Azkar(
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: He is Allah, [who is] One. Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent. [Al-Ikhlas: 1-4]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: ئه‌و خوایه‌ی که ناوی الله‌ خوایه‌کی تاک و ته‌نهایه‌ (بێ هاوه‌ڵ و هاوتایه‌). خوا زاتێکی پایه‌دار و ده‌سه‌ڵاتداره، بێ‌نیازه و هه‌موو دروستکراوان پێویستیان پێیه‌تی. نه‌ که‌سی لێ بووه‌ و نه‌ خۆشی له که‌س بووه‌. و هه‌رگیز هیچ هاوتا و هاوشێوه‌یه‌کی بۆ نه‌بووه و نییه‌. [الإخلاص: 1-4]',
      repeat: 3,
      source: 'سوورەتی ئیخڵاس [112: 1-4]',
    ),
    Azkar(
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: I seek refuge in the Lord of daybreak From the evil of that which He created, And from the evil of darkness when it settles, And from the evil of the blowers in knots, And from the evil of an envier when he envies. [Al-Falaq: 1-5]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: په‌نا ده‌گرم به په‌روه‌ردگاری به‌ره‌به‌یان، له شه‌ڕ و خراپه‌ی هه‌موو ئه‌و شتانه‌ی دروستی کردوون، و له شه‌ڕ و خراپه‌ی تاریکی شه‌و کاتێک دادێت، و له شه‌ڕ و خراپه‌ی ئه‌و جادووگه‌رانه‌ی پف ده‌که‌ن له گرێیه‌کاندا، و له شه‌ڕ و خراپه‌ی حه‌سوود کاتێک حه‌سوودی ده‌بات. [الفلق: 1-5]',
      repeat: 3,
      source: 'سوورەتی فەلەق [113: 1-5]',
    ),
    Azkar(
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: I seek refuge in the Lord of mankind, The Sovereign of mankind, The God of mankind, From the evil of the retreating whisperer - Who whispers into the breasts of mankind - From among the jinn and mankind. [An-Nas: 1-6]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: په‌نا ده‌گرم به په‌روه‌ردگاری خه‌ڵکی، پادشا و خاوه‌نداری خه‌ڵکی، په‌رستراوی حه‌قیقی خه‌ڵکی، له شه‌ڕ و خراپه‌ی وه‌سوه‌سه‌ده‌ری پاشه‌کشه‌که‌ری خۆشاره‌وه‌ (شه‌یتان)، ئه‌وه‌ی که وه‌سوه‌سه ده‌خاته دڵ و سینه‌ی خه‌ڵکییه‌وه‌، چ له جنۆکه‌ بێت یان له مرۆڤ. [الناس: 1-6]',
      repeat: 3,
      source: 'سوورەتی ناس [114: 1-6]',
    ),
    Azkar(
      arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      translation: 'I seek forgiveness from Allah and repent to Him.',
      kurdishTranslation:
          'لە خوای گەورە داوای لێخۆشبوون دەکەم و دەگەڕێمەوە بۆ لای بە تۆبەکردن.',
      repeat: 100,
      source: 'Sahih Muslim',
    ),
  ];

  static final List<Azkar> sleepAzkar = [
    Azkar(
      arabic:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      translation:
          'Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is [presently] before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great. [Al-Baqarah: 255]',
      kurdishTranslation:
          'خوا ئه‌و خوایه‌یه‌ که هیچ په‌رستراوێکی ڕاسته‌قینه‌ نییه‌ بێجگه له‌و، هه‌میشه‌ زیندووه‌ و ڕاگری هه‌موو بوونه‌وه‌ره، نه‌ وه‌نه‌وز و خه‌واڵوویی ده‌یگرێت و نه‌ خه‌و. هه‌رچی له‌ ئاسمانه‌کان و هه‌رچی له‌ زه‌ویدایه‌ هه‌ر هی ئه‌وه‌. کێیه ئه‌و که‌سه‌ی بتوانێت تکا و شه‌فاعه‌ت له‌لای ئه‌و بکات مه‌گه‌ر به‌ مۆڵه‌تی خۆی؟ ئاگاداره به هه‌موو ئه‌وه‌ی له‌به‌رده‌میانه‌ و ئه‌وه‌ی له‌پشتیانه‌، و که‌س هیچ شتێک له زانستی ئه‌و نازانێت مه‌گه‌ر به‌وه‌ی خۆی بیه‌وێت. کورسییه‌که‌ی هه‌موو ئاسمانه‌کان و زه‌وی گرتۆته‌وه و پاراستنی ئاسمانه‌کان و زه‌وی هیچ ماندووی ناکات؛ و هه‌ر ئه‌وه‌ پله‌به‌رز و گه‌وره‌ و پایه‌دار. [البقرة: 255]',
      repeat: 1,
      source: 'ئایەتی کورسی [البقرة: 255]',
    ),
    Azkar(
      arabic:
          'آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِنْ رُسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ ۝ لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      translation:
          'The Messenger has believed in what was revealed to him from his Lord, and [so have] the believers. All of them have believed in Allah and His angels and His books and His messengers, [saying], "We make no distinction between any of His messengers." And they say, "We hear and we obey. [We seek] Your forgiveness, our Lord, and to You is the [final] destination." Allah does not charge a soul except [with that within] its capacity. It will have [the consequence of] what [good] it has earned, and it will bear [the consequence of] what [evil] it has taken on. "Our Lord, do not impose blame upon us if we have forgotten or erred. Our Lord, and lay not upon us a burden like that which You laid upon those before us. Our Lord, and burden us not with that which we have no ability to bear. And pardon us; and forgive us; and have mercy upon us. You are our protector, so give us victory over the disbelieving people." [Al-Baqarah: 285-286]',
      kurdishTranslation:
          'پێغه‌مبه‌ر (د.خ) باوه‌ڕی هێنا به‌وه‌ی له لایه‌ن په‌روه‌ردگاریه‌وه بۆی دابه‌زیوه و باوه‌ڕدارانیش هه‌موو باوه‌ڕیان هێنا. هه‌موویان باوه‌ڕیان هێنا به خوا، به فریشته‌کانی، به کتێبه‌کانی و به پێغه‌مبه‌رانی، (ده‌ڵێن:) ئێمه هیچ جیاوازییه‌ک ناکه‌ین له‌نێوان پێغه‌مبه‌رانیدا، و وتیان: بیستمان و فه‌رمانبه‌ردار بووین، داوای لێخۆشبوونت ده‌که‌ین ئه‌ی په‌روه‌ردگارمان، و گه‌ڕانه‌وه‌مان ته‌نها بۆ لای تۆیه‌. خوا هیچ که‌سێک ناهێنێته ژێر بارێکه‌وه مه‌گه‌ر به ئه‌ندازه‌ی توانای خۆی، هه‌ر خێرێکی کردبێت بۆ خۆیه‌تی و هه‌ر شه‌ڕێکیشی کردبێت له‌سه‌ر خۆیه‌تی. په‌روه‌ردگارا، لێمان مه‌گره ئه‌گه‌ر له‌بیرمان چوو یان هه‌ڵه‌مان کرد. په‌روه‌ردگارا، باری قورسمان به‌سه‌ردا مه‌سه‌پێنه وه‌کو چۆن به‌سه‌ر پێشینانی ئێمه‌دا سه‌پاندت. په‌روه‌ردگارا، شتێکمان پێ مه‌سپێره که توانامان پێی نه‌بێت، لێمان ببووره و لێمان خۆش ببه و ڕه‌حمان پێ بکه‌، تۆ په‌روه‌ردگار و سه‌رپه‌رشتیاری ئێمه‌یت، که‌واته سه‌رکه‌وتنمان پێ ببه‌خشه به‌سه‌ر کۆمه‌ڵی بێباوه‌ڕاندا. [البقرة: 285-286]',
      repeat: 1,
      source: 'کۆتایی سوورەتی بەقەرە [البقرة: 285-286]',
    ),
    Azkar(
      id: 6700,
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ تَبَٰرَكَ ٱلَّذِي بِيَدِهِ ٱلۡمُلۡكُ وَهُوَ عَلَىٰ كُلِّ شَيۡءٖ قَدِيرٌ ۝ ٱلَّذِي خَلَقَ ٱلۡمَوۡتَ وَٱلۡحَيَوٰةَ لِيَبۡلُوَكُمۡ أَيُّكُمۡ أَحۡسَنُ عَمَلٗاۚ وَهُوَ ٱلۡعَزِيزُ ٱلۡغَفُورُ ۝ ٱلَّذِي خَلَقَ سَبۡعَ سَمَٰوَٰتٖ طِبَاقٗاۖ مَّا تَرَىٰ فِي خَلۡقِ ٱلرَّحۡمَٰنِ مِن تَفَٰوُتٖۖ فَٱرۡجِعِ ٱلۡبَصَرَ هَلۡ تَرَىٰ مِن فُطُورٖ ۝ ثُمَّ ٱرۡجِعِ ٱلۡبَصَرَ كَرَّتَيۡنِ يَنقَلِبۡ إِلَيۡكَ ٱلۡبَصَرُ خَاسِئٗا وَهُوَ حَسِيرٞ ۝ وَلَقَدۡ زَيَّنَّا ٱلسَّمَآءَ ٱلدُّنۡيَا بِمَصَٰبِيحَ وَجَعَلۡنَٰهَا رُجُومٗا لِّلشَّيَٰطِينِۖ وَأَعۡتَدۡنَا لَهُمۡ عَذَابَ ٱلسَّعِيرِ ۝ وَلِلَّذِينَ كَفَرُواْ بِرَبِّهِمۡ عَذَابُ جَهَنَّمَۖ وَبِئۡسَ ٱلۡمَصِيرُ ۝ إِذَآ أُلۡقُواْ فِيهَا سَمِعُواْ لَهَا شَهِيقٗا وَهِيَ تَفُورُ ۝ تَكَادُ تَمَيَّزُ مِنَ ٱلۡغَيۡظِۖ كُلَّمَآ أُلۡقِيَ فِيهَا فَوۡجٞ سَأَلَهُمۡ خَزَنَتُهَآ أَلَمۡ يَأۡتِكُمۡ نَذِيرٞ ۝ قَالُواْ بَلَىٰ قَدۡ جَآءَنَا نَذِيرٞ فَكَذَّبۡنَا وَقُلۡنَا مَا نَزَّلَ ٱللَّهُ مِن شَيۡءٍ إِنۡ أَنتُمۡ إِلَّا فِي ضَلَٰلٖ كَبِيرٖ ۝ وَقَالُواْ لَوۡ كُنَّا نَسۡمَعُ أَوۡ نَعۡقِلُ مَا كُنَّا فِيٓ أَصۡحَٰبِ ٱلسَّعِيرِ ۝ فَٱعۡتَرَفُواْ بِذَنۢبِهِمۡ فَسُحۡقٗا لِّأَصۡحَٰبِ ٱلسَّعِيرِ ۝ إِنَّ ٱلَّذِينَ يَخۡشَوۡنَ رَبَّهُم بِٱلۡغَيۡبِ لَهُم مَّغۡفِرَةٞ وَأَجۡرٞ كَبِيرٞ ۝ وَأَسِرُّواْ قَوۡلَكُمۡ أَوِ ٱجۡهَرُواْ بِهِۦٓۖ إِنَّهُۥ عَلِيمُۢ بِذَاتِ ٱلصُّدُورِ ۝ أَلَا يَعۡلَمُ مَنۡ خَلَقَ وَهُوَ ٱللَّطِيفُ ٱلۡخَبِيرُ ۝ هُوَ ٱلَّذِي جَعَلَ لَكُمُ ٱلۡأَرۡضَ ذَلُولٗا فَٱمۡشُواْ فِي مَنَاكِبِهَا وَكُلُواْ مِن رِّزۡقِهِۦۖ وَإِلَيۡهِ ٱلنُّشُورُ ۝ ءَأَمِنتُم مَّن فِي ٱلسَّمَآءِ أَن يَخۡسِفَ بِكُمُ ٱلۡأَرۡضَ فَإِذَا هِيَ تَمُورُ ۝ أَمۡ أَمِنتُم مَّن فِي ٱلسَّمَآءِ أَن يُرۡسِلَ عَلَيۡكُمۡ حَاصِبٗاۖ فَسَتَعۡلَمُونَ كَيۡفَ نَذِيرِ ۝ وَلَقَدۡ كَذَّبَ ٱلَّذِينَ مِن قَبۡلِهِمۡ فَكَيۡفَ كَانَ نَكِيرِ ۝ أَوَلَمۡ يَرَوۡاْ إِلَى ٱلطَّيۡرِ فَوۡقَهُمۡ صَٰٓفَّٰتٖ وَيَقۡبِضۡنَۚ مَا يُمۡسِكُهُنَّ إِلَّا ٱلرَّحۡمَٰنُۚ إِنَّهُۥ بِكُلِّ شَيۡءِۭ بَصِيرٌ ۝ أَمَّنۡ هَٰذَا ٱلَّذِي هُوَ جُندٞ لَّكُمۡ يَنصُرُكُم مِّن دُونِ ٱلرَّحۡمَٰنِۚ إِنِ ٱلۡكَٰفِرُونَ إِلَّا فِي غُرُورٍ ۝ أَمَّنۡ هَٰذَا ٱلَّذِي يَرۡزُقُكُمۡ إِنۡ أَمۡسَكَ رِزۡقَهُۥۚ بَل لَّجُّواْ فِي عُتُوّٖ وَنُفُورٍ ۝ أَفَمَن يَمۡشِي مُكِبًّا عَلَىٰ وَجۡهِهِۦٓ أَهۡدَىٰٓ أَمَّن يَمۡشِي سَوِيًّا عَلَىٰ صِرَٰطٖ مُّسۡتَقِيمٖ ۝ قُلۡ هُوَ ٱلَّذِيٓ أَنشَأَكُمۡ وَجَعَلَ لَكُمُ ٱلسَّمۡعَ وَٱلۡأَبۡصَٰرَ وَٱلۡأَفۡـِٔدَةَۚ قَلِيلٗا مَّا تَشۡكُرُونَ ۝ قُلۡ هُوَ ٱلَّذِي ذَرَأَكُمۡ فِي ٱلۡأَرۡضِ وَإِلَيۡهِ تُحۡشَرُونَ ۝ وَيَقُولُونَ مَتَىٰ هَٰذَا ٱلۡوَعۡدُ إِن كُنتُمۡ صَٰدِقِينَ ۝ قُلۡ إِنَّمَا ٱلۡعِلۡمُ عِندَ ٱللَّهِ وَإِنَّمَآ أَنَا۠ نَذِيرٞ مُّبِينٞ ۝ فَلَمَّا رَأَوۡهُ زُلۡفَةٗ سِيٓـَٔتۡ وُجُوهُ ٱلَّذِينَ كَفَرُواْ وَقِيلَ هَٰذَا ٱلَّذِي كُنتُم بِهِۦ تَدَّعُونَ ۝ قُلۡ أَرَءَيۡتُمۡ إِنۡ أَهۡلَكَنِيَ ٱللَّهُ وَمَن مَّعِيَ أَوۡ رَحِمَنَا فَمَن يُجِيرُ ٱلۡكَٰفِرِينَ مِنۡ عَذَابٍ أَلِيمٖ ۝ قُلۡ هُوَ ٱلرَّحۡمَٰنُ ءَامَنَّا بِهِۦ وَعَلَيۡهِ تَوَكَّلۡنَاۖ فَسَتَعۡلَمُونَ مَنۡ هُوَ فِي ضَلَٰلٖ مُّبِينٖ ۝ قُلۡ أَرَءَيۡتُمۡ إِنۡ أَصۡبَحَ مَآؤُكُمۡ غَوۡرٗا فَمَن يَأۡتِيكُم بِمَآءٖ مَّعِينِۭ ۝',
      translation:
          'Surah Al-Mulk (The Sovereignty) - Complete 30 verses. The Prophet ﷺ said: "Surah Al-Mulk is the protector from the torment of the grave." [Sunan At-Tirmidhi]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. (1) مەزنایەتی و پایەبەرزی بۆ ئەو کەسەی، خونکاری بە دەس خۆیەتی و لەسەر هەموو شت توانایە. (2) ئەوە کە مردن و ژینی داهێناوە، تا ئێوە تاقی کاتەوە کامتان ئاکاری جوانترە. هەر ئەویشە لێبوردەی خاوەن دەستەڵات. (3) ئەوکەسەی حەو ئاسمانی چین لەسەر چینی سازداوە. لە دەسکاری ئەو خودایەدا هیچ ناڕێکییەک نابینی. جارێکی تر تماشا کە، ئاخۆ قەڵشێکی تێدایە؟ (4) دیسانەوە چاوی پێدا بگێڕەوە. سۆمای چاوت بە داماوی و بە ڕاماوی بەرەو خۆت دەگەڕێتەوە. (5) ئێمە ئاسمانی دنیامان بە زۆر چرا ڕازاندەوە. کردیشمانن بە کەرستەی ڕاوەدوو نانی شەیتانان. ئازاری گڕپەداریشمان بۆ ساز کردون. (6) بۆ ئەوانەش کە بڕوایان بە پەروەرندەیان نییە، جەزرەبەی جەهەندەم هەیە و ئای چ ئەنجامێ خراپە! (7) گەر دەیانهاوینە ناوی، نێڵەنێڵی جەهەندەمیان گوێ لێ دەبێ و هەر هەڵدەچێ. (8) وەختە لە داخا شەق بەرێ. تا جوونێکی تێ داوێژن، گزیرەکانی جەهەندەم پێیان ئێژن: ئاخۆ ئێوە ترسێنەرتان نەهاتە لا؟ (9) ئێژن: بەڵێ، ترسێنەر هاتبووە لامان؛ ئەوسا باوەڕمان پێ نەکرد و گوتمان: خوا هیچ شتی نەناردۆتە خوار؛ ئێوە بێ سۆ لەناو گومڕایی گەورەدان. (10) ئەشڵێن: ئەگەر گوێ بیس باین یاخۆ تێ گەیباین، نەدەبووینە یارانی ئەم ئاگردانە. (11) ئاوا گوناهانی خۆیان پێ لێ دەنێن. هەی لە ئارادا نەمێنن ئەم هەواڵانی دۆژەهە! (12) ئەوکەسانەی - لە نەدیدە - لە پەروەرێنیان ئەترسن، لێخۆشبوون و پاداشی گەورەیان هەیە. (13) ئێوە سرتە قسە بکەن، یان وە دەنگی بەرزی بێژن، ئەو لە ڕازێ کە بە دڵاندا دەبوورێ ئاگادارە. (14) ئاخۆ کەسێ ئافراندوویە، چۆن نازانێ؟ وردیلەبین و ئاگادار، هەر خۆیەتی. (15) ئەوە کە ئەم زەمینەی بۆ کەوی کردوون، شانەوشان تێیدا بگەڕێن و لە بژیوەکەی بخۆن. هەستانەوەش بۆ لای ئەوە. (16) ئاخۆ ئێوە لەو کەسەی لە ئاسمانە ترسوو نییە، کە بە هەردا ڕۆتان بەرێ و لەپڕ زەوین بێتە لەرین؟ (17) ئاخۆ ئێوە لەو کەسەی لە ئاسمانە ترسوو نییە، باڕنێکی زیخ و چەوتان لێ هەڵبکا؟ ئەوساکە زوو پێدەزانن هەڕەشەی من چتۆ بووە. (18) خۆ بەر لەوانەش هەر هەبوون بە نیشانەکانی منیان بڕوا نەبووە؛ سا چۆنیان بە گژدا هاتم. (19) ئاخۆ ئەوان ئەو مەلانەیان نەدیون کە لەسەرووی ئەوانەوە لەنگەریانە و باڵ لێک دەدەن؟ غەیرەز خودا کێ دەتوانێ ڕاگیریان کا؟ خودا بۆ خۆی لە هەموو شت چاوەدێرە. (20) ئاخۆ بەغەیری ئەو کێیە سوپا و یاریدەدەرتان بێ؟ نەخێر خودانەناسەکان [بەخۆبینی] خەڵەتاون. (21) ئەدی کێیە ئەو کەسەی بژیوتان دەدا، ئەگەر بژیوی لێ بڕین؟ نەخێر ئەوان لەسەر خۆ بە زل زانین و ڕەوینەوە پێداگرن. (22) ئاخۆ کەسێ دەمەوڕوو بە هەردا دەخشێ چاکتر بە ڕێگە دەزانێ، یان ئەو کەسەی بە ئاسایی بەسەر ڕاستەڕێدا دەڕوا؟ (23) بێژە: ئەوە کە ئێوەی وەدی هێناوە و گۆش و چەم و دڵی دانێ. ئێوە کەمتر شوکرێ دەکەن. (24) بێژە: ئەوە کە ئێوەی لەم زەمینەدا پەرژ و بڵاو کردۆتەوە؛ لای ئەویش کۆ دەکرێنەوە. (25) دەشڵێن: ئەگەر ئێوە ڕاستن، ئەو بەڵێنەو کەی دێتە جێ؟ (26) بێژە: تەنیا خودا لەمە ئاگادارە. من هەر ئەوەندەم لەسەرە پێتان بێژم: دەبێ لە خودا بترسن. (27) جا ئەو کاتەی لە نزیکەوە دەیبینن، خوانەناسان چڕ و چاویان گرژ دەبێ و پێیان ئێژن: وا ئەمەیە کە ئێوە داواتان دەکرد. (28) بێژە: بە من بێژن ئەگەر، خودا من و ئەو کەسانەی لەگەڵ منن لەناو بەرێ، یان بەر بەزەییی خۆیمان خا، دەی سا کێ خودانەناسان لە ئێش و ژان دەپارێزێ؟ (29) بێژە: ئەوە خوای دڵاوا؛ باوەڕیمان پێ هێناوە و خۆمان هەر بەو سپاردووە؛ ئەنگۆش هەر بینا زانیتان کێ ئاشکرا گومڕا بووە. (30) بێژە: بە من بێژن ئەگەر ئاوەکەتان ڕۆ چوو بەناخی زەوینا، ئەوسا کێ ئاوی زەڵاڵی ڕەوانتان دە فریا دەخا؟',
      repeat: 1,
      source: 'سوورەتی الملک [سورة الملك: 1-30]',
    ),
    Azkar(
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: He is Allah, [who is] One. Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent. [Al-Ikhlas: 1-4]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: ئه‌و خوایه‌ی که ناوی الله‌ خوایه‌کی تاک و ته‌نهایه‌ (بێ هاوه‌ڵ و هاوتایه‌). خوا زاتێکی پایه‌دار و ده‌سه‌ڵاتداره، بێ‌نیازه و هه‌موو دروستکراوان پێویستیان پێیه‌تی. نه‌ که‌سی لێ بووه‌ و نه‌ خۆشی له که‌س بووه‌. و هه‌رگیز هیچ هاوتا و هاوشێوه‌یه‌کی بۆ نه‌بووه و نییه‌. [الإخلاص: 1-4]',
      repeat: 3,
      source: 'سوورەتی ئیخڵاس [112: 1-4]',
    ),
    Azkar(
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: I seek refuge in the Lord of daybreak From the evil of that which He created, And from the evil of darkness when it settles, And from the evil of the blowers in knots, And from the evil of an envier when he envies. [Al-Falaq: 1-5]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: په‌نا ده‌گرم به په‌روه‌ردگاری به‌ره‌به‌یان، له شه‌ڕ و خراپه‌ی هه‌موو ئه‌و شتانه‌ی دروستی کردوون، و له شه‌ڕ و خراپه‌ی تاریکی شه‌و کاتێک دادێت، و له شه‌ڕ و خراپه‌ی ئه‌و جادووگه‌رانه‌ی پف ده‌که‌ن له گرێیه‌کاندا، و له شه‌ڕ و خراپه‌ی حه‌سوود کاتێک حه‌سوودی ده‌بات. [الفلق: 1-5]',
      repeat: 3,
      source: 'سوورەتی فەلەق [113: 1-5]',
    ),
    Azkar(
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: I seek refuge in the Lord of mankind, The Sovereign of mankind, The God of mankind, From the evil of the retreating whisperer - Who whispers into the breasts of mankind - From among the jinn and mankind. [An-Nas: 1-6]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: په‌نا ده‌گرم به په‌روه‌ردگاری خه‌ڵکی، پادشا و خاوه‌نداری خه‌ڵکی، په‌رستراوی حه‌قیقی خه‌ڵکی، له شه‌ڕ و خراپه‌ی وه‌سوه‌سه‌ده‌ری پاشه‌کشه‌که‌ری خۆشاره‌وه‌ (شه‌یتان)، ئه‌وه‌ی که وه‌سوه‌سه ده‌خاته دڵ و سینه‌ی خه‌ڵکییه‌وه‌، چ له جنۆکه‌ بێت یان له مرۆڤ. [الناس: 1-6]',
      repeat: 3,
      source: 'سوورەتی ناس [114: 1-6]',
    ),
    Azkar(
      arabic:
          'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي ، وَبِكَ أَرْفَعُهُ ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا ، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
      translation:
          'In Your name my Lord, I lie down and in Your name I rise, so if You take my soul then have mercy upon it, and if You release it then protect it with that which You protect Your righteous slaves.',
      kurdishTranslation:
          'بە ناوی تۆوە ئەی پەروەردگارم پشتم دادەنێم و بە ناوی تۆوە هەڵیدەگرم، جا ئەگەر گیانم کێشا ئەوا ڕەحمی پێ بکە، وە ئەگەر بەرتدا ئەوا بیپارێزە بەوەی کە بەندە چاکەکانتی پێ دەپارێزیت.',
      repeat: 1,
      source: 'Sahih al-Bukhari & Muslim',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ إِنَّكَ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا ، لَكَ مَمَاتُهَا وَمَحْيَاهَا ، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا ، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ',
      translation:
          'O Allah, You have created my soul and it is You who take it. To You belongs its death and its life. If You grant it life, protect it, and if You let it die, forgive it. O Allah, I ask You for well-being.',
      kurdishTranslation:
          'خوایە، تۆ نەفسی منت دروستکردووە و هەر تۆش دەیکێشیت، مردن و ژیانی بۆ تۆیە، ئەگەر ژیانت پێ بەخشی بیپارێزە، و ئەگەر مراندت لێی خۆشبە، خوایە داوای عافیەتت لێ دەکەم.',
      repeat: 1,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      translation:
          'O Allah, protect me from Your punishment on the Day You resurrect Your servants.',
      kurdishTranslation:
          'خوایە، لە سزاکەت بپارێزە لەو ڕۆژەی بەندەکانت زیندوو دەکەیتەوە.',
      repeat: 3,
      source: 'Sunan Abu Dawud & At-Tirmidhi',
    ),
    Azkar(
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      translation: 'In Your name, O Allah, I live and I die.',
      kurdishTranslation: 'بە ناوی تۆی خوایە دەمرم و دەژیم.',
      repeat: 1,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic: 'سُبْحَانَ اللَّهِ',
      translation: 'Glory be to Allah.',
      kurdishTranslation: 'پاک و بێگەردە خوا لە هەموو کەم و کوڕییەک.',
      repeat: 33,
      source: 'Sahih al-Bukhari & Muslim',
    ),
    Azkar(
      arabic: 'الْحَمْدُ لِلَّهِ',
      translation: 'All praise is for Allah.',
      kurdishTranslation: 'هەموو ستایشێک بۆ خوایە.',
      repeat: 33,
      source: 'Sahih al-Bukhari & Muslim',
    ),
    Azkar(
      arabic: 'اللَّهُ أَكْبَرُ',
      translation: 'Allah is the Greatest.',
      kurdishTranslation: 'خوا گەورەتر و گەورەترینە.',
      repeat: 34,
      source: 'Sahih al-Bukhari & Muslim',
    ),
    Azkar(
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا ، وَكَفَانَا ، وَآوَانَا ، فَكَمْ مِمَّنْ لَا كَافِيَ لَهُ وَلَا مُؤْوِيَ',
      translation:
          'All praise is for Allah, Who fed us and gave us drink, and sufficed us and sheltered us, for how many are there who have no protector and no shelterer.',
      kurdishTranslation:
          'سوپاس و ستایش بۆ ئەو خوایەی کە خواردن و خواردنەوەی پێداوین و بەسی کردووین و جێگەی پێداوین، چەندین کەس هەن کە کەسیان نییە بەسیان بکات و جێگەیان بداتێ.',
      repeat: 1,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ ، وَرَبَّ الْعَرْشِ الْعَظِيمِ ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ ، فَالِقَ الْحَبِّ وَالنَّوَىٰ ، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْفُرْقَانِ ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ',
      translation:
          'O Allah, Lord of the seven heavens and Lord of the Mighty Throne, our Lord and Lord of all things, Splitter of the seed and date stone, Revealer of the Torah and the Gospel and the Quran, I seek refuge in You from the evil of all things, You have a grasp of their forelock.',
      kurdishTranslation:
          'خوایە، پەروەردگاری حەوت ئاسمان و پەروەردگاری عەرشی گەورە، پەروەردگارمان و پەروەردگاری هەموو شتێک، تۆ شکێنەری تۆو و دانەیت و تۆ نێرەری تەورات و ئینجیل و فەرمانیت. پەنات بۆ دەهێنم لە خراپی هەموو شتێک کە تۆ دەستی بەسەردا گرتووە.',
      repeat: 1,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي ، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ ، وَأَنْ أَقْتَرِفَ عَلَىٰ نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَىٰ مُسْلِمٍ',
      translation:
          'O Allah, Knower of the unseen and seen, Originator of the heavens and earth, Lord and Sovereign of all things: I testify that there is no deity except You. I seek refuge in You from the evil of myself and from the evil of Satan and his polytheism, and from committing evil against myself or bringing it upon a Muslim.',
      kurdishTranslation:
          'خوایە، زانای نهێنی و ئاشکرا، بەدیهێنەری ئاسمانەکان و زەوی، پەروەردگار و پاشای هەموو شتێک: شایەتی دەدەم کە هیچ پەرستراوێک بە حەق نییە جگە لە تۆ. پەنات پێدەگرم لە خراپەی نەفسی خۆم، و لە خراپەی شەیتان و هاوەڵبڕیاردانی، و لەوەی کە خراپەیەک بەسەر خۆمدا بهێنم یان ڕایکێشم بۆ سەر موسڵمانێک.',
      repeat: 1,
      source: 'Sunan Abu Dawud & At-Tirmidhi',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ ، رَغْبَةً وَرَهْبَةً إِلَيْكَ ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ',
      translation:
          'O Allah, I have submitted myself to You, I have entrusted my affair to You, I have turned my face toward You, and I have placed my back upon You, hoping in You and fearing You. There is no refuge or escape from You except to You. I believe in Your Book which You have revealed and in Your Prophet whom You have sent.',
      kurdishTranslation:
          'خوایە، نەفسی خۆمم سپاردووەتە دەستت، و کاروبارەکانم سپاردووەتە تۆ، و ڕووم کردووەتە تۆ، و پشتم بە تۆ بەستووە؛ بە هیوای پاداشت و ترسی سزاکەت. هیچ پەنابەرێک و هیچ ڕزگاربوونێک لە تۆ نییە جگە لە پەنابردن بۆ تۆ. باوەڕم هێناوە بەو کتێبە کە ناردووتە و بەو پێغەمبەرەی کە ناردووتە.',
      repeat: 1,
      source: 'Sahih al-Bukhari & Muslim',
    ),
  ];

  // ─── Waking Up Azkar (أذكار الاستيقاظ) ─── Hisnul Muslim 1-4
  static final List<Azkar> wakeupAzkar = [
    // 1 — Al-Bukhari / Muslim
    Azkar(
      arabic:
          'الحَمْدُ لِلّهِ الّذي أَحْيانا بَعْدَ ما أَماتَنا وَإليه النُّشور',
      translation:
          'Praise is to Allah Who gives us life after He has caused us to die and to Him is the return.',
      kurdishTranslation:
          'ستایش بۆ خوایە ئەوەی کە ژیانمانی دایەوە دوای ئەوەی مردنمانی کردبوو، و گەڕانەوەمان بۆ لای ئەوەیە.',
      repeat: 1,
      source: 'Al-Bukhari 11/113; Muslim 4/2083',
    ),
    // 2 — Al-Bukhari / Ibn Majah
    Azkar(
      arabic:
          'لا إلهَ إلاّ اللّهُ وَحْدَهُ لا شَريكَ له لهُ المُلكُ ولهُ الحَمدُ وهوَ على كلّ شيءٍ قدير سُبْحانَ اللهِ والحمْدُ لله ولا إلهَ إلاّ اللهُ واللهُ أكبَر وَلا حَولَ وَلا قوّة إلاّ باللّهِ العليّ العظيم رَبِّ اغْفرْ لي',
      translation:
          'There is none worthy of worship but Allah alone, Who has no partner. His is the dominion and to Him belongs all praise and He is able to do all things. Glory is to Allah. Praise is to Allah. There is none worthy of worship but Allah. Allah is the Most Great. There is no might and no power except with Allah, the Exalted, the Mighty. My Lord, forgive me.',
      kurdishTranslation:
          'هیچ پەرستراوێک نییە مەگەر خوا تەنها، هیچ هاوبەشێکی نییە. هی ئەوە مووڵکەکەیە و ستایشی هەمووی هی ئەوەیە، و ئەو لەسەر هەموو شتێک توانادارە. پاکی بۆ خوا، ستایش بۆ خوا، هیچ پەرستراوێک نییە مەگەر خوا، خوا گەورەتریینە. هیچ ئارام و توانایەک نییە مەگەر بە خوای بەرز و گەورە. پەروەردگارم، لێم ببورە.',
      repeat: 1,
      source: 'Al-Bukhari, Fathul-Bari 3/39; Ibn Majah 2/335',
    ),
    // 3 — At-Tirmidhi
    Azkar(
      arabic:
          'الحمدُ للهِ الذي عافاني في جَسَدي وَرَدَّ عَليَّ روحي وَأَذِنَ لي بِذِكْرِه',
      translation:
          'Praise is to Allah who gave strength to my body and returned my soul to me and permitted me to remember Him.',
      kurdishTranslation:
          'ستایش بۆ خوایە ئەوەی کە تەندرووستیم بە جەستەمدا بەخشی و ڕوحیمی بۆ گەڕاندەوە و مۆڵەتیم دا تا بیاددی کردنم بەجێ بهێنمە.',
      repeat: 1,
      source: 'At-Tirmidhi 5/473; Sahih Tirmidhi 3/144',
    ),
    // 4 — Al-Imran 190-200
    Azkar(
      arabic:
          'إِنَّ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ وَاخْتِلَافِ اللَّيْلِ وَالنَّهَارِ لَآيَاتٍ لِأُولِي الْأَلْبَابِ ۝ الَّذِينَ يَذْكُرُونَ اللَّهَ قِيَامًا وَقُعُودًا وَعَلَىٰ جُنُوبِهِمْ وَيَتَفَكَّرُونَ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ رَبَّنَا مَا خَلَقْتَ هَٰذَا بَاطِلًا سُبْحَانَكَ فَقِنَا عَذَابَ النَّارِ ۝ رَبَّنَا إِنَّكَ مَنْ تُدْخِلِ النَّارَ فَقَدْ أَخْزَيْتَهُ ۖ وَمَا لِلظَّالِمِينَ مِنْ أَنْصَارٍ ۝ رَبَّنَا إِنَّنَا سَمِعْنَا مُنَادِيًا يُنَادِي لِلإِيمَانِ أَنْ آمِنُوا بِرَبِّكُمْ فَآمَنَّا ۚ رَبَّنَا فَاغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا وَتَوَفَّنَا مَعَ الْأَبْرَارِ ۝ رَبَّنَا وَآتِنَا مَا وَعَدْتَنَا عَلَىٰ رُسُلِكَ وَلَا تُخْزِنَا يَوْمَ الْقِيَامَةِ ۗ إِنَّكَ لَا تُخْلِفُ الْمِيعَادَ ۝ فَاسْتَجَابَ لَهُمْ رَبُّهُمْ أَنِّي لَا أُضِيعُ عَمَلَ عَامِلٍ مِنْكُمْ مِنْ ذَكَرٍ أَوْ أُنْثَىٰ ۖ بَعْضُكُمْ مِنْ بَعْضٍ ۖ فَالَّذِينَ هَاجَرُوا وَأُخْرِجُوا مِنْ دِيَارِهِمْ وَأُوذُوا فِي سَبِيلِي وَقَاتَلُوا وَقُتِلُوا لَأُكَفِّرَنَّ عَنْهُمْ سَيِّئَاتِهِمْ وَلأُدْخِلَنَّهُمْ جَنَّاتٍ تَجْرِي مِنْ تَحْتِهَا الْأَنْهَارُ ثَوَابًا مِنْ عِنْدِ اللَّهِ ۗ وَاللَّهُ عِنْدَهُ حُسْنُ الثَّوَابِ ۝ لَا يَغُرَّنَّكَ تَقَلُّبُ الَّذِينَ كَفَرُوا فِي الْبِلَادِ ۝ مَتَاعٌ قَلِيلٌ ثُمَّ مَأْوَاهُمْ جَهَنَّمُ ۚ وَبِئْسَ الْمِهَادُ ۝ لَٰكِنِ الَّذِينَ اتَّقَوْا رَبَّهُمْ لَهُمْ جَنَّاتٌ تَجْرِي مِنْ تَحْتِهَا الْأَنْهَارُ خَالِدِينَ فِيهَا نُزُلًا مِنْ عِنْدِ اللَّهِ ۗ وَمَا عِنْدَ اللَّهِ خَيْرٌ لِلْأَبْرَارِ ۝ وَإِنَّ مِنْ أَهْلِ الْكِتَابِ لَمَنْ يُؤْمِنُ بِاللَّهِ وَمَا أُنْزِلَ إِلَيْكُمْ وَمَا أُنْزِلَ إِلَيْهِمْ خَاشِعِينَ لِلَّهِ لَا يَشْتَرُونَ بِآيَاتِ اللَّهِ ثَمَنًا قَلِيلًا ۗ أُولَٰئِكَ لَهُمْ أَجْرُهُمْ عِنْدَ رَبِّهِمْ ۗ إِنَّ اللَّهَ سَرِيعُ الْحِسَابِ ۝ يَا أَيُّهَا الَّذِينَ آمَنُوا اصْبِرُوا وَصَابِرُوا وَرَابِطُوا وَاتَّقُوا اللَّهَ لَعَلَّكُمْ تُفْلِحُونَ',
      translation:
          'Indeed, in the creation of the heavens and the earth and the alternation of the night and the day are signs for those of understanding - {190} Who remember Allah while standing or sitting or [lying] on their sides and give thought to the creation of the heavens and the earth, [saying], "Our Lord, You did not create this aimlessly; exalted are You [above such a thing]; then protect us from the punishment of the Fire. {191} Our Lord, indeed whoever You admit to the Fire - You have disgraced him, and for the wrongdoers there are no helpers. {192} Our Lord, indeed we have heard a caller calling to faith, [saying], \'Believe in your Lord,\' and we have believed. Our Lord, so forgive us our sins and remove from us our misdeeds and cause us to die with the righteous. {193} Our Lord, and grant us what You promised us through Your messengers and do not disgrace us on the Day of Resurrection. Indeed, You do not fail in Your promise." {194} And their Lord responded to them, "Never will I allow to be lost the work of [any] worker among you, whether male or female; you are of one another. So those who emigrated or were evicted from their homes or were harmed in My cause or fought or were killed - I will surely remove from them their misdeeds, and I will surely admit them to gardens beneath which rivers flow as reward from Allah, and Allah has with Him the best reward." {195} Be not deceived by the [uninhibited] movement of the disbelievers throughout the land. {196} [It is but] a small enjoyment; then their [final] refuge is Hell, and wretched is the resting place. {197} But those who feared their Lord will have gardens beneath which rivers flow, abiding eternally therein, as accommodation from Allah. And that which is with Allah is best for the righteous. {198} And indeed, among the People of the Scripture are those who believe in Allah and what was revealed to you and what was revealed to them, [being] humbly submissive to Allah. They do not exchange the verses of Allah for a small price. Those will have their reward with their Lord. Indeed, Allah is swift in account. {199} O you who have believed, persevere and endure and remain stationed and fear Allah that you may be successful. {200} [Ali \'Imran: 190-200]',
      kurdishTranslation:
          'به‌ڕاستی له‌ دروستکردنی ئاسمانه‌کان و زه‌ویدا و له‌ ئاڵوگۆڕی شه‌و و ڕۆژدا به‌ڵگه‌ و نیشانه‌ی زۆر هه‌ن بۆ که‌سانی ژیر و هۆشمه‌ند. {190} ئه‌وانه‌ی یادی خوا ده‌که‌ن له‌کاتێکدا که به‌پێوه‌ن یان دانیشتوون یان ڕاکشاون، و هه‌میشه‌ بیرده‌که‌نه‌وه له دروستبوونی ئاسمانه‌کان و زه‌ویدا: په‌روه‌ردگارا، تۆ ئه‌م هه‌موو دروستکراوانه‌ت بێ‌هوده‌ و بێ‌ئامانج دروست نه‌کردووه‌، پاکی و بێگه‌ردی شایسته‌ی تۆیه‌، ده تۆش بمانپارێزه له سزای ئاگری دۆزه‌خ. {191} په‌روه‌ردگارا، به‌ڕاستی تۆ هه‌رکه‌س بخه‌یته ناو ئاگری دۆزه‌خه‌وه‌ ئه‌وه ڕیسوا و شه‌رمه‌زارت کردووه‌، و بۆ ستەمکاران هیچ یاریده‌ده‌رێک نییه‌. {192} په‌روه‌ردگارا، به‌ڕاستی ئێمه گوێمان له بانگخوازێک بوو بانگی ده‌کرد بۆ ئیمان و ده‌یفه‌رموو: باوه‌ڕ بهێنن به په‌روه‌ردگارتان، ئێمه‌ش باوه‌ڕمان هێنا. په‌روه‌ردگارا، له‌ گوناهه‌کانمان خۆش ببه و چاوپۆشی بکه له‌ خراپه‌کارییه‌کانمان و له‌گه‌ڵ چاکه‌کاراندا بمانمرێنه‌. {193} په‌روه‌ردگارا، ئه‌و به‌ڵێنانه‌شمان بۆ بهێنه‌دی که له‌سه‌ر زاری پێغه‌مبه‌رانت به‌ ئێمه‌ت داوه‌، و له ڕۆژی قیامه‌تدا شه‌رمه‌زارمان مه‌که‌، بێگومان تۆ به‌ڵێن ناشکێنیت. {194} په‌روه‌ردگاریشیان دوعاکه‌یانی قبووڵ کرد که: به‌ڕاستی من هه‌وڵ و کرده‌وه‌ی هیچ کارکه‌رێکتان به‌زایه‌ ناده‌م، چ نێر بێت یان مێ، هه‌ندێکتان له هه‌ندێکی ترتانن. ئه‌وانه‌ی کۆچیان کرد و له ماڵ و وڵاتیان ده‌رکران و ئازار دران له پێناوی مندا و جه‌نگان و شه‌هید کران، سوێند بێت چاوپۆشی له‌ گوناهه‌کانیان ده‌که‌م و ده‌یانخه‌مه باخه‌کانی به‌هه‌شته‌وه که ڕووباره‌کان به‌ژێریاندا ده‌ڕوات، ئه‌مه‌ش پاداشتێکه له‌لایه‌ن خواوه‌ و خوا پاداشتی چاک و جوانی لایه‌. {195} (ئه‌ی ئیماندار) هاتوچۆ و ده‌سه‌ڵاتی بێباوه‌ڕان له شار و وڵاتاندا تۆ هه‌ڵنه‌خه‌ڵه‌تێنێت. {196} ڕابواردنێکی که‌مه و پاشان جێگایان دۆزه‌خه‌، و چه‌ند خراپه‌ ئه‌و جێگه‌یه‌! {197} به‌ڵام ئه‌وانه‌ی له په‌روه‌ردگاریان ترسان باخه‌کانی به‌هه‌شتیان بۆ هه‌یه‌ که ڕووباره‌کان به‌ژێریاندا ده‌ڕوات و هه‌میشه‌یی تێیدا ده‌مێننه‌وه‌، ئه‌مه‌ش پێشوازییه‌که له‌لایه‌ن خواوه‌، و ئه‌وه‌ی لای خوایه‌ بۆ چاکه‌کاران چاکترینه‌. {198} و به‌ڕاستی هه‌ندێک له ئه‌هلی کتێب هه‌ن که باوه‌ڕیان به خوا هه‌یه و به قورئانیش که بۆ ئێوه دابه‌زیوه و به‌وه‌ش که بۆ خۆیان دابه‌زیوه‌، له‌کاتێکدا ملکه‌چن بۆ خوا و ئایه‌ته‌کانی خوا به نرخێکی که‌م نافرۆشن، ئه‌وانه پاداشتیان لای په‌روه‌ردگاریانه‌، به‌ڕاستی خوا به په‌له لێپرسینه‌وه ده‌کات. {199} ئه‌ی ئه‌وانه‌ی باوه‌ڕتان هێناوه‌! ئارام بگرن و خۆڕاگر بن و ئاماده‌باش بن له سه‌نگه‌ردا و له‌ خوا بترسن، بۆ ئه‌وه‌ی سه‌رفراز بن. {200} [آل عمران: 190-200]',
      repeat: 1,
      source: 'دە ئایەتی کۆتایی سوورەتی ئالی عیمران [190-200]',
    ),
  ];

  static final List<Azkar> prayerAzkar = [
    Azkar(
      id: 1,
      arabic: 'أَسْتَغْفِرُ اللهَ',
      translation: 'I ask Allah for forgiveness.',
      kurdishTranslation: 'داوای لێخۆشبوون لە خوای گەورە دەکەم.',
      repeat: 3,
      source: 'داوای لێخۆشبوون',
    ),
    Azkar(
      id: 2,
      arabic:
          'اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      translation:
          'O Allah, You are Peace and from You comes peace. Blessed are You, O Owner of majesty and honor.',
      kurdishTranslation:
          'ئەی خوایە، تۆ خۆت سەلام و ئاشتییت، و سەلام و ئاشتی لەلای تۆوەیە. پڕبەرەکەتیت، ئەی خاوەنی شکۆ و ڕێز.',
      repeat: 1,
      source: 'دوعای سەلام',
    ),
    Azkar(
      id: 3,
      arabic:
          'لَا إِلَٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      translation:
          'There is no deity except Allah alone, without partner. To Him belongs sovereignty, and to Him belongs praise, and He is over all things competent.',
      kurdishTranslation:
          'هیچ پەرستراوێکی ڕاست نییە جگە لە خوای تەنها، هیچ هاوبەشێکی نییە. هەموو دەسەڵات و ستایش بۆ ئەوە، و ئەو بەسەر هەموو شتێکدا توانا‌دارە.',
      repeat: 1,
      source: 'تەوحید',
    ),
    Azkar(
      id: 4,
      arabic:
          'اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
      translation:
          'O Allah, none can withhold what You have given, none can give what You have withheld, and no fortune can benefit its possessor against You.',
      kurdishTranslation:
          'ئەی خوایە، هیچ کەسێک ناتوانێت ڕێگری لەوە بکات کە تۆ دەیبەخشیت، و هیچ کەسێک ناتوانێت ئەوە ببەخشێت کە تۆ ڕێگری لێدەکەیت. خاوەن سامان و پلە و پایە، لەلای تۆوە سامان و پلەکەی سوودی پێ ناگەیەنێت.',
      repeat: 1,
      source: 'دوعای بەخشین و ڕێگرتن',
    ),
    Azkar(
      id: 5,
      arabic:
          'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ، لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ، لَا إِلَهَ إِلَّا اللهُ، وَلَا نَعْبُدُ إِلَّا إِيَّاهُ، لَهُ النِّعْمَةُ وَلَهُ الْفَضْلُ، وَلَهُ الثَّنَاءُ الْحَسَنُ، لَا إِلَهَ إِلَّا اللهُ مُخْلِصِينَ لَهُ الدِّينَ وَلَوْ كَرِهَ الْكَافِرُونَ',
      translation:
          'There is no deity except Allah alone, without partner. To Him belongs sovereignty, and to Him belongs praise, and He is over all things competent. There is no power and no strength except with Allah. There is no deity except Allah, and we worship none but Him. To Him belong blessing, grace, and good praise. There is no deity except Allah, [being] sincere to Him in religion, even if the disbelievers dislike it.',
      kurdishTranslation:
          'هیچ پەرستراوێکی ڕاست نییە جگە لە خوای تەنها، هیچ هاوبەشێکی نییە. هەموو دەسەڵات و ستایش بۆ ئەوە و ئەو بەسەر هەموو شتێکدا توانا‌دارە. هیچ توانایەک و هیچ هێزێک نییە جگە بە یارمەتی خوا. هیچ پەرستراوێک نییە جگە لە خوا، و جگە لە ئەو هیچ کەسێک ناپەرستین. نیعمەت و فەزڵ بۆ ئەوە، و ستایشی جوانیش بۆ ئەوە. هیچ پەرستراوێک نییە جگە لە خوا؛ بە دڵپاکی دینمان تەنها بۆ ئەو دەکەین، هەرچەندە بێباوەڕان بەوە ڕازی نەبن.',
      repeat: 1,
      source: 'ذکری کۆکردنەوە',
    ),
    Azkar(
      id: 6,
      arabic: 'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ',
      translation:
          'O Allah, help me to remember You, thank You, and worship You in the best manner.',
      kurdishTranslation:
          'ئەی خوایە، یارمەتیم بدە بۆ یادکردنەوەی تۆ، سوپاسگوزاریت کردن، و بە باشترین شێوە پەرستنت کردن.',
      repeat: 1,
      source: 'دوعای یارمەتی بۆ عیبادەت',
    ),
    Azkar(
      id: 7,
      arabic: 'سُبْحَانَ اللهِ',
      translation: 'Glory be to Allah.',
      kurdishTranslation: 'پاک و بێگەردە خوا لە هەموو کەم و کوڕییەک.',
      repeat: 33,
      source: 'تەسبیح',
    ),
    Azkar(
      id: 8,
      arabic: 'الْحَمْدُ لِلَّهِ',
      translation: 'Praise be to Allah.',
      kurdishTranslation: 'هەموو ستایش و سوپاس بۆ خوایە.',
      repeat: 33,
      source: 'حەمد',
    ),
    Azkar(
      id: 9,
      arabic: 'اللهُ أَكْبَرُ',
      translation: 'Allah is the Greatest.',
      kurdishTranslation: 'خوا گەورەتر و بەرزترە لە هەموو شتێک.',
      repeat: 33,
      source: 'تەکبیر',
    ),
    Azkar(
      id: 10,
      arabic:
          'لَا إِلَٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      translation:
          'There is no deity except Allah alone, without partner. To Him belongs sovereignty, and to Him belongs praise, and He is over all things competent.',
      kurdishTranslation:
          'هیچ پەرستراوێکی ڕاست نییە جگە لە خوای تەنها، هیچ هاوبەشێکی نییە. هەموو دەسەڵات و ستایش بۆ ئەوە، و ئەو بەسەر هەموو شتێکدا توانا‌دارە.',
      repeat: 1,
      source: 'تەواوکردنی سەد',
    ),
    Azkar(
      id: 11,
      arabic:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      translation:
          'Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is [presently] before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great. [Al-Baqarah: 255]',
      kurdishTranslation:
          'خوا ئه‌و خوایه‌یه‌ که هیچ په‌رستراوێکی ڕاسته‌قینه‌ نییه‌ بێجگه له‌و، هه‌میشه‌ زیندووه‌ و ڕاگری هه‌موو بوونه‌وه‌ره، نه‌ وه‌نه‌وز و خه‌واڵوویی ده‌یگرێت و نه‌ خه‌و. هه‌رچی له‌ ئاسمانه‌کان و هه‌رچی له‌ زه‌ویدایه‌ هه‌ر هی ئه‌وه‌. کێیه ئه‌و که‌سه‌ی بتوانێت تکا و شه‌فاعه‌ت له‌لای ئه‌و بکات مه‌گه‌ر به‌ مۆڵه‌تی خۆی؟ ئاگاداره به هه‌موو ئه‌وه‌ی له‌به‌رده‌میانه‌ و ئه‌وه‌ی له‌پشتیانه‌، و که‌س هیچ شتێک له زانستی ئه‌و نازانێت مه‌گه‌ر به‌وه‌ی خۆی بیه‌وێت. کورسییه‌که‌ی هه‌موو ئاسمانه‌کان و زه‌وی گرتۆته‌وه و پاراستنی ئاسمانه‌کان و زه‌وی هیچ ماندووی ناکات؛ و هه‌ر ئه‌وه‌ پله‌به‌رز و گه‌وره‌ و پایه‌دار. [البقرة: 255]',
      repeat: 1,
      source: 'ئایەتی کورسی [البقرة: 255]',
    ),
    Azkar(
      id: 12,
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: He is Allah, [who is] One. Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent. [Al-Ikhlas: 1-4]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: ئه‌و خوایه‌ی که ناوی الله‌ خوایه‌کی تاک و ته‌نهایه‌ (بێ هاوه‌ڵ و هاوتایه‌). خوا زاتێکی پایه‌دار و ده‌سه‌ڵاتداره، بێ‌نیازه و هه‌موو دروستکراوان پێویستیان پێیه‌تی. نه‌ که‌سی لێ بووه‌ و نه‌ خۆشی له که‌س بووه‌. و هه‌رگیز هیچ هاوتا و هاوشێوه‌یه‌کی بۆ نه‌بووه و نییه‌. [الإخلاص: 1-4]',
      repeat: 1,
      source: 'سوورەتی ئیخڵاس [112: 1-4]',
    ),
    Azkar(
      id: 13,
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: I seek refuge in the Lord of daybreak From the evil of that which He created, And from the evil of darkness when it settles, And from the evil of the blowers in knots, And from the evil of an envier when he envies. [Al-Falaq: 1-5]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: په‌نا ده‌گرم به په‌روه‌ردگاری به‌ره‌به‌یان، له شه‌ڕ و خراپه‌ی هه‌موو ئه‌و شتانه‌ی دروستی کردوون، و له شه‌ڕ و خراپه‌ی تاریکی شه‌و کاتێک دادێت، و له شه‌ڕ و خراپه‌ی ئه‌و جادووگه‌رانه‌ی پف ده‌که‌ن له گرێیه‌کاندا، و له شه‌ڕ و خراپه‌ی حه‌سوود کاتێک حه‌سوودی ده‌بات. [الفلق: 1-5]',
      repeat: 1,
      source: 'سوورەتی فەلەق [113: 1-5]',
    ),
    Azkar(
      id: 14,
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
      translation:
          'In the name of Allah, the Entirely Merciful, the Especially Merciful. Say: I seek refuge in the Lord of mankind, The Sovereign of mankind, The God of mankind, From the evil of the retreating whisperer - Who whispers into the breasts of mankind - From among the jinn and mankind. [An-Nas: 1-6]',
      kurdishTranslation:
          'بە ناوی خوای بەخشندەی میهرەبان. بڵێ: په‌نا ده‌گرم به په‌روه‌ردگاری خه‌ڵکی، پادشا و خاوه‌نداری خه‌ڵکی، په‌رستراوی حه‌قیقی خه‌ڵکی، له شه‌ڕ و خراپه‌ی وه‌سوه‌سه‌ده‌ری پاشه‌کشه‌که‌ری خۆشاره‌وه‌ (شه‌یتان)، ئه‌وه‌ی که وه‌سوه‌سه ده‌خاته دڵ و سینه‌ی خه‌ڵکییه‌وه‌، چ له جنۆکه‌ بێت یان له مرۆڤ. [الناس: 1-6]',
      repeat: 1,
      source: 'سوورەتی ناس [114: 1-6]',
    ),
  ];

  static final List<Azkar> quranAzkar = [
    Azkar(
      arabic: 'وَقُلْ رَبِّ زِدْنِي عِلْمًا',
      translation: 'And say: My Lord, increase me in knowledge.',
      kurdishTranslation: 'بڵێ: پەروەردگارم، زانینم زیاد بکە.',
      repeat: 1,
      source: 'Quran 20:114',
    ),
    Azkar(
      arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      translation:
          'Our Lord, grant us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
      kurdishTranslation:
          'پەروەردگارمان، لە دونیا و دواڕۆژدا چاکی بۆمان بدە، و لە سزای دۆزەخ بپارێزە.',
      repeat: 1,
      source: 'Quran 2:201',
    ),
    Azkar(
      arabic: 'رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      translation: 'Our Lord, do not hold us accountable if we forget or make a mistake. Do not burden us with what we cannot bear. Pardon us, forgive us, and have mercy on us. You are our Protector, so help us.',
      kurdishTranslation: 'پەروەردگارمان، ئەگەر لەبیرمان چوو یان هەڵەمان کرد، لێمان مەپرسە. ئەو بارەمان مەخە سەر کە توانای هەڵگرتنی نییە. لێمان خۆش ببە، بیبورە و ڕەحممان پێ بکە؛ تۆ سەرپەرشتیاری ئێمەیت، کەواتە یارمەتیمان بدە.',
      repeat: 1,
      source: 'Quran 2:286',
    ),
    Azkar(
      arabic: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ',
      translation: 'Our Lord, do not let our hearts deviate after You have guided us, and grant us mercy from You. Indeed, You are the Bestower.',
      kurdishTranslation: 'پەروەردگارمان، دڵەکانمان لە دوای ڕێنموونیکردنت لادەر مەکە، و لەلای خۆتەوە ڕەحمەتێکمان پێ ببەخشە؛ بەڕاستی تۆ بەخشەرترینی.',
      repeat: 1,
      source: 'Quran 3:8',
    ),
    Azkar(
      arabic: 'رَبَّنَا إِنَّنَا سَمِعْنَا مُنَادِيًا يُنَادِي لِلْإِيمَانِ أَنْ آمِنُوا بِرَبِّكُمْ فَآمَنَّا ۚ رَبَّنَا فَاغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا وَتَوَفَّنَا مَعَ الْأَبْرَارِ',
      translation: 'Our Lord, we heard a caller calling to faith, so we believed. Our Lord, forgive our sins, remove our misdeeds, and let us die among the righteous.',
      kurdishTranslation: 'پەروەردگارمان، گوێمان لە بانگەوازکەرێک بوو بۆ باوەڕ، ئێمەش باوەڕمان هێنا. پەروەردگارمان، گوناهەکانمان ببورە، خراپەکانمان بسڕەوە و لەگەڵ چاکان بمێرێنەوە.',
      repeat: 1,
      source: 'Quran 3:193',
    ),
    Azkar(
      arabic: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      translation: 'My Lord, make me an establisher of prayer, and many from my descendants. Our Lord, accept my supplication.',
      kurdishTranslation: 'پەروەردگارم، من و نەوەکانم بکە بە دامەزرێنەری نوێژ؛ پەروەردگارمان، دوعاکەم وەرگرە.',
      repeat: 1,
      source: 'Quran 14:40',
    ),
    Azkar(
      arabic: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      translation: 'Our Lord, grant us from our spouses and offspring comfort to our eyes and make us an example for the righteous.',
      kurdishTranslation: 'پەروەردگارمان، لە هاوسەر و نەوەکانمانەوە خۆشی و ڕووناکیی چاومان پێ ببەخشە، و ئێمە بکە بە نموونە بۆ پارێزگاران.',
      repeat: 1,
      source: 'Quran 25:74',
    ),
    Azkar(
      arabic: 'رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ ۝ وَأَعُوذُ بِكَ رَبِّ أَنْ يَحْضُرُونِ',
      translation: 'My Lord, I seek refuge in You from the incitements of the devils, and I seek refuge in You lest they be present with me.',
      kurdishTranslation: 'پەروەردگارم، پەنا دەگرم بە تۆ لە وسووسە و هاندانی شەیتانەکان، و پەنا دەگرم بە تۆ کە لەلای من ئامادە بن.',
      repeat: 1,
      source: 'Quran 23:97-98',
    ),
    Azkar(
      arabic: 'لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      translation: 'There is no deity except You; glory be to You. Indeed, I have been among the wrongdoers.',
      kurdishTranslation: 'هیچ پەرستراوێک نییە جگە لە تۆ؛ پاک و بێگەردیت. بەڕاستی من لە ستەمکاران بووم.',
      repeat: 1,
      source: 'Quran 21:87',
    ),
    Azkar(
      arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي ۝ وَيَسِّرْ لِي أَمْرِي ۝ وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي ۝ يَفْقَهُوا قَوْلِي',
      translation: 'My Lord, expand for me my chest, ease for me my task, and untie the knot from my tongue so that they may understand my speech.',
      kurdishTranslation: 'پەروەردگارم، سینگم فراوان بکە، کارەکەم ئاسان بکە، گرێی زمانم بکەرەوە تا قسەکەم تێبگەن.',
      repeat: 1,
      source: 'Quran 20:25-28',
    ),
    Azkar(
      arabic: 'رَبَّنَا وَاجْعَلْنَا مُسْلِمَيْنِ لَكَ وَمِن ذُرِّيَّتِنَا أُمَّةً مُّسْلِمَةً لَّكَ وَأَرِنَا مَنَاسِكَنَا وَتُبْ عَلَيْنَا ۖ إِنَّكَ أَنتَ التَّوَّابُ الرَّحِيمُ',
      translation: 'Our Lord, make us submissive to You, and from our descendants make a nation submissive to You. Show us our rites and accept our repentance. Indeed, You are the Accepting of repentance, the Most Merciful.',
      kurdishTranslation: 'پەروەردگارمان، ئێمە بکە بە ملکەچی خۆت، و لە نەوەکانمانەوە کۆمەڵێک دروست بکە کە ملکەچی تۆ بن. عیبەدەتمان پیشان بدە و تۆبەمان لێ وەرگرە؛ بەڕاستی تۆ زۆر تۆبەوەرگر و میهرەبانیت.',
      repeat: 1,
      source: 'Quran 2:128',
    ),
    Azkar(
      arabic: 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَتَوَفَّنَا مُسْلِمِينَ',
      translation: 'Our Lord, pour upon us patience and let us die as Muslims in submission to You.',
      kurdishTranslation: 'پەروەردگارمان، ئارامی و خۆڕاگریمان بەسەردا ببارێنە و بە موسڵمانی و ملکەچی خۆت بمێرێنەوە.',
      repeat: 1,
      source: 'Quran 7:126',
    ),
    Azkar(
      arabic: 'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      translation: 'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers.',
      kurdishTranslation: 'پەروەردگارمان، خۆمان ستەم لە خۆمان کردووە؛ ئەگەر لێمان خۆش نەبیت و ڕەحممان پێ نەکەیت، بەدڵنیایی لە زیانکاران دەبین.',
      repeat: 1,
      source: 'Quran 7:23',
    ),
    Azkar(
      arabic: 'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      translation: 'Our Lord, forgive me, my parents, and the believers on the Day the account is established.',
      kurdishTranslation: 'پەروەردگارمان، لە ڕۆژی دامەزرانی حیسابدا من و دایک و باوکم و هەموو باوەڕداران ببورە.',
      repeat: 1,
      source: 'Quran 14:41',
    ),
    Azkar(
      arabic: 'رَبِّ أَنزِلْنِي مُنزَلًا مُّبَارَكًا وَأَنتَ خَيْرُ الْمُنزِلِينَ',
      translation: 'My Lord, let me land at a blessed landing place, and You are the best to accommodate us.',
      kurdishTranslation: 'پەروەردگارم، لە شوێنێکی پڕ لە بەرەکەت جێگیرم بکە، و تۆ باشترینی جێگیرکەرانی.',
      repeat: 1,
      source: 'Quran 23:29',
    ),
    Azkar(
      arabic: 'رَبِّ هَبْ لِي حُكْمًا وَأَلْحِقْنِي بِالصَّالِحِينَ ۝ وَاجْعَل لِّي لِسَانَ صِدْقٍ فِي الْآخِرِينَ ۝ وَاجْعَلْنِي مِن وَرَثَةِ جَنَّةِ النَّعِيمِ',
      translation: 'My Lord, grant me wisdom and join me with the righteous. Grant me an honorable mention among later generations, and make me among the inheritors of the Garden of Bliss.',
      kurdishTranslation: 'پەروەردگارم، حیکمەت و دانایی پێم ببەخشە و بە چاکانم بگەیەنە. ناوی چاکم لە نەوەکانی دوای خۆمدا بەجێبهێڵە، و من بکە لە میراتگرانی بەهەشتی ناز و نیعمەت.',
      repeat: 1,
      source: 'Quran 26:83-85',
    ),
    Azkar(
      arabic: 'رَبِّ هَبْ لِي مِن لَّدُنكَ ذُرِّيَّةً طَيِّبَةً ۖ إِنَّكَ سَمِيعُ الدُّعَاءِ',
      translation: 'My Lord, grant me from You a good offspring. Indeed, You are the Hearer of supplication.',
      kurdishTranslation: 'پەروەردگارم، لەلای خۆتەوە نەوەیەکی چاکم پێ ببەخشە؛ بەڕاستی تۆ بیسەری دوعایت.',
      repeat: 1,
      source: 'Quran 3:38',
    ),
    Azkar(
      arabic: 'رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      translation: 'My Lord, indeed I am, for whatever good You would send down to me, in need.',
      kurdishTranslation: 'پەروەردگارم، بەڕاستی من پێویستم بە هەر چاکییەکە کە بۆم دەنێریت.',
      repeat: 1,
      source: 'Quran 28:24',
    ),
    Azkar(
      arabic: 'رَبَّنَا اغْفِرْ لَنَا وَلِإِخْوَانِنَا الَّذِينَ سَبَقُونَا بِالْإِيمَانِ وَلَا تَجْعَلْ فِي قُلُوبِنَا غِلًّا لِّلَّذِينَ آمَنُوا رَبَّنَا إِنَّكَ رَءُوفٌ رَّحِيمٌ',
      translation: 'Our Lord, forgive us and our brothers who preceded us in faith, and do not place in our hearts resentment toward those who believe. Our Lord, You are Kind and Merciful.',
      kurdishTranslation: 'پەروەردگارمان، ئێمە و برا باوەڕدارەکانمان ببورە کە پێش ئێمە باوەڕیان هێنا، و لە دڵماندا کینەی ئەوانەی باوەڕیان هێناوە مەخە. پەروەردگارمان، تۆ بەزەیی و میهرەبانیت.',
      repeat: 1,
      source: 'Quran 59:10',
    ),
  ];

  static final List<Azkar> generalAzkar = [
    Azkar(
      id: 81,
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ، وَأَعُوذُ بِكَ مِنَ النَّارِ',
      translation: 'O Allah, I ask You for Paradise, and I seek refuge in You from the Fire.',
      kurdishTranslation: 'خودایە داوای بەهەشتت لێ دەکەم، و پەنات پێ دەگرم لە ئاگری دۆزەخ. (ئەگەر 3 جار بگوترێت بەهەشت و دۆزەخ داوا دەکەن خوا بیباتە بەهەشت و لە دۆزەخ بیپارێزێت).',
      repeat: 3,
      source: 'سنن أبي داود (792)، جامع الترمذي (2572)، سنن النسائي (5521) - صحيح',
    ),
    Azkar(
      id: 82,
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَمَا قَرَّبَ إِلَيْهَا مِنْ قَوْلٍ أَوْ عَمَلٍ، وَأَعُوذُ بِكَ مِنَ النَّارِ وَمَا قَرَّبَ إِلَيْهَا مِنْ قَوْلٍ أَوْ عَمَلٍ',
      translation: 'O Allah, I ask You for Paradise and every word or deed that brings one closer to it, and I seek refuge in You from the Fire and every word or deed that brings one closer to it.',
      kurdishTranslation: 'خودایە داوای بەهەشتت لێ دەکەم و هەر وتە یان کردەوەیەک کە لێی نزیکم دەکاتەوە، و پەنات پێ دەگرم لە ئاگری دۆزەخ و هەر وتە یان کردەوەیەک کە لێی نزیکم دەکاتەوە.',
      repeat: 1,
      source: 'سنن ابن ماجه (3846)، مسند أحمد (25019) - صحيح',
    ),
    Azkar(
      id: 83,
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ شَرِّ سَمْعِي، وَمِنْ شَرِّ بَصَرِي، وَمِنْ شَرِّ لِسَانِي، وَمِنْ شَرِّ قَلْبِي، وَمِنْ شَرِّ مَنِيِّي',
      translation: 'O Allah, I seek refuge in You from the evil of my hearing, from the evil of my sight, from the evil of my tongue, from the evil of my heart, and from the evil of my desires.',
      kurdishTranslation: 'خودایە پەنات پێ دەگرم لە خراپەی بیستنم (گوێم)، لە خراپەی بینینم (چاوم)، لە خراپەی زمانم، لە خراپەی دڵم، و لە خراپەی ئارەزووی شەهوەتم.',
      repeat: 1,
      source: 'سنن أبي داود (1551)، جامع الترمذي (3492)، سنن النسائي (5444) - صحيح',
    ),
    Azkar(
      id: 84,
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْجُبْنِ، وَأَعُوذُ بِكَ مِنَ الْبُخْلِ، وَأَعُوذُ بِكَ مِنْ أَنْ أُرَدَّ إِلَى أَرْذَلِ الْعُمُرِ',
      translation: 'O Allah, I seek refuge in You from cowardice, I seek refuge in You from miserliness, and I seek refuge in You from reaching the most decrepit old age.',
      kurdishTranslation: 'خودایە پەنات پێ دەگرم لە ترسنۆکی، و پەنات پێ دەگرم لە ڕەزیلی و چاوچنۆکی، و پەنات پێ دەگرم لەوەی بگەمە تەمەنی هەرە پیری و بێ هێزی و لەدەستدانی هۆش.',
      repeat: 1,
      source: 'صحيح البخاري (2822)',
    ),
    Azkar(
      id: 85,
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي مِمَّا ابْتَلَاكَ بِهِ، وَفَضَّلَنِي عَلَى كَثِيرٍ مِمَّنْ خَلَقَ تَفْضِيلًا',
      translation: 'All praise is for Allah Who has spared me from that with which He has tested you, and has favored me over much of what He created with marked preference.',
      kurdishTranslation: 'سوپاس بۆ ئەو خوایەی کە پاراستمی لەو بەڵا و نەخۆشییەی تۆی پێ تاقیکردووەتەوە، و فەزڵ و ڕێزی دام بەسەر زۆرێک لە دروستکراوەکانیدا. (هەرکەس بیڵێت ئەو بەڵایەی تووش نابێت).',
      repeat: 1,
      source: 'جامع الترمذي (3431)، سنن ابن ماجه (3892) - حسن',
    ),
    Azkar(
      id: 86,
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ فِعْلَ الْخَيْرَاتِ، وَتَرْكَ الْمُنْكَرَاتِ، وَحُبَّ الْمَسَاكِينِ، وَإِذَا أَرَدْتَ بِعِبَادِكَ فِتْنَةً فَاقْبِضْنِي إِلَيْكَ غَيْرَ مَفْتُونٍ',
      translation: 'O Allah, I ask You for the performance of good deeds, the abandonment of evil deeds, love for the needy, and if You intend a trial for Your servants, take my soul to You without being subjected to the trial.',
      kurdishTranslation: 'خودایە داوای ئەنجامدانی کردەوە چاکەکانت لێ دەکەم، و دەستبەرداربوون لە کارە خراپەکان، و خۆشویستنی هەژاران؛ و ئەگەر ویستت فیتنە و تاقیکردنەوە بخەیتە نێو بەندەکانت، بە پاکی و بێ ئەوەی تووشی فیتنەکە بووبم گیانم بکێشە بۆ لای خۆت.',
      repeat: 1,
      source: 'جامع الترمذي (3235)، مسند أحمد (22109) - صحيح',
    ),
    Azkar(
      id: 87,
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الثَّبَاتَ فِي الْأَمْرِ، وَالْعَزِيمَةَ عَلَى الرُّشْدِ، وَأَسْأَلُكَ مُوجِبَاتِ رَحْمَتِكَ، وَعَزَائِمَ مَغْفِرَتِكَ',
      translation: 'O Allah, I ask You for steadfastness in all affairs, resolve upon righteousness, and I ask You for the means that draw Your mercy and the deeds that secure Your forgiveness.',
      kurdishTranslation: 'خودایە داوای دامەزراوی و چەسپاویت لێ دەکەم لە کارەکانمدا (لەسەر دین)، و ئیرادەی بەهێز لەسەر ڕێگای حەق و هیدایەت، و داوای ئەو هۆکارانەت لێ دەکەم کە ڕەحمەتی تۆ مسۆگەر دەکەن، و ئەو ئیرادەیەی کە لێخۆشبوونت بەدەستدەهێنێت.',
      repeat: 1,
      source: 'سنن النسائي (1304)، سنن الترمذي (3407) - صحيح',
    ),
    Azkar(
      id: 88,
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ قَلْبًا سَلِيمًا، وَلِسَانًا صَادِقًا، وَأَسْأَلُكَ مِنْ خَيْرِ مَا تَعْلَمُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا تَعْلَمُ',
      translation: 'O Allah, I ask You for a sound and pure heart, a truthful tongue, I ask You of the good that You know, and I seek refuge in You from the evil that You know.',
      kurdishTranslation: 'خودایە داوای دڵێکی پاک و سەلیم (لە شیرک و کینە) و زمانێکی ڕاستگۆت لێ دەکەم، و داوای ئەو خێرەت لێ دەکەم کە تۆ دەیزانیت، و پەنات پێ دەگرم لەو شەڕەی کە تۆ دەیزانیت.',
      repeat: 1,
      source: 'سنن النسائي (1304)، مسند أحمد (17114) - صحيح',
    ),
    Azkar(
      id: 89,
      arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      translation: 'I seek refuge in Allah from Satan the outcast.',
      kurdishTranslation: 'پەنا بە خودا دەگرم لە شەیتانی نەفرەتلێکراو و دەرکراو لە ڕەحمەت. (پێغەمبەر د.خ فەرمووی: ئەگەر کەسێکی تووڕە بیڵێت ئەوەی هەیەتی لێی لادەچێت).',
      repeat: 1,
      source: 'صحيح البخاري (6115)، صحيح مسلم (2610)',
    ),
    Azkar(
      id: 90,
      arabic: 'سُبْحَانَ اللَّهِ مِلْءَ الْمِيزَانِ، وَمُنْتَهَى الْعِلْمِ، وَمَبْلَغَ الرِّضَا، وَزِنَةَ الْعَرْشِ',
      translation: 'Glory be to Allah to the full extent of the Scale, to the limit of knowledge, to the utmost reach of pleasure, and to the weight of the Throne.',
      kurdishTranslation: 'پاکی و بێگەردی بۆ خودا بە ئەندازەی پڕیی تەرازوو، بە ئەوپەڕی زانست، بە تەواوی ڕەزامەندیی زاتی پیرۆزی، و بە کێشی عەرشە مەزنەکەی.',
      repeat: 3,
      source: 'مسند أحمد (22894) - حسن',
    ),
    Azkar(
      id: 91,
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ جَارِ السُّوءِ فِي دَارِ الْمُقَامَةِ؛ فَإِنَّ جَارَ الْبَادِيَةِ يَتَحَوَّلُ',
      translation: 'O Allah, I seek refuge in You from a bad neighbor in a permanent residence, for the nomad neighbor moves on.',
      kurdishTranslation: 'خودایە پەنات پێ دەگرم لە دراوسێی خراپ لە شوێنی نیشتەجێبوونی هەمیشەییمدا، چونکە دراوسێی کاتی و سەفەر جێگۆڕکێ دەکات و دەڕوات.',
      repeat: 1,
      source: 'سنن النسائي (5502)، الأدب المفرد (117) - حسن صحيح',
    ),
    Azkar(
      id: 92,
      arabic: 'اللَّهُمَّ اجْعَلْنِي شَكُورًا، وَاجْعَلْنِي صَبُورًا، وَاجْعَلْنِي فِي عَيْنِي صَغِيرًا، وَفِي أَعْيُنِ النَّاسِ كَبِيرًا',
      translation: 'O Allah, make me deeply grateful, make me abundantly patient, make me humble in my own eyes, and honorable in the eyes of people.',
      kurdishTranslation: 'خودایە بمکە بە بەندەیەکی زۆر شوکرگوزار، و بمکە بە بەندەیەکی زۆر ئارامگر، و لە چاوی نەفسی خۆمدا بە بچووک و بێفیزم دابنێ، و لە چاوی خەڵکیدا بە گەورە و بەڕێزم بکە.',
      repeat: 1,
      source: 'مجمع الزوائد للهيثمي (10/181)، البزار - حسن',
    ),
    Azkar(
      id: 93,
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْفَقْرِ، وَالْقِلَّةِ، وَالذِّلَّةِ، وَأَعُوذُ بِكَ مِنْ أَنْ أَظْلِمَ أَوْ أُظْلَمَ',
      translation: 'O Allah, I seek refuge in You from poverty, scarcity, and humiliation, and I seek refuge in You from wronging others or being wronged.',
      kurdishTranslation: 'خودایە پەنات پێ دەگرم لە هەژاری، لە کەمیی پێداویستی و سامان، و لە سەرشۆڕی و خوارژێری؛ و پەنات پێ دەگرم لەوەی ستەم لە کەس بکەم یان ستەمم لێ بکرێت.',
      repeat: 1,
      source: 'سنن أبي داود (1544)، سنن النسائي (5460) - صحيح',
    ),
    Azkar(
      id: 94,
      arabic: 'اللَّهُمَّ قَنِّعْنِي بِمَا رَزَقْتَنِي، وَبَارِكْ لِي فِيهِ، وَاخْلُفْ عَلَى كُلِّ غَائِبَةٍ لِي بِخَيْرٍ',
      translation: 'O Allah, make me content with what You have provided me, bless it for me, and replace anything I lose with what is better for me.',
      kurdishTranslation: 'خودایە دڵم پڕ بکە لە قەناعەت بەو ڕزقەی پێتم بەخشیوە، و بەرەکەتم بۆ تێدا بخە، و هەر شتێکم لەدەست چوو بە خێرتر بۆم قەرەبوو بکەرەوە.',
      repeat: 1,
      source: 'المستدرك للحاكم (1/510)، الأدب المفرد (681) - صحيح',
    ),
    Azkar(
      id: 95,
      arabic: 'اللَّهُمَّ أَلْهِمْنِي رُشْدِي، وَأَعِذْنِي مِنْ شَرِّ نَفْسِي',
      translation: 'O Allah, inspire me with sound guidance, and protect me from the evil of my own self.',
      kurdishTranslation: 'خودایە ڕێگای حەق و دروستم بخەرە دڵ (ئیلهامم پێ ببەخشە)، و بمپارێزە لە شەڕ و خراپەی نەفسی خۆم.',
      repeat: 1,
      source: 'جامع الترمذي (3483)، مسند أحمد - صحيح',
    ),
    Azkar(
      id: 96,
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْجُوعِ، فَإِنَّهُ بِئْسَ الضَّجِيعُ، وَأَعُوذُ بِكَ مِنَ الْخِيَانَةِ، فَإِنَّهَا بِئْسَتِ الْبِطَانَةُ',
      translation: 'O Allah, I seek refuge in You from hunger, for it is an evil companion, and I seek refuge in You from treachery, for it is an evil inward trait.',
      kurdishTranslation: 'خودایە پەنات پێ دەگرم لە برسییەتی چونکە بەڕاستی خراپترین هاونشینە، و پەنات پێ دەگرم لە خیانەت و ناپاکی چونکە بەڕاستی خراپترین خوو و خەسڵەتە.',
      repeat: 1,
      source: 'سنن أبي داود (1547)، سنن النسائي (5468) - حسن صحيح',
    ),
    Azkar(
      id: 97,
      arabic: 'السَّلَامُ عَلَيْكُمْ دَارَ قَوْمٍ مُؤْمِنِينَ، وَإِنَّا إِنْ شَاءَ اللَّهُ بِكُمْ لَاحِقُونَ',
      translation: 'Peace be upon you, O abode of believing people, and indeed we, if Allah wills, shall join you.',
      kurdishTranslation: 'سڵاوی خواتان لێ بێت ئەی ماڵی گەلی ئیمانداران، و بێگومان ئێمەش بە ویستی خودا پێتان دەگەینەوە.',
      repeat: 1,
      source: 'صحيح مسلم (249)',
    ),
    Azkar(
      id: 98,
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا الثَّوْبَ وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      translation: 'All praise is due to Allah Who clothed me with this garment and provided it for me without any power or strength on my part.',
      kurdishTranslation: 'سوپاس بۆ ئەو خوایەی ئەم پۆشاکەی پێ بەخشیم و کردی بە ڕزقم بە بێ هیچ هێز و توانایەکی خۆم. (گوناهەکانی ڕابردووی دەسڕدرێتەوە).',
      repeat: 1,
      source: 'سنن أبي داود (4023)، جامع الترمذي (3458) - حسن',
    ),
    Azkar(
      id: 99,
      arabic: 'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَمَا أَظْلَلْنَ، وَرَبَّ الْأَرَضِينَ السَّبْعِ وَمَا أَقْلَلْنَ، أَسْأَلُكَ خَيْرَ هَذِهِ الْقَرْيَةِ وَخَيْرَ أَهْلِهَا، وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ أَهْلِهَا',
      translation: 'O Allah, Lord of the seven heavens and all they overshadow, Lord of the seven earths and all they carry; I ask You for the good of this town and the good of its people, and I seek refuge in You from its evil and the evil of its people.',
      kurdishTranslation: 'خودایە، ئەی پەروەردگاری حەوت ئاسمانەکە و ئەوەی سێبەریان بەسەردا کردووە، و پەروەردگاری حەوت زەوییەکە و ئەوەی هەڵیانگرتووە؛ داوای خێری ئەم شارۆچکەیە و خێری دانیشتووانەکەیت لێ دەکەم، و پەنات پێ دەگرم لە شەڕی و لە شەڕی دانیشتووانەکەی.',
      repeat: 1,
      source: 'المستدرك للحاكم (2/100)، سنن النسائي الكبرى - حسن',
    ),
    Azkar(
      id: 100,
      arabic: 'بَارَكَ اللَّهُ لَكَ فِي أَهْلِكَ وَمَالِكَ، إِنَّمَا جَزَاءُ السَّلَفِ الْحَمْدُ وَالْأَدَاءُ',
      translation: 'May Allah bless you in your family and your wealth; the only reward for a loan is praise and repayment.',
      kurdishTranslation: 'خودا بەرەکەت بخاتە نێو خێزان و سامانەکەتەوە، بەڕاستی پاداشتی قەرز تەنها ستایش و دانەوەی تەواویەتی.',
      repeat: 1,
      source: 'سنن النسائي (4683)، سنن ابن ماجه (2424) - حسن',
    ),
    Azkar(
      id: 101,
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      translation: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
      kurdishTranslation: 'پەنا دەگرم بە وتە تەواوەکانی خودا لە شەڕی هەر شتێک کە دروستی کردووە. (هیچ شتێک زیانی پێ ناگەیەنێت تا ئەو کاتەی لەو شوێنە دەڕوات).',
      repeat: 3,
      source: 'صحيح مسلم (2708)',
    ),
    Azkar(
      id: 102,
      arabic: 'بِسْمِ اللَّهِ وَاللَّهُ أَكْبَرُ، اللَّهُمَّ هَذَا مِنْكَ وَلَكَ، اللَّهُمَّ تَقَبَّلْ مِنِّي',
      translation: 'In the Name of Allah, and Allah is the Greatest. O Allah, this is from You and for You. O Allah, accept it from me.',
      kurdishTranslation: 'بە ناوی خودا، و خودا لە هەموو شتێک گەورەترە. خودایە ئەمە لە ڕزقی تۆوەیە و بۆ تۆشە، خودایە لێمی قبووڵ بفەرموو.',
      repeat: 1,
      source: 'صحيح مسلم (1967)، سنن أبي داود (2795)',
    ),
    Azkar(
      id: 103,
      arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ (وتَفْلٌ عَنْ يَسَارِهِ ثَلَاثًا)',
      translation: 'I seek refuge in Allah from Satan the outcast (and spit dryly to the left three times).',
      kurdishTranslation: 'پەنا دەگرم بە خودا لە شەیتانی نەفرەتلێکراو (و 3 جار فوو دەکاتە لای چەپی بە بێ تف).',
      repeat: 3,
      source: 'صحيح مسلم (2203)',
    ),
    Azkar(
      id: 104,
      arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      translation: 'Allah is sufficient for us, and He is the best Disposer of affairs.',
      kurdishTranslation: 'خودامان بەسە و ئەو چاکترین سەرپەرشتیار و پشتیوانە. (ئیبراهیم لە ناو ئاگر و پێغەمبەر محەمەد لە کاتی کۆبوونەوەی دوژمنان فەرموویان).',
      repeat: 7,
      source: 'صحيح البخاري (4563)',
    ),
    Azkar(
      id: 105,
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ التَّرَدِّي، وَالْهَدْمِ، وَالْغَرَقِ، وَالْحَرِيقِ، وَأَعُوذُ بِكَ أَنْ يَتَخَبَّطَنِيَ الشَّيْطَانُ عِنْدَ الْمَوْتِ',
      translation: 'O Allah, I seek refuge in You from falling from a height, from being crushed under rubble, from drowning, from burning, and I seek refuge in You from Satan taking possession of me at the time of death.',
      kurdishTranslation: 'خودایە پەنات پێ دەگرم لە کەوتنەخوارەوە لە بەرزایی، لە داڕمانی دیوار و خانوو بەسەرمدا، لە خنکان لە ئاودا، و لە سووتان بە ئاگر؛ و پەنات پێ دەگرم لەوەی شەیتان لە کاتی سەرەمەرگدا فریوم بدات و دەستم بەسەردا بگرێت.',
      repeat: 1,
      source: 'سنن أبي داود (1552)، سنن النسائي (5531) - صحيح',
    ),
    Azkar(
      id: 106,
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      translation: 'Glory be to Allah and His is the praise; I seek the forgiveness of Allah and repent to Him.',
      kurdishTranslation: 'پاکی و ستایش بۆ خودا، داوای لێخۆشبوون لە خودا دەکەم و دەگەڕێمەوە بۆ لای بە تۆبەکردن.',
      repeat: 100,
      source: 'صحيح مسلم (484)',
    ),
    Azkar(
      id: 107,
      arabic: 'أَذْهِبِ الْبَاسَ رَبَّ النَّاسِ، اشْفِ وَأَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
      translation: 'Remove the affliction, O Lord of mankind, and bring healing, for You are the Healer. There is no healing except Your healing—a healing that leaves behind no disease.',
      kurdishTranslation: 'ئەی پەروەردگاری هەموو خەڵکی ئەم ئازار و ناڕەحەتییە لابەرە! شیفا ببەخشە چونکە تەنها هەر تۆیت شیفابەخش، هیچ شیفایەک نییە بێجگە لە شیفای تۆ نەبێت، شیفایەک کە هیچ نەخۆشی و دەردێک بەجێناهێڵێت.',
      repeat: 1,
      source: 'صحيح البخاري (5743)، صحيح مسلم (2191)',
    ),
    Azkar(
      id: 108,
      arabic: 'اللَّهُمَّ اغْفِرْ لِأَبِي وَأُمِّي، وَارْفَعْ دَرَجَتَهُمَا فِي الْمَهْدِيِّينَ',
      translation: 'O Allah, forgive my father and mother, and elevate their rank among the rightly guided.',
      kurdishTranslation: 'خودایە لە دایک و باوکم خۆش ببە، و پلە و پایەیان بەرز بکەرەوە لە نێو ڕێنموونیکراوان لە بەهەشتدا.',
      repeat: 1,
      source: 'مستنبط من صحيح مسلم (920)، مسند أحمد (10610) - صحيح',
    ),
    Azkar(
      id: 109,
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الرِّضَا بَعْدَ الْقَضَاءِ، وَبَرْدَ الْعَيْشِ بَعْدَ الْمَوْتِ، وَلَذَّةَ النَّظَرِ إِلَى وَجْهِكَ، وَالشَّوْقَ إِلَى لِقَائِكَ',
      translation: 'O Allah, I ask You for contentment after the decree, for the coolness of life after death, for the delight of gazing upon Your noble Face, and for the longing to meet You.',
      kurdishTranslation: 'خودایە داوای ڕازیبوونم لێ دەکەم دوای دەرچوونی بڕیارەکانت (قەزاکەت)، و ژیانێکی ئاسوودە و فێنک دوای مردن، و چێژی سەیرکردنی ڕوخساری پیرۆزت، و شەوق و پەرۆشی بۆ گەیشتن بە دیدارت لە بەهەشتدا.',
      repeat: 1,
      source: 'سنن النسائي (1305)، مسند أحمد (18325) - صحيح',
    ),
    Azkar(
      id: 110,
      arabic: 'لَا إِلَهَ إِلَّا اللَّهُ',
      translation: 'There is no true deity worthy of worship except Allah alone.',
      kurdishTranslation: 'هیچ پەرستراوێک نییە شایستەی پەرستن بێت بێجگە لە ئەڵڵا بە تەنیا. (پێغەمبەر د.خ فەرمووی: هەرکەس کۆتا قسەی دنیای ئەم وتەیە بێت دەچێتە بەهەشت).',
      repeat: 1,
      source: 'سنن أبي داود (3116)، مسند أحمد (22034) - صحيح',
    ),
  ];

  static final List<Azkar> ayatKursiAzkar = [
    Azkar(
      id: 255,
      arabic:
          'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا بِإِذۡنِهِۦۚ يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ وَمَا خَلۡفَهُمۡۖ وَلَا يُحِيطُونَ بِشَيۡءٖ مِّنۡ عِلۡمِهِۦٓ إِلَّا بِمَا شَآءَۚ وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَۖ وَلَا يَـُٔودُهُۥ حِفۡظُهُمَاۚ وَهُوَ ٱلۡعَلِيُّ ٱلۡعَظِيمُ',
      translation:
          'Allah - there is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
      kurdishTranslation:
          'خوا ئەو زاتەیە کە هیچ خوایەکی تر نییە شایەنی پەرستن بێت جگە لە ئەو، ئەو زاتەی هەمیشە زیندووە و ڕاگری بوونەوەرە. نە خەواڵوویی دەست بەسەردا دەگرێت و نە خەو. هەرچی لە ئاسمانەکان و زەویدایە هەر موڵکی ئەوە. کێیە بتوانێت شەفاعەت بکات لە لای بێ مۆڵەتی ئەو؟ ئەو دەزانێت چی لە پێشیانە و چی لە پشتیانە، هیچ شتێکیش لە زانستی ئەو دەستناکەوێت مەگەر ئەوەی خۆی بیەوێت. کورسییەکەی ئاسمانەکان و زەوی گرتۆتەوە، و پاراستنی هەردووکیانی پێ گران نییە. و ئەو بەرز و پایەدار و گەورەیە.',
      repeat: 1,
      source: 'سوورەتی البقرة: 255',
    ),
  ];

  static Map<String, List<Azkar>> getAzkarByCategory(String categoryId) {
    switch (categoryId) {
      case 'morning':
        return {'morning': morningAzkar};
      case 'evening':
        return {'evening': eveningAzkar};
      case 'sleep':
        return {'sleep': sleepAzkar};
      case 'wakeup':
        return {'wakeup': wakeupAzkar};
      case 'prayer':
        return {'prayer': prayerAzkar};
      case 'quran':
        return {'quran': quranAzkar};
      case 'ayat_kursi':
        return {'ayat_kursi': ayatKursiAzkar};
      case 'surah_mulk':
        return {'surah_mulk': ayatKursiAzkar}; // Will be loaded dynamically if in reading screen
      case 'surah_kahf':
        return {'surah_kahf': ayatKursiAzkar}; // Will be loaded dynamically if in reading screen
      case 'general':
        return {'general': generalAzkar};
      default:
        return {'morning': morningAzkar};
    }
  }
}
