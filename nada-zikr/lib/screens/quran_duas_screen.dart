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
import 'quran_screen.dart';

/// Premier Quranic Duas Explorer & Supplications Hub
class QuranDuasScreen extends StatefulWidget {
  final String? initialSurah;

  const QuranDuasScreen({Key? key, this.initialSurah}) : super(key: key);

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
  final Set<int> _expandedEnglishIds = {};
  bool _heroEnglishExpanded = false;

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

  /// Open exact Ayah in Holy Quran reader with Tafsiri Asan
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

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.languageCode;
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

              final matchesSearch = d.kurdishMeaning.toLowerCase().contains(query) ||
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Navigation Row
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.panelColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.panelBorderColor),
                                ),
                                child: Center(
                                  child: Icon(Icons.arrow_back_ios_new_rounded,
                                      color: AppColors.cream, size: 18),
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
                                      Flexible(
                                        child: Text(
                                          isKurdish
                                              ? 'دوعاکانی قورئانی پیرۆز'
                                              : (isArabic
                                                  ? 'أدعية القرآن الكريم'
                                                  : 'Quranic Supplications'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: isKurdish
                                              ? AppTheme.kurdishTitle(
                                                  fontSize: 18,
                                                  color: AppColors.cream)
                                              : AppTheme.englishTitle(
                                                  fontSize: 18,
                                                  color: AppColors.cream),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981)
                                              .withValues(alpha: 0.18),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFF10B981)
                                                .withValues(alpha: 0.4),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                           isKurdish ? '70 دوعا' : '70 Duas',
                                          style: const TextStyle(
                                            color: Color(0xFF34D399),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isKurdish
                                        ? 'دوعا پیرۆزەکان بە دەقی عوسمانی و تەفسیری ئاسان'
                                        : (isArabic
                                            ? '70 دعاء مبارك من آيات الذكر الحكيم'
                                            : '70 authentic supplications from the Holy Quran'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: isKurdish
                                        ? AppTheme.kurdishText(
                                            fontSize: 11,
                                            color: AppColors.mutedText)
                                        : AppTheme.englishText(
                                            fontSize: 11,
                                            color: AppColors.mutedText),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Favorites Filter Toggle
                            GestureDetector(
                              onTap: () {
                                AppHaptics.lightImpact();
                                setState(() {
                                  _showFavoritesOnly = !_showFavoritesOnly;
                                });
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _showFavoritesOnly
                                      ? const Color(0xFFEF4444)
                                          .withValues(alpha: 0.2)
                                      : AppColors.panelColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _showFavoritesOnly
                                        ? const Color(0xFFEF4444)
                                        : AppColors.panelBorderColor,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    _showFavoritesOnly
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: _showFavoritesOnly
                                        ? const Color(0xFFF87171)
                                        : AppColors.mutedText,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Search Bar
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.panelColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isSearching
                                  ? const Color(0xFF10B981)
                                  : AppColors.panelBorderColor,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            onTap: () => setState(() => _isSearching = true),
                            style: AppTheme.kurdishText(
                                color: AppColors.cream, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: isKurdish
                                  ? 'گەڕان لە دەقی دوعاکان، مانا یان سوورەت...'
                                  : (isArabic
                                      ? 'بحث في نصوص الأدعية، المعنى أو السور...'
                                      : 'Search supplications, meaning or Surah...'),
                              hintStyle: isKurdish
                                  ? AppTheme.kurdishText(
                                      color: AppColors.faintText, fontSize: 12)
                                  : AppTheme.englishText(
                                      color: AppColors.faintText, fontSize: 12),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: _searchQuery.isNotEmpty
                                      ? const Color(0xFF10B981)
                                      : AppColors.mutedText,
                                  size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                      child: Icon(Icons.close_rounded,
                                          color: AppColors.mutedText, size: 18),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Featured "Dua of the Day" Banner (if not searching)
                if (_searchQuery.isEmpty &&
                    _selectedSurah == 'all' &&
                    !_showFavoritesOnly &&
                    dailyDua != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      child: _buildDuaOfTheDayBanner(
                          context, dailyDua, isKurdish, isArabic),
                    ),
                  ),

                // Surah Filter Chip Strip
                SliverToBoxAdapter(
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 14),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: surahsMap.keys.length + 1,
                      itemBuilder: (context, idx) {
                        if (idx == 0) {
                          final isSelected = _selectedSurah == 'all';
                          return GestureDetector(
                            onTap: () {
                              AppHaptics.lightImpact();
                              setState(() => _selectedSurah = 'all');
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF10B981)
                                    : AppColors.panelColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF10B981)
                                      : AppColors.panelBorderColor,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  isKurdish
                                      ? 'هەمووی (${allDuas.length})'
                                      : (isArabic
                                          ? 'الكل (${allDuas.length})'
                                          : 'All (${allDuas.length})'),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.cream,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final surahName = surahsMap.keys.elementAt(idx - 1);
                        final count = surahsMap[surahName] ?? 0;
                        final isSelected = _selectedSurah == surahName;

                        // Display formatted Kurdish or standard name
                        final sampleDua = allDuas.firstWhere(
                          (d) => d.surah == surahName,
                          orElse: () => QuranDuaItem(
                            id: 0,
                            surah: surahName,
                            ayah: '',
                            arabic: '',
                            easyTajweed: '',
                            kurdishMeaning: '',
                          ),
                        );
                        final displayName = isKurdish
                            ? sampleDua.surahNameKu
                            : (isArabic ? sampleDua.surahNameAr : surahName);

                        return GestureDetector(
                          onTap: () {
                            AppHaptics.lightImpact();
                            setState(() => _selectedSurah = surahName);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF10B981)
                                  : AppColors.panelColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF10B981)
                                    : AppColors.panelBorderColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$displayName ($count)',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.cream,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Dua Count Header Info
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isKurdish
                              ? 'ئەنجامەکان (${filteredDuas.length} دوعا)'
                              : (isArabic
                                  ? 'الأدعية (${filteredDuas.length})'
                                  : 'Results (${filteredDuas.length})'),
                          style: AppTheme.kurdishText(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                        if (_showFavoritesOnly)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isKurdish ? 'دڵخوازەکان' : 'Favorites',
                              style: const TextStyle(
                                  color: Color(0xFFF87171), fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Duas List
                if (filteredDuas.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book_rounded,
                                color: AppColors.faintText, size: 56),
                            const SizedBox(height: 14),
                            Text(
                              isKurdish
                                  ? 'هیچ دوعایەک نەدۆزرایەوە'
                                  : 'No supplications found',
                              style: AppTheme.kurdishText(
                                  color: AppColors.cream, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dua = filteredDuas[index];
                          final isFav = _favoriteIds.contains(dua.id);
                          final reciteCount = _reciteCounters[dua.id] ?? 0;

                          return _buildDuaCard(
                            context: context,
                            dua: dua,
                            isKurdish: isKurdish,
                            isArabic: isArabic,
                            isFav: isFav,
                            reciteCount: reciteCount,
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

  /// Dua Card Widget
  Widget _buildDuaCard({
    required BuildContext context,
    required QuranDuaItem dua,
    required bool isKurdish,
    required bool isArabic,
    required bool isFav,
    required int reciteCount,
  }) {
    final surahLabel = isKurdish
        ? dua.surahNameKu
        : (isArabic ? dua.surahNameAr : dua.surah);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: reciteCount > 0
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : AppColors.panelBorderColor,
          width: reciteCount > 0 ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar with Surah tag (tappable to jump to Quran), ID badge and Favorite Heart
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                // Tappable Surah & Ayah Badge (Opens exact Ayah in Quran reader)
                Flexible(
                  child: GestureDetector(
                    onTap: () => _openQuranAyah(dua.surahNumber, dua.ayahNumber),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_stories_rounded,
                              color: Color(0xFF34D399), size: 13),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '$surahLabel : ${dua.ayah}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isKurdish
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
                            color: const Color(0xFF34D399).withValues(alpha: 0.7),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Dua Number Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.panelBorderColor),
                  ),
                  child: Text(
                    '#${dua.id}',
                    style: TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Favorite Button
                GestureDetector(
                  onTap: () => _toggleFavorite(dua.id),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isFav
                          ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                          : AppColors.darkBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFav
                            ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                            : AppColors.panelBorderColor,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav
                            ? const Color(0xFFF87171)
                            : AppColors.mutedText,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Central Arabic Dua Calligraphy Card (Tapping text also jumps to Quran)
          GestureDetector(
            onTap: () => _openQuranAyah(dua.surahNumber, dua.ayahNumber),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0F261F).withValues(alpha: 0.7),
                    const Color(0xFF131C24),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    dua.arabic,
                    textAlign: TextAlign.center,
                    style: AppTheme.arabicTitle(
                      color: const Color(0xFFF3E8C8),
                      fontSize: 21,
                      height: 1.85,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.open_in_new_rounded,
                          color: const Color(0xFF34D399).withValues(alpha: 0.7),
                          size: 11),
                      const SizedBox(width: 4),
                      Text(
                        isKurdish
                            ? 'لە قورئاندا بیبینە'
                            : (isArabic
                                ? 'عرض الآية في المصحف'
                                : 'View in Quran'),
                        style: TextStyle(
                          color: const Color(0xFF34D399).withValues(alpha: 0.75),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (reciteCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isKurdish
                            ? 'خوێندراوەتەوە: $reciteCount جار'
                            : 'Recited: $reciteCount times',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Dual Meaning Section: Kurdish Tafsiri Asan (first) + Expandable English
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kurdish Section Header & Text
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        '📖 تەفسیری ئاسان (کوردی)',
                        style: AppTheme.kurdishText(
                          fontSize: 10,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  dua.kurdishMeaning,
                  textAlign: TextAlign.right,
                  style: AppTheme.kurdishText(
                    color: AppColors.cream.withValues(alpha: 0.95),
                    fontSize: 14,
                    height: 1.65,
                  ),
                ),

                // English Translation Toggle
                if (dua.englishMeaning.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      AppHaptics.selectionClick();
                      setState(() {
                        if (_expandedEnglishIds.contains(dua.id)) {
                          _expandedEnglishIds.remove(dua.id);
                        } else {
                          _expandedEnglishIds.add(dua.id);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _expandedEnglishIds.contains(dua.id)
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                            : AppColors.darkBg.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _expandedEnglishIds.contains(dua.id)
                              ? const Color(0xFF60A5FA).withValues(alpha: 0.4)
                              : AppColors.panelBorderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _expandedEnglishIds.contains(dua.id)
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 16,
                            color: const Color(0xFF93C5FD),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _expandedEnglishIds.contains(dua.id)
                                ? (isKurdish ? 'شاردنەوەی مانای ئینگلیزی' : 'Hide English Meaning')
                                : (isKurdish ? 'پیشاندانی مانای ئینگلیزی (English)' : 'Show English Translation'),
                            style: const TextStyle(
                              color: Color(0xFF93C5FD),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_expandedEnglishIds.contains(dua.id)) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '🌐 English Translation (Sahih Int.)',
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
                            dua.englishMeaning,
                            textAlign: TextAlign.left,
                            style: AppTheme.englishText(
                              color: AppColors.cream.withValues(alpha: 0.92),
                              fontSize: 13,
                            ).copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),

          // Action Toolbar (Recite, Copy, Share Card)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.darkBg.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              border: Border(
                top: BorderSide(
                    color: AppColors.panelBorderColor.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                // Quick Tap Counter Button
                GestureDetector(
                  onTap: () {
                    AppHaptics.lightImpact();
                    setState(() {
                      _reciteCounters[dua.id] = reciteCount + 1;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app_rounded,
                            color: Color(0xFF34D399), size: 14),
                        const SizedBox(width: 5),
                        Text(
                          isKurdish ? 'خوێندنەوە' : 'Recite',
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Copy Action
                _buildActionIconButton(
                  icon: Icons.copy_rounded,
                  label: isKurdish ? 'کۆپی' : 'Copy',
                  onTap: () {
                    AppHaptics.lightImpact();
                    final textToCopy = '${dua.arabic}\n\n'
                        '📖 تەفسیری ئاسان:\n${dua.kurdishMeaning}\n\n'
                        '🌐 English Translation:\n${dua.englishMeaning}\n\n'
                        '[ $surahLabel • ${dua.ayah} ]\n'
                        'لە ئەپی نەدا (Nada) 🌟';
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF34D399), size: 18),
                            const SizedBox(width: 10),
                            Text(
                              isKurdish
                                  ? 'دەق و تەفسیری دوعاکە کۆپی کرا'
                                  : 'Dua text & translation copied',
                              style: isKurdish
                                  ? AppTheme.kurdishText(
                                      color: Colors.white, fontSize: 12)
                                  : AppTheme.englishText(
                                      color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.panelColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                // Share Card Action (Generates Card & Share)
                _buildActionIconButton(
                  icon: Icons.share_rounded,
                  label: isKurdish ? 'کارت' : 'Card',
                  isPrimary: true,
                  onTap: () {
                    AppHaptics.lightImpact();
                    showDialog(
                      context: context,
                      builder: (ctx) => DuaCardGeneratorDialog(
                        azkar: dua.toAzkar(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Action icon button helper
  Widget _buildActionIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFF10B981).withValues(alpha: 0.22)
              : AppColors.panelColor,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFF10B981).withValues(alpha: 0.45)
                : AppColors.panelBorderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? const Color(0xFF34D399) : AppColors.cream,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? const Color(0xFF34D399) : AppColors.cream,
                fontSize: 11,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Featured Dua of the Day Hero Banner
  Widget _buildDuaOfTheDayBanner(BuildContext context, QuranDuaItem dua,
      bool isKurdish, bool isArabic) {
    final surahLabel = isKurdish
        ? dua.surahNameKu
        : (isArabic ? dua.surahNameAr : dua.surah);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F3B2C),
            Color(0xFF132A22),
            Color(0xFF131C24),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Top Tag
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: AppColors.gold, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      isKurdish
                          ? 'دوعای قورئانیی ڕۆژ'
                          : (isArabic
                              ? 'دعاء اليوم من القرآن'
                              : 'Quranic Dua of the Day'),
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Tappable Surah reference on banner
              GestureDetector(
                onTap: () => _openQuranAyah(dua.surahNumber, dua.ayahNumber),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_stories_rounded,
                          color: Color(0xFF34D399), size: 12),
                      const SizedBox(width: 5),
                      Text(
                        '$surahLabel : ${dua.ayah}',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Arabic Text (Tapping jumps to Quran reader)
          GestureDetector(
            onTap: () => _openQuranAyah(dua.surahNumber, dua.ayahNumber),
            child: Text(
              dua.arabic,
              textAlign: TextAlign.center,
              style: AppTheme.arabicTitle(
                color: const Color(0xFFFDE68A),
                fontSize: 20,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Dual Meaning Section: Kurdish (first) + Expandable English
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '📖 تەفسیری ئاسان (کوردی)',
                      style: AppTheme.kurdishText(
                        fontSize: 10,
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dua.kurdishMeaning,
                textAlign: TextAlign.right,
                style: AppTheme.kurdishText(
                  color: AppColors.cream.withValues(alpha: 0.95),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              if (dua.englishMeaning.isNotEmpty) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    AppHaptics.selectionClick();
                    setState(
                        () => _heroEnglishExpanded = !_heroEnglishExpanded);
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _heroEnglishExpanded
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                              : AppColors.panelColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _heroEnglishExpanded
                                ? const Color(0xFF60A5FA).withValues(alpha: 0.4)
                                : AppColors.panelBorderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _heroEnglishExpanded
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              size: 14,
                              color: const Color(0xFF93C5FD),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _heroEnglishExpanded
                                  ? 'شاردنەوەی ئینگلیزی'
                                  : 'English Translation ▼',
                              style: const TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_heroEnglishExpanded) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      dua.englishMeaning,
                      textAlign: TextAlign.left,
                      style: AppTheme.englishText(
                        color: AppColors.cream.withValues(alpha: 0.92),
                        fontSize: 12,
                      ).copyWith(height: 1.45),
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 14),
          // Banner bottom actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _openQuranAyah(dua.surahNumber, dua.ayahNumber),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: AppColors.panelColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.panelBorderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          color: Color(0xFF34D399), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        isKurdish ? 'خوێندنەوە لە قورئان' : 'Read in Quran',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppHaptics.lightImpact();
                  showDialog(
                    context: context,
                    builder: (ctx) =>
                        DuaCardGeneratorDialog(azkar: dua.toAzkar()),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.share_rounded,
                          color: Color(0xFF34D399), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        isKurdish ? 'هاوبەشکردنی کارت' : 'Share Card',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
