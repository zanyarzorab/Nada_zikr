import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_haptics.dart';
import 'app_theme.dart';

/// Bottom sheet revealing full metadata, Quran reader jump, copy, share, and recitation actions when a Dua or Ayah is tapped.
class SpiritualDetailSheet extends StatefulWidget {
  final String arabic;
  final String kurdishMeaning;
  final String englishMeaning;
  final String source;
  final String? categoryTag;
  final String? title;
  final String? narrator;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final int reciteCount;
  final ValueChanged<int> onReciteChanged;
  final VoidCallback onShareCard;
  final VoidCallback onCopy;
  final VoidCallback? onOpenInQuran;
  final VoidCallback? onFocusRead;
  final String lang;
  final bool isAyah;
  final bool showReciteCounter;

  const SpiritualDetailSheet({
    super.key,
    required this.arabic,
    required this.kurdishMeaning,
    this.englishMeaning = '',
    required this.source,
    this.categoryTag,
    this.title,
    this.narrator,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.reciteCount,
    required this.onReciteChanged,
    required this.onShareCard,
    required this.onCopy,
    this.onOpenInQuran,
    this.onFocusRead,
    required this.lang,
    this.isAyah = false,
    this.showReciteCounter = true,
  });

  static Future<void> show(
    BuildContext context, {
    required String arabic,
    required String kurdishMeaning,
    String englishMeaning = '',
    required String source,
    String? categoryTag,
    String? title,
    String? narrator,
    required bool isFavorite,
    required VoidCallback onToggleFavorite,
    required int reciteCount,
    required ValueChanged<int> onReciteChanged,
    required VoidCallback onShareCard,
    required VoidCallback onCopy,
    VoidCallback? onOpenInQuran,
    VoidCallback? onFocusRead,
    required String lang,
    bool isAyah = false,
    bool showReciteCounter = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SpiritualDetailSheet(
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
        onReciteChanged: onReciteChanged,
        onShareCard: onShareCard,
        onCopy: onCopy,
        onOpenInQuran: onOpenInQuran,
        onFocusRead: onFocusRead,
        lang: lang,
        isAyah: isAyah,
        showReciteCounter: showReciteCounter,
      ),
    );
  }

  @override
  State<SpiritualDetailSheet> createState() => _SpiritualDetailSheetState();
}

class _SpiritualDetailSheetState extends State<SpiritualDetailSheet> {
  late int _count;
  late bool _fav;

  @override
  void initState() {
    super.initState();
    _count = widget.reciteCount;
    _fav = widget.isFavorite;
  }

  void _increment() {
    AppHaptics.mediumImpact();
    setState(() {
      _count++;
    });
    widget.onReciteChanged(_count);
  }

  void _toggleFav() {
    AppHaptics.mediumImpact();
    setState(() {
      _fav = !_fav;
    });
    widget.onToggleFavorite();
  }

  @override
  Widget build(BuildContext context) {
    final isKurdish = widget.lang == 'ku';
    final isArabic = widget.lang == 'ar';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: AppColors.panelBorderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.faintText.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // Header Meta Bar: Surah / Source + Close Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                // Category / Source Badge
                if (widget.categoryTag != null && widget.categoryTag!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: AppColors.softSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.panelBorderColor.withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      widget.categoryTag!,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),

                // Close Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.panelColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 16, color: Color(0x1AFFFFFF)),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Optional Title
                  if (widget.title != null && widget.title!.isNotEmpty) ...[
                    Text(
                      widget.title!,
                      textAlign: TextAlign.center,
                      style: isKurdish
                          ? AppTheme.kurdishTitle(
                              fontSize: 16, color: AppColors.gold)
                          : AppTheme.englishTitle(
                              fontSize: 16, color: AppColors.gold),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Optional Narrator
                  if (widget.narrator != null && widget.narrator!.isNotEmpty) ...[
                    Text(
                      widget.narrator!,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Arabic Calligraphy Hero
                  Text(
                    widget.arabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: widget.isAyah
                        ? AppTheme.quranAyahText(
                            fontSize: 25,
                            color: const Color(0xFFFFFBEB),
                            height: 2.05,
                          )
                        : GoogleFonts.scheherazadeNew(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFFFBEB),
                            height: 2.0,
                          ),
                  ),

                  const SizedBox(height: 18),

                  // Kurdish Meaning
                  if (widget.kurdishMeaning.isNotEmpty) ...[
                    Text(
                      widget.kurdishMeaning,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: AppTheme.kurdishText(
                        color: AppColors.cream.withValues(alpha: 0.9),
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // English Meaning
                  if (widget.englishMeaning.isNotEmpty) ...[
                    Text(
                      widget.englishMeaning,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      style: AppTheme.englishText(
                        color: AppColors.cream.withValues(alpha: 0.8),
                        fontSize: 14,
                      ).copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Source reference
                  Text(
                    widget.source,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.veryFaintText,
                      fontSize: 11.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // "View in Quran" Button (for Quran Duas)
                  if (widget.onOpenInQuran != null) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenInQuran!();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.45),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_stories_rounded,
                                color: Color(0xFF34D399), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isKurdish
                                  ? 'بینین و خوێندنەوە لە قورئانی پیرۆزدا'
                                  : (isArabic
                                      ? 'عرض الآية في المصحف الشريف'
                                      : 'View Ayah in Holy Quran'),
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Action Buttons Row (Recite, Bookmark, Copy, Share Card, Focus)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Recite Tap Counter (hidden for hadiths)
                      if (widget.showReciteCounter)
                        _buildActionButton(
                          icon: Icons.touch_app_rounded,
                          label: _count > 0 ? '$_count' : (isKurdish ? 'خوێندنەوە' : 'Recite'),
                          isActive: _count > 0,
                          activeColor: const Color(0xFF10B981),
                          onTap: _increment,
                        ),

                      // Favorite Bookmark
                      _buildActionButton(
                        icon: _fav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        label: isKurdish ? 'دڵخواز' : 'Save',
                        isActive: _fav,
                        activeColor: const Color(0xFFF43F5E),
                        onTap: _toggleFav,
                      ),

                      // Copy
                      _buildActionButton(
                        icon: Icons.copy_rounded,
                        label: isKurdish ? 'کۆپی' : 'Copy',
                        onTap: () {
                          Navigator.pop(context);
                          widget.onCopy();
                        },
                      ),

                      // Share Card Generator
                      _buildActionButton(
                        icon: Icons.share_rounded,
                        label: isKurdish ? 'کارت' : 'Card',
                        onTap: () {
                          Navigator.pop(context);
                          widget.onShareCard();
                        },
                      ),

                      // Fullscreen Reading
                      if (widget.onFocusRead != null)
                        _buildActionButton(
                          icon: Icons.fullscreen_rounded,
                          label: isKurdish ? 'تایبەت' : 'Focus',
                          onTap: () {
                            Navigator.pop(context);
                            widget.onFocusRead!();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final color = isActive && activeColor != null ? activeColor : AppColors.cream;

    return GestureDetector(
      onTap: () {
        AppHaptics.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isActive && activeColor != null
                  ? activeColor.withValues(alpha: 0.18)
                  : AppColors.panelColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive && activeColor != null
                    ? activeColor.withValues(alpha: 0.45)
                    : AppColors.panelBorderColor.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 20),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
