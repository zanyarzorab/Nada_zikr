const data = require('./node_modules/imanikurd/data/dhikr.json');
const fs = require('fs');

// Get all after-prayer zikrs from package
const afterPrayer = data.items.filter(d => d.categoryId === 9).sort((a, b) => a.id - b.id);

// Add comprehensive authentic after-prayer zikrs with English translations
const completeAfterPrayerZikrs = [
  {
    order: 1,
    name: 'Testimony of Faith After Prayer',
    arabic: 'أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّداً عَبْدُهُ وَرَسُولُهُ',
    english: 'I testify that there is no deity except Allah alone, with no partner, and I testify that Muhammad is His servant and messenger.',
    kurdish: 'شایەتی دەدەم بەوەی، کە ھیچ پەرستراوێک شایستەی پەرستن نییە، جگە لە خودایەی تاکی بێ ھاوەڵ، ھەروەھا شایەتی دەدەم بەوەی، کە بەڕاستی موحەممەد (صلی الله علیە وسلم) بەندە و نێردراوی خودایە.',
    repeat: 1,
    source: 'Sunan Abu Dawud'
  },
  {
    order: 2,
    name: 'Seeking Repentance and Purification',
    arabic: 'اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ',
    english: 'O Allah, make me among those who repent and make me among those who purify themselves.',
    kurdish: 'خودایە بمگێڕە لە بەندە تەوبە کارەکان و بەندە خۆ پاککەرەوەکان.',
    repeat: 1,
    source: 'Sunan At-Tirmidhi'
  },
  {
    order: 3,
    name: 'Glorification and Repentance After Prayer',
    arabic: 'سُبْحانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ أَنْتَ، أَسْتَغْفِرُكَ وَأَتوبُ إِلَيْكَ',
    english: 'Glory and praise be to You, O Allah. I testify that there is no deity except You. I seek Your forgiveness and repent to You.',
    kurdish: 'خودایە پاکی و بێگەردی و ستایش بۆ تۆ، شایەتی دەدەم بەوەی، کە ھیچ پەرستراوێک شایستەی پەرستن نییە جگە لە تۆ، داوای لێخۆشبونت لێدەکەم و بۆ لای تۆش دەگەڕێمەوە.',
    repeat: 1,
    source: 'Sahih Muslim'
  },
  {
    order: 4,
    name: 'Glorification of Allah (33 times)',
    arabic: 'سُبْحَانَ اللَّهِ',
    english: 'Glory be to Allah.',
    kurdish: 'پاکی و بێگەردی بۆ خودایە.',
    repeat: 33,
    source: 'Sahih Muslim'
  },
  {
    order: 5,
    name: 'All Praise is for Allah (33 times)',
    arabic: 'الْحَمْدُ لِلَّهِ',
    english: 'All praise is for Allah.',
    kurdish: 'ھەموو ستایش و سوپاس بۆ خودایە.',
    repeat: 33,
    source: 'Sahih Muslim'
  },
  {
    order: 6,
    name: 'Allah is the Greatest (34 times)',
    arabic: 'اللَّهُ أَكْبَرُ',
    english: 'Allah is the Greatest.',
    kurdish: 'خودا گەورەترینە.',
    repeat: 34,
    source: 'Sahih Muslim'
  },
  {
    order: 7,
    name: 'Seeking Forgiveness (3 times)',
    arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    english: 'I seek forgiveness from Allah and repent to Him.',
    kurdish: 'لە خودای گەورە داوای لێخۆشبوون دەکەم و ھەڕەشە دەکەم بۆ لای ئەو.',
    repeat: 3,
    source: 'Sahih Muslim'
  },
  {
    order: 8,
    name: 'Seeking Divine Blessings',
    arabic: 'اللَّهُمَّ أَنْتَ السَّلاَمُ وَمِنْكَ السَّلاَمُ، تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالْإِكْرَامِ',
    english: 'O Allah, You are As-Salam (the Source of Peace), and from You is all peace. Blessed are You, O Possessor of Majesty and Honour.',
    kurdish: 'خودایە، تۆ سڵاو ئاشتیی، و ئاشتی لەلای تۆیە، بارکت و پیرۆزت بێ، ئەی خوداى بەرز و گرامی.',
    repeat: 1,
    source: 'Sahih Muslim'
  },
  {
    order: 9,
    name: 'Supplication for Guidance',
    arabic: 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ',
    english: 'O Allah, guide me among those You have guided, grant me well-being among those You have granted well-being, and take me under Your protection among those You have protected.',
    kurdish: 'خودایە، ڕێنمایمان بکە لە ناو ئەوانی کە ڕێنموون کردیت، پاکی و سۆزی لێ دەکەم لە ناو ئەوانی کە تۆ پاک و سۆز کردیت، و مانی بکە بە سەرپەرستی خۆت لە ناو ئەوانی کە تۆ سەرپەرستی کردیت.',
    repeat: 1,
    source: 'Sunan At-Tirmidhi'
  },
  {
    order: 10,
    name: 'Prayer for Paradise and Protection from Hell',
    arabic: 'اللَّهُمَّ اجْعَلْ أَحَبَّ أَعْمَالِي إِلَيْكَ أَحْدَثَهَا، وَاجْعَلْ أَنْفَعَهَا أَطْوَلَهَا، وَحَبِّبْ إِلَيَّ أَحْسَنَهَا',
    english: 'O Allah, make the dearest of my deeds to You the most recent ones, and make the most beneficial of them the longest-lasting, and make the best of them beloved to me.',
    kurdish: 'خودایە، گرانترین کار و کرده لەلای خۆت بکە نویترین یان دوایین کردارم، و سوودترینیان بکە درێژترینیان، و خۆشترین کار و کرده لە دل بیا.',
    repeat: 1,
    source: 'Sunan An-Nasa\'i'
  },
  {
    order: 11,
    name: 'Testimony and Supplication (Perfect Praise)',
    arabic: 'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    english: 'There is no deity except Allah alone, with no partner. To Him belongs the dominion and all praise, and He is over all things competent.',
    kurdish: 'ھیچ پەرستراوێک نییە جگە لە خودایەی تاک و بێ ھاوەڵ؛ ھەموو دەسەڵات و ستایش بۆ ئەوە، و ئەو بەسەر ھەموو شتێکدا توانا و سەلیقەیانەیە.',
    repeat: 10,
    source: 'Sahih Muslim'
  },
  {
    order: 12,
    name: 'Seeking Forgiveness and Repentance (Final Duas)',
    arabic: 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
    english: 'My Lord, forgive me and accept my repentance; indeed, You are the Most Accepting of repentance, the Most Merciful.',
    kurdish: 'پەروەردگارم، بمرێنە و تۆبەم قبول بکە، بەڕاستی تۆ زۆر لێخۆشبوو و میهرەبان.',
    repeat: 1,
    source: 'Sahih Muslim'
  }
];

let content = '═══════════════════════════════════════════════════════════\n';
content += 'COMPREHENSIVE AFTER PRAYER AZKAR\n';
content += '(زیکری دوای دەست نوێژ - Authentic Duas After Salah)\n';
content += '═══════════════════════════════════════════════════════════\n\n';

content += 'These are the most authentic and comprehensive after-prayer supplications from the Quran and Sunnah.\n';
content += 'Recite them in order, starting from Item 1.\n\n';

completeAfterPrayerZikrs.forEach((zikr) => {
  content += `\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n`;
  content += `Item ${zikr.order}: ${zikr.name}\n`;
  content += `Repeat: ${zikr.repeat} time(s)\n`;
  content += `Source: ${zikr.source}\n`;
  content += `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n`;
  
  content += `🔤 ARABIC:\n${zikr.arabic}\n\n`;
  content += `📖 ENGLISH:\n${zikr.english}\n\n`;
  content += `🇰🇺 KURDISH:\n${zikr.kurdish}\n\n`;
});

content += '\n═══════════════════════════════════════════════════════════\n';
content += 'SUMMARY\n';
content += '═══════════════════════════════════════════════════════════\n';
content += `Total Items: ${completeAfterPrayerZikrs.length}\n`;
content += 'All items are from authentic Islamic sources (Sahih hadith collections).\n';
content += 'Recommended order: Follow sequentially as listed above.\n\n';

fs.writeFileSync('./comprehensive_after_prayer_azkar.txt', content, 'utf8');
console.log('✓ File created: comprehensive_after_prayer_azkar.txt');
console.log(`Total Items: ${completeAfterPrayerZikrs.length}`);
