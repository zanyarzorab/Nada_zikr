import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_localizations.dart';
import '../models/azkar_model.dart';
import '../models/hadith_model.dart';
import '../services/app_haptics.dart';
import '../services/hadith_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/dua_card_generator.dart';
import '../widgets/focused_reading_sheet.dart';
import '../widgets/spiritual_content_card.dart';
import '../widgets/spiritual_detail_sheet.dart';

/// Premier Hadith Explorer & Reading Hub
class HadithScreen extends StatefulWidget {
  final String? initialChapter;

  const HadithScreen({super.key, this.initialChapter});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  late Future<List<HadithItem>> _hadithsFuture;
  String _selectedChapter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showFavoritesOnly = false;
  final Set<int> _favoriteIds = {};
  bool? _showEnglishMode;

  @override
  void initState() {
    super.initState();
    if (widget.initialChapter != null) {
      _selectedChapter = widget.initialChapter!;
    }
    _hadithsFuture = HadithService.loadAllHadiths();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _copyHadith(HadithItem hadith, bool isKurdish, [String lang = 'ku']) {
    AppHaptics.lightImpact();
    final text = '📜 فەرموودەی پێغەمبەر ﷺ:\n\n'
        '${hadith.narratorAr}\n'
        '«${hadith.textAr}»\n\n'
        'مانای کوردی:\n${hadith.textKu}\n\n'
        'English Translation:\n${hadith.textEn}\n\n'
        'سەرچاوە: ${hadith.source} (${hadith.grade})\n'
        'لە ئەپی (نەدا) 🌟';

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
                  ? 'فەرموودەکە کۆپیکرا بۆ کلیپبۆرد'
                  : 'Hadith copied to clipboard',
              style: isKurdish
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

  void _showHadithCardSheet(HadithItem hadith) {
    AppHaptics.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => DuaCardGeneratorDialog(
        azkar: Azkar(
          id: hadith.id,
          arabic: hadith.textAr,
          translation: hadith.textEn,
          kurdishTranslation: hadith.textKu,
          repeat: 1,
          source: '${hadith.narratorAr} • ${hadith.source} (${hadith.grade})',
        ),
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
        child: FutureBuilder<List<HadithItem>>(
          future: _hadithsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            final allHadiths = snapshot.data ?? [];
            final dailyHadith = HadithService.getHadithOfTheDay(allHadiths);

            // Extract unique chapters with counts
            final chaptersMap = <String, int>{};
            for (final h in allHadiths) {
              chaptersMap[h.chapter] = (chaptersMap[h.chapter] ?? 0) + 1;
            }

            // Filter hadiths by chapter, favorites, and search query
            final filteredHadiths = allHadiths.where((h) {
              if (_showFavoritesOnly && !_favoriteIds.contains(h.id)) {
                return false;
              }
              final matchesChapter =
                  _selectedChapter == 'all' || h.chapter == _selectedChapter;
              final query = _searchQuery.trim().toLowerCase();
              if (query.isEmpty) return matchesChapter;

              final matchesSearch = h.textKu.toLowerCase().contains(query) ||
                  h.textEn.toLowerCase().contains(query) ||
                  h.chapterEn.toLowerCase().contains(query) ||
                  h.textAr.toLowerCase().contains(query) ||
                  h.narratorAr.toLowerCase().contains(query) ||
                  h.chapter.toLowerCase().contains(query) ||
                  h.source.toLowerCase().contains(query);

              return matchesChapter && matchesSearch;
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

                // Chapters Horizontal Filter Chips
                SliverToBoxAdapter(
                  child: _buildChapterChips(
                      chaptersMap, allHadiths, allHadiths.length, lang, isKurdish, isArabic),
                ),

                // Hadith of the Day Spotlight Card (Only when not searching & not filtered)
                if (!_isSearching &&
                    !_showFavoritesOnly &&
                    dailyHadith != null &&
                    _selectedChapter == 'all')
                  SliverToBoxAdapter(
                    child: _buildSpotlightHadithCard(
                        dailyHadith, lang, isKurdish, isArabic),
                  ),

                // Results Count Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _showFavoritesOnly
                              ? (isKurdish
                                  ? 'فەرموودە هەڵبژێردراوەکانم'
                                  : (isArabic
                                      ? 'الأحاديث المفضلة'
                                      : 'Saved Hadiths'))
                              : (isKurdish
                                  ? '${filteredHadiths.length} فەرموودە'
                                  : (isArabic
                                      ? '${filteredHadiths.length} حديث'
                                      : '${filteredHadiths.length} Hadiths')),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedChapter != 'all')
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedChapter = 'all'),
                            child: Text(
                              isKurdish
                                  ? 'پاککردنەوەی فلتەر'
                                  : (isArabic
                                      ? 'إلغاء التصفية'
                                      : 'Clear filter'),
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.gold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Hadiths List
                if (filteredHadiths.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(isKurdish),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final hadith = filteredHadiths[index];


                          final hasKurdish =
                              hadith.textKu.trim().isNotEmpty;
                          final hasEnglish =
                              hadith.textEn.trim().isNotEmpty;
                          final bool preferEnglish =
                              _showEnglishMode ?? (lang == 'en');
                          final bool isDisplayingEnglish =
                              (preferEnglish && hasEnglish) || !hasKurdish;

                          return SpiritualContentCard(
                            arabic: hadith.textAr,
                            narrator: hadith.narratorAr,
                            kurdishMeaning: hadith.textKu,
                            englishMeaning: hadith.textEn,
                            source: '📖 ${hadith.source} (${hadith.grade})',
                            categoryTag: hadith.getChapter(lang),
                            categoryTagIcon: Icons.menu_book_rounded,
                            isFavorite: _favoriteIds.contains(hadith.id),
                            showReciteCounter: false,
                            onToggleFavorite: () {
                              AppHaptics.mediumImpact();
                              setState(() {
                                final isFav = _favoriteIds.contains(hadith.id);
                                if (isFav) {
                                  _favoriteIds.remove(hadith.id);
                                } else {
                                  _favoriteIds.add(hadith.id);
                                }
                              });
                            },
                            reciteCount: 0,
                            onRecite: () {},
                            onShareCard: () => _showHadithCardSheet(hadith),
                            onCopy: () =>
                                _copyHadith(hadith, isKurdish, lang),
                            onFocusRead: () async {
                              await FocusedReadingSheet.show(
                                context,
                                arabic: hadith.textAr,
                                narrator: hadith.narratorAr,
                                kurdishMeaning: hadith.textKu,
                                englishMeaning: hadith.textEn,
                                source: '📖 ${hadith.source} (${hadith.grade})',
                                title: hadith.getChapter(lang),
                                lang: lang,
                                showReciteCounter: false,
                              );
                            },
                            lang: lang,
                            meaningBadgeKurdishLabel: '📜 مانای فەرموودە (کوردی)',
                            isDisplayingEnglish: isDisplayingEnglish,
                            onToggleLanguage: () {
                              AppHaptics.selectionClick();
                              setState(() {
                                _showEnglishMode = !isDisplayingEnglish;
                              });
                            },
                          );
                        },
                        childCount: filteredHadiths.length,
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
                      ? 'فەرموودە پیرۆزەکان'
                      : (isArabic
                          ? 'الأحاديث النبوية الشريفة'
                          : 'Noble Prophetic Hadiths'),
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
                      ? '100 فەرموودەی صەحیح و پەسەند لە بارەی ژیان و ئیمان'
                      : (isArabic
                          ? '100 حديث نبوي صحيح في شتى أبواب الخير'
                          : '100 authentic hadiths on faith & life'),
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
                      ? AppColors.gold.withValues(alpha: 0.5)
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
          // Favorites Toggle
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
                      ? const Color(0xFFE11D48).withValues(alpha: 0.5)
                      : AppColors.panelBorderColor.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                _showFavoritesOnly
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
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
              ? 'گەڕان لە فەرموودەکان، تەوەر یان دەق...'
              : (isArabic
                  ? 'ابحث في نصوص الأحاديث أو الأبواب...'
                  : 'Search hadiths, topics, or keywords...'),
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
  // CHAPTER FILTER CHIPS
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildChapterChips(Map<String, int> chaptersMap, List<HadithItem> allHadiths,
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
            isSelected: _selectedChapter == 'all',
            onTap: () {
              AppHaptics.selectionClick();
              setState(() => _selectedChapter = 'all');
            },
            isKurdish: isKurdish,
          ),
          ...chaptersMap.entries.map((entry) {
            final isSelected = _selectedChapter == entry.key;
            final sampleHadith = allHadiths.firstWhere(
              (h) => h.chapter == entry.key,
              orElse: () => allHadiths.first,
            );
            final localizedChapter = sampleHadith.getChapter(lang);
            return _buildFilterChip(
              label: '$localizedChapter (${entry.value})',
              isSelected: isSelected,
              onTap: () {
                AppHaptics.selectionClick();
                setState(() => _selectedChapter = entry.key);
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
  // HADITH OF THE DAY (CALM SPOTLIGHT)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSpotlightHadithCard(
    HadithItem hadith,
    String lang,
    bool isKurdish,
    bool isArabic,
  ) {
    final isFav = _favoriteIds.contains(hadith.id);

    return GestureDetector(
      onTap: () {
        AppHaptics.lightImpact();
        SpiritualDetailSheet.show(
          context,
          arabic: hadith.textAr,
          kurdishMeaning: hadith.textKu,
          englishMeaning: hadith.textEn,
          source: '📖 ${hadith.source} (${hadith.grade})',
          categoryTag: hadith.getChapter(lang),
          narrator: hadith.narratorAr,
          isFavorite: isFav,
          onToggleFavorite: () {
            AppHaptics.mediumImpact();
            setState(() {
              if (isFav) {
                _favoriteIds.remove(hadith.id);
              } else {
                _favoriteIds.add(hadith.id);
              }
            });
          },
          reciteCount: 0,
          onReciteChanged: (_) {},
          onShareCard: () => _showHadithCardSheet(hadith),
          onCopy: () => _copyHadith(hadith, isKurdish, lang),
          onFocusRead: () {
            FocusedReadingSheet.show(
              context,
              arabic: hadith.textAr,
              narrator: hadith.narratorAr,
              kurdishMeaning: hadith.textKu,
              englishMeaning: hadith.textEn,
              source: '📖 ${hadith.source} (${hadith.grade})',
              title: hadith.getChapter(lang),
              lang: lang,
              showReciteCounter: false,
            );
          },
          lang: lang,
          showReciteCounter: false,
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
                              ? 'فەرموودەی ئەمڕۆ'
                              : (isArabic ? 'حديث اليوم المختار' : 'Hadith of the Day'),
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
                    Text(
                      hadith.getChapter(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        AppHaptics.mediumImpact();
                        setState(() {
                          if (isFav) {
                            _favoriteIds.remove(hadith.id);
                          } else {
                            _favoriteIds.add(hadith.id);
                          }
                        });
                      },
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
              hadith.narratorAr,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.gold.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '«${hadith.textAr}»',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: AppTheme.arabicTitle(
                fontSize: 17,
                color: const Color(0xFFFFFBEB),
                height: 1.75,
              ),
            ),
            if (hadith.textKu.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                lang == 'en' && hadith.textEn.isNotEmpty
                    ? hadith.textEn
                    : hadith.textKu,
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
                Expanded(
                  child: Text(
                    '📖 ${hadith.source} (${hadith.grade})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.veryFaintText,
                      fontSize: 10.5,
                    ),
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
                ? Icons.bookmark_border_rounded
                : Icons.search_off_rounded,
            size: 48,
            color: AppColors.faintText,
          ),
          const SizedBox(height: 14),
          Text(
            _showFavoritesOnly
                ? (isKurdish
                    ? 'هیچ فەرموودەیەکت لە دڵخوازەکان دیاری نەکردووە'
                    : 'No saved hadiths yet')
                : (isKurdish
                    ? 'هیچ فەرموودەیەک بەم ناوە نەدۆزرایەوە'
                    : 'No hadiths found matching your query'),
            textAlign: TextAlign.center,
            style: isKurdish
                ? AppTheme.kurdishText(
                    fontSize: 13.5, color: AppColors.mutedText)
                : AppTheme.englishText(
                    fontSize: 13.5, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
