const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'lib/models/app_data.dart');
let content = fs.readFileSync(filePath, 'utf-8');

const newSleepAzkar = `  static final List<Azkar> sleepAzkar = [
    Azkar(
      arabic:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      translation:
          'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
      kurdishTranslation:
          'خوا هیچ پەرستراوێک نییە جگە لە ئەو، زیندوو و بەڕێوەبەری هەموو بوونەوەرەکانە. نە خەواڵووبوون و نە خەوتن دەیگرێت. هەرچی لە ئاسمانەکان و زەوییە هی ئەوە. کێیە ئەوەی لەلای ئەو شەفاعەت بکات مەگەر بە مۆڵەتی ئەو؟ ئەو دەزانێت چی لەبەردەمیانە و چی لەپشتەوەیانە، و هیچ شتێک لە زانستی ئەو ناگرنەوە مەگەر بەوەی ئەو بیەوێت. کورسییەکەی ئاسمانەکان و زەویی گرتووەتەوە و پاراستنی ئەوان ماندووی ناکات؛ و ئەو بەرز و گەورەیە.',
      repeat: 1,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic:
          'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِّن رُّسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ ۚ لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      translation:
          'The Messenger has believed in what was revealed to him from his Lord, and so have the believers. All of them have believed in Allah and His angels and His books and His messengers, we make no distinction between any of His messengers. They say: We have heard and we obey, our Lord, Your forgiveness, and to You is the destination. Allah does not burden a soul beyond that it can bear. For it is what it has earned, and upon it is what it has deserved. Our Lord, do not impose blame upon us if we have forgotten or erred. Our Lord, and lay not upon us a burden like that which You laid upon those before us. Our Lord, and burden us not with what we have no ability to bear. And pardon us; and forgive us; and have mercy upon us. You are our protector, so give us victory over the disbelieving people.',
      kurdishTranslation:
          'پێغەمبەر باوەڕی هێنا بەوەی لەلایەن پەروەردگارەکەی بۆی نێردراوە و باوەڕدارانیش هەموویان باوەڕیان هێنا. هەموویان باوەڕ بە خوا و فریشتەکان و کتێبەکان و پێغەمبەرەکان هێناوە. ئیمە لە نێوان یەک لە پێغەمبەرەکانی دا جیاکردنەوە ناکەین. دوایان گوت: بیستمان و فێرمان برد. ئەی پەروەردگارمان، بەخشنت، و گەڕانەوەمان بۆ تۆیە. خوا ڕۆح و تواناتێک زیاتر بار دانی لە ئەوەی دەتوانێت پشتتێ بكات. هی ئەوەی بە دەستی هێنا و لێی بدات. ئەی پەروەردگارمان، ئیمە شتێکی بیرمان کەوتەوە یان هەڵە کردین، مان سزا مەدە. ئەی پەروەردگارمان، بارێکی قورس بەسەرمان مەدانە، هەمان بەسەرەوەی داوە. ئەی پەروەردگارمان، بارێکی نامان هیچ تواناتێکی بۆ نییە مەدانە. بمباڵێ لێمان، مان ببەخشە، بەزەییم پێدا بهێنە. تۆ مولای و پاسەوان و یاریدەدەرمانی، فیرۆزی دەکەنەوە لە گەڵ خەڵکی بێ‌باوەڕ.',
      repeat: 1,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic:
          'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      translation:
          'Say: He is Allah, [Who is] One, Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent.',
      kurdishTranslation:
          'بڵێ: ئەو خوایە تاک و تەنهایە. خوا بێ‌نیازە. نەیخستووەتە دنیا و خۆشی لەدایک نەبووە. هیچ کەسێک هاوتای ئەو نییە.',
      repeat: 3,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      translation:
          'Say: I seek refuge in the Lord of the dawn From the evil of that which He has created; And from the evil of darkness when it settles; And from the evil of those who blow on knots; And from the evil of the envier when he envies.',
      kurdishTranslation:
          'بڵێ: پەنای دەبەم بە پەروەردگاری بەیانی، لە خراپی ئەوەی دروستی کردووە، و لە خراپی تاریکی شەو کاتێک دێتە پێشەوە، و لە خراپی ئەوانەی لە گرێکاندا فوو دەکەن، و لە خراپی حەسوود کاتێک حەسودی دەکات.',
      repeat: 3,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
      translation:
          'Say: I seek refuge in the Lord of mankind, The Sovereign of mankind, The God of mankind, From the evil of the whisperer who withdraws, Who whispers [evil suggestions] into the breasts of mankind, From among the jinn and mankind.',
      kurdishTranslation:
          'بڵێ: پەنای دەبەم بە پەروەردگاری خەڵک، پاشای خەڵک، پەرستراوی خەڵک، لە خراپی ئەو وەسوەسەخەرەی خۆی دەشارێتەوە، ئەوەی وەسوەسە لە دڵی خەڵکدا دەخات، لە جین و مرۆڤ.',
      repeat: 3,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic: 'سُبْحَانَ اللَّهِ',
      translation: 'Glory be to Allah.',
      kurdishTranslation: 'پاک و بێگەردە خوا لە هەموو کەم و کوڕییەک.',
      repeat: 33,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic: 'الْحَمْدُ لِلَّهِ',
      translation: 'All praise is for Allah.',
      kurdishTranslation: 'هەموو ستایشێک بۆ خوایە.',
      repeat: 33,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic: 'اللَّهُ أَكْبَرُ',
      translation: 'Allah is the Greatest.',
      kurdishTranslation: 'خوا گەورەتر و گەورەترینە.',
      repeat: 34,
      source: 'Sahih Muslim',
    ),
    Azkar(
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      translation: 'By Your name, O Allah, I live and I die.',
      kurdishTranslation: 'بە ناوی تۆی خوایە دەمرم و دەژیم.',
      repeat: 1,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ. آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ.',
      translation:
          'O Allah, I have submitted myself to You, I have turned my face toward You, I have entrusted my affair to You, I have placed my back upon You, hoping in You and fearing You. There is no refuge or escape from You except to You. I believe in Your Book which You have revealed and in Your Prophet whom You have sent.',
      kurdishTranslation:
          'خوایە، خۆمم سپاردووەتە دەستت، ڕووم کردووەتە تۆ، کاروبارەکانمی سپاردووەتە تۆ، و پشتم بە تۆ بەستووە؛ بە هیوای پاداشت و ترسی سزاکەت. هیچ پەنابەرێک و هیچ ڕزگاربوونێک لە تۆ نییە جگە لە پەنابردن بۆ تۆ. باوەڕم بەو کتێبە هێناوە کە ناردووتە و بەو پێغەمبەرەش کە ناردووتە.',
      repeat: 1,
      source: 'Sahih al-Bukhari',
    ),
    Azkar(
      arabic: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      translation:
          'O Allah, protect me from Your punishment on the Day You resurrect Your servants.',
      kurdishTranslation:
          'خوایە، لە سزاکەت بپارێزە لەو ڕۆژەی بەندەکانت زیندوو دەکەیتەوە.',
      repeat: 1,
      source: 'Sunan Abu Dawud',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ، وَرَبَّ الْعَرْشِ الْعَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَىٰ، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْفُرْقَانِ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ.',
      translation:
          'O Allah, Lord of the seven heavens and Lord of the Mighty Throne, our Lord and Lord of all things, Splitter of the seed and date stone, Revealer of the Torah and the Gospel and the Quran, I seek refuge in You from the evil of all things, You have a grasp of their forelock.',
      kurdishTranslation:
          'خوایە، پەروەردگاری حەوت ئاسمان و پەروەردگاری عەرشی گەورە، پەروەردگارمان و پەروەردگاری هەموو شتێک، تۆ شکێنەری تۆو و دانەیت و تۆ نێرەری تەورات و ئینجیل و فەرمانیت. پەنات بۆ دەهێنم لە خراپی هەموو شتێک کە تۆ دەستی بەسەردا گرتووە.',
      repeat: 1,
      source: 'Sunan Abu Dawud',
    ),
    Azkar(
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ.',
      translation:
          'O Allah, I ask You for forgiveness and well-being in this world and the Hereafter.',
      kurdishTranslation:
          'خوایە، داوای لێبوردن و عافەت لە دنیا و دواڕۆژت لێدەکەم.',
      repeat: 1,
      source: 'Sunan Ibn Majah',
    ),
  ];`;

// Find and replace sleepAzkar
const sleepAzkarStart = content.indexOf('static final List<Azkar> sleepAzkar = [');
if (sleepAzkarStart === -1) {
  console.error('ERROR: Could not find sleepAzkar');
  process.exit(1);
}

// Find the closing bracket and semicolon
let bracketCount = 0;
let sleepAzkarEnd = -1;
for (let i = sleepAzkarStart + 'static final List<Azkar> sleepAzkar = '.length; i < content.length; i++) {
  if (content[i] === '[') bracketCount++;
  if (content[i] === ']') {
    bracketCount--;
    if (bracketCount === 0) {
      sleepAzkarEnd = i + 1;
      if (content[i + 1] === ';') sleepAzkarEnd = i + 2;
      break;
    }
  }
}

if (sleepAzkarEnd === -1) {
  console.error('ERROR: Could not find end of sleepAzkar');
  process.exit(1);
}

console.log(`Found sleepAzkar from ${sleepAzkarStart} to ${sleepAzkarEnd}`);
console.log(`Replacing ${sleepAzkarEnd - sleepAzkarStart} characters`);

// Replace the section
const newContent = content.substring(0, sleepAzkarStart) + newSleepAzkar + content.substring(sleepAzkarEnd);

// Write back
fs.writeFileSync(filePath, newContent, 'utf-8');
console.log('✓ sleepAzkar successfully updated!');
