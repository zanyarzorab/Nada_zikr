import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../app_localizations.dart';
import '../screens/quran_screen.dart';
import '../services/quran_audio_service.dart';
import '../services/quran_download_service.dart';
import 'app_theme.dart';
import 'downloaded_surahs_sheet.dart';
import 'reciter_selector_sheet.dart';

class QuranAudioPlayerWidget extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int totalAyahs;
  final VoidCallback? onClose;

  const QuranAudioPlayerWidget({
    Key? key,
    required this.surahNumber,
    required this.surahName,
    this.totalAyahs = 0,
    this.onClose,
  }) : super(key: key);

  @override
  State<QuranAudioPlayerWidget> createState() => _QuranAudioPlayerWidgetState();
}

class _QuranAudioPlayerWidgetState extends State<QuranAudioPlayerWidget> {
  double _currentSpeed = 1.0;
  bool _isOfflineAvailable = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  double _dragOffset = 0;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _checkOfflineStatus();
  }

  @override
  void didUpdateWidget(covariant QuranAudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surahNumber != widget.surahNumber) {
      _checkOfflineStatus();
    }
  }

  Future<void> _checkOfflineStatus() async {
    final reciter = QuranAudioService.instance.selectedReciter;
    final downloaded = await QuranDownloadService.instance.isSurahDownloaded(
      widget.surahNumber,
      reciter.id,
    );
    if (mounted) {
      setState(() {
        _isOfflineAvailable = downloaded;
      });
    }
  }

  Future<void> _startDownload() async {
    final reciter = QuranAudioService.instance.selectedReciter;
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final file = await QuranDownloadService.instance.downloadSurah(
      widget.surahNumber,
      reciter,
      onProgress: (p) {
        if (mounted) {
          setState(() {
            _downloadProgress = p;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isDownloading = false;
        _isOfflineAvailable = file != null;
      });
      if (file != null) {
        await QuranAudioService.instance
            .switchToLocalFileIfAvailable(widget.surahNumber);
      }
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      final lang = loc?.locale.languageCode ?? 'ku';
      final isKurdish = lang == 'ku';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            file != null
                ? (isKurdish
                    ? 'سورەتی ${widget.surahName} بە سەرکەوتوویی دابەزی بۆ ئۆفلاین!'
                    : (lang == 'ar'
                        ? 'تم تنزيل سورة ${widget.surahName} بنجاح للاستماع دون اتصال!'
                        : 'Surah ${widget.surahName} downloaded successfully for offline!'))
                : (isKurdish
                    ? 'دابەزاندن شکستی هێنا. تکایە هێڵی ئینتەرنێت بپشکنە.'
                    : (lang == 'ar'
                        ? 'فشل التنزيل. يرجى التحقق من اتصال الإنترنت.'
                        : 'Download failed. Please check internet connection.')),
          ),
          backgroundColor: file != null ? AppColors.gold : Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteOffline() async {
    final reciter = QuranAudioService.instance.selectedReciter;
    await QuranDownloadService.instance
        .deleteDownloadedSurah(widget.surahNumber, reciter.id);
    if (mounted) {
      setState(() {
        _isOfflineAvailable = false;
      });
      final loc = AppLocalizations.of(context);
      final lang = loc?.locale.languageCode ?? 'ku';
      final isKurdish = lang == 'ku';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isKurdish
                ? 'فایلی ئۆفلاین سڕایەوە.'
                : (lang == 'ar'
                    ? 'تم حذف الملف دون اتصال.'
                    : 'Offline file deleted.'),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleSpeed() {
    final speeds = [1.0, 1.25, 1.5, 2.0];
    final nextIndex = (speeds.indexOf(_currentSpeed) + 1) % speeds.length;
    setState(() {
      _currentSpeed = speeds[nextIndex];
    });
    QuranAudioService.instance.setSpeed(_currentSpeed);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    final isKurdish = lang == 'ku';
    final reciter = QuranAudioService.instance.selectedReciter;
    final audioService = QuranAudioService.instance;
    final playbackHint = lang == 'ku'
        ? 'ئەگەر نیشاندانی ئایەت وەستا یان خوێنەرێکت گۆڕی، کرتە لە وەستاندن و پەخشکردن بکە تا ڕێکخستنەکان دروست ببنەوە.'
        : lang == 'ar'
            ? 'إذا توقف تمييز الآية أو غيّرت القارئ، اضغط إيقاف مؤقت ثم تشغيل لمزامنة الإعدادات بشكل صحيح.'
            : 'If highlighting stops or you change the reciter, press Pause and Play once to sync the settings correctly.';
    final panelHint = lang == 'ku'
        ? 'بۆ شاردنەوەی پەنیلی دەنگ، بۆ لای چەپ ڕایبکێشە؛ بۆ گەڕاندنەوە، دەستگرتنەکە بۆ لای ڕاست ڕابکێشە.'
        : lang == 'ar'
            ? 'اسحب لوحة الصوت لليسار لإخفائها، واسحب المقبض لليمين لإعادتها.'
            : 'Swipe the audio panel left to hide it, then drag the handle right to bring it back.';

    return StreamBuilder<PlayerState>(
      stream: audioService.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing ?? false;

        final isPlayingThisSurah =
            audioService.currentSurahNumber == widget.surahNumber;

        final panel = Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gold.withValues(alpha: 0.22),
                AppColors.softSurface,
                AppColors.darkPanel,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.45), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar: Reciter name & Offline Download Status Pill
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: isKurdish || lang == 'ar'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              final previousReciterId = audioService.selectedReciter.id;
                              await ReciterSelectorSheet.show(context);
                              if (audioService.selectedReciter.id !=
                                  previousReciterId) {
                                widget.onClose?.call();
                              }
                              _checkOfflineStatus();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.gold.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_rounded,
                                      color: AppColors.gold, size: 14),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      reciter.localizedName(lang),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: isKurdish
                                          ? AppTheme.kurdishText(
                                              fontSize: 11,
                                              color: AppColors.gold,
                                              fontWeight: FontWeight.bold)
                                          : AppTheme.englishText(
                                              fontSize: 11,
                                              color: AppColors.gold,
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(Icons.arrow_drop_down_rounded,
                                      color: AppColors.gold, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: audioService.hasExactTimingSupport
                                ? const Color(0xFF10B981).withValues(alpha: 0.18)
                                : AppColors.darkBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: audioService.hasExactTimingSupport
                                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                  : AppColors.panelBorderColor,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            audioService.hasExactTimingSupport
                                ? (isKurdish
                                    ? '✨ دیاریکردن'
                                    : (lang == 'ar'
                                        ? '✨ تمييز'
                                        : '✨ Highlight'))
                                : (isKurdish
                                    ? '📻 دەنگ'
                                    : (lang == 'ar'
                                        ? '📻 صوت'
                                        : '📻 Audio')),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: audioService.hasExactTimingSupport
                                  ? const Color(0xFF34D399)
                                  : AppColors.faintText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  const SizedBox(width: 6),

                  // Controls on Right: Download, Speed, Close
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isDownloading)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.amber),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(_downloadProgress * 100).toInt()}%',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber),
                                  ),
                                ],
                              ),
                            )
                          else if (_isOfflineAvailable)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                    onTap: () async {
                                      await DownloadedSurahsSheet.show(
                                        context,
                                        onSurahSelected: (surah) {
                                          if (surah.number == widget.surahNumber) {
                                            if (!QuranAudioService.instance.player.playing) {
                                              QuranAudioService.instance.resume();
                                            }
                                          } else {
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (_) => SurahReadingScreen(
                                                  surah: surah,
                                                  autoPlayAudio: true,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                      _checkOfflineStatus();
                                    },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.green.withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.download_done_rounded,
                                            size: 12, color: Colors.greenAccent),
                                        const SizedBox(width: 4),
                                        Text(
                                          isKurdish
                                              ? 'ئۆفلاین'
                                              : (lang == 'ar' ? 'بدون إنترنت' : 'Offline'),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.greenAccent),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: _deleteOffline,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black26,
                                    ),
                                    child: const Icon(Icons.delete_outline_rounded,
                                        size: 14, color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            )
                          else
                            GestureDetector(
                              onTap: _startDownload,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.gold.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.download_rounded,
                                        size: 12, color: AppColors.gold),
                                    const SizedBox(width: 4),
                                    Text(
                                      isKurdish
                                          ? 'دابەزاندن'
                                          : (lang == 'ar' ? 'تنزيل' : 'Download'),
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.gold),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(width: 6),

                          // Speed button
                          GestureDetector(
                            onTap: _toggleSpeed,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.darkPanel,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: AppColors.panelBorderColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.speed_rounded,
                                      size: 13, color: AppColors.faintText),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${_currentSpeed}x',
                                    style: AppTheme.englishText(
                                        fontSize: 10,
                                        color: AppColors.faintText,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Close / Stop Button
                          GestureDetector(
                            onTap: () async {
                              await audioService.stop();
                              if (mounted) widget.onClose?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black38,
                              ),
                              child: Icon(Icons.close_rounded,
                                  size: 16, color: AppColors.faintText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: AppColors.gold),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            playbackHint,
                            textDirection: lang == 'ku' || lang == 'ar'
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: AppTheme.englishText(
                                fontSize: 10, color: AppColors.faintText),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            panelHint,
                            textDirection: lang == 'ku' || lang == 'ar'
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: AppTheme.englishText(
                                fontSize: 10, color: AppColors.faintText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Middle Row: Surah Title & Play/Pause Controls
              Row(
                children: [
                  // Big Play / Pause Circle Button
                  GestureDetector(
                    onTap: () {
                      if (isPlayingThisSurah && playing) {
                        audioService.pause();
                      } else if (isPlayingThisSurah && !playing) {
                        audioService.resume();
                      } else {
                        audioService.playSurah(
                          widget.surahNumber,
                          widget.surahName,
                          totalAyahs: widget.totalAyahs,
                        );
                      }
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFFF2A1),
                            AppColors.gold,
                            const Color(0xFF8B6B1B),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                              )
                            : Icon(
                                (isPlayingThisSurah && playing)
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 28,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Surah Title info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPlayingThisSurah
                              ? (playing
                                  ? (isKurdish
                                      ? 'تلاوەت دەکرێت...'
                                      : (lang == 'ar'
                                          ? 'جارٍ التلاوة...'
                                          : 'Playing...'))
                                  : (isKurdish
                                      ? 'وەستێنراوە'
                                      : (lang == 'ar'
                                          ? 'متوقف مؤقتاً'
                                          : 'Paused')))
                              : (isKurdish
                                  ? 'گوێ لە ڕێبەرایەتی تلاوەت بگرە'
                                  : (lang == 'ar'
                                      ? 'استمع إلى التلاوة'
                                      : 'Listen to recitation')),
                          style: isKurdish
                              ? AppTheme.kurdishText(
                                  fontSize: 11, color: AppColors.faintText)
                              : (lang == 'ar'
                                  ? AppTheme.arabicText(
                                      fontSize: 11, color: AppColors.faintText)
                                  : AppTheme.englishText(
                                      fontSize: 11, color: AppColors.faintText)),
                        ),
                        Text(
                          widget.surahName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.kurdishTitle(
                              fontSize: 16, color: AppColors.cream),
                        ),
                        StreamBuilder<int?>(
                          stream: audioService.currentAyahStream,
                          builder: (context, ayahSnapshot) {
                            final liveAyah = ayahSnapshot.data ??
                                audioService.currentAyahNumber;
                            if (liveAyah == null || liveAyah < 1) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.gold
                                          .withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.graphic_eq_rounded,
                                        size: 11, color: AppColors.gold),
                                    const SizedBox(width: 3),
                                    Text(
                                      isKurdish
                                          ? 'ئایەت $liveAyah'
                                          : (lang == 'ar'
                                              ? 'الآية $liveAyah'
                                              : 'Ayah $liveAyah'),
                                      style: isKurdish
                                          ? AppTheme.kurdishText(
                                              fontSize: 10,
                                              color: AppColors.gold,
                                              fontWeight: FontWeight.bold)
                                          : (lang == 'ar'
                                              ? AppTheme.arabicText(
                                                  fontSize: 10,
                                                  color: AppColors.gold,
                                                  fontWeight: FontWeight.bold)
                                              : AppTheme.englishText(
                                                  fontSize: 10,
                                                  color: AppColors.gold,
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Bottom Progress Bar & Timers
              StreamBuilder<Duration?>(
                stream: audioService.durationStream,
                builder: (context, durationSnapshot) {
                  final duration = durationSnapshot.data ?? Duration.zero;

                  return StreamBuilder<Duration>(
                    stream: audioService.positionStream,
                    builder: (context, positionSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      final maxDurationMs = duration.inMilliseconds.toDouble();
                      final currentPositionMs = position.inMilliseconds
                          .toDouble()
                          .clamp(0.0, maxDurationMs > 0 ? maxDurationMs : 1.0);

                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12),
                              activeTrackColor: AppColors.gold,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: const Color(0xFFFFD700),
                            ),
                            child: Slider(
                              value: currentPositionMs,
                              max: maxDurationMs > 0 ? maxDurationMs : 1.0,
                              onChanged: (val) {
                                if (isPlayingThisSurah) {
                                  audioService.seek(
                                      Duration(milliseconds: val.toInt()));
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: AppTheme.englishText(
                                      fontSize: 10, color: AppColors.faintText),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: AppTheme.englishText(
                                      fontSize: 10, color: AppColors.faintText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );

        if (_isCollapsed) {
          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 0) {
                setState(() => _dragOffset =
                    (_dragOffset + details.delta.dx).clamp(0.0, 90.0));
              }
            },
            onHorizontalDragEnd: (_) {
              if (_dragOffset > 30) {
                setState(() {
                  _isCollapsed = false;
                  _dragOffset = 0;
                });
              } else {
                setState(() => _dragOffset = 0);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin:
                  const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
              height: 28,
              transform: Matrix4.translationValues(_dragOffset - 70, 0, 0),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
              ),
              child: Center(
                child:
                    Icon(Icons.swipe_rounded, size: 16, color: AppColors.gold),
              ),
            ),
          );
        }

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx < 0) {
              setState(() => _dragOffset =
                  (_dragOffset + details.delta.dx).clamp(-120.0, 0.0));
            }
          },
          onHorizontalDragEnd: (_) {
            if (_dragOffset < -55) {
              setState(() {
                _isCollapsed = true;
                _dragOffset = 0;
              });
            } else {
              setState(() => _dragOffset = 0);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: panel,
          ),
        );
      },
    );
  }
}
