import 'dart:async';
import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/quran_reciter.dart';
import '../services/quran_audio_service.dart';
import '../services/quran_timing_service.dart';
import 'app_theme.dart';

class ReciterSelectorSheet extends StatefulWidget {
  const ReciterSelectorSheet({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReciterSelectorSheet(),
    );
  }

  @override
  State<ReciterSelectorSheet> createState() => _ReciterSelectorSheetState();
}

class _ReciterSelectorSheetState extends State<ReciterSelectorSheet> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QuranReciter> get _filteredReciters {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return kQuranReciters;
    return kQuranReciters.where((r) {
      return r.nameKu.toLowerCase().contains(q) ||
          r.nameAr.contains(q) ||
          r.nameEn.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    final isKurdish = lang == 'ku';
    final isRTL = lang == 'ar' || lang == 'ku';
    final currentReciter = QuranAudioService.instance.selectedReciter;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 35,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.record_voice_over_rounded,
                          color: AppColors.gold, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isKurdish
                                  ? 'خوێنەرانی قورئان (${kQuranReciters.length} خوێنەر)'
                                  : 'Quran Reciters (${kQuranReciters.length} Reciters)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.kurdishTitle(
                                  fontSize: 17, color: AppColors.gold),
                            ),
                            Text(
                              isKurdish
                                  ? 'خوێنەرانی دیاریکردنی ئایەت و دەنگی سوورەت'
                                  : 'Ayah Highlighting & Full Surah Reciters',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.kurdishText(
                                  fontSize: 11, color: AppColors.faintText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: AppColors.faintText),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              style: AppTheme.englishText(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: isKurdish
                    ? 'گەڕان بۆ خوێنەر... / Search Reciter'
                    : 'Search Reciter',
                hintStyle: AppTheme.englishText(
                    color: AppColors.faintText, fontSize: 13),
                prefixIcon:
                    Icon(Icons.search_rounded, color: AppColors.gold, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            color: AppColors.faintText, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.panelColor,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.panelBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.panelBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.gold, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _filteredReciters.length +
                  (_searchQuery.trim().isEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (_searchQuery.trim().isEmpty && index == 7) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 14),
                    child: Column(
                      children: [
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.softSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.panelBorderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 14, color: AppColors.gold),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  isKurdish
                                      ? 'خوێنەرانی دەنگی تەواوی سوورەت (بێ دیاریکردنی ئایەت)'
                                      : 'Full Surah Audio Reciters (No Ayah Highlighting)',
                                  style: AppTheme.englishText(
                                    fontSize: 11,
                                    color: AppColors.cream,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.white24, height: 1),
                      ],
                    ),
                  );
                }

                final reciter = _filteredReciters[
                    index - (_searchQuery.trim().isEmpty && index > 7 ? 1 : 0)];
                final isSelected = reciter.id == currentReciter.id;
                final hasHighlighting =
                    QuranTimingService.instance.supportsExactTiming(reciter.id);

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    unawaited(QuranAudioService.instance.setReciter(reciter));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gold.withValues(alpha: 0.18)
                          : AppColors.panelColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.gold
                            : AppColors.panelBorderColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.gold.withValues(alpha: 0.3)
                                : AppColors.gold.withValues(alpha: 0.1),
                            border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: Center(
                            child: Icon(
                              isSelected
                                  ? Icons.volume_up_rounded
                                  : (hasHighlighting
                                      ? Icons.record_voice_over_rounded
                                      : Icons.person_rounded),
                              color: AppColors.gold,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      reciter.localizedName(lang),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: isKurdish
                                          ? AppTheme.kurdishText(
                                              fontSize: 15,
                                              color: isSelected
                                                  ? AppColors.gold
                                                  : AppColors.cream,
                                              fontWeight: FontWeight.bold,
                                            )
                                          : AppTheme.englishText(
                                              fontSize: 15,
                                              color: isSelected
                                                  ? AppColors.gold
                                                  : AppColors.cream,
                                              fontWeight: FontWeight.bold,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    flex: 2,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: hasHighlighting
                                              ? const Color(0xFF10B981)
                                                  .withValues(alpha: 0.18)
                                              : AppColors.darkBg,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: hasHighlighting
                                                ? const Color(0xFF10B981)
                                                    .withValues(alpha: 0.4)
                                                : AppColors.panelBorderColor,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          hasHighlighting
                                              ? (isKurdish
                                                  ? '✨ نیشاندانی ئایەت'
                                                  : (lang == 'ar'
                                                      ? '✨ تمييز الآيات'
                                                      : '✨ Highlighting'))
                                              : (isKurdish
                                                  ? '📻 سوورەت'
                                                  : (lang == 'ar'
                                                      ? '📻 سورة كاملة'
                                                      : '📻 Full Surah')),
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: hasHighlighting
                                                ? const Color(0xFF34D399)
                                                : AppColors.faintText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${reciter.nameAr} · ${reciter.style}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                                style: AppTheme.arabicText(
                                  fontSize: 12,
                                  color: isSelected
                                      ? AppColors.gold.withValues(alpha: 0.8)
                                      : AppColors.faintText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFD700),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
  }
}
