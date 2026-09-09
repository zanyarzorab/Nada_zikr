import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/app_data.dart';
import '../models/azkar_model.dart';
import '../services/app_haptics.dart';
import '../services/quran_service.dart';
import '../services/storage_service.dart';
import '../services/dhikr_package_service.dart';
import '../services/hadith_service.dart';
import '../services/quran_dua_service.dart';
import '../services/zikr_audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/app_theme.dart';
import '../widgets/dua_card_generator.dart';

class ReadingScreen extends StatefulWidget {
  final AzkarCategory category;

  const ReadingScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  List<Azkar> _azkarList = const [];
  int _currentIndex = 0;
  // Stores per-zikr repeat counts so navigating back/forward keeps progress
  final Map<int, int> _repeatCounts = {};
  bool _completed = false;
  bool _isCountingPulse = false;
  bool _showEnglishTranslation = false;

  int get _repeatCount => _repeatCounts[_currentIndex] ?? 0;
  void _setRepeatCount(int val) => _repeatCounts[_currentIndex] = val;

  @override
  void initState() {
    super.initState();
    _loadAzkar();
  }

  @override
  void dispose() {
    ZikrAudioService.instance.stop();
    super.dispose();
  }

  Future<void> _loadAzkar() async {
    final list =
        AppData.getAzkarByCategory(widget.category.id)[widget.category.id];
    _azkarList = list ?? AppData.morningAzkar;
    if (widget.category.id == 'morning' ||
        widget.category.id == 'evening' ||
        widget.category.id == 'prayer') {
      _azkarList =
          await DhikrPackageService.instance.loadCategory(widget.category.id);
    } else if (widget.category.id == 'hadith') {
      final hadiths = await HadithService.loadAllHadiths();
      _azkarList = hadiths.map((h) {
        return Azkar(
          id: h.id,
          arabic: h.textAr,
          translation: h.narratorAr,
          kurdishTranslation: h.textKu,
          repeat: 1,
          source: '${h.chapter} • ${h.source} (${h.grade})',
        );
      }).toList();
    } else if (widget.category.id == 'surah_mulk') {
      final ayahs = await QuranService.instance.loadAyahsForSurah(67);
      _azkarList = await Future.wait(ayahs.map((a) async {
        final tafsir = await QuranService.instance.getTafsir('hazhar', 67, a.ayah) ??
            await QuranService.instance.getTafsir('asan', 67, a.ayah) ?? '';
        return Azkar(
          id: a.ayah,
          arabic: a.text,
          translation: '',
          kurdishTranslation: tafsir,
          repeat: 1,
          source: 'سوورەتی الملك : ${a.ayah}',
        );
      }));
    } else if (widget.category.id == 'surah_kahf') {
      final ayahs = await QuranService.instance.loadAyahsForSurah(18);
      _azkarList = await Future.wait(ayahs.map((a) async {
        final tafsir = await QuranService.instance.getTafsir('hazhar', 18, a.ayah) ??
            await QuranService.instance.getTafsir('asan', 18, a.ayah) ?? '';
        return Azkar(
          id: a.ayah,
          arabic: a.text,
          translation: '',
          kurdishTranslation: tafsir,
          repeat: 1,
          source: 'سوورەتی الكهف : ${a.ayah}',
        );
      }));
    } else if (widget.category.id == 'quran') {
      final duas = await QuranDuaService.loadAllDuas();
      _azkarList = duas.map((d) => d.toAzkar()).toList();
    }
    if (mounted) setState(() {});
  }

  Future<void> _handleCount() async {
    final current = _azkarList[_currentIndex];
    StorageService.incrementZikrCount(zikrKey: current.arabic, count: 1);

    setState(() {
      _isCountingPulse = true;
    });
    AppHaptics.lightImpact();

    if (_repeatCount < current.repeat) {
      setState(() => _setRepeatCount(_repeatCount + 1));
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) {
          setState(() => _isCountingPulse = false);
        }
      });
      return;
    }

    if (_currentIndex < _azkarList.length - 1) {
      if (ZikrAudioService.instance.currentlyPlayingKey?.startsWith('zikr_') == true) {
        ZikrAudioService.instance.stop();
      }
      setState(() {
        _currentIndex++;
        _isCountingPulse = false;
      });
      return;
    }

    await _completeSession();
  }

  Future<void> _handleNext() async {
    if (_currentIndex < _azkarList.length - 1) {
      if (ZikrAudioService.instance.currentlyPlayingKey?.startsWith('zikr_') == true) {
        ZikrAudioService.instance.stop();
      }
      setState(() {
        _currentIndex++;
      });
      return;
    }

    await _completeSession();
  }

  void _handleBack() {
    if (_currentIndex > 0) {
      if (ZikrAudioService.instance.currentlyPlayingKey?.startsWith('zikr_') == true) {
        ZikrAudioService.instance.stop();
      }
      setState(() {
        _currentIndex--;
      });
      return;
    }

    ZikrAudioService.instance.stop();
    Navigator.pop(context);
  }

  Future<void> _completeSession() async {
    await StorageService.recordSessionCompletion();
    if (const ['morning', 'evening', 'sleep'].contains(widget.category.id)) {
      await StorageService.markDailyPathComplete(widget.category.id);
    }
    setState(() => _completed = true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    final isKurdish = lang == 'ku';

    if (_completed) {
      return _buildCompletedScreen(isKurdish, loc);
    }

    if (_azkarList.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final current = _azkarList[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBg,
              AppColors.darkBgAlt,
              AppColors.softSurface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.panelColor,
                    border: Border.all(color: AppColors.panelBorderColor),
                    borderRadius: BorderRadius.circular(20),
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
                          child: Icon(Icons.arrow_back,
                              size: 16, color: AppColors.cream),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.getTitle(lang),
                              style: isKurdish
                                  ? AppTheme.kurdishTitle(
                                      fontSize: 15, color: AppColors.cream)
                                  : AppTheme.englishText(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${_currentIndex + 1} / ${_azkarList.length}',
                              style: AppTheme.englishText(
                                  fontSize: 11, color: AppColors.faintText),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.share_outlined, color: AppColors.gold),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                DuaCardGeneratorDialog(azkar: current),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _azkarList.isNotEmpty
                        ? (_currentIndex + 1) / _azkarList.length
                        : 0.0,
                    backgroundColor: AppColors.panelColor,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _handleCount,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.panelColor,
                            border:
                                Border.all(color: AppColors.panelBorderColor),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              if (widget.category.id == 'morning' ||
                                  widget.category.id == 'evening' ||
                                  widget.category.id == 'ayat_kursi') ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: _buildAudioButton(current, isKurdish),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                              Text(
                                current.displayArabic,
                                style: AppTheme.arabicTitle(fontSize: 24),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Dual Meaning: Kurdish First + Expandable English
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (current.kurdishTranslation.isNotEmpty) ...[
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: AppColors.gold
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      '📖 مانای کوردی',
                                      style: AppTheme.kurdishText(
                                        fontSize: 11,
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                current.kurdishTranslation,
                                style: AppTheme.kurdishText(
                                  color:
                                      AppColors.cream.withValues(alpha: 0.95),
                                  fontSize: 14,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                            ],

                            // English Translation Expandable Toggle
                            if (current.translation.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  AppHaptics.selectionClick();
                                  setState(() => _showEnglishTranslation =
                                      !_showEnglishTranslation);
                                },
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: _showEnglishTranslation
                                              ? const Color(0xFF3B82F6)
                                                  .withValues(alpha: 0.18)
                                              : AppColors.darkPanel,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _showEnglishTranslation
                                                ? const Color(0xFF60A5FA)
                                                    .withValues(alpha: 0.45)
                                                : AppColors.panelBorderColor,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _showEnglishTranslation
                                                  ? Icons.expand_less_rounded
                                                  : Icons.expand_more_rounded,
                                              size: 16,
                                              color: const Color(0xFF93C5FD),
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                _showEnglishTranslation
                                                    ? 'شاردنەوەی ئینگلیزی'
                                                    : 'پیشاندانی مانای ئینگلیزی (English) ▼',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF93C5FD),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_showEnglishTranslation) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B)
                                        .withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF3B82F6)
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF3B82F6)
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              '🌐 English Translation',
                                              style: TextStyle(
                                                color: Color(0xFF93C5FD),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        current.translation,
                                        style: AppTheme.englishText(
                                          color: AppColors.cream
                                              .withValues(alpha: 0.92),
                                          fontSize: 13,
                                        ).copyWith(height: 1.5),
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: AnimatedScale(
                            scale: _isCountingPulse ? 1.06 : 1.0,
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOut,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 22),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.08),
                                border: Border.all(
                                    color:
                                        AppColors.gold.withValues(alpha: 0.28)),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isKurdish
                                        ? 'ژمارە: ${current.repeatLabel}'
                                        : 'Repeat: ${current.repeatLabel}',
                                    style: AppTheme.englishText(
                                        fontSize: 11,
                                        color: AppColors.faintText,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_repeatCount / ${current.repeatLabel}',
                                    style: AppTheme.englishTitle(
                                        fontSize: 30, color: AppColors.gold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _repeatCount >= current.repeat
                                        ? (isKurdish ? 'تەواوبوو' : 'Completed')
                                        : (() {
                                            final remaining =
                                                current.repeat - _repeatCount;
                                            if (remaining == 1) {
                                              return isKurdish
                                                  ? 'یەک جار بکە'
                                                  : 'Tap 1 time';
                                            }
                                            return isKurdish
                                                ? 'بۆ $remaining جار بکە'
                                                : 'Tap $remaining times';
                                          }()),
                                    style: isKurdish
                                        ? AppTheme.kurdishText(
                                            color: AppColors.cream,
                                            fontSize: 12)
                                        : AppTheme.englishText(
                                            color: AppColors.cream,
                                            fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(
                              current.repeat > 10 ? 10 : current.repeat,
                              (i) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i < _repeatCount
                                        ? AppColors.gold
                                        : AppColors.panelColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                child: Row(
                  children: [
                    // 1. Back / Previous (<)
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.faintText,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            side: BorderSide(color: AppColors.panelBorderColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: _handleBack,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chevron_left_rounded,
                                    size: 18, color: AppColors.faintText),
                                const SizedBox(width: 4),
                                Text(
                                  isKurdish
                                      ? 'گەڕانەوە'
                                      : (lang == 'ar' ? 'السابق' : 'Back'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: isKurdish
                                      ? AppTheme.kurdishTitle(
                                          fontSize: 14,
                                          color: AppColors.faintText)
                                      : AppTheme.englishText(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.faintText),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 2. Count (Center)
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.darkBg,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                          onPressed: _handleCount,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isKurdish
                                  ? 'ژماردن'
                                  : (lang == 'ar' ? 'تسبيح' : 'Count'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: isKurdish
                                  ? AppTheme.kurdishTitle(
                                      fontSize: 15, color: AppColors.darkBg)
                                  : AppTheme.englishTitle(
                                      fontSize: 15, color: AppColors.darkBg),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 3. Next (>)
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.panelColor,
                            foregroundColor: AppColors.cream,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            side: BorderSide(color: AppColors.panelBorderColor),
                            elevation: 0,
                          ),
                          onPressed: _handleNext,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isKurdish
                                  ? 'دواتر'
                                  : (lang == 'ar' ? 'التالي' : 'Next'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: isKurdish
                                      ? AppTheme.kurdishTitle(
                                          fontSize: 14,
                                          color: AppColors.cream)
                                      : AppTheme.englishText(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.cream),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right_rounded,
                                    size: 18, color: AppColors.cream),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedScreen(bool isKurdish, AppLocalizations? loc) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 68, color: AppColors.gold),
                const SizedBox(height: 24),
                Text(
                  isKurdish
                      ? 'خوای گەورە پاداشتت بداتەوە!'
                      : 'Session Completed!',
                  style: isKurdish
                      ? AppTheme.kurdishTitle(fontSize: 22, color: AppColors.gold)
                      : AppTheme.englishTitle(
                          fontSize: 22, color: AppColors.gold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isKurdish
                      ? 'هەموو زیکرەکانی ئەم بەشەت بە سەرکەوتوویی خوێندەوە.'
                      : 'You have completed all Azkar in this category.',
                  style: isKurdish
                      ? AppTheme.kurdishText(
                          color: AppColors.mutedText, fontSize: 14)
                      : AppTheme.englishText(
                          color: AppColors.mutedText, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.darkBg,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    isKurdish ? 'گەڕانەوە بۆ سەرەتا' : 'Return Home',
                    style: isKurdish
                        ? AppTheme.kurdishTitle(
                            fontSize: 15, color: AppColors.darkBg)
                        : AppTheme.englishTitle(
                            fontSize: 15, color: AppColors.darkBg),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioButton(Azkar zikr, bool isKurdish) {
    final zikrId = zikr.id ?? (_currentIndex + 1);
    final itemKey = 'zikr_${widget.category.id}_${zikrId}_$_currentIndex';

    return StreamBuilder<PlayerState>(
      stream: ZikrAudioService.instance.itemPlayerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;
        final processingState = playerState?.processingState;
        final isBuffering = processingState == ProcessingState.buffering ||
            processingState == ProcessingState.loading;
        final isThisPlaying = isPlaying &&
            ZikrAudioService.instance.itemCurrentlyPlayingKey == itemKey;

        return GestureDetector(
          onTap: () {
            ZikrAudioService.instance.toggleZikrItemAudio(
              zikr,
              _currentIndex,
              widget.category.id,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isThisPlaying
                  ? AppColors.gold.withValues(alpha: 0.22)
                  : AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isThisPlaying
                    ? AppColors.gold
                    : AppColors.gold.withValues(alpha: 0.3),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBuffering && isThisPlaying)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    )
                  else
                    Icon(
                      isThisPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.volume_up_rounded,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    isThisPlaying
                        ? (isKurdish ? 'ڕاگرتن' : 'Pause')
                        : (isKurdish ? 'خوێندنەوەی دەنگی' : 'Listen'),
                    style: isKurdish
                        ? AppTheme.kurdishTitle(
                            fontSize: 12, color: AppColors.gold)
                        : AppTheme.englishTitle(
                            fontSize: 12, color: AppColors.gold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
