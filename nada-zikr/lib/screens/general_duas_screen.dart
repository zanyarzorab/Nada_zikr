import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_localizations.dart';
import '../models/general_dua_model.dart';
import '../services/app_haptics.dart';
import '../services/general_dua_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/dua_card_generator.dart';
import '../widgets/focused_reading_sheet.dart';
import '../widgets/spiritual_content_card.dart';
import '../widgets/spiritual_detail_sheet.dart';

class GeneralDuasScreen extends StatefulWidget {
  final String? initialCategory;

  const GeneralDuasScreen({
    super.key,
    this.initialCategory,
  });

  @override
  State<GeneralDuasScreen> createState() => _GeneralDuasScreenState();
}

class _GeneralDuasScreenState extends State<GeneralDuasScreen> {
  late Future<List<GeneralDuaItem>> _duasFuture;
  String _selectedCategory = 'all';
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
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _duasFuture = GeneralDuaService.loadAllDuas();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await GeneralDuaService.getFavoriteIds();
    if (mounted) {
      setState(() {
        _favoriteIds = favs;
      });
    }
  }

  Future<void> _toggleFavorite(int id) async {
    AppHaptics.mediumImpact();
    await GeneralDuaService.toggleFavorite(id);
    await _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _copyDua(GeneralDuaItem dua, bool isKurdish, bool isArabic) {
    AppHaptics.lightImpact();
    final textToCopy = '💫 دوعای پیرۆزی فەرموودە:\n\n'
        '${dua.arabic}\n\n'
        '📖 مانای کوردی:\n${dua.kurdishMeaning}\n\n'
        '🌐 English Translation:\n${dua.englishMeaning}\n\n'
        'سەرچاوە: ${dua.hadithSource}\n'
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
        child: FutureBuilder<List<GeneralDuaItem>>(
          future: _duasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(
                  isKurdish
                      ? 'هەڵەیەک ڕوویدا لە بارکردنی دوعاکان'
                      : 'Error loading supplications',
                  style: AppTheme.kurdishText(color: AppColors.cream),
                ),
              );
            }

            final allDuas = snapshot.data!;

            // Extract unique categories
            final categorySet = <String>{'all'};
            for (final d in allDuas) {
              if (d.category.isNotEmpty) {
                categorySet.add(d.category);
              }
            }
            final categories = categorySet.toList();

            // Filter Duas
            final filteredDuas = allDuas.where((d) {
              if (_showFavoritesOnly && !_favoriteIds.contains(d.id)) {
                return false;
              }
              if (_selectedCategory != 'all' &&
                  d.category != _selectedCategory) {
                return false;
              }
              if (_searchQuery.isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                final matchesArabic = d.arabic.toLowerCase().contains(q);
                final matchesKurdish =
                    d.kurdishMeaning.toLowerCase().contains(q);
                final matchesEnglish =
                    d.englishMeaning.toLowerCase().contains(q);
                final matchesTitle = d.title.toLowerCase().contains(q);
                final matchesSource =
                    d.hadithSource.toLowerCase().contains(q);
                return matchesArabic ||
                    matchesKurdish ||
                    matchesEnglish ||
                    matchesTitle ||
                    matchesSource;
              }
              return true;
            }).toList();

            final duaOfTheDay = GeneralDuaService.getDuaOfTheDay(allDuas);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top App Bar
                SliverToBoxAdapter(
                  child: _buildHeader(context, isKurdish, isArabic, lang),
                ),

                // Search Bar (if activated)
                if (_isSearching)
                  SliverToBoxAdapter(
                    child: _buildSearchBar(isKurdish),
                  ),

                // Topic Categories Filter Chips
                SliverToBoxAdapter(
                  child: _buildCategoryChips(
                      categories, lang, isKurdish, isArabic),
                ),

                // Hero Banner: Prophetic Dua of the Day (Clean & Compact)
                if (!_isSearching &&
                    !_showFavoritesOnly &&
                    _selectedCategory == 'all' &&
                    duaOfTheDay != null)
                  SliverToBoxAdapter(
                    child: _buildDuaOfTheDayBanner(
                        duaOfTheDay, isKurdish, isArabic, lang),
                  ),

                // Section Title / Results counter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
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
                                  ? 'دوعا پیرۆزەکان'
                                  : (isArabic
                                      ? 'الأدعية النبوية الشريفة'
                                      : 'Prophetic Duas')),
                          style: isKurdish
                              ? AppTheme.kurdishTitle(
                                  fontSize: 16, color: AppColors.cream)
                              : (isArabic
                                  ? AppTheme.arabicTitle(
                                      fontSize: 16, color: AppColors.cream)
                                  : AppTheme.englishTitle(
                                      fontSize: 15, color: AppColors.cream)),
                        ),
                        Text(
                          '${filteredDuas.length} / ${allDuas.length}',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Empty State
                if (filteredDuas.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(isKurdish),
                  )
                else
                  // Content-First Duas List
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dua = filteredDuas[index];
                          final isFav = _favoriteIds.contains(dua.id);
                          final reciteCount = _reciteCounters[dua.id] ?? 0;

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
                            kurdishMeaning: dua.kurdishMeaning,
                            englishMeaning: dua.englishMeaning,
                            source: '📖 ${dua.hadithSource}',
                            categoryTag: dua.getCategoryTitle(lang),
                            categoryTagIcon: Icons.auto_awesome_rounded,
                            title: dua.getDisplayTitle(lang),
                            isFavorite: isFav,
                            onToggleFavorite: () => _toggleFavorite(dua.id),
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
                                source: '📖 ${dua.hadithSource}',
                                title: dua.getDisplayTitle(lang),
                                initialCount: reciteCount,
                                lang: lang,
                              );
                              if (newCount != null && mounted) {
                                setState(() {
                                  _reciteCounters[dua.id] = newCount;
                                });
                              }
                            },
                            lang: lang,
                            meaningBadgeKurdishLabel: '📖 مانای دوعا (کوردی)',
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
  Widget _buildHeader(
      BuildContext context, bool isKurdish, bool isArabic, String lang) {
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
                      ? 'زیکر و دوعای گشتی'
                      : (isArabic
                          ? 'الأذكار والأدعية النبوية'
                          : 'General & Prophetic Duas'),
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
                      ? '110 دوعای فەرموودەی سەحیح و سوننەت'
                      : (isArabic
                          ? '110 دعاء نبوي من الأحاديث الصحيحة'
                          : '110 Authentic Prophetic Supplications'),
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
          // Search Action
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
  Widget _buildSearchBar(bool isKurdish) {
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
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: TextStyle(color: AppColors.cream, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: isKurdish
              ? 'گەڕان لە دەقی عەرەبی، مانا، یان سەرچاوە...'
              : 'Search in Arabic, meaning, or source...',
          hintStyle: TextStyle(color: AppColors.faintText, fontSize: 12.5),
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: AppColors.gold, size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded,
                      color: AppColors.cream, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TOPIC CATEGORY CHIPS
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildCategoryChips(List<String> categories, String lang,
      bool isKurdish, bool isArabic) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _selectedCategory;

          String label;
          if (cat == 'all') {
            label = isKurdish
                ? 'هەمووی'
                : (isArabic ? 'الكل' : 'All');
          } else {
            if (cat.contains('(') && cat.contains(')')) {
              final parts = cat.split('(');
              final enPart = parts[0].trim();
              final kuPart = parts[1].replaceAll(')', '').trim();
              label = isKurdish
                  ? (kuPart.isNotEmpty ? kuPart : enPart)
                  : (enPart.isNotEmpty ? enPart : kuPart);
            } else {
              label = cat;
            }
          }

          return GestureDetector(
            onTap: () {
              AppHaptics.selectionClick();
              setState(() {
                _selectedCategory = cat;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(right: 7),
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
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
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // FEATURED PROPHETIC DUA HERO BANNER (REFINED & CALM)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDuaOfTheDayBanner(GeneralDuaItem dua, bool isKurdish,
      bool isArabic, String lang) {
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
          source: '📖 ${dua.hadithSource}',
          categoryTag: dua.getCategoryTitle(lang),
          title: dua.getDisplayTitle(lang),
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
          onFocusRead: () async {
            final newCount = await FocusedReadingSheet.show(
              context,
              arabic: dua.arabic,
              kurdishMeaning: dua.kurdishMeaning,
              englishMeaning: dua.englishMeaning,
              source: '📖 ${dua.hadithSource}',
              title: dua.getDisplayTitle(lang),
              initialCount: reciteCount,
              lang: lang,
            );
            if (newCount != null && mounted) {
              setState(() {
                _reciteCounters[dua.id] = newCount;
              });
            }
          },
          lang: lang,
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
                          isKurdish ? 'دوعای هەڵبژێردراوی ئەمڕۆ' : 'Daily Prophetic Dua',
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
                      dua.getCategoryTitle(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10.5,
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
              style: AppTheme.arabicTitle(
                color: const Color(0xFFFFFBEB),
                fontSize: 18,
                height: 1.8,
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
                Expanded(
                  child: Text(
                    '📖 ${dua.hadithSource}',
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
