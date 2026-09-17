import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_localizations.dart';
import '../models/quran_dua_model.dart';
import '../services/app_haptics.dart';
import '../services/quran_dua_service.dart';
import '../services/quran_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/dua_card_generator.dart';
import '../widgets/focused_reading_sheet.dart';
import '../widgets/spiritual_content_card.dart';
import '../widgets/spiritual_detail_sheet.dart';
import 'quran_screen.dart';

/// Premier Quranic Duas Explorer & Supplications Hub
class QuranDuasScreen extends StatefulWidget {
  final String? initialSurah;

  const QuranDuasScreen({super.key, this.initialSurah});

  @override
  State<QuranDuasScreen> createState() => _QuranDuasScreenState();
}

class _QuranDuasScreenState extends State<QuranDuasScreen> {
  late Future<List<QuranDuaItem>> _duasFuture;
  String _selectedSurah = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showFavoritesOnly = false;
  Set<int> _favoriteIds = {};
  final Map<int, int> _reciteCounters = {};
  bool? _showEnglishMode;

  @override
  void initState() {
    super.initState();
    if (widget.initialSurah != null) {
      _selectedSurah = widget.initialSurah!;
    }
    _duasFuture = QuranDuaService.loadAllDuas();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await QuranDuaService.getFavoriteIds();
    if (mounted) {
      setState(() {
        _favoriteIds = favs;
      });
    }
  }

  Future<void> _toggleFavorite(int id) async {
    AppHaptics.mediumImpact();
    await QuranDuaService.toggleFavorite(id);
    await _loadFavorites();
  }

  /// Open exact Ayah in Holy Quran reader with Tafsir
  Future<void> _openQuranAyah(int surahNumber, int ayahNumber) async {
    AppHaptics.lightImpact();
    try {
      final surahs = await QuranService.instance.loadSurahs();
      if (!mounted) return;
      final surah = surahs.firstWhere(
        (item) => item.number == surahNumber,
        orElse: () => surahs.first,
      );
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
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _copyDua(QuranDuaItem dua, bool isKurdish, bool isArabic) {
    AppHaptics.lightImpact();
    final surahLabel = isKurdish
        ? dua.surahNameKu
        : (isArabic ? dua.surahNameAr : dua.surah);

    final text = '💫 دوعای پیرۆزی قورئانی پیرۆز:\n\n'
        '«${dua.arabic}»\n\n'
        '📖 تەفسیری ئاسان (کوردی):\n${dua.kurdishMeaning}\n\n'
        '🌐 English Translation:\n${dua.englishMeaning}\n\n'
        'سەرچاوە: $surahLabel : ئایەتی ${dua.ayah}\n'
        'لە ئەپی نەدا (Nada) 🌟';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF34D399), size: 18),
            const SizedBox(width: 10),
            Text(
              isKurdish
                  ? 'دوعاکە کۆپیکرا بۆ کلیپبۆرد'
                  : (isArabic
                      ? 'تم نسخ الدعاء إلى الحافظة'
                      : 'Dua copied to clipboard'),
              style: (isKurdish || isArabic)
                  ? AppTheme.kurdishText(color: Colors.white, fontSize: 12)
                  : AppTheme.englishText(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppColors.panelColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? AppLocalizations.languageCode;
    final isKurdish = lang == 'ku';
    final isArabic = lang == 'ar';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: FutureBuilder<List<QuranDuaItem>>(
          future: _duasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              );
            }

            final allDuas = snapshot.data ?? [];
            final dailyDua = QuranDuaService.getDuaOfTheDay(allDuas);

            // Extract unique surahs with counts
            final surahsMap = <String, int>{};
            for (final d in allDuas) {
              surahsMap[d.surah] = (surahsMap[d.surah] ?? 0) + 1;
            }

            // Filter duas by surah, favorites, and search query
            final filteredDuas = allDuas.where((d) {
              if (_showFavoritesOnly && !_favoriteIds.contains(d.id)) {
                return false;
              }

              final matchesSurah =
                  _selectedSurah == 'all' || d.surah == _selectedSurah;
              final query = _searchQuery.trim().toLowerCase();
              if (query.isEmpty) return matchesSurah;

              final matchesSearch =
                  d.kurdishMeaning.toLowerCase().contains(query) ||
                      d.englishMeaning.toLowerCase().contains(query) ||
                      d.arabic.toLowerCase().contains(query) ||
                      d.surah.toLowerCase().contains(query) ||
                      d.surahNameKu.toLowerCase().contains(query) ||
                      d.surahNameAr.toLowerCase().contains(query) ||
                      d.ayah.toLowerCase().contains(query);

              return matchesSurah && matchesSearch;
            }).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top App Bar
                SliverToBoxAdapter(
                  child: _buildHeader(context, isKurdish, isArabic),
                ),

                // Search Bar (if activated)
                if (_isSearching)
                  SliverToBoxAdapter(
                    child: _buildSearchBar(isKurdish, isArabic),
                  ),

                // Surahs Horizontal Filter Chips
                SliverToBoxAdapter(
                  child: _buildSurahChips(
                      surahsMap, allDuas, allDuas.length, lang, isKurdish, isArabic),
                ),

                // Quranic Dua of the Day Hero Banner (Only when not searching & not filtered)
                if (!_isSearching &&
                    !_showFavoritesOnly &&
                    dailyDua != null &&
                    _selectedSurah == 'all')
                  SliverToBoxAdapter(
                    child: _buildDuaOfTheDayBanner(
                        context, dailyDua, isKurdish, isArabic),
                  ),

                // Section Title / Results counter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _showFavoritesOnly
                              ? (isKurdish
                                  ? 'دوعا هەڵبژێردراوەکانم'
                                  : (isArabic
                                      ? 'الأدعية المفضلة'
                                      : 'Saved Supplications'))
                              : (isKurdish
                                  ? '${filteredDuas.length} دوعای قورئانی'
                                  : (isArabic
                                      ? '${filteredDuas.length} دعاء قرآني'
                                      : '${filteredDuas.length} Quranic Duas')),
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedSurah != 'all')
                          GestureDetector(
                            onTap: () => setState(() => _selectedSurah = 'all'),
                            child: Text(
                              isKurdish
                                  ? 'پاککردنەوەی فلتەر'
                                  : (isArabic ? 'إلغاء التصفية' : 'Clear filter'),
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.gold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Duas List
                if (filteredDuas.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(isKurdish),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dua = filteredDuas[index];
                          final isFav = _favoriteIds.contains(dua.id);
                          final reciteCount =
                              _reciteCounters[dua.id] ?? 0;

                          final surahLabel = isKurdish
                              ? dua.surahNameKu
                              : (isArabic ? dua.surahNameAr : dua.surah);

                          final hasKurdish =
                              dua.kurdishMeaning.trim().isNotEmpty;
                          final hasEnglish =
                              dua.englishMeaning.trim().isNotEmpty;
                          final bool preferEnglish =
                              _showEnglishMode ?? (lang == 'en');
                          final bool isDisplayingEnglish =
                              (preferEnglish && hasEnglish) || !hasKurdish;

                          return SpiritualContentCard(
                            arabic: dua.arabic,
                            isAyah: true,
                            kurdishMeaning: dua.kurdishMeaning,
                            englishMeaning: dua.englishMeaning,
                            source: '📖 $surahLabel : ${dua.ayah}',
                            categoryTag: '$surahLabel : ${dua.ayah}',
                            categoryTagIcon: Icons.auto_stories_rounded,
                            onCategoryTap: () => _openQuranAyah(
                                dua.surahNumber, dua.ayahNumber),
                            onOpenInQuran: () => _openQuranAyah(
                                dua.surahNumber, dua.ayahNumber),
                            isFavorite: isFav,
                            onToggleFavorite: () =>
                                _toggleFavorite(dua.id),
                            reciteCount: reciteCount,
                            onReciteChanged: (newCount) {
                              setState(() {
                                _reciteCounters[dua.id] = newCount;
                              });
                            },
                            onRecite: () {
                              AppHaptics.lightImpact();
                              setState(() {
                                _reciteCounters[dua.id] = reciteCount + 1;
                              });
                            },
                            onShareCard: () {
                              AppHaptics.lightImpact();
                              showDialog(
                                context: context,
                                builder: (ctx) => DuaCardGeneratorDialog(
                                    azkar: dua.toAzkar()),
                              );
                            },
                            onCopy: () => _copyDua(dua, isKurdish, isArabic),
                            onFocusRead: () async {
                              final newCount = await FocusedReadingSheet.show(
                                context,
                                arabic: dua.arabic,
                                kurdishMeaning: dua.kurdishMeaning,
                                englishMeaning: dua.englishMeaning,
                                source: '📖 $surahLabel : ${dua.ayah}',
                                title: surahLabel,
                                initialCount: reciteCount,
                                lang: lang,
                                isAyah: true,
                              );
                              if (newCount != null && mounted) {
                                setState(() {
                                  _reciteCounters[dua.id] = newCount;
                                });
                              }
                            },
                            lang: lang,
                            meaningBadgeKurdishLabel: '📖 تەفسیری ئاسان (کوردی)',
                            isDisplayingEnglish: isDisplayingEnglish,
                            onToggleLanguage: () {
                              AppHaptics.selectionClick();
                              setState(() {
                                _showEnglishMode = !isDisplayingEnglish;
                              });
                            },
                          );
                        },
                        childCount: filteredDuas.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, bool isKurdish, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.panelColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.panelBorderColor.withValues(alpha: 0.6),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.cream,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKurdish
                      ? 'دوعاکانی قورئانی پیرۆز'
                      : (isArabic
                          ? 'أدعية القرآن الكريم'
                          : 'Quranic Supplications'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isKurdish
                      ? AppTheme.kurdishTitle(
                          fontSize: 17, color: AppColors.cream)
                      : AppTheme.englishTitle(
                          fontSize: 17, color: AppColors.cream),
                ),
                Text(
                  isKurdish
                      ? '70 دوعای پیرۆز بە تەفسیری ئاسان'
                      : (isArabic
                          ? '70 دعاء مبارك من آيات الذكر الحكيم'
                          : '70 authentic supplications from the Holy Quran'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isKurdish
                      ? AppTheme.kurdishText(
                          fontSize: 11, color: AppColors.mutedText)
                      : AppTheme.englishText(
                          fontSize: 11, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          // Search Button
          GestureDetector(
            onTap: () {
              AppHaptics.lightImpact();
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _isSearching
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : AppColors.panelColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isSearching
                      ? AppColors.gold
                      : AppColors.panelBorderColor.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                size: 18,
                color: _isSearching ? AppColors.gold : AppColors.cream,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Favorites Filter Toggle
          GestureDetector(
            onTap: () {
              AppHaptics.selectionClick();
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _showFavoritesOnly
                    ? const Color(0xFFE11D48).withValues(alpha: 0.15)
                    : AppColors.panelColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _showFavoritesOnly
                      ? const Color(0xFFE11D48)
                      : AppColors.panelBorderColor.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                _showFavoritesOnly
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 18,
                color: _showFavoritesOnly
                    ? const Color(0xFFF43F5E)
                    : AppColors.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSearchBar(bool isKurdish, bool isArabic) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(color: AppColors.cream, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: isKurdish
              ? 'گەڕان لە دوعاکان، سوورەت یان ئایەت...'
              : (isArabic
                  ? 'ابحث في نصوص الأدعية أو السور...'
                  : 'Search supplications, surahs, or ayahs...'),
          hintStyle: TextStyle(color: AppColors.faintText, fontSize: 12.5),
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: AppColors.gold, size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded,
                      color: AppColors.cream, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SURAHS FILTER CHIPS
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSurahChips(Map<String, int> surahsMap, List<QuranDuaItem> allDuas,
      int totalCount, String lang, bool isKurdish, bool isArabic) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildFilterChip(
            label: isKurdish
                ? 'هەمووی ($totalCount)'
                : (isArabic ? 'الكل ($totalCount)' : 'All ($totalCount)'),
            isSelected: _selectedSurah == 'all',
            onTap: () {
              AppHaptics.selectionClick();
              setState(() => _selectedSurah = 'all');
            },
            isKurdish: isKurdish,
          ),
          ...surahsMap.entries.map((entry) {
            final isSelected = _selectedSurah == entry.key;
            final sampleDua = allDuas.firstWhere(
              (d) => d.surah == entry.key,
              orElse: () => allDuas.first,
            );
            final localizedSurahName = sampleDua.getSurahName(lang);
            return _buildFilterChip(
              label: '$localizedSurahName (${entry.value})',
              isSelected: isSelected,
              onTap: () {
                AppHaptics.selectionClick();
                setState(() => _selectedSurah = entry.key);
              },
              isKurdish: isKurdish,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isKurdish,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.panelColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : AppColors.panelBorderColor.withValues(alpha: 0.5),
            width: 0.8,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.darkBg : AppColors.cream,
              fontSize: 11.5,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // QURANIC DUA OF THE DAY (CALM SPOTLIGHT)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDuaOfTheDayBanner(BuildContext context, QuranDuaItem dua,
      bool isKurdish, bool isArabic) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? AppLocalizations.languageCode;
    final surahLabel = isKurdish
        ? dua.surahNameKu
        : (isArabic ? dua.surahNameAr : dua.surah);
    final isFav = _favoriteIds.contains(dua.id);
    final reciteCount = _reciteCounters[dua.id] ?? 0;

    return GestureDetector(
      onTap: () {
        AppHaptics.lightImpact();
        SpiritualDetailSheet.show(
          context,
          arabic: dua.arabic,
          kurdishMeaning: dua.kurdishMeaning,
          englishMeaning: dua.englishMeaning,
          source: '📖 $surahLabel : ${dua.ayah}',
          categoryTag: '$surahLabel : ${dua.ayah}',
          isFavorite: isFav,
          onToggleFavorite: () => _toggleFavorite(dua.id),
          reciteCount: reciteCount,
          onReciteChanged: (newCount) {
            setState(() {
              _reciteCounters[dua.id] = newCount;
            });
          },
          onShareCard: () {
            AppHaptics.lightImpact();
            showDialog(
              context: context,
              builder: (ctx) => DuaCardGeneratorDialog(azkar: dua.toAzkar()),
            );
          },
          onCopy: () => _copyDua(dua, isKurdish, isArabic),
          onOpenInQuran: () => _openQuranAyah(dua.surahNumber, dua.ayahNumber),
          onFocusRead: () async {
            final newCount = await FocusedReadingSheet.show(
              context,
              arabic: dua.arabic,
              kurdishMeaning: dua.kurdishMeaning,
              englishMeaning: dua.englishMeaning,
              source: '📖 $surahLabel : ${dua.ayah}',
              title: surahLabel,
              initialCount: reciteCount,
              lang: lang,
              isAyah: true,
            );
            if (newCount != null && mounted) {
              setState(() {
                _reciteCounters[dua.id] = newCount;
              });
            }
          },
          lang: lang,
          isAyah: true,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.panelColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFav
                ? AppColors.gold.withValues(alpha: 0.5)
                : AppColors.gold.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: AppColors.gold, size: 15),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isKurdish
                              ? 'دوعای قورئانیی ئەمڕۆ'
                              : (isArabic
                                  ? 'دعاء اليوم من القرآن'
                                  : 'Daily Quranic Dua'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _openQuranAyah(dua.surahNumber, dua.ayahNumber),
                      child: Text(
                        '$surahLabel : ${dua.ayah}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Recite count badge
                    if (reciteCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
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
                      const SizedBox(width: 6),
                    ],
                    GestureDetector(
                      onTap: () => _toggleFavorite(dua.id),
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        isFav
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 18,
                        color: isFav
                            ? const Color(0xFFF43F5E)
                            : AppColors.veryFaintText.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              dua.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: AppTheme.quranAyahText(
                color: const Color(0xFFFFFBEB),
                fontSize: 19,
                height: 1.9,
              ),
            ),
            if (dua.kurdishMeaning.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                lang == 'en' && dua.englishMeaning.isNotEmpty
                    ? dua.englishMeaning
                    : dua.kurdishMeaning,
                textDirection:
                    lang == 'en' ? TextDirection.ltr : TextDirection.rtl,
                textAlign: lang == 'en' ? TextAlign.left : TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.8),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _openQuranAyah(dua.surahNumber, dua.ayahNumber),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories_outlined,
                          size: 13, color: AppColors.mutedText),
                      const SizedBox(width: 4),
                      Text(
                        isKurdish
                            ? 'لە قورئاندا بیبینە'
                            : (isArabic ? 'عرض في القرآن' : 'View in Quran'),
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isKurdish
                          ? 'دەست لێبدە بۆ زیاتر'
                          : (isArabic ? 'اضغط للمزيد' : 'Tap for more'),
                      style: TextStyle(
                        color: AppColors.gold.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      isKurdish
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      size: 14,
                      color: AppColors.gold.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState(bool isKurdish) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _showFavoritesOnly
                ? Icons.favorite_border_rounded
                : Icons.search_off_rounded,
            size: 48,
            color: AppColors.faintText,
          ),
          const SizedBox(height: 14),
          Text(
            _showFavoritesOnly
                ? (isKurdish
                    ? 'هیچ دوعایەکت لە دڵخوازەکان دیاری نەکردووە'
                    : 'No saved supplications yet')
                : (isKurdish
                    ? 'هیچ دوعایەک بەم ناوەوە نەدۆزرایەوە'
                    : 'No supplications found'),
            textAlign: TextAlign.center,
            style: isKurdish
                ? AppTheme.kurdishText(
                    color: AppColors.mutedText, fontSize: 13.5)
                : AppTheme.englishText(
                    color: AppColors.mutedText, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
