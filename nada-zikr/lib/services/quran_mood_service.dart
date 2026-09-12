import 'package:flutter/material.dart';

import '../models/app_data.dart';
import 'quran_service.dart';

class QuranMoodPalette {
  final Color primary;
  final Color secondary;
  final Color surface;
  final String emoji;

  const QuranMoodPalette({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.emoji,
  });

  IconData get iconData {
    switch (emoji) {
      case '🌿':
        return Icons.spa_rounded;
      case '☁️':
        return Icons.cloud_rounded;
      case '✨':
        return Icons.auto_awesome_rounded;
      case '🌙':
        return Icons.bedtime_rounded;
      case '☀️':
        return Icons.sentiment_very_satisfied_rounded;
      case '💧':
        return Icons.water_drop_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }
}

class QuranMoodVerse {
  final int surah;
  final int ayah;
  final String arabicText;
  final String englishMeaning;
  final String? kurdishMeaning;
  final String theme;
  final String reflection;

  const QuranMoodVerse({
    required this.surah,
    required this.ayah,
    required this.arabicText,
    required this.englishMeaning,
    this.kurdishMeaning,
    required this.theme,
    required this.reflection,
  });

  String get location => 'Surah $surah:$ayah';
}

class QuranMoodSuggestion {
  final String moodId;
  final String title;
  final String shortMessage;
  final List<QuranMoodVerse> verses;

  const QuranMoodSuggestion({
    required this.moodId,
    required this.title,
    required this.shortMessage,
    required this.verses,
  });

  String get shareText => shareTextFor('en');

  String shareTextFor(String language) {
    final isKurdish = language == 'ku';
    final isArabic = language == 'ar';
    final lines = <String>[
      isKurdish ? 'کارتی هەستی قورئان' : isArabic ? 'بطاقة مزاج قرآنية' : 'Quran mood card',
      isKurdish ? 'هەست: $moodId' : isArabic ? 'المزاج: $moodId' : 'Mood: $moodId',
      title,
      shortMessage,
      '',
    ];

    for (final verse in verses) {
      lines.add(isKurdish
          ? 'سورەت ${verse.surah}:${verse.ayah}'
          : isArabic
              ? 'السورة ${verse.surah}:${verse.ayah}'
              : 'Surah ${verse.surah}:${verse.ayah}');
      lines.add(verse.arabicText);
      lines.add(isKurdish ? (verse.kurdishMeaning ?? verse.englishMeaning) : verse.englishMeaning);
      lines.add('');
    }

    return lines.join('\n');
  }
}

class QuranMoodService {
  QuranMoodService._();

  static final QuranMoodService instance = QuranMoodService._();

  final Map<String, QuranMoodPalette> _moodPalettes = {
    'grateful': const QuranMoodPalette(
      primary: Color(0xFF89B97A),
      secondary: Color(0xFF1C5E4A),
      surface: Color(0x1A89B97A),
      emoji: '🌿',
    ),
    'anxious': const QuranMoodPalette(
      primary: Color(0xFF7BA8D9),
      secondary: Color(0xFF1F3C5E),
      surface: Color(0x1A7BA8D9),
      emoji: '☁️',
    ),
    'hopeful': const QuranMoodPalette(
      primary: Color(0xFFE9C56B),
      secondary: Color(0xFF5B4B2A),
      surface: Color(0x1AE9C56B),
      emoji: '✨',
    ),
    'tired': const QuranMoodPalette(
      primary: Color(0xFFB590C8),
      secondary: Color(0xFF3E2E5E),
      surface: Color(0x1AB590C8),
      emoji: '🌙',
    ),
    'joyful': const QuranMoodPalette(
      primary: Color(0xFFF4B861),
      secondary: Color(0xFF7D4C1F),
      surface: Color(0x1AF4B861),
      emoji: '☀️',
    ),
    'sad': const QuranMoodPalette(
      primary: Color(0xFF8CA5C9),
      secondary: Color(0xFF2B3E59),
      surface: Color(0x1A8CA5C9),
      emoji: '💧',
    ),
  };

  final Map<String, List<QuranMoodVerse>> _library = {
    'grateful': [
      const QuranMoodVerse(
        surah: 14,
        ayah: 7,
        arabicText: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
        englishMeaning: 'If you are grateful, I will surely increase you.',
        theme: 'gratitude',
        reflection: 'Allah opens the door to more blessings when the heart stays thankful.',
      ),
      const QuranMoodVerse(
        surah: 16,
        ayah: 11,
        arabicText: 'يُرْسِلِ السَّمَاءَ عَلَيْكُم مِّدْرَارًا',
        englishMeaning: 'He sends down rain from the sky for you in abundance.',
        theme: 'blessing',
        reflection: 'The rain is a reminder that mercy often arrives gently but steadily.',
      ),
      const QuranMoodVerse(
        surah: 35,
        ayah: 3,
        arabicText: 'إِن تَشْكُرُوا يَشْكُرْ لَكُمْ',
        englishMeaning: 'If you are grateful, He will surely reward you.',
        theme: 'thankfulness',
        reflection: 'Gratitude is not only a feeling, it is a way of seeing life with mercy.',
      ),
      const QuranMoodVerse(
        surah: 31,
        ayah: 12,
        arabicText: 'قَدْ أَفْلَحَ مَن تَزَكَّى',
        englishMeaning: 'He has succeeded who purifies himself.',
        theme: 'purification',
        reflection: 'The soul grows lighter when it remembers what it has been given.',
      ),
      const QuranMoodVerse(
        surah: 2,
        ayah: 152,
        arabicText: 'فَاذْكُرُونِي أَذْكُرْكُمْ',
        englishMeaning: 'Remember Me, and I will remember you.',
        theme: 'connection',
        reflection: 'A thankful heart is an attentive heart; remembrance keeps it alive.',
      ),
      const QuranMoodVerse(
        surah: 39,
        ayah: 10,
        arabicText: 'وَسَيَجْزِي اللَّهُ الشَّاكِرِينَ',
        englishMeaning: 'And Allah will reward the grateful.',
        theme: 'reward',
        reflection: 'Your gratitude is never small in Allah’s sight.',
      ),
      const QuranMoodVerse(
        surah: 7,
        ayah: 96,
        arabicText: 'لَوْ أَنَّ أَهْلَ الْقُرَى آمَنُوا',
        englishMeaning: 'If only the people of the towns had believed and been mindful.',
        theme: 'faith',
        reflection: 'Belief turns ordinary days into signs of mercy and abundance.',
      ),
      const QuranMoodVerse(
        surah: 30,
        ayah: 41,
        arabicText: 'ظَهَرَ الْفَسَادُ فِي الْبَرِّ وَالْبَحْرِ',
        englishMeaning: 'Corruption has appeared on land and sea because of what people’s hands have done.',
        theme: 'awareness',
        reflection: 'Gratitude protects the heart from forgetting the Source of every blessing.',
      ),
      const QuranMoodVerse(
        surah: 6,
        ayah: 162,
        arabicText: 'إِنَّ صَلَاتِي وَنُسُكِي وَمَحْيَايَ وَمَمَاتِي',
        englishMeaning: 'Indeed, my prayer, my rites, my living and my dying are for Allah.',
        theme: 'devotion',
        reflection: 'Everything becomes meaningful when gratitude is shaped by submission.',
      ),
      const QuranMoodVerse(
        surah: 27,
        ayah: 40,
        arabicText: 'مَن كَانَ يُرِيدُ الْعِزَّةَ فَلِلَّهِ الْعِزَّةُ جَمِيعًا',
        englishMeaning: 'Whoever desires honor, then to Allah belongs all honor.',
        theme: 'humility',
        reflection: 'True gratitude is humble enough to recognize the Giver of every good thing.',
      ),
    ],
    'anxious': [
      const QuranMoodVerse(
        surah: 94,
        ayah: 5,
        arabicText: 'مَعَ الْعُسْرِ يُسْرًا',
        englishMeaning: 'With hardship comes ease.',
        theme: 'relief',
        reflection: 'Anxiety is never the end of the story; ease is already paired with the hardship.',
      ),
      const QuranMoodVerse(
        surah: 65,
        ayah: 2,
        arabicText: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
        englishMeaning: 'Whoever relies upon Allah, He is sufficient for him.',
        theme: 'trust',
        reflection: 'The heart can rest when it knows it is not carrying the whole burden alone.',
      ),
      const QuranMoodVerse(
        surah: 2,
        ayah: 286,
        arabicText: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
        englishMeaning: 'Allah does not burden a soul beyond what it can bear.',
        theme: 'capacity',
        reflection: 'Your struggle is not beyond your capacity; your heart is being guided through it.',
      ),
      const QuranMoodVerse(
        surah: 10,
        ayah: 62,
        arabicText: 'أَلَا إِنَّ أَوْلِيَاءَ اللَّهِ لَا خَوْفٌ عَلَيْهِمْ',
        englishMeaning: 'Indeed, the allies of Allah have no fear.',
        theme: 'safety',
        reflection: 'The safest place for a restless heart is the shelter of Allah.',
      ),
      const QuranMoodVerse(
        surah: 9,
        ayah: 51,
        arabicText: 'مَا أَصَابَكَ مِنْ حَسَنَةٍ فَمِنَ اللَّهِ',
        englishMeaning: 'Whatever good befalls you is from Allah.',
        theme: 'source',
        reflection: 'Not every answer is visible yet, but every mercy still has a Source.',
      ),
      const QuranMoodVerse(
        surah: 41,
        ayah: 30,
        arabicText: 'إِنَّ الَّذِينَ قَالُوا رَبُّنَا اللَّهُ',
        englishMeaning: 'Indeed, those who say, “Our Lord is Allah” then remain upright...',
        theme: 'steadfastness',
        reflection: 'A steady heart is built by returning to Allah before the fear grows louder.',
      ),
      const QuranMoodVerse(
        surah: 3,
        ayah: 139,
        arabicText: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا',
        englishMeaning: 'Do not weaken or grieve.',
        theme: 'courage',
        reflection: 'The heart can hold fear without letting fear become the whole truth.',
      ),
      const QuranMoodVerse(
        surah: 6,
        ayah: 16,
        arabicText: 'مَن يَهْدِ اللَّهُ فَهُوَ الْمُهْتَدِي',
        englishMeaning: 'Whomsoever Allah guides, none can mislead him.',
        theme: 'guidance',
        reflection: 'Even in uncertainty, guidance is still a living promise from Allah.',
      ),
      const QuranMoodVerse(
        surah: 16,
        ayah: 127,
        arabicText: 'وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا بِاللَّهِ',
        englishMeaning: 'Be patient, and your patience is only through Allah.',
        theme: 'patience',
        reflection: 'Patience is not about pretending not to struggle; it is about leaning on Allah.',
      ),
      const QuranMoodVerse(
        surah: 8,
        ayah: 46,
        arabicText: 'وَلَا تَكُونُوا كَالَّذِينَ خَرَجُوا',
        englishMeaning: 'Do not be like those who came out from their homes boastfully...',
        theme: 'reflection',
        reflection: 'Even difficult days can become a test of humility instead of panic.',
      ),
    ],
    'hopeful': [
      const QuranMoodVerse(
        surah: 39,
        ayah: 53,
        arabicText: 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا',
        englishMeaning: 'Say, “O My servants who have transgressed...”',
        theme: 'mercy',
        reflection: 'Mercy is still open, even when the heart feels far from its best state.',
      ),
      const QuranMoodVerse(
        surah: 13,
        ayah: 28,
        arabicText: 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ',
        englishMeaning: 'Those who believe and whose hearts find peace in the remembrance of Allah.',
        theme: 'peace',
        reflection: 'Hope grows where remembrance becomes the center of the heart.',
      ),
      const QuranMoodVerse(
        surah: 48,
        ayah: 5,
        arabicText: 'يَغْفِرْ لَكُمْ ذُنُوبَكُمْ',
        englishMeaning: 'He will forgive your sins.',
        theme: 'forgiveness',
        reflection: 'Even a tired heart can still be met with forgiveness and a fresh start.',
      ),
      const QuranMoodVerse(
        surah: 30,
        ayah: 60,
        arabicText: 'فَاصْبِرْ إِنَّ وَعْدَ اللَّهِ حَقٌّ',
        englishMeaning: 'Be patient; indeed, Allah’s promise is true.',
        theme: 'promise',
        reflection: 'Hope is not denial of pain but trust in Allah’s timing.',
      ),
      const QuranMoodVerse(
        surah: 15,
        ayah: 55,
        arabicText: 'قُلْ هُوَ الرَّحْمَٰنُ آمَنَّا بِهِ',
        englishMeaning: 'Say: He is the Most Merciful; we believe in Him.',
        theme: 'trust',
        reflection: 'A hopeful heart learns to stand on Allah’s mercy before circumstances change.',
      ),
      const QuranMoodVerse(
        surah: 17,
        ayah: 7,
        arabicText: 'إِنْ أَحْسَنتُمْ أَحْسَنتُمْ لِأَنفُسِكُمْ',
        englishMeaning: 'If you do good, you do good for yourselves.',
        theme: 'growth',
        reflection: 'The good you plant in hardship will return in ways you cannot yet see.',
      ),
      const QuranMoodVerse(
        surah: 9,
        ayah: 40,
        arabicText: 'إِلَّا تَصْرِفْ عَنَّا كَرْبَهُ',
        englishMeaning: 'If He does not remove the hardship from us...',
        theme: 'assurance',
        reflection: 'Allah can be near even in a moment that still feels heavy.',
      ),
      const QuranMoodVerse(
        surah: 11,
        ayah: 88,
        arabicText: 'وَلَا يَأْتِيهِمْ بَأْسُنَا',
        englishMeaning: 'And our punishment will not come to them suddenly.',
        theme: 'delay',
        reflection: 'Sometimes the waiting is part of the mercy, not a sign of abandonment.',
      ),
      const QuranMoodVerse(
        surah: 61,
        ayah: 11,
        arabicText: 'تُؤْمِنُونَ بِاللَّهِ وَرَسُولِهِ',
        englishMeaning: 'You believe in Allah and His Messenger.',
        theme: 'faith',
        reflection: 'Hope becomes stronger when it is rooted in faith, not only in outcomes.',
      ),
      const QuranMoodVerse(
        surah: 2,
        ayah: 255,
        arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
        englishMeaning: 'Allah — there is no deity except Him.',
        theme: 'sustenance',
        reflection: 'The heart can breathe when it remembers that Allah is the ultimate shelter.',
      ),
    ],
    'tired': [
      const QuranMoodVerse(
        surah: 73,
        ayah: 20,
        arabicText: 'إِنَّ رَبَّكَ يَعْلَمُ أَنَّكَ تَقُومُ أَدْنَى',
        englishMeaning: 'Indeed, your Lord knows that you stand up for prayer...',
        theme: 'rest',
        reflection: 'Even when you feel tired, your effort is seen and never lost in Allah’s sight.',
      ),
      const QuranMoodVerse(
        surah: 94,
        ayah: 5,
        arabicText: 'مَعَ الْعُسْرِ يُسْرًا',
        englishMeaning: 'With hardship comes ease.',
        theme: 'ease',
        reflection: 'Weariness is not a sign that your effort is useless; ease is being prepared.',
      ),
      const QuranMoodVerse(
        surah: 2,
        ayah: 153,
        arabicText: 'اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
        englishMeaning: 'Seek help through patience and prayer.',
        theme: 'support',
        reflection: 'When the body is weak, prayer becomes the quiet strength that keeps the heart steady.',
      ),
      const QuranMoodVerse(
        surah: 3,
        ayah: 200,
        arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اصْبِرُوا',
        englishMeaning: 'O believers, be patient.',
        theme: 'patience',
        reflection: 'Patience is not passivity; it is faith holding the line in weakness.',
      ),
      const QuranMoodVerse(
        surah: 12,
        ayah: 87,
        arabicText: 'لَا تَأْيَسُوا مِن رَوْحِ اللَّهِ',
        englishMeaning: 'Do not despair of Allah’s mercy.',
        theme: 'mercy',
        reflection: 'Tiredness can feel final, but mercy is never finished with a believing heart.',
      ),
      const QuranMoodVerse(
        surah: 16,
        ayah: 96,
        arabicText: 'مَنْ عَمِلَ صَالِحًا',
        englishMeaning: 'Whoever does righteous deeds will receive a reward.',
        theme: 'reward',
        reflection: 'Your quiet effort is still counted, even when you cannot feel the result yet.',
      ),
      const QuranMoodVerse(
        surah: 28,
        ayah: 80,
        arabicText: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
        englishMeaning: 'Indeed, with hardship comes ease.',
        theme: 'recovery',
        reflection: 'Your tired heart is not being abandoned; it is being prepared for restoration.',
      ),
      const QuranMoodVerse(
        surah: 18,
        ayah: 28,
        arabicText: 'وَاصْبِرْ نَفْسَكَ',
        englishMeaning: 'And be patient with yourself.',
        theme: 'self-kindness',
        reflection: 'Patience includes gentleness toward yourself when your strength is low.',
      ),
      const QuranMoodVerse(
        surah: 5,
        ayah: 54,
        arabicText: 'وَيَغْفِرْ لَكُمْ ذُنُوبَكُمْ',
        englishMeaning: 'And He will forgive your sins.',
        theme: 'forgiveness',
        reflection: 'A tired soul can still be met by Allah’s forgiveness without needing to be perfect.',
      ),
      const QuranMoodVerse(
        surah: 6,
        ayah: 125,
        arabicText: 'وَمَن يُرِدْ ثَوَابَ الدُّنْيَا',
        englishMeaning: 'Whoever seeks the reward of this world...',
        theme: 'balance',
        reflection: 'The soul finds rest when it remembers that real ease is tied to Allah’s wisdom.',
      ),
    ],
    'joyful': [
      const QuranMoodVerse(
        surah: 10,
        ayah: 26,
        arabicText: 'لِلَّذِينَ أَحْسَنُوا الْحُسْنَى',
        englishMeaning: 'For those who do good is the best reward.',
        theme: 'goodness',
        reflection: 'Joy is a sign that the heart is remembering the beauty of doing good.',
      ),
      const QuranMoodVerse(
        surah: 30,
        ayah: 37,
        arabicText: 'فَبِرَحْمَةٍ مِنَ اللَّهِ',
        englishMeaning: 'Then by mercy from Allah, you were gentle with them.',
        theme: 'mercy',
        reflection: 'A joyful heart notices the mercy that often hides inside everyday moments.',
      ),
      const QuranMoodVerse(
        surah: 16,
        ayah: 97,
        arabicText: 'مَنْ عَمِلَ صَالِحًا',
        englishMeaning: 'Whoever does good deeds will be rewarded.',
        theme: 'reward',
        reflection: 'Goodness has a living fragrance, even before the reward is visible.',
      ),
      const QuranMoodVerse(
        surah: 2,
        ayah: 261,
        arabicText: 'مَثَلُ الَّذِينَ يُنْفِقُونَ',
        englishMeaning: 'The example of those who spend in the cause of Allah is like a grain...',
        theme: 'generosity',
        reflection: 'Joy grows when the heart learns that giving also heals the giver.',
      ),
      const QuranMoodVerse(
        surah: 13,
        ayah: 29,
        arabicText: 'الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ',
        englishMeaning: 'Those who believe and do righteous deeds.',
        theme: 'faith',
        reflection: 'Joy is a natural companion to a life shaped by faith and good action.',
      ),
      const QuranMoodVerse(
        surah: 6,
        ayah: 160,
        arabicText: 'مَنْ جَاءَ بِالْحَسَنَةِ فَلَهُ عَشْرُ أَمْثَالِهَا',
        englishMeaning: 'Whoever comes with a good deed will have ten times its reward.',
        theme: 'multiplication',
        reflection: 'The smallest good act can create a much larger joy than we expect.',
      ),
      const QuranMoodVerse(
        surah: 35,
        ayah: 30,
        arabicText: 'إِنَّ الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ',
        englishMeaning: 'Indeed, those who believe and do righteous deeds...',
        theme: 'purpose',
        reflection: 'Joyful hearts often carry a clear purpose; they know their efforts matter.',
      ),
      const QuranMoodVerse(
        surah: 76,
        ayah: 12,
        arabicText: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَى',
        englishMeaning: 'And your Lord will give you, and you will be satisfied.',
        theme: 'satisfaction',
        reflection: 'The joy of the heart grows as it learns to trust Allah’s generosity.',
      ),
      const QuranMoodVerse(
        surah: 93,
        ayah: 5,
        arabicText: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَى',
        englishMeaning: 'And your Lord will give you, and you will be satisfied.',
        theme: 'fulfillment',
        reflection: 'Real joy is not loud; it is the calm certainty that Allah is enough.',
      ),
      const QuranMoodVerse(
        surah: 24,
        ayah: 4,
        arabicText: 'وَالَّذِينَ يَرْمُونَ الْمُحْصَنَاتِ',
        englishMeaning: 'And those who accuse chaste women...',
        theme: 'purity',
        reflection: 'A joyful heart also chooses clarity, dignity, and purity in its inner life.',
      ),
    ],
    'sad': [
      const QuranMoodVerse(
        surah: 94,
        ayah: 1,
        arabicText: 'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ',
        englishMeaning: 'Did We not expand your chest for you?',
        theme: 'comfort',
        reflection: 'Allah knows the heaviness of a burdened heart and still gives room to breathe.',
      ),
      const QuranMoodVerse(
        surah: 2,
        ayah: 153,
        arabicText: 'اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
        englishMeaning: 'Seek help through patience and prayer.',
        theme: 'support',
        reflection: 'The heart is not meant to carry sorrow alone; prayer is its shelter.',
      ),
      const QuranMoodVerse(
        surah: 12,
        ayah: 87,
        arabicText: 'لَا تَأْيَسُوا مِن رَوْحِ اللَّهِ',
        englishMeaning: 'Do not despair of Allah’s mercy.',
        theme: 'mercy',
        reflection: 'Sadness is a moment, but mercy is the greater reality of Allah’s care.',
      ),
      const QuranMoodVerse(
        surah: 3,
        ayah: 153,
        arabicText: 'لَا تَهِنُوا وَلَا تَحْزَنُوا',
        englishMeaning: 'Do not weaken or grieve.',
        theme: 'courage',
        reflection: 'A grieving heart can still be strong enough to return to Allah.',
      ),
      const QuranMoodVerse(
        surah: 20,
        ayah: 130,
        arabicText: 'فَاصْبِرْ عَلَى مَا يَقُولُونَ',
        englishMeaning: 'Be patient over what they say.',
        theme: 'steadfastness',
        reflection: 'Some sadness is not a sign of weakness; it is a sign of being human and still choosing Allah.',
      ),
      const QuranMoodVerse(
        surah: 17,
        ayah: 82,
        arabicText: 'وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ',
        englishMeaning: 'And We send down from the Quran that which is a healing.',
        theme: 'healing',
        reflection: 'The Quran is not only guidance; it is also a healing for the wounded heart.',
      ),
      const QuranMoodVerse(
        surah: 15,
        ayah: 49,
        arabicText: 'فَبَشِّرْ عِبَادِي',
        englishMeaning: 'So give good tidings to My servants.',
        theme: 'hope',
        reflection: 'Allah’s promise still reaches the heart even in sorrow.',
      ),
      const QuranMoodVerse(
        surah: 31,
        ayah: 17,
        arabicText: 'وَصَبْرِ',
        englishMeaning: 'And be patient.',
        theme: 'patience',
        reflection: 'The tears are real, but so is Allah’s care that keeps the heart from collapsing.',
      ),
      const QuranMoodVerse(
        surah: 41,
        ayah: 53,
        arabicText: 'سَنُرِيهِمْ آيَاتِنَا فِي الْآفَاقِ',
        englishMeaning: 'We will show them Our signs in the horizons and within themselves.',
        theme: 'reassurance',
        reflection: 'There are signs of Allah even in the deepest sadness.',
      ),
      const QuranMoodVerse(
        surah: 10,
        ayah: 4,
        arabicText: 'إِنَّ فِي ذَلِكَ لَآيَاتٍ لِّقَوْمٍ يَتَفَكَّرُونَ',
        englishMeaning: 'Indeed in that are signs for people who reflect.',
        theme: 'reflection',
        reflection: 'Sadness can become a doorway to reflection, gentleness, and renewed faith.',
      ),
    ],
  };

  QuranMoodSuggestion suggestForMood(String moodId) {
    final normalizedId = _library.containsKey(moodId) ? moodId : 'grateful';
    final verses = _library[normalizedId] ?? const <QuranMoodVerse>[];
    final titleMap = {
      'grateful': 'A heart that remembers blessings',
      'anxious': 'A reminder for a restless heart',
      'hopeful': 'A light for uncertain days',
      'tired': 'A gentle reminder to rest in Allah',
      'joyful': 'A gift of gratitude and joy',
      'sad': 'A comfort for a heavy heart',
    };

    final messageMap = {
      'grateful': 'Take a moment to thank Allah for what He has already given you.',
      'anxious': 'You are not alone. Allah is near, and relief is coming.',
      'hopeful': 'Hold on to hope — Allah’s mercy is greater than the weight you carry.',
      'tired': 'You do not need to carry everything alone. Rest in Him.',
      'joyful': 'Let gratitude deepen your joy and keep your heart connected to Allah.',
      'sad': 'Your heart is not unseen by Allah. He knows and He comforts.',
    };

    return QuranMoodSuggestion(
      moodId: normalizedId,
      title: titleMap[normalizedId] ?? 'A grounded reminder',
      shortMessage: messageMap[normalizedId] ?? 'Open your heart and return to Allah.',
      verses: verses.take(10).toList(),
    );
  }

  List<QuranMoodVerse> versesForMood(String moodId) {
    return [...(_library[moodId] ?? const <QuranMoodVerse>[])];
  }

  QuranMoodPalette themeFor(String moodId) {
    return _moodPalettes[moodId] ??
        const QuranMoodPalette(
          primary: Color(0xFF89B97A),
          secondary: Color(0xFF1C5E4A),
          surface: Color(0x1A89B97A),
          emoji: '🌿',
        );
  }

  bool supportsMood(String moodId) => _library.containsKey(moodId);

  Future<QuranMoodSuggestion> withKurdishTafsir(QuranMoodSuggestion suggestion) async {
    final verses = await Future.wait(
      suggestion.verses.map((verse) async {
        final kurdishMeaning = await QuranService.instance.getTafsir('asan', verse.surah, verse.ayah);
        return QuranMoodVerse(
          surah: verse.surah,
          ayah: verse.ayah,
          arabicText: verse.arabicText,
          englishMeaning: verse.englishMeaning,
          kurdishMeaning: kurdishMeaning,
          theme: verse.theme,
          reflection: verse.reflection,
        );
      }),
    );

    return QuranMoodSuggestion(
      moodId: suggestion.moodId,
      title: suggestion.title,
      shortMessage: suggestion.shortMessage,
      verses: verses,
    );
  }

  String moodLabel(String moodId, String lang) {
    final mood = AppData.moods.firstWhere(
      (item) => item.id == moodId,
      orElse: () => AppData.moods.first,
    );
    return mood.getDisplay(lang);
  }

  String titleFor(String moodId, String lang) {
    final english = {
      'grateful': 'A heart that remembers blessings',
      'anxious': 'A reminder for a restless heart',
      'hopeful': 'A light for uncertain days',
      'tired': 'A gentle reminder to rest in Allah',
      'joyful': 'A gift of gratitude and joy',
      'sad': 'A comfort for a heavy heart',
    };
    final kurdish = {
      'grateful': 'دڵێک کە بیرەوەرییەکان دەناسێت',
      'anxious': 'بیرخەرەوەیەک بۆ دڵێکی نائارام',
      'hopeful': 'ڕووناکییەک بۆ ڕۆژە نادیارەکان',
      'tired': 'بیرخەرەوەیەکی نەرم بۆ پشوودان لە پەناى خوا',
      'joyful': 'دیارییەک لە سوپاس و دڵخۆشی',
      'sad': 'دڵنەواییەک بۆ دڵێکی قورس',
    };
    final arabic = {
      'grateful': 'قلب يتذكر النعم',
      'anxious': 'تذكير لقلب قلق',
      'hopeful': 'نور للأيام غير الواضحة',
      'tired': 'تذكير لطيف بالراحة في رحمة الله',
      'joyful': 'هدية من الشكر والفرح',
      'sad': 'مواساة لقلب مثقل',
    };
    return (lang == 'ku' ? kurdish : lang == 'ar' ? arabic : english)[moodId] ?? english['grateful']!;
  }

  String messageFor(String moodId, String lang) {
    final english = {
      'grateful': 'Take a moment to thank Allah for what He has already given you.',
      'anxious': 'You are not alone. Allah is near, and relief is coming.',
      'hopeful': 'Hold on to hope — Allah’s mercy is greater than the weight you carry.',
      'tired': 'You do not need to carry everything alone. Rest in Him.',
      'joyful': 'Let gratitude deepen your joy and keep your heart connected to Allah.',
      'sad': 'Your heart is not unseen by Allah. He knows and He comforts.',
    };
    final kurdish = {
      'grateful': 'کەمێک وەستە و سوپاسی ئەو بەخششە بکە کە خوا پێی بەخشیویت.',
      'anxious': 'تەنیا نیت. خوا نزیکە و ئاسوودەیی دێت.',
      'hopeful': 'هیوا بەدەستهێنە؛ ڕەحمەتی خوا لە بارگرانییەکەی تۆ گەورەترە.',
      'tired': 'پێویست ناکات هەموو شتێک بە تەنیا هەڵبگریت. لە پەناى ئەو پشووبدە.',
      'joyful': 'با سوپاس دڵخۆشیت قووڵتر بکات و دڵت بە خواوە پەیوەست بێت.',
      'sad': 'دڵت لەلایەن خواوە نەبینراو نییە؛ ئەو دەیزانێت و دڵنەواییت دەکات.',
    };
    final arabic = {
      'grateful': 'خذ لحظة لشكر الله على ما منحك إياه.',
      'anxious': 'لست وحدك. الله قريب والفرج قادم.',
      'hopeful': 'تمسك بالأمل، فرحمة الله أوسع من حملك.',
      'tired': 'لا تحتاج إلى حمل كل شيء وحدك. استرح في كنفه.',
      'joyful': 'دع الشكر يعمق فرحك ويربط قلبك بالله.',
      'sad': 'قلبك ليس غائباً عن الله. إنه يعلم حزنك ويواسيك.',
    };
    return (lang == 'ku' ? kurdish : lang == 'ar' ? arabic : english)[moodId] ?? english['grateful']!;
  }
}
