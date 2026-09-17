import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_haptics.dart';
import 'app_theme.dart';
import 'spiritual_detail_sheet.dart';

/// Content-first, ultra-clean spiritual card.
/// Keeps the card face pure and distraction-free with larger Arabic & Meaning text.
/// Tapping the card opens the SpiritualDetailSheet revealing Surah, Ayah, Quran jump, copy, share, and counting.
class SpiritualContentCard extends StatelessWidget {
  final String arabic;
  final String kurdishMeaning;
  final String englishMeaning;
  final String source;
  final String? categoryTag;
  final IconData? categoryTagIcon;
  final VoidCallback? onCategoryTap;
  final String? title;
  final String? narrator;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final int reciteCount;
  final ValueChanged<int>? onReciteChanged;
  final VoidCallback onRecite;
  final VoidCallback onShareCard;
  final VoidCallback onCopy;
  final VoidCallback? onOpenInQuran;
  final VoidCallback? onFocusRead;
  final String lang;
  final String meaningBadgeKurdishLabel;
  final bool isDisplayingEnglish;
  final VoidCallback? onToggleLanguage;
  final bool isAyah;
  final bool showReciteCounter;

  const SpiritualContentCard({
    super.key,
    required this.arabic,
    required this.kurdishMeaning,
    this.englishMeaning = '',
    required this.source,
    this.categoryTag,
    this.categoryTagIcon,
    this.onCategoryTap,
    this.title,
    this.narrator,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.reciteCount,
    this.onReciteChanged,
    required this.onRecite,
    required this.onShareCard,
    required this.onCopy,
    this.onOpenInQuran,
    this.onFocusRead,
    required this.lang,
    required this.meaningBadgeKurdishLabel,
    required this.isDisplayingEnglish,
    this.onToggleLanguage,
    this.isAyah = false,
    this.showReciteCounter = true,
  });

  void _openDetailSheet(BuildContext context) {
    AppHaptics.lightImpact();
    SpiritualDetailSheet.show(
      context,
      arabic: arabic,
      kurdishMeaning: kurdishMeaning,
      englishMeaning: englishMeaning,
      source: source,
      categoryTag: categoryTag,
      title: title,
      narrator: narrator,
      isFavorite: isFavorite,
      onToggleFavorite: onToggleFavorite,
      reciteCount: reciteCount,
      onReciteChanged: (newCount) {
        if (onReciteChanged != null) {
          onReciteChanged!(newCount);
        } else {
          onRecite();
        }
      },
      onShareCard: onShareCard,
      onCopy: onCopy,
      onOpenInQuran: onOpenInQuran,
      onFocusRead: onFocusRead,
      lang: lang,
      isAyah: isAyah,
      showReciteCounter: showReciteCounter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKurdish = lang == 'ku';
    final isArabic = lang == 'ar';
    final hasKurdish = kurdishMeaning.trim().isNotEmpty;
    final hasEnglish = englishMeaning.trim().isNotEmpty;
    final hasBoth = hasKurdish && hasEnglish;
    final hasContent = hasKurdish || hasEnglish;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFavorite
              ? AppColors.gold.withValues(alpha: 0.4)
              : AppColors.panelBorderColor.withValues(alpha: 0.6),
          width: isFavorite ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openDetailSheet(context),
          splashColor: AppColors.gold.withValues(alpha: 0.06),
          highlightColor: AppColors.gold.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Meta Row: Language switch badge on one side, subtle bookmark on the other
                Row(
                  children: [
                    // Language Switcher Badge (kept minimal & preserves exact test expectation keys)
                    if (hasContent)
                      GestureDetector(
                        onTap: hasBoth ? onToggleLanguage : null,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDisplayingEnglish
                                ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                                : AppColors.softSurface.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDisplayingEnglish
                                  ? const Color(0xFF60A5FA).withValues(alpha: 0.3)
                                  : AppColors.panelBorderColor.withValues(alpha: 0.4),
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isDisplayingEnglish
                                    ? (isKurdish
                                        ? 'مانای ئینگلیزی'
                                        : (isArabic
                                            ? 'الترجمة بالإنجليزية'
                                            : 'English Translation'))
                                    : meaningBadgeKurdishLabel,
                                style: isDisplayingEnglish
                                    ? const TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFF93C5FD),
                                        fontWeight: FontWeight.w600,
                                      )
                                    : AppTheme.kurdishText(
                                        fontSize: 10.5,
                                        color: AppColors.mutedText,
                                        fontWeight: FontWeight.w600,
                                      ),
                              ),
                              if (hasBoth) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.swap_horiz_rounded,
                                  size: 11,
                                  color: isDisplayingEnglish
                                      ? const Color(0xFF93C5FD)
                                      : AppColors.mutedText,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  isDisplayingEnglish
                                      ? (isKurdish ? 'کوردی' : 'Kurdish')
                                      : 'English',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isDisplayingEnglish
                                        ? const Color(0xFF93C5FD)
                                        : AppColors.gold.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Subtle Recite indicator if recited (hidden for hadiths)
                    if (showReciteCounter && reciteCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$reciteCount',
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Subtle Bookmark Button
                    GestureDetector(
                      onTap: onToggleFavorite,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          isFavorite
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          size: 18,
                          color: isFavorite
                              ? const Color(0xFFF43F5E)
                              : AppColors.veryFaintText.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Optional Narrator line (for Hadiths)
                if (narrator != null && narrator!.isNotEmpty) ...[
                  Text(
                    narrator!,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // 1. Arabic Zikr / Ayah Text (BIGGER, Majestic, Dignified)
                Text(
                  arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: isAyah
                      ? AppTheme.quranAyahText(
                          fontSize: 25,
                          color: const Color(0xFFFFFBEB),
                          height: 2.05,
                        )
                      : GoogleFonts.scheherazadeNew(
                          fontSize: 24.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFFBEB),
                          height: 2.0,
                        ),
                ),

                // 2. Meaning & Translation (BIGGER, Comfortable, Beautiful)
                if (hasContent) ...[
                  const SizedBox(height: 12),
                  Text(
                    isDisplayingEnglish ? englishMeaning : kurdishMeaning,
                    textAlign:
                        isDisplayingEnglish ? TextAlign.left : TextAlign.right,
                    textDirection: isDisplayingEnglish
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    style: isDisplayingEnglish
                        ? AppTheme.englishText(
                            color: AppColors.cream.withValues(alpha: 0.9),
                            fontSize: 15.5,
                          ).copyWith(height: 1.65)
                        : AppTheme.kurdishText(
                            color: AppColors.cream.withValues(alpha: 0.9),
                            fontSize: 15.5,
                            height: 1.7,
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
