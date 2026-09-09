import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/app_data.dart';
import '../services/quran_service.dart';
import '../widgets/app_theme.dart';
import 'quran_screen.dart';
import 'reading_screen.dart';
import 'hadith_screen.dart';
import 'quran_duas_screen.dart';
import 'general_duas_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    final isKurdish = lang == 'ku';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkBg, AppColors.darkBgAlt, AppColors.softSurface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.panelColor,
                    border: Border.all(color: AppColors.panelBorderColor),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back, size: 18, color: AppColors.cream),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc?.translate('azkar') ?? (isKurdish ? 'زیکر و دوعاکان' : 'Zikr & Duas'),
                              style: isKurdish
                                  ? AppTheme.kurdishTitle(fontSize: 20, color: AppColors.gold)
                                  : AppTheme.englishTitle(fontSize: 20, color: AppColors.gold),
                            ),
                             Text(
                               isKurdish ? 'زیکر و دوعا قورئانی و سوننەتییەکان' : (lang == 'ar' ? 'الأذكار والأدعية من القرآن والسنة' : 'Daily Dhikr & Supplications from Quran & Sunnah'),
                               style: isKurdish
                                   ? AppTheme.kurdishText(fontSize: 12, color: AppColors.mutedText)
                                   : AppTheme.arabicText(fontSize: 13, color: AppColors.mutedText),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(height: 20),

                // Azkar Categories List (Clean & Streamlined)
                Column(
                  children: AppData.azkarCategories.map((cat) {
                    final color = Color(int.parse('0xFF${cat.color.substring(1)}'));
                    final realCount = cat.count;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () async {
                          if (cat.id == 'surah_mulk') {
                            final surahs = await QuranService.instance.loadSurahs();
                            final surah = surahs.firstWhere((s) => s.number == 67);
                            if (!context.mounted) return;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SurahReadingScreen(surah: surah)));
                            return;
                          }
                          if (cat.id == 'surah_kahf') {
                            final surahs = await QuranService.instance.loadSurahs();
                            final surah = surahs.firstWhere((s) => s.number == 18);
                            if (!context.mounted) return;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SurahReadingScreen(surah: surah)));
                            return;
                          }
                          if (cat.id == 'hadith') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen()));
                            return;
                          }
                          if (cat.id == 'quran') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranDuasScreen()));
                            return;
                          }
                          if (cat.id == 'general') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneralDuasScreen()));
                            return;
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingScreen(category: cat)));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.panelColor,
                            border: Border.all(color: AppColors.panelBorderColor),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 14, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Icon(cat.iconData, color: color, size: 26),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.getTitle(lang),
                                      style: isKurdish
                                          ? AppTheme.kurdishTitle(fontSize: 15, color: AppColors.cream)
                                          : AppTheme.englishText(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      () {
                                        if (cat.id == 'ayat_kursi') {
                                          return isKurdish
                                              ? '1 ئایەت • ئایەتی کورسی [البقرة: 255]'
                                              : (lang == 'ar'
                                                  ? 'آية واحدة • آية الكرسي [البقرة: 255]'
                                                  : '1 Ayah • Ayat Al-Kursi [Al-Baqarah: 255]');
                                        }
                                        if (cat.id == 'surah_mulk') {
                                          return isKurdish
                                              ? '30 ئایەت • سوورەتی الملك'
                                              : (lang == 'ar'
                                                  ? '30 آية • سورة الملك'
                                                  : '30 Ayahs • Surah Al-Mulk');
                                        }
                                        if (cat.id == 'surah_kahf') {
                                          return isKurdish
                                              ? '110 ئایەت • سوورەتی الكهف'
                                              : (lang == 'ar'
                                                  ? '110 آيات • سورة الكهف'
                                                  : '110 Ayahs • Surah Al-Kahf');
                                        }
                                        if (cat.id == 'quran') {
                                          return isKurdish
                                              ? '$realCount دوعای قورئانی بە تەفسیر'
                                              : (lang == 'ar'
                                                  ? '$realCount دعاء قرآني مبارك'
                                                  : '$realCount Quranic Supplications');
                                        }
                                        if (cat.id == 'hadith') {
                                          return isKurdish
                                              ? '$realCount فەرموودەی نەبەوی پیرۆز'
                                              : (lang == 'ar'
                                                  ? '$realCount حديثاً نبوياً شریفاً'
                                                  : '$realCount Noble Hadiths');
                                        }
                                        if (cat.id == 'general') {
                                          return isKurdish
                                              ? '$realCount دوعای پێغەمبەرانە لە فەرموودە'
                                              : (lang == 'ar'
                                                  ? '$realCount دعاء نبوي مأثور من السنة'
                                                  : '$realCount Prophetic Duas from Sunnah');
                                        }
                                        return isKurdish
                                            ? '$realCount زیکری پێویست'
                                            : (lang == 'ar'
                                                ? '$realCount أذكار'
                                                : '$realCount Essential Adhkar');
                                      }(),
                                      style: isKurdish
                                          ? AppTheme.kurdishText(
                                              color: AppColors.faintText,
                                              fontSize: 11)
                                          : AppTheme.arabicText(
                                              color: color, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$realCount',
                                    style: AppTheme.englishText(
                                        color: color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
