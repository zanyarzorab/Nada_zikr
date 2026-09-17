import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_haptics.dart';
import 'app_theme.dart';

/// Serene, distraction-free focused reading sheet for deep spiritual contemplation and recitation.
class FocusedReadingSheet extends StatefulWidget {
  final String arabic;
  final String kurdishMeaning;
  final String englishMeaning;
  final String source;
  final String? title;
  final String? narrator;
  final int initialCount;
  final String lang;
  final bool isAyah;
  final bool showReciteCounter;

  const FocusedReadingSheet({
    super.key,
    required this.arabic,
    required this.kurdishMeaning,
    this.englishMeaning = '',
    required this.source,
    this.title,
    this.narrator,
    this.initialCount = 0,
    required this.lang,
    this.isAyah = false,
    this.showReciteCounter = true,
  });

  static Future<int?> show(
    BuildContext context, {
    required String arabic,
    required String kurdishMeaning,
    String englishMeaning = '',
    required String source,
    String? title,
    String? narrator,
    int initialCount = 0,
    required String lang,
    bool isAyah = false,
    bool showReciteCounter = true,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FocusedReadingSheet(
        arabic: arabic,
        kurdishMeaning: kurdishMeaning,
        englishMeaning: englishMeaning,
        source: source,
        title: title,
        narrator: narrator,
        initialCount: initialCount,
        lang: lang,
        isAyah: isAyah,
        showReciteCounter: showReciteCounter,
      ),
    );
  }

  @override
  State<FocusedReadingSheet> createState() => _FocusedReadingSheetState();
}

class _FocusedReadingSheetState extends State<FocusedReadingSheet> {
  late int _count;
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  void _increment() {
    AppHaptics.mediumImpact();
    setState(() {
      _count++;
    });
  }

  void _reset() {
    AppHaptics.selectionClick();
    setState(() {
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKurdish = widget.lang == 'ku';
    final isEnglish = widget.lang == 'en';
    final hasTranslation =
        widget.kurdishMeaning.isNotEmpty || widget.englishMeaning.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: AppColors.panelBorderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.faintText.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          // Header bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                IconButton(
                  onPressed: () => Navigator.pop(context, _count),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.cream,
                  tooltip: isKurdish ? 'داخستن' : 'Close',
                ),

                // Title / Reference
                Expanded(
                  child: Text(
                    widget.title ?? widget.source,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Reset counter (only when counting is enabled)
                if (widget.showReciteCounter && _count > 0)
                  IconButton(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    color: AppColors.faintText,
                    tooltip: isKurdish ? 'دوبارەکردنەوە' : 'Reset count',
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0x1FFFFFFF)),

          // Scrollable Reading Content
          Expanded(
            child: GestureDetector(
              onTap: widget.showReciteCounter ? _increment : null,
              behavior: HitTestBehavior.opaque,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    if (widget.narrator != null &&
                        widget.narrator!.isNotEmpty) ...[
                      Text(
                        widget.narrator!,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Arabic Calligraphy Hero
                    Text(
                      widget.arabic,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: widget.isAyah
                          ? AppTheme.quranAyahText(
                              fontSize: 27,
                              color: const Color(0xFFFFFBEB),
                              height: 2.1,
                            )
                          : GoogleFonts.scheherazadeNew(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFFFBEB),
                              height: 2.05,
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Meaning toggle & content
                    if (hasTranslation) ...[
                      GestureDetector(
                        onTap: () {
                          AppHaptics.selectionClick();
                          setState(() => _showTranslation = !_showTranslation);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.softSurface.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.panelBorderColor
                                  .withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showTranslation
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 14,
                                color: AppColors.mutedText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isKurdish
                                    ? (_showTranslation
                                        ? 'شاردنەوەی مانا'
                                        : 'پیشاندانی مانا')
                                    : (_showTranslation
                                        ? 'Hide meaning'
                                        : 'Show meaning'),
                                style: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showTranslation) ...[
                        const SizedBox(height: 14),
                        Text(
                          isEnglish && widget.englishMeaning.isNotEmpty
                              ? widget.englishMeaning
                              : (widget.kurdishMeaning.isNotEmpty
                                  ? widget.kurdishMeaning
                                  : widget.englishMeaning),
                          textAlign: TextAlign.center,
                          textDirection:
                              isEnglish ? TextDirection.ltr : TextDirection.rtl,
                          style: isEnglish
                              ? AppTheme.englishText(
                                  color: AppColors.cream.withValues(alpha: 0.85),
                                  fontSize: 15,
                                ).copyWith(height: 1.65)
                              : AppTheme.kurdishText(
                                  color: AppColors.cream.withValues(alpha: 0.85),
                                  fontSize: 15,
                                  height: 1.7,
                                ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 20),

                    // Source reference
                    Text(
                      widget.source,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.veryFaintText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Big Tactile Bottom Recite Tap Button (only for zikr/dua, not hadith)
          if (widget.showReciteCounter)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: GestureDetector(
                  onTap: _increment,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _count > 0
                              ? const Color(0xFF0F766E)
                              : AppColors.panelColor,
                          _count > 0
                              ? const Color(0xFF0D9488)
                              : AppColors.darkBgAlt,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _count > 0
                            ? const Color(0xFF14B8A6).withValues(alpha: 0.6)
                            : AppColors.gold.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _count > 0
                              ? const Color(0xFF14B8A6).withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.2),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 20,
                          color: _count > 0
                              ? const Color(0xFF5EEAD4)
                              : AppColors.gold,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isKurdish
                              ? (_count > 0 ? 'خوێندراوە: $_count' : 'بۆ ژماردن دەست لێبدە')
                              : (_count > 0 ? 'Recited: $_count' : 'Tap to Count'),
                          style: TextStyle(
                            color: _count > 0
                                ? const Color(0xFFF0FDFA)
                                : AppColors.cream,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
