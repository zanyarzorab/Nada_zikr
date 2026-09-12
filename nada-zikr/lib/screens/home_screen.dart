import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/app_data.dart';
import '../models/azkar_model.dart';
import '../services/app_haptics.dart';
import '../services/app_share_service.dart';
import '../services/quran_mood_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import 'categories_screen.dart';
import 'favorite_mood_cards_screen.dart';
import 'names_of_allah_screen.dart';
import 'quran_screen.dart';
import 'statistics_screen.dart';
import 'tasbeeh_screen.dart';
import 'reading_screen.dart';
import 'hadith_screen.dart';
import 'quran_duas_screen.dart';
import 'general_duas_screen.dart';
import '../services/quran_service.dart';
import '../services/prayer_repository.dart';
import '../widgets/qibla_compass_sheet.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index)? onSelectTab;
  const HomeScreen({Key? key, this.onSelectTab}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _profile;
  String? _selectedMood;
  Map<String, bool> _dailyPath = {};

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
  void initState() {
    super.initState();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    AppThemeController.instance.addListener(_onThemeChanged);
    StorageService.dailyPathChanges.addListener(_onDailyPathChanged);
    _loadProfile();
  }

  @override
  void dispose() {
    AppThemeController.instance.removeListener(_onThemeChanged);
    StorageService.dailyPathChanges.removeListener(_onDailyPathChanged);
    super.dispose();
  }

  void _onDailyPathChanged() {
    _loadDailyPath();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDailyPath();
  }

  void _loadDailyPath() {
    if (mounted) {
      final completion = StorageService.getDailyPathCompletion();
      final hasCompletedAllFour = completion['morning'] == true &&
          completion['tasbeeh'] == true &&
          completion['evening'] == true &&
          completion['sleep'] == true;
      setState(() => _dailyPath = completion);

      if (hasCompletedAllFour) {
        final loc = AppLocalizations.of(context);
        final isKurdish = (loc?.locale.languageCode ?? 'ku') == 'ku';
        _checkAndShowDailyPathCongrats(isKurdish);
      }
    }
  }


  void _checkAndShowDailyPathCongrats(bool isKurdish) async {
    final completion = StorageService.getDailyPathCompletion();
    final hasCompletedAllFour = completion['morning'] == true &&
        completion['tasbeeh'] == true &&
        completion['evening'] == true &&
        completion['sleep'] == true;
    if (!hasCompletedAllFour) return;

    final now = DateTime.now();
    final todayKey = 'daily_path_congrats_shown_${now.year}_${now.month}_${now.day}';
    final alreadyShown =
        await StorageService.readSetting(todayKey, defaultValue: false);
    if (alreadyShown == true) return;
    await StorageService.saveSetting(todayKey, true);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkPanel,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppColors.gold, width: 1.5),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.emoji_events_rounded, size: 48, color: AppColors.gold),
                ),
                const SizedBox(height: 16),
                Text(
                  isKurdish ? 'پیرۆزباییت لێ دەکەین!' : 'Congratulations!',
                  textAlign: TextAlign.center,
                  style: isKurdish
                      ? AppTheme.kurdishTitle(fontSize: 22, color: AppColors.gold)
                      : AppTheme.englishTitle(fontSize: 22, color: AppColors.gold),
                ),
                const SizedBox(height: 10),
                Text(
                  isKurdish
                      ? 'تەواوی 4 بەشی ڕێڕەوی ڕۆژانەی زیکرەکانت بۆ ئەمڕۆ بە سەرکەوتوویی تەواو کرد. خوای میهرەبان بەڵێنی پاداشتی زۆرترت پێ دەدات.'
                      : 'You have successfully completed all 4 steps of your Daily Path today. May Allah reward you greatly!',
                  textAlign: TextAlign.center,
                  style: isKurdish
                      ? AppTheme.kurdishText(fontSize: 13, color: AppColors.cream)
                      : AppTheme.englishText(fontSize: 13, color: AppColors.cream),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isKurdish
                            ? 'الحمد لله (سوپاس بۆ خوا)'
                            : 'Alhamdulillah (Praise be to Allah)',
                        style: isKurdish
                            ? AppTheme.kurdishTitle(
                                fontSize: 14, color: Colors.black)
                            : AppTheme.englishTitle(
                                fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDailyStep(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadDailyPath();
  }

  Future<void> _openDailyCategory(String categoryId) async {
    final category = AppData.azkarCategories.firstWhere(
      (item) => item.id == categoryId,
    );
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReadingScreen(category: category)),
    );
    _loadDailyPath();
  }

  Future<void> _loadProfile() async {
    final profile = await StorageService.getUserProfile();
    if (mounted) {
      setState(() => _profile = profile);
    }
  }

  Future<void> _onRefresh() async {
    AppHaptics.selectionClick();
    await Future.wait([
      _loadProfile(),
      Future.microtask(() => _loadDailyPath()),
    ]);
    if (mounted) setState(() {});
  }

  String _getGreeting(String lang) {
    final hour = DateTime.now().hour;
    if (lang == 'ku') {
      if (hour >= 4 && hour < 12) return 'بەیانیت باش';
      if (hour >= 12 && hour < 17) return 'ڕۆژت باش';
      if (hour >= 17 && hour < 21) return 'ئێوارەت باش';
      return 'شەوت باش';
    } else if (lang == 'en') {
      if (hour >= 4 && hour < 12) return 'Good Morning';
      if (hour >= 12 && hour < 17) return 'Good Afternoon';
      if (hour >= 17 && hour < 21) return 'Good Evening';
      return 'Good Night';
    } else {
      if (hour >= 4 && hour < 12) return 'صباح الخير';
      if (hour >= 12 && hour < 17) return 'طاب نهارك';
      if (hour >= 17 && hour < 21) return 'مساء الخير';
      return 'طابت ليلتك';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    final isKurdish = lang == 'ku';
    final isArabic = lang == 'ar';

    if (_profile == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final customName = _profile!.name.trim();
    final hasName = customName.isNotEmpty &&
        customName.toLowerCase() != 'beloved' &&
        customName != 'موسڵمان';

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
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cream.withValues(alpha: 0.04),
                ),
              ),
            ),
            SafeArea(
              child: RefreshIndicator(
                color: AppColors.gold,
                backgroundColor: AppColors.darkPanel,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.panelColor,
                          border: Border.all(color: AppColors.panelBorderColor),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 26,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        loc?.translate('appTitle') ?? 'نەدا',
                                        style: isKurdish
                                            ? AppTheme.kurdishTitle(
                                                fontSize: 16, color: AppColors.gold)
                                            : AppTheme.englishTitle(
                                                fontSize: 16,
                                                color: AppColors.gold),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.gold
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: AppColors.gold
                                                    .withValues(alpha: 0.25)),
                                          ),
                                          child: Text(
                                            loc?.translate('appTagline') ??
                                                (isKurdish
                                                    ? 'شەونمی ئارامی بۆ دڵەکان'
                                                    : 'Dew of Spiritual Serenity'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: isKurdish
                                                ? AppTheme.kurdishText(
                                                    fontSize: 10,
                                                    color: AppColors.gold,
                                                    fontWeight: FontWeight.bold)
                                                : (isArabic
                                                    ? AppTheme.arabicText(
                                                        fontSize: 10,
                                                        color: AppColors.gold)
                                                    : AppTheme.englishText(
                                                        fontSize: 10,
                                                        color: AppColors.gold,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getGreeting(lang),
                                    style: isKurdish
                                        ? (hasName
                                            ? AppTheme.kurdishText(
                                                color: AppColors.mutedText,
                                                fontSize: 13)
                                            : AppTheme.kurdishTitle(
                                                fontSize: 20,
                                                color: AppColors.cream))
                                        : (hasName
                                            ? AppTheme.labelText(
                                                color: AppColors.mutedText)
                                            : AppTheme.englishTitle(
                                                fontSize: 20,
                                                color: AppColors.cream)),
                                  ),
                                  if (hasName) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      customName,
                                      style: isKurdish
                                          ? AppTheme.kurdishTitle(fontSize: 20)
                                          : AppTheme.englishTitle(fontSize: 20),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const StatisticsScreen()));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.12),
                                  border: Border.all(
                                      color: AppColors.gold
                                          .withValues(alpha: 0.25)),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.local_fire_department_rounded, size: 20, color: AppColors.gold),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_profile!.currentStreak}',
                                      style: AppTheme.englishTitle(
                                          fontSize: 18, color: AppColors.cream),
                                    ),
                                    Text(
                                      loc?.translate('streak') ?? 'ڕۆژ',
                                      style: isKurdish
                                          ? AppTheme.kurdishText(
                                              fontSize: 10,
                                              color: AppColors.faintText)
                                          : AppTheme.englishText(
                                              fontSize: 10,
                                              color: AppColors.faintText),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Mood selector
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  loc?.translate('moodTitle') ?? 'ئەمڕۆ هەستت چۆنە؟',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: isKurdish
                                      ? AppTheme.kurdishTitle(
                                          fontSize: 14, color: AppColors.gold)
                                      : AppTheme.labelText(
                                          color: AppColors.mutedText),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const FavoriteMoodCardsScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.gold.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bookmark_rounded,
                                          size: 14, color: AppColors.gold),
                                      const SizedBox(width: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          loc?.translate('savedCards') ??
                                              (isKurdish
                                                  ? 'کارتە دڵخوازەکان'
                                                  : (lang == 'ar'
                                                      ? 'المحفوظات'
                                                      : 'Saved Cards')),
                                          style: isKurdish
                                              ? AppTheme.kurdishText(
                                                  color: AppColors.gold,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold)
                                              : AppTheme.englishText(
                                                  color: AppColors.gold,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                ...AppData.moods.map((mood) {
                                  final isSelected = _selectedMood == mood.id;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedMood =
                                          isSelected ? null : mood.id),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.gold
                                                  .withValues(alpha: 0.16)
                                              : AppColors.panelColor,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.gold
                                                    .withValues(alpha: 0.4)
                                                : AppColors.panelBorderColor,
                                          ),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              mood.iconData,
                                              size: 20,
                                              color: isSelected
                                                  ? AppColors.gold
                                                  : AppColors.faintText,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              mood.getDisplay(lang),
                                              style: isKurdish
                                                  ? AppTheme.kurdishText(
                                                      color: isSelected
                                                          ? AppColors.gold
                                                          : AppColors.faintText,
                                                      fontSize: 12,
                                                    )
                                                  : AppTheme.arabicText(
                                                      color: isSelected
                                                          ? AppColors.gold
                                                          : AppColors.faintText,
                                                      fontSize: 12,
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          if (_selectedMood != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc?.translate('moodSubtitle') ??
                                        'دوعا و زیکری تایبەت بەپێی بارودۆخی دڵت هەڵبژێرە',
                                    style: isKurdish
                                        ? AppTheme.kurdishText(
                                            color: AppColors.faintText,
                                            fontSize: 11)
                                        : AppTheme.englishText(
                                            color: AppColors.faintText,
                                            fontSize: 11),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _openMoodCard,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 12),
                                        backgroundColor: AppColors.gold
                                            .withValues(alpha: 0.14),
                                        foregroundColor: AppColors.cream,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          side: BorderSide(
                                              color: AppColors.gold
                                                  .withValues(alpha: 0.35)),
                                        ),
                                      ),
                                      icon: const Icon(
                                          Icons.auto_awesome_rounded,
                                          size: 18),
                                      label: Text(
                                        loc?.translate('createMoodCard') ??
                                            'دروستکردنی کارتی هەست',
                                        style: isKurdish
                                            ? AppTheme.kurdishTitle(
                                                fontSize: 12,
                                                color: AppColors.cream)
                                            : AppTheme.englishTitle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.cream),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Quick Path
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isKurdish ? 'ڕێڕەوی ڕۆژانە' : 'DAILY PATH',
                                style: isKurdish
                                    ? AppTheme.kurdishTitle(
                                        fontSize: 14, color: AppColors.gold)
                                    : AppTheme.labelText(
                                        color: AppColors.mutedText),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color:
                                          AppColors.gold.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '${['morning', 'tasbeeh', 'evening', 'sleep'].where((step) => _dailyPath[step] == true).length} / 4',
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildPathItem(
                            isKurdish ? 'زیکری بەیانیان' : 'Morning Azkar',
                            'أذكار الصباح',
                            _dailyPath['morning'] == true,
                            () => _openDailyCategory('morning'),
                            isKurdish,
                          ),
                          const SizedBox(height: 8),
                          _buildPathItem(
                            isKurdish ? 'تەسبیح' : 'Tasbih',
                            'تسبيح',
                            _dailyPath['tasbeeh'] == true,
                            () {
                              if (widget.onSelectTab != null) {
                                widget.onSelectTab!(2);
                              } else {
                                _openDailyStep(const TasbeehScreen());
                              }
                            },
                            isKurdish,
                          ),
                          const SizedBox(height: 8),
                          _buildPathItem(
                            isKurdish ? 'زیکری ئێواران' : 'Evening Azkar',
                            'أذكار المساء',
                            _dailyPath['evening'] == true,
                            () => _openDailyCategory('evening'),
                            isKurdish,
                          ),
                          const SizedBox(height: 8),
                          _buildPathItem(
                            isKurdish ? 'زیکری پێش خەوتن' : 'Sleep Azkar',
                            'أذكار النوم',
                            _dailyPath['sleep'] == true,
                            () => _openDailyCategory('sleep'),
                            isKurdish,
                          ),
                          if (['morning', 'tasbeeh', 'evening', 'sleep'].where((step) => _dailyPath[step] == true).length == 4)
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.gold.withValues(alpha: 0.24),
                                    AppColors.softSurface,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.gold, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.15),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.celebration_rounded, size: 28, color: AppColors.gold),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isKurdish
                                              ? 'پیرۆزە! ڕێڕەوی ڕۆژانەت ۱۰۰٪ تەواو کرد'
                                              : 'Daily Path 100% Completed!',
                                          style: isKurdish
                                              ? AppTheme.kurdishTitle(
                                                  fontSize: 13, color: AppColors.gold)
                                              : AppTheme.englishTitle(
                                                  fontSize: 13, color: AppColors.gold),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          isKurdish
                                              ? 'خوای گەورە پاداشتی خێرت بداتەوە و زیکرەکانت لێ قبوڵ بکات'
                                              : 'May Allah accept your daily zikr and reward you immensely!',
                                          style: isKurdish
                                              ? AppTheme.kurdishText(
                                                  fontSize: 11, color: AppColors.cream)
                                              : AppTheme.englishText(
                                                  fontSize: 11, color: AppColors.cream),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Horizontal Zikrs Section
                    _buildHorizontalZikrsSection(isKurdish, lang),

                    // Grid Quick Access
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isKurdish ? 'بەشە خێراکان' : 'QUICK ACCESS',
                            style: isKurdish
                                ? AppTheme.kurdishTitle(
                                    fontSize: 14, color: AppColors.gold)
                                : AppTheme.labelText(
                                    color: AppColors.mutedText),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildQuickCard(
                                label: isKurdish
                                    ? 'ناوی خوای گەورە'
                                    : (lang == 'ar'
                                        ? 'أسماء الله الحسنى'
                                        : '99 Names'),
                                subtitle: isKurdish
                                    ? 'ئەسماول حوسنا'
                                    : (lang == 'ar'
                                        ? 'معاني وفضائل'
                                        : 'Asmaul Husna'),
                                badgeText: isKurdish
                                    ? '99 ناو'
                                    : (lang == 'ar' ? '99 اسم' : '99 Names'),
                                icon: Icons.stars_rounded,
                                accentColor: AppColors.gold,
                                isKurdish: isKurdish,
                                imagePath: 'assets/images/quick_names_of_allah.jpg',
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const NamesOfAllahScreen()));
                                },
                              ),
                              _buildQuickCard(
                                label: isKurdish
                                    ? 'زیکر و دوعاکان'
                                    : (lang == 'ar'
                                        ? 'الأذكار والأدعية'
                                        : 'All Zikr & Duas'),
                                subtitle: isKurdish
                                    ? 'سەرجەم بەشەکان'
                                    : (lang == 'ar'
                                        ? 'جميع الأقسام'
                                        : 'All Categories'),
                                badgeText: isKurdish
                                    ? 'هەموو'
                                    : (lang == 'ar' ? 'الكل' : 'All'),
                                icon: Icons.auto_stories_rounded,
                                accentColor: const Color(0xFF10B981),
                                isKurdish: isKurdish,
                                imagePath: 'assets/images/quick_all_zikr.jpg',
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const CategoriesScreen()));
                                },
                              ),
                              _buildQuickCard(
                                label: isKurdish
                                    ? 'ڕووگەی قیبلە'
                                    : (lang == 'ar'
                                        ? 'اتجاه القبلة'
                                        : 'Qibla Compass'),
                                subtitle: isKurdish
                                    ? 'دۆزینەوەی قیبلە'
                                    : (lang == 'ar'
                                        ? 'تحديد دقيق'
                                        : 'Find Qibla'),
                                badgeText: isKurdish
                                    ? 'قیبلە'
                                    : (lang == 'ar' ? 'مباشر' : 'Live'),
                                icon: Icons.explore_rounded,
                                accentColor: const Color(0xFF0EA5E9),
                                isKurdish: isKurdish,
                                imagePath: 'assets/images/quick_qibla_compass.jpg',
                                onTap: () async {
                                  final schedule = await PrayerRepository
                                      .getPrayerScheduleForDate(
                                          date: DateTime.now());
                                  final lat = (schedule['latitude'] as num?)
                                          ?.toDouble() ??
                                      36.1911;
                                  final lng = (schedule['longitude'] as num?)
                                          ?.toDouble() ??
                                      44.0092;
                                  final locName = isKurdish
                                      ? (schedule['locationNameKu']?.toString() ??
                                          schedule['locationName']?.toString() ??
                                          'کوردستان')
                                      : (lang == 'ar'
                                          ? (schedule['locationNameAr']?.toString() ??
                                              schedule['locationName']?.toString() ??
                                              'كردستان')
                                          : (schedule['locationNameEn']?.toString() ??
                                              schedule['locationName']?.toString() ??
                                              'Kurdistan'));
                                  if (!context.mounted) return;
                                  QiblaCompassSheet.show(
                                    context,
                                    latitude: lat,
                                    longitude: lng,
                                    locationName: locName,
                                  );
                                },
                              ),
                              _buildQuickCard(
                                label: isKurdish
                                    ? 'ئامار و بەردەوامی'
                                    : (lang == 'ar'
                                        ? 'الإحصائيات والإنجاز'
                                        : 'Streaks & Stats'),
                                subtitle: isKurdish
                                    ? 'پێشکەوتنی تۆ'
                                    : (lang == 'ar'
                                        ? 'متابعة يومية'
                                        : 'Your progress'),
                                badgeText: isKurdish
                                    ? 'ئامار'
                                    : (lang == 'ar' ? 'تقدم' : 'Stats'),
                                icon: Icons.local_fire_department_rounded,
                                accentColor: AppColors.fireOrange,
                                isKurdish: isKurdish,
                                imagePath: 'assets/images/quick_streak_stats.jpg',
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const StatisticsScreen()));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  String? _getCategoryThumbnail(String catId) {
    switch (catId) {
      case 'morning':
        return 'assets/images/cat_morning.jpg';
      case 'wakeup':
        return 'assets/images/cat_wakeup.jpg';
      case 'evening':
        return 'assets/images/cat_evening.jpg';
      case 'sleep':
        return 'assets/images/cat_sleep.jpg';
      case 'prayer':
      case 'after_prayer':
        return 'assets/images/cat_prayer.jpg';
      case 'ayat_kursi':
        return 'assets/images/cat_ayat_kursi.jpg';
      case 'quran':
      case 'surah_mulk':
      case 'surah_kahf':
        return 'assets/images/cat_quran.jpg';
      case 'hadith':
        return 'assets/images/cat_hadith.jpg';
      case 'general':
      default:
        return 'assets/images/cat_general.jpg';
    }
  }

  Widget _buildCategoryCardThumbnail(String thumb, String catId) {
    // Before Sleep is the reference framing (single full cover)
    if (catId == 'sleep') {
      return Image.asset(
        thumb,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => const SizedBox(),
      );
    }

    // Tuning per category so every card matches Before Sleep's 88px artwork scale
    double scale = 0.95;
    Alignment alignment = Alignment.center;

    switch (catId) {
      case 'morning':
        scale = 0.95;
        alignment = const Alignment(0, -0.08);
        break;
      case 'evening':
      case 'wakeup':
        scale = 0.98;
        alignment = const Alignment(0, -0.15);
        break;
      case 'prayer':
      case 'after_prayer':
        scale = 0.94;
        alignment = const Alignment(0, -0.06);
        break;
      case 'ayat_kursi':
        scale = 0.96;
        alignment = const Alignment(0, -0.05);
        break;
      case 'quran':
      case 'surah_mulk':
      case 'surah_kahf':
        scale = 0.95;
        alignment = const Alignment(0, -0.10);
        break;
      case 'hadith':
        scale = 0.78;
        alignment = const Alignment(0, -0.04);
        break;
      case 'general':
      default:
        scale = 0.95;
        alignment = const Alignment(0, -0.10);
        break;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Ambient background fill matching the artwork's native tone
        Image.asset(
          thumb,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox(),
        ),
        // 2. Soft darkening overlay so background detail fades into smooth atmosphere
        Container(
          color: const Color(0xFF070D18).withValues(alpha: 0.75),
        ),
        // 3. Crisp foreground artwork matching Before Sleep reference scale
        Transform.scale(
          scale: scale,
          alignment: alignment,
          child: Image.asset(
            thumb,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalZikrsSection(bool isKurdish, String lang) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isKurdish
                              ? 'زیکر و دوعاکان'
                              : (lang == 'ar' ? 'الأذكار والأدعية' : 'ZIKR & DUAS'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: isKurdish
                              ? AppTheme.kurdishTitle(
                                  fontSize: 15, color: AppColors.gold)
                              : AppTheme.labelText(color: AppColors.cream),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isKurdish
                            ? 'هەموو بەشەکان'
                            : (lang == 'ar' ? 'جميع الأقسام' : 'View All'),
                        style: isKurdish
                            ? AppTheme.kurdishText(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)
                            : AppTheme.englishText(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isKurdish
                            ? Icons.arrow_back_ios_new_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 118,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: AppData.azkarCategories.length,
              itemBuilder: (context, index) {
                final cat = AppData.azkarCategories[index];
                final catColor =
                    Color(int.parse(cat.color.replaceFirst('#', '0xFF')));
                final title = isKurdish
                    ? cat.kurdish
                    : (lang == 'en' ? cat.english : cat.label);
                final thumb = _getCategoryThumbnail(cat.id);

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () async {
                      if (cat.id == 'surah_mulk') {
                        final surahs = await QuranService.instance.loadSurahs();
                        final surah = surahs.firstWhere((s) => s.number == 67);
                        if (!context.mounted) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    SurahReadingScreen(surah: surah)));
                        return;
                      }
                      if (cat.id == 'surah_kahf') {
                        final surahs = await QuranService.instance.loadSurahs();
                        final surah = surahs.firstWhere((s) => s.number == 18);
                        if (!context.mounted) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    SurahReadingScreen(surah: surah)));
                        return;
                      }
                      if (cat.id == 'hadith') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HadithScreen()));
                        return;
                      }
                      if (cat.id == 'quran') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const QuranDuasScreen()));
                        return;
                      }
                      if (cat.id == 'general') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GeneralDuasScreen()));
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReadingScreen(category: cat),
                        ),
                      );
                    },
                    child: Container(
                      width: 145,
                      decoration: BoxDecoration(
                        color: AppColors.panelColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: catColor.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: catColor.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (thumb != null)
                            _buildCategoryCardThumbnail(thumb, cat.id),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.black.withValues(alpha: 0.55),
                                  const Color(0xFF070D18).withValues(alpha: 0.94),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -15,
                            right: isKurdish ? -15 : null,
                            left: isKurdish ? null : -15,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: catColor.withValues(alpha: 0.22),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(11),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                          color: catColor.withValues(alpha: 0.45),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(cat.iconData,
                                            size: 15, color: catColor),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: catColor.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Text(
                                        '${cat.count}',
                                        style: isKurdish
                                            ? AppTheme.kurdishText(
                                                color: AppColors.cream,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                              )
                                            : AppTheme.englishText(
                                                color: AppColors.cream,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: isKurdish
                                      ? AppTheme.kurdishTitle(
                                          fontSize: 12.5,
                                          color: AppColors.cream)
                                      : AppTheme.englishTitle(
                                          fontSize: 12.5,
                                          color: AppColors.cream),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMoodCard() async {
    final moodId = _selectedMood ?? 'grateful';
    final suggestion = await QuranMoodService.instance.withKurdishTafsir(
      QuranMoodService.instance.suggestForMood(moodId),
    );
    if (!mounted) return;
    final locale = AppLocalizations.of(context)?.locale.languageCode ?? 'ku';
    final tone = QuranMoodService.instance.themeFor(moodId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _MoodCardSheetContent(
          suggestion: suggestion,
          moodId: moodId,
          locale: locale,
          tone: tone,
          onOpenAyah: _openQuranAyah,
        );
      },
    );
  }
}

class _MoodCardSheetContent extends StatefulWidget {
  final QuranMoodSuggestion suggestion;
  final String moodId;
  final String locale;
  final dynamic tone;
  final void Function(int surah, int ayah) onOpenAyah;

  const _MoodCardSheetContent({
    required this.suggestion,
    required this.moodId,
    required this.locale,
    required this.tone,
    required this.onOpenAyah,
  });

  @override
  State<_MoodCardSheetContent> createState() => _MoodCardSheetContentState();
}

class _MoodCardSheetContentState extends State<_MoodCardSheetContent> {
  bool _isSaved = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    final saved = await StorageService.isFavoriteMoodCard(widget.suggestion);
    if (mounted) {
      setState(() {
        _isSaved = saved;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    final nowSaved =
        await StorageService.toggleFavoriteMoodCard(widget.suggestion);
    if (!mounted) return;
    setState(() => _isSaved = nowSaved);

    final isK = widget.locale == 'ku';
    final isAr = widget.locale == 'ar';

    final message = nowSaved
        ? (isK
            ? 'کارتەکە پاشەکەوت کرا بۆ دڵخوازەکان'
            : isAr
                ? 'تم حفظ البطاقة في المحفوظات'
                : 'Card saved to favorites!')
        : (isK
            ? 'کارتەکە لاپرا لە دڵخوازەکان'
            : isAr
                ? 'تمت إزالة البطاقة من المحفوظات'
                : 'Card removed from saved cards');

    final undoLabel = isK
        ? 'گەڕاندنەوە'
        : isAr
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
            Icon(
              nowSaved
                  ? Icons.bookmark_added_rounded
                  : Icons.bookmark_remove_rounded,
              color: AppColors.gold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: isK
                    ? AppTheme.kurdishText(color: AppColors.cream, fontSize: 13)
                    : AppTheme.englishText(
                        color: AppColors.cream, fontSize: 13),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: undoLabel,
          textColor: AppColors.gold,
          onPressed: () async {
            final undoneSaved =
                await StorageService.toggleFavoriteMoodCard(widget.suggestion);
            if (mounted) {
              setState(() => _isSaved = undoneSaved);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tone = widget.tone;
    final locale = widget.locale;
    final isKurdish = locale == 'ku';
    final shareLabel =
        AppLocalizations.of(context)?.translate('share') ?? 'هاوبەشکردن';

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                    tone.primary.withValues(alpha: 0.22), AppColors.darkPanel),
                Color.alphaBlend(tone.secondary.withValues(alpha: 0.18),
                    AppColors.darkBgAlt),
                AppColors.darkBg,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: tone.primary.withValues(alpha: 0.34)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.42),
                blurRadius: 28,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tone.primary.withValues(alpha: 0.24),
                      tone.secondary.withValues(alpha: 0.20),
                      AppColors.panelColor,
                    ],
                  ),
                  border:
                      Border.all(color: tone.primary.withValues(alpha: 0.38)),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: tone.primary.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: tone.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: tone.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tone.iconData,
                              size: 14, color: tone.primary),
                          const SizedBox(width: 6),
                          Text(
                            QuranMoodService.instance
                                .moodLabel(widget.moodId, locale),
                            style: isKurdish
                                ? AppTheme.kurdishText(
                                    fontSize: 11,
                                    color: tone.primary,
                                    fontWeight: FontWeight.w700)
                                : AppTheme.englishText(
                                    fontSize: 11,
                                    color: tone.primary,
                                    fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      QuranMoodService.instance.titleFor(widget.moodId, locale),
                      style: isKurdish
                          ? AppTheme.kurdishTitle(
                              fontSize: 24, color: AppColors.cream)
                          : AppTheme.englishTitle(
                              fontSize: 24, color: AppColors.cream),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      QuranMoodService.instance
                          .messageFor(widget.moodId, locale),
                      style: isKurdish
                          ? AppTheme.kurdishText(
                              color: AppColors.faintText, fontSize: 13)
                          : AppTheme.englishText(
                              color: AppColors.faintText, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          tooltip: _isSaved
                              ? (isKurdish
                                  ? 'لە هەڵگیراوەکان بیسڕەوە'
                                  : 'Unsave card')
                              : (isKurdish
                                  ? 'کارتەکە پاشەکەوت بکە'
                                  : 'Save card'),
                          onPressed: _isLoading ? null : _toggleSave,
                          icon: Icon(
                            _isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_add_rounded,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              AppShareService.share(
                                context,
                                widget.suggestion.shareTextFor(locale),
                              );
                            },
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: Text(shareLabel),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ...widget.suggestion.verses.map((verse) => _MoodVerseCard(
                    verse: verse,
                    moodId: widget.moodId,
                    title: widget.suggestion.title,
                    shortMessage: widget.suggestion.shortMessage,
                    locale: locale,
                    tone: tone,
                    onOpenAyah: widget.onOpenAyah,
                  )),
            ],
          ),
        ),
      );
      },
    );
  }
}

class _MoodVerseCard extends StatefulWidget {
  final QuranMoodVerse verse;
  final String moodId;
  final String title;
  final String shortMessage;
  final String locale;
  final QuranMoodPalette tone;
  final void Function(int surah, int ayah) onOpenAyah;

  const _MoodVerseCard({
    required this.verse,
    required this.moodId,
    required this.title,
    required this.shortMessage,
    required this.locale,
    required this.tone,
    required this.onOpenAyah,
  });

  @override
  State<_MoodVerseCard> createState() => _MoodVerseCardState();
}

class _MoodVerseCardState extends State<_MoodVerseCard> {
  bool _isSaved = false;
  bool _isLoading = true;

  String get _cardId =>
      'ayah_${widget.moodId}_${widget.verse.surah}_${widget.verse.ayah}';

  Map<String, dynamic> get _cardData => {
        'id': _cardId,
        'cardType': 'ayah',
        'moodId': widget.moodId,
        'title': widget.title,
        'shortMessage': widget.shortMessage,
        'verses': [
          {
            'surah': widget.verse.surah,
            'ayah': widget.verse.ayah,
            'arabicText': widget.verse.arabicText,
            'englishMeaning': widget.verse.englishMeaning,
            'kurdishMeaning': widget.verse.kurdishMeaning,
            'reflection': widget.verse.reflection,
          },
        ],
      };

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final saved = await StorageService.isGenericCardSaved(_cardData);
    if (!mounted) return;
    setState(() {
      _isSaved = saved;
      _isLoading = false;
    });
  }

  Future<void> _toggleSaved() async {
    final saved = await StorageService.toggleGenericCard(_cardData);
    if (!mounted) return;
    setState(() => _isSaved = saved);
  }

  @override
  Widget build(BuildContext context) {
    final isKurdish = widget.locale == 'ku';
    final isRtl = isKurdish || widget.locale == 'ar';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.tone.primary.withValues(alpha: 0.12),
            AppColors.panelColor,
            widget.tone.secondary.withValues(alpha: 0.14),
          ],
        ),
        border: Border.all(color: widget.tone.primary.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      widget.onOpenAyah(widget.verse.surah, widget.verse.ayah),
                  child: Text(
                    '${AppLocalizations.of(context)?.translate('surah') ?? 'سورەت'} ${widget.verse.surah}:${widget.verse.ayah}',
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                    style: (isRtl
                            ? AppTheme.kurdishText(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)
                            : AppTheme.englishText(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700))
                        .copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.gold),
                  ),
                ),
              ),
              IconButton(
                tooltip: _isSaved ? 'Unsave ayah' : 'Save ayah',
                onPressed: _isLoading ? null : _toggleSaved,
                icon: Icon(_isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_add_rounded),
                color: AppColors.gold,
              ),
            ],
          ),
          GestureDetector(
            onTap: () =>
                widget.onOpenAyah(widget.verse.surah, widget.verse.ayah),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.verse.arabicText,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.quranAyahText(
                      fontSize: 26, color: AppColors.cream),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.locale == 'ku'
                      ? (widget.verse.kurdishMeaning ??
                          widget.verse.englishMeaning)
                      : widget.verse.englishMeaning,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: isKurdish
                      ? AppTheme.kurdishText(
                          color: AppColors.cream, fontSize: 13)
                      : AppTheme.englishText(
                          color: AppColors.cream, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPathItem(String label, String arabic, bool done,
    VoidCallback onTap, bool isKurdish) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: done
            ? AppColors.gold.withValues(alpha: 0.07)
            : AppColors.panelColor,
        border: Border.all(
          color: done
              ? AppColors.gold.withValues(alpha: 0.18)
              : AppColors.panelBorderColor,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.gold.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: done
                ? Icon(Icons.check_circle, size: 16, color: AppColors.gold)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: isKurdish
                  ? AppTheme.kurdishText(
                      color: done ? AppColors.faintText : AppColors.cream,
                      fontSize: 13)
                  : AppTheme.englishText(
                      color: done ? AppColors.faintText : AppColors.cream,
                      fontSize: 13),
            ),
          ),
          if (!isKurdish && arabic.isNotEmpty)
            Text(
              arabic,
              style: AppTheme.arabicText(
                  color: done
                      ? AppColors.gold.withValues(alpha: 0.5)
                      : AppColors.gold,
                  fontSize: 14),
              textDirection: TextDirection.rtl,
            )
          else if (isKurdish)
            Text(
              done ? 'تەواوکرا ✓' : 'خوێندنەوە',
              style: AppTheme.kurdishText(
                  color: done
                      ? AppColors.gold.withValues(alpha: 0.5)
                      : AppColors.gold,
                  fontSize: 12),
            ),
        ],
      ),
    ),
  );
}

Widget _buildQuickCard({
  required String label,
  required String subtitle,
  required IconData icon,
  required Color accentColor,
  required bool isKurdish,
  required String imagePath,
  VoidCallback? onTap,
  String? badgeText,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background 3D luxury artwork
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
          // Multi-stop gradient scrim to ensure text and icon readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.6),
                  const Color(0xFF070D18).withValues(alpha: 0.94),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          // Accent bottom glow
          Positioned(
            bottom: -20,
            left: isKurdish ? null : -20,
            right: isKurdish ? -20 : null,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.25),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(icon, size: 19, color: accentColor),
                      ),
                    ),
                    if (badgeText != null)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.45),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              badgeText,
                              style: isKurdish
                                  ? AppTheme.kurdishText(
                                      color: AppColors.cream,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)
                                  : AppTheme.englishText(
                                      color: AppColors.cream,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isKurdish
                          ? AppTheme.kurdishTitle(
                              fontSize: 13.5, color: AppColors.cream)
                          : AppTheme.englishTitle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cream),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isKurdish
                          ? AppTheme.kurdishText(
                              color: AppColors.faintText, fontSize: 11)
                          : AppTheme.englishText(
                              color: AppColors.faintText, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
