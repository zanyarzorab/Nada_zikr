import 'package:flutter/material.dart';
import '../services/app_share_service.dart';

import '../app_localizations.dart';
import '../services/quran_mood_service.dart';
import '../services/quran_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import 'quran_screen.dart';

class FavoriteMoodCardsScreen extends StatefulWidget {
  const FavoriteMoodCardsScreen({super.key});

  @override
  State<FavoriteMoodCardsScreen> createState() => _FavoriteMoodCardsScreenState();
}

class _FavoriteMoodCardsScreenState extends State<FavoriteMoodCardsScreen> {
  late Future<List<Map<String, dynamic>>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = StorageService.readFavoriteMoodCards();
  }

  Future<void> _refresh() async {
    final cards = await StorageService.readFavoriteMoodCards();
    if (!mounted) return;
    setState(() => _favoritesFuture = Future.value(cards));
  }

  Future<void> _openQuranAyah(int surahNumber, int ayahNumber) async {
    final surahs = await QuranService.instance.loadSurahs();
    if (!mounted) return;
    final surah = surahs.firstWhere((item) => item.number == surahNumber);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SurahReadingScreen(
          surah: surah,
          initialAyah: ayahNumber,
          openInitialTafsir: true,
          initialTafsirId: StorageService.getPreferredTafsir(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)?.locale.languageCode ?? 'ku';
    final isKurdish = locale == 'ku';
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF0B2A1D), AppColors.darkBgAlt, const Color(0xFF24573C)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _favoritesFuture,
            builder: (context, snapshot) {
              final cards = snapshot.data ?? const <Map<String, dynamic>>[];

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)?.translate('savedCards') ?? 'کارتە هەڵگیراوەکانم',
                            textDirection: isKurdish ? TextDirection.rtl : TextDirection.ltr,
                            style: isKurdish
                              ? AppTheme.kurdishTitle(fontSize: 24, color: AppColors.gold)
                              : AppTheme.englishTitle(fontSize: 24, color: AppColors.gold),
                          ),
                        ),
                        if (cards.isNotEmpty)
                          IconButton(
                            tooltip: isKurdish ? 'سڕینەوەی هەمووی' : 'Clear all',
                            icon: const Icon(Icons.delete_sweep_rounded),
                            color: AppColors.faintText,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.darkPanel,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text(
                                    isKurdish ? 'سڕینەوەی هەموو کارتەکان' : 'Clear All Saved Cards',
                                    style: isKurdish ? AppTheme.kurdishTitle(color: AppColors.gold) : AppTheme.englishTitle(color: AppColors.gold),
                                  ),
                                  content: Text(
                                    isKurdish ? 'دڵنیایت لە سڕینەوەی هەموو کارتە پاشەکەوتکراوەکان؟' : 'Are you sure you want to clear all saved cards?',
                                    style: isKurdish ? AppTheme.kurdishText(color: AppColors.cream) : AppTheme.englishText(color: AppColors.cream),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text(isKurdish ? 'نەخێر' : 'Cancel', style: TextStyle(color: AppColors.faintText)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(isKurdish ? 'بەڵێ، بسڕەوە' : 'Clear All', style: const TextStyle(color: Colors.redAccent)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await StorageService.clearAllFavoriteMoodCards();
                                await _refresh();
                              }
                            },
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            '${cards.length}',
                            style: AppTheme.englishText(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: cards.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                AppLocalizations.of(context)?.translate('emptySavedCards') ??
                                  'هیچ کارتێکی هەڵگیراو نییە. لە باری دەروونیتەوە یەکێک دروست بکە.',
                                textDirection: isKurdish ? TextDirection.rtl : TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: isKurdish
                                  ? AppTheme.kurdishText(color: AppColors.faintText, fontSize: 15)
                                  : AppTheme.englishText(color: AppColors.faintText, fontSize: 15),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              final card = cards[index];
                              return _MoodCardTile(
                                data: card,
                                index: index,
                                locale: locale,
                                onDelete: () async {
                                  final deletedCard = Map<String, dynamic>.from(card);
                                  await StorageService.deleteFavoriteMoodCard(index);
                                  await _refresh();
                                  if (!context.mounted) return;

                                  final deletedText = locale == 'ku'
                                      ? 'کارتەکە سڕایەوە'
                                      : locale == 'ar'
                                          ? 'تمت إزالة البطاقة'
                                          : 'Card removed';
                                  final undoText = locale == 'ku'
                                      ? 'گەڕاندنەوە'
                                      : locale == 'ar'
                                          ? 'تراجع'
                                          : 'Undo';

                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.darkPanel,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      content: Row(
                                        children: [
                                          Icon(Icons.bookmark_remove_rounded, color: AppColors.gold, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              deletedText,
                                              style: locale == 'ku'
                                                  ? AppTheme.kurdishText(color: AppColors.cream, fontSize: 13)
                                                  : AppTheme.englishText(color: AppColors.cream, fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      action: SnackBarAction(
                                        label: undoText,
                                        textColor: AppColors.gold,
                                        onPressed: () async {
                                          await StorageService.insertFavoriteMoodCardAt(index, deletedCard);
                                          await _refresh();
                                        },
                                      ),
                                    ),
                                  );
                                },
                                onShare: () {
                                  final text = _buildShareText(card, locale);
                                  AppShareService.share(context, text);
                                },
                                onVerseTap: (surah, ayah) => _openQuranAyah(surah, ayah),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _buildShareText(Map<String, dynamic> card, String locale) {
    final loc = AppLocalizations.of(context);
    final moodId = (card['moodId'] ?? 'grateful').toString();
    final title = QuranMoodService.instance.titleFor(moodId, locale);
    final shortMessage = QuranMoodService.instance.messageFor(moodId, locale);
    final verses = (card['verses'] as List?) ?? const <Map<String, dynamic>>[];

    final lines = <String>[title, shortMessage, ''];
    for (final item in verses) {
      final verse = Map<String, dynamic>.from(item);
      lines.add('${loc?.translate('surah') ?? 'سورەت'} ${verse['surah']}:${verse['ayah']}');
      lines.add(verse['arabicText']?.toString() ?? '');
        lines.add(locale == 'ku'
          ? (verse['kurdishMeaning']?.toString() ?? verse['englishMeaning']?.toString() ?? '')
          : (verse['englishMeaning']?.toString() ?? ''));
      lines.add('');
    }
    return lines.join('\n');
  }
}

class _MoodCardTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final String locale;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final void Function(int surah, int ayah) onVerseTap;

  const _MoodCardTile({
    required this.data,
    required this.index,
    required this.locale,
    required this.onDelete,
    required this.onShare,
    required this.onVerseTap,
  });

  @override
  Widget build(BuildContext context) {
    final verses = (data['verses'] as List?) ?? const <Map<String, dynamic>>[];
    final moodId = (data['moodId'] ?? 'grateful').toString();
    final tone = QuranMoodService.instance.themeFor(moodId);
    final isKurdish = locale == 'ku';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tone.primary.withValues(alpha: 0.30),
            tone.secondary.withValues(alpha: 0.24),
            AppColors.darkPanel,
          ],
        ),
        border: Border.all(color: tone.primary.withValues(alpha: 0.40)),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.26),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: tone.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: tone.primary.withValues(alpha: 0.24)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tone.iconData, color: tone.primary, size: 14),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          QuranMoodService.instance.moodLabel(moodId, locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: isKurdish
                            ? AppTheme.kurdishText(fontSize: 10, color: tone.primary, fontWeight: FontWeight.w700)
                            : AppTheme.englishText(fontSize: 10, color: tone.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: locale == 'ku'
                    ? 'لە هەڵگیراوەکان بیسڕەوە'
                    : locale == 'ar'
                        ? 'إزالة من المحفوظات'
                        : 'Remove from saved cards',
                onPressed: onDelete,
                icon: const Icon(Icons.bookmark_remove_rounded),
                color: AppColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            QuranMoodService.instance.titleFor(moodId, locale),
            textDirection: isKurdish ? TextDirection.rtl : TextDirection.ltr,
            style: isKurdish
              ? AppTheme.kurdishTitle(fontSize: 18, color: AppColors.cream)
              : AppTheme.englishTitle(fontSize: 18, color: AppColors.cream),
          ),
          const SizedBox(height: 6),
          Text(
            QuranMoodService.instance.messageFor(moodId, locale),
            textDirection: isKurdish ? TextDirection.rtl : TextDirection.ltr,
            style: isKurdish
              ? AppTheme.kurdishText(color: AppColors.faintText, fontSize: 12)
              : AppTheme.englishText(color: AppColors.faintText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ...verses.take(2).map((verse) {
            final map = Map<String, dynamic>.from(verse);
            return GestureDetector(
              onTap: () => onVerseTap(
                int.tryParse(map['surah']?.toString() ?? '') ?? 0,
                int.tryParse(map['ayah']?.toString() ?? '') ?? 0,
              ),
              child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tone.primary.withValues(alpha: 0.14),
                    AppColors.darkBg.withValues(alpha: 0.72),
                    tone.secondary.withValues(alpha: 0.16),
                  ],
                ),
                border: Border.all(color: tone.primary.withValues(alpha: 0.16)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    map['arabicText']?.toString() ?? '',
                    textDirection: TextDirection.rtl,
                    style: AppTheme.quranAyahText(fontSize: 22, color: AppColors.cream),
                  ),
                  const SizedBox(height: 6),
                      Text(
                        '${AppLocalizations.of(context)?.translate('surah') ?? 'سورەت'} ${map['surah']}:${map['ayah']}',
                        textDirection: isKurdish ? TextDirection.rtl : TextDirection.ltr,
                        style: (isKurdish
                            ? AppTheme.kurdishText(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700)
                            : AppTheme.englishText(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700)).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.gold,
                            ),
                      ),
                  const SizedBox(height: 6),
                  if (map['kurdishMeaning'] != null &&
                      map['kurdishMeaning'].toString().isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '📖 مانای کوردی',
                            style: AppTheme.kurdishText(
                              fontSize: 9,
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      map['kurdishMeaning'].toString(),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: AppTheme.kurdishText(
                          color: AppColors.cream, fontSize: 12),
                    ),
                  ],
                  if (map['englishMeaning'] != null &&
                      map['englishMeaning'].toString().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '🌐 English Meaning',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF93C5FD),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      map['englishMeaning'].toString(),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      style: AppTheme.englishText(
                          color: AppColors.faintText, fontSize: 11),
                    ),
                  ],
                ],
              ),
              ),
            );
          }),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share_rounded),
              label: Text(AppLocalizations.of(context)?.translate('share') ?? 'هاوبەشکردن'),
            ),
          ),
        ],
      ),
    );
  }
}
