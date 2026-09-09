import 'dart:io';
import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/quran_reciter.dart';
import '../services/app_haptics.dart';
import '../services/quran_audio_service.dart';
import '../services/quran_download_service.dart';
import '../services/quran_service.dart';
import '../screens/quran_screen.dart';
import 'app_theme.dart';
import 'reciter_selector_sheet.dart';

class DownloadedSurahsSheet extends StatefulWidget {
  final VoidCallback? onPlaySurah;
  final void Function(QuranSurahMeta surah)? onSurahSelected;

  const DownloadedSurahsSheet({
    Key? key,
    this.onPlaySurah,
    this.onSurahSelected,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onPlaySurah,
    void Function(QuranSurahMeta surah)? onSurahSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DownloadedSurahsSheet(
        onPlaySurah: onPlaySurah,
        onSurahSelected: onSurahSelected,
      ),
    );
  }

  @override
  State<DownloadedSurahsSheet> createState() => _DownloadedSurahsSheetState();
}

class _DownloadedSurahsSheetState extends State<DownloadedSurahsSheet> {
  late Future<List<_DownloadedSurahItem>> _downloadedFuture;
  int _totalBytes = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _downloadedFuture = _loadDownloadedSurahs();
    });
  }

  Future<List<_DownloadedSurahItem>> _loadDownloadedSurahs() async {
    final reciter = QuranAudioService.instance.selectedReciter;
    final allSurahs = await QuranService.instance.loadSurahs();
    final downloadedNumbers =
        await QuranDownloadService.instance.getDownloadedSurahs(reciter.id);

    _totalBytes = await QuranDownloadService.instance
        .getTotalDownloadedBytes(reciterId: reciter.id);

    final List<_DownloadedSurahItem> items = [];
    for (final num in downloadedNumbers) {
      final meta = allSurahs.firstWhere(
        (s) => s.number == num,
        orElse: () => QuranSurahMeta(
          number: num,
          arabicName: 'سورة $num',
          kurdishName: 'سورەتی $num',
          englishName: 'Surah $num',
          englishNameTranslation: 'Surah $num',
          numberOfAyahs: 0,
          revelationType: '',
        ),
      );

      final filePath = await QuranDownloadService.instance
          .getAudioFilePath(num, reciter.id);
      final file = File(filePath);
      final size = file.existsSync() ? file.lengthSync() : 0;

      items.add(_DownloadedSurahItem(meta: meta, fileSizeBytes: size));
    }

    return items;
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 KB';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  void _openSurah(QuranSurahMeta surah) {
    AppHaptics.selectionClick();
    Navigator.of(context).pop();
    if (widget.onSurahSelected != null) {
      widget.onSurahSelected!(surah);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SurahReadingScreen(
            surah: surah,
            autoPlayAudio: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    final isKurdish = lang == 'ku';
    final isRtl = isKurdish || lang == 'ar';
    final reciter = QuranAudioService.instance.selectedReciter;

    final sheetTitle = isKurdish
        ? 'سورەتە دابەزێنراوەکان (ئۆفلاین)'
        : (lang == 'ar'
            ? 'السور المحملة (دون إنترنت)'
            : 'Downloaded Surahs (Offline)');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1.5,
        ),
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
            // Top Drag Handle
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Header: Title & Storage Summary Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.offline_pin_rounded,
                            color: AppColors.gold, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sheetTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: isKurdish
                              ? AppTheme.kurdishTitle(
                                  fontSize: 16, color: AppColors.cream)
                              : AppTheme.englishTitle(
                                  fontSize: 16, color: AppColors.cream),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: AppColors.faintText, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reciter Switcher Bar
            GestureDetector(
              onTap: () async {
                final previousId = reciter.id;
                await ReciterSelectorSheet.show(context);
                if (QuranAudioService.instance.selectedReciter.id !=
                    previousId) {
                  _refresh();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.panelColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_rounded,
                            color: AppColors.gold, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          reciter.localizedName(lang),
                          style: isKurdish
                              ? AppTheme.kurdishText(
                                  fontSize: 13,
                                  color: AppColors.cream,
                                  fontWeight: FontWeight.bold)
                              : AppTheme.englishText(
                                  fontSize: 13,
                                  color: AppColors.cream,
                                  fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          isKurdish
                              ? 'گۆڕین'
                              : (lang == 'ar' ? 'تغيير' : 'Change'),
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isRtl
                              ? Icons.chevron_left_rounded
                              : Icons.chevron_right_rounded,
                          color: AppColors.gold,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Storage Summary Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkBg.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.panelBorderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sd_storage_rounded,
                          color: AppColors.gold, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${isKurdish ? 'قەبارەی گشتی' : (lang == 'ar' ? 'المساحة المستخدمة' : 'Total Storage')}: ${_formatBytes(_totalBytes)}',
                        style: AppTheme.englishText(
                            fontSize: 12, color: AppColors.cream),
                      ),
                    ],
                  ),
                  if (_totalBytes > 0)
                    GestureDetector(
                      onTap: () => _confirmClearAll(context, isKurdish, lang, reciter),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          isKurdish
                              ? 'سڕینەوەی هەموو'
                              : (lang == 'ar' ? 'حذف الكل' : 'Clear All'),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Surahs List
            Expanded(
              child: FutureBuilder<List<_DownloadedSurahItem>>(
                future: _downloadedFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    );
                  }

                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.panelColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.gold.withValues(alpha: 0.3)),
                              ),
                              child: Icon(Icons.cloud_download_outlined,
                                  color: AppColors.gold, size: 36),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isKurdish
                                  ? 'هیچ سورەتێک دابەزێنراو نییە'
                                  : (lang == 'ar'
                                      ? 'لا توجد سور محملة'
                                      : 'No Downloaded Surahs'),
                              style: isKurdish
                                  ? AppTheme.kurdishTitle(
                                      fontSize: 16, color: AppColors.cream)
                                  : AppTheme.englishTitle(
                                      fontSize: 16, color: AppColors.cream),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isKurdish
                                  ? 'دەتوانیت لە پەڕەی خوێندنەوە هەر سورەتێک داببەزێنیت تا بەبێ ئینتەرنێت گوێی لێبگریت.'
                                  : (lang == 'ar'
                                      ? 'يمكنك تنزيل أي سورة من مشغل الصوت للاستماع إليها دون اتصال بالإنترنت.'
                                      : 'You can download any surah from the audio player to listen completely offline.'),
                              textAlign: TextAlign.center,
                              style: isKurdish
                                  ? AppTheme.kurdishText(
                                      fontSize: 12, color: AppColors.faintText)
                                  : AppTheme.englishText(
                                      fontSize: 12, color: AppColors.faintText),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final name = isKurdish
                          ? item.meta.kurdishName
                          : (lang == 'ar'
                              ? item.meta.arabicName
                              : item.meta.englishName);

                      final isCurrentlyPlaying = QuranAudioService
                              .instance.currentSurahNumber ==
                          item.meta.number;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _openSurah(item.meta),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isCurrentlyPlaying
                                  ? AppColors.gold.withValues(alpha: 0.15)
                                  : AppColors.panelColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isCurrentlyPlaying
                                    ? AppColors.gold
                                    : AppColors.panelBorderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Surah Number
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${item.meta.number}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Surah Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: isKurdish
                                            ? AppTheme.kurdishTitle(
                                                fontSize: 14,
                                                color: isCurrentlyPlaying
                                                    ? AppColors.gold
                                                    : AppColors.cream)
                                            : AppTheme.englishText(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isCurrentlyPlaying
                                                    ? AppColors.gold
                                                    : AppColors.cream),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.meta.numberOfAyahs} ${isKurdish ? 'ئایەت' : (lang == 'ar' ? 'آيات' : 'ayahs')} · ${_formatBytes(item.fileSizeBytes)}',
                                        style: AppTheme.englishText(
                                            fontSize: 11,
                                            color: AppColors.faintText),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Action: Play Offline
                                IconButton(
                                  icon: Icon(
                                    isCurrentlyPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_fill_rounded,
                                    color: AppColors.gold,
                                    size: 28,
                                  ),
                                  onPressed: () async {
                                    AppHaptics.selectionClick();
                                    if (isCurrentlyPlaying &&
                                        QuranAudioService.instance.player.playing) {
                                      await QuranAudioService.instance.pause();
                                    } else {
                                      await QuranAudioService.instance.playSurah(
                                        item.meta.number,
                                        name,
                                        totalAyahs: item.meta.numberOfAyahs,
                                      );
                                      widget.onPlaySurah?.call();
                                    }
                                    setState(() {});
                                  },
                                ),

                                // Action: Delete
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    AppHaptics.selectionClick();
                                    await QuranDownloadService.instance
                                        .deleteDownloadedSurah(
                                            item.meta.number, reciter.id);
                                    _refresh();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, bool isKurdish, String lang,
      QuranReciter reciter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkPanel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isKurdish
              ? 'سڕینەوەی هەموو سورەتەکان'
              : (lang == 'ar' ? 'حذف جميع السور' : 'Clear All Downloads'),
          style: TextStyle(color: AppColors.gold),
        ),
        content: Text(
          isKurdish
              ? 'دڵنیایت لە سڕینەوەی تەواوی فایلە دەنگییە دابەزێنراوەکانی ئەم قورئانخوێنە؟'
              : (lang == 'ar'
                  ? 'هل أنت متأكد من حذف جميع الملفات الصوتية المحملة لهذا القارئ؟'
                  : 'Are you sure you want to delete all downloaded audio files for this reciter?'),
          style: TextStyle(color: AppColors.cream),
        ),
        actions: [
          TextButton(
            child: Text(
              isKurdish ? 'پاشگەزبوونەوە' : (lang == 'ar' ? 'إلغاء' : 'Cancel'),
              style: TextStyle(color: AppColors.faintText),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
                isKurdish ? 'سڕینەوە' : (lang == 'ar' ? 'حذف' : 'Delete')),
            onPressed: () async {
              Navigator.pop(ctx);
              await QuranDownloadService.instance
                  .clearAllDownloads(reciterId: reciter.id);
              _refresh();
            },
          ),
        ],
      ),
    );
  }
}

class _DownloadedSurahItem {
  final QuranSurahMeta meta;
  final int fileSizeBytes;

  const _DownloadedSurahItem({
    required this.meta,
    required this.fileSizeBytes,
  });
}
