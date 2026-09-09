import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_localizations.dart';
import '../models/general_dua_model.dart';
import '../services/app_haptics.dart';
import '../services/general_dua_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/dua_card_generator.dart';

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
  final Set<int> _expandedEnglishIds = {};
  bool _heroEnglishExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.languageCode;
    final isKurdish = lang == 'ku';
    final isArabic = lang == 'ar';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF062820),
              AppColors.darkBg,
              AppColors.darkBgAlt,
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<GeneralDuaItem>>(
            future: _duasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.gold,
                  ),
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
              var filteredDuas = allDuas.where((d) {
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
                slivers: [
                  // App Bar
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

                  // Hero Banner: Prophetic Dua of the Day
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _showFavoritesOnly
                                ? (isKurdish
                                    ? 'دوعا هەڵبژێردراوەکانم'
                                    : 'Saved Supplications')
                                : (isKurdish
                                    ? 'دوعا پیرۆزەکان'
                                    : 'Prophetic Duas'),
                            style: isKurdish
                                ? AppTheme.kurdishTitle(
                                    fontSize: 17, color: AppColors.cream)
                                : AppTheme.englishTitle(
                                    fontSize: 16, color: AppColors.cream),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.panelColor,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppColors.panelBorderColor),
                            ),
                            child: Text(
                              '${filteredDuas.length} / ${allDuas.length}',
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
                  ),

                  // Empty State
                  if (filteredDuas.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildEmptyState(isKurdish),
                    )
                  else
                    // General Duas List
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final dua = filteredDuas[index];
                            final isFav = _favoriteIds.contains(dua.id);
                            final reciteCount = _reciteCounters[dua.id] ?? 0;

                            return _buildDuaCard(
                              dua: dua,
                              isFav: isFav,
                              reciteCount: reciteCount,
                              isKurdish: isKurdish,
                              isArabic: isArabic,
                              lang: lang,
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
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(
      BuildContext context, bool isKurdish, bool isArabic, String lang) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.panelBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 14),
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
                          fontSize: 18, color: AppColors.gold)
                      : AppTheme.englishTitle(
                          fontSize: 17, color: AppColors.gold),
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
                          fontSize: 11, color: AppColors.faintText)
                      : AppTheme.englishText(
                          fontSize: 11, color: AppColors.faintText),
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
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _isSearching
                    ? AppColors.gold.withValues(alpha: 0.25)
                    : AppColors.darkBgAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearching
                      ? AppColors.gold
                      : AppColors.panelBorderColor,
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
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _showFavoritesOnly
                    ? const Color(0xFFE11D48).withValues(alpha: 0.2)
                    : AppColors.darkBgAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showFavoritesOnly
                      ? const Color(0xFFE11D48)
                      : AppColors.panelBorderColor,
                ),
              ),
              child: Icon(
                _showFavoritesOnly
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                size: 18,
                color: _showFavoritesOnly
                    ? const Color(0xFFF43F5E)
                    : AppColors.cream,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: TextStyle(color: AppColors.cream, fontSize: 14),
        decoration: InputDecoration(
          hintText: isKurdish
              ? 'گەڕان لە دەقی عەرەبی، مانا، یان سەرچاوە...'
              : 'Search in Arabic, meaning, or source...',
          hintStyle: TextStyle(color: AppColors.faintText, fontSize: 13),
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: AppColors.gold, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon:
                      Icon(Icons.clear_rounded, color: AppColors.cream, size: 18),
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
      height: 44,
      margin: const EdgeInsets.only(top: 6, bottom: 8),
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
            label = isKurdish ? '✨ هەموو دوعاکان' : '✨ All Duas';
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
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold
                    : AppColors.panelColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.gold
                      : AppColors.panelBorderColor,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.darkBg : AppColors.cream,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
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
  // FEATURED PROPHETIC DUA OF THE DAY BANNER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDuaOfTheDayBanner(GeneralDuaItem dua, bool isKurdish,
      bool isArabic, String lang) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF134E4A),
            const Color(0xFF0F766E).withValues(alpha: 0.8),
            AppColors.panelColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Top Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isKurdish ? 'دوعای هەڵبژێردراوی ڕۆژ' : 'Featured Daily Dua',
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
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    dua.getCategoryTitle(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF5EEAD4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Arabic Text
          Text(
            dua.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: AppTheme.arabicTitle(
              color: const Color(0xFFFDE68A),
              fontSize: 20,
              height: 1.8,
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
                      '📖 مانای دوعا (کوردی)',
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
                textDirection: TextDirection.rtl,
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
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      dua.englishMeaning,
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.ltr,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '📖 ${dua.hadithSource}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.faintText,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  _buildActionIconButton(
                    icon: Icons.copy_rounded,
                    label: isKurdish ? 'کۆپی' : 'Copy',
                    onTap: () {
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
                          content: Text(
                            isKurdish
                                ? 'دوعاکە کۆپیکرا بۆ کلیپبۆرد ✨'
                                : 'Dua copied to clipboard ✨',
                          ),
                          backgroundColor: AppColors.gold,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionIconButton(
                    icon: Icons.share_rounded,
                    label: isKurdish ? 'کارت' : 'Card',
                    isPrimary: true,
                    onTap: () {
                      AppHaptics.lightImpact();
                      showDialog(
                        context: context,
                        builder: (ctx) =>
                            DuaCardGeneratorDialog(azkar: dua.toAzkar()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DUA ITEM CARD
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDuaCard({
    required GeneralDuaItem dua,
    required bool isFav,
    required int reciteCount,
    required bool isKurdish,
    required bool isArabic,
    required String lang,
  }) {
    final title = dua.getDisplayTitle(lang);
    final categoryTitle = dua.getCategoryTitle(lang);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.panelColor,
            AppColors.darkBgAlt,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFav
              ? AppColors.gold.withValues(alpha: 0.5)
              : AppColors.panelBorderColor,
          width: isFav ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header Row: Category pill, Title, and Bookmark
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 10),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      categoryTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5EEAD4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isKurdish
                        ? AppTheme.kurdishText(
                            color: AppColors.cream,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          )
                        : AppTheme.englishText(
                            color: AppColors.cream,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ),
                // Favorite Button
                GestureDetector(
                  onTap: () => _toggleFavorite(dua.id),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isFav
                          ? const Color(0xFFE11D48).withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isFav
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      size: 20,
                      color: isFav
                          ? const Color(0xFFF43F5E)
                          : AppColors.faintText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Arabic Matn Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBg.withValues(alpha: 0.8),
                  AppColors.darkBgAlt.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              dua.arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicTitle(
                color: const Color(0xFFFFFBEB),
                fontSize: 19,
                height: 1.8,
              ),
            ),
          ),

          // Dual Meaning Section: Kurdish (first) + Expandable English
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kurdish Section Header & Text
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        '📖 مانای دوعا (کوردی)',
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
                  textDirection: TextDirection.rtl,
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
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
                                    ? (isKurdish
                                        ? 'شاردنەوەی مانای ئینگلیزی'
                                        : 'Hide English Meaning')
                                    : (isKurdish
                                        ? 'پیشاندانی مانای ئینگلیزی (English)'
                                        : 'Show English Translation'),
                                style: const TextStyle(
                                  color: Color(0xFF93C5FD),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
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
                            dua.englishMeaning,
                            textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
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

          // Action Toolbar: Recite counter, Source, Copy, Share Card
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
                          isKurdish
                              ? (reciteCount > 0
                                  ? 'خوێندراوە ($reciteCount)'
                                  : 'خوێندنەوە')
                              : (reciteCount > 0
                                  ? 'Recited ($reciteCount)'
                                  : 'Recite'),
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
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '📖 ${dua.hadithSource}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.faintText,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Copy Action
                _buildActionIconButton(
                  icon: Icons.copy_rounded,
                  label: isKurdish ? 'کۆپی' : 'Copy',
                  onTap: () {
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
                                  : 'Dua copied to clipboard',
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
                // Share Card Action
                _buildActionIconButton(
                  icon: Icons.share_rounded,
                  label: isKurdish ? 'کارت' : 'Card',
                  isPrimary: true,
                  onTap: () {
                    AppHaptics.lightImpact();
                    showDialog(
                      context: context,
                      builder: (ctx) =>
                          DuaCardGeneratorDialog(azkar: dua.toAzkar()),
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

  // ════════════════════════════════════════════════════════════════════════════
  // ACTION ICON BUTTON
  // ════════════════════════════════════════════════════════════════════════════
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
              ? AppColors.gold.withValues(alpha: 0.18)
              : AppColors.darkBgAlt,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isPrimary
                ? AppColors.gold.withValues(alpha: 0.45)
                : AppColors.panelBorderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? AppColors.gold : AppColors.cream,
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? AppColors.gold : AppColors.cream,
                fontSize: 11,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
              ),
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
            size: 54,
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
                    color: AppColors.mutedText, fontSize: 14)
                : AppTheme.englishText(
                    color: AppColors.mutedText, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
