import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_localizations.dart';
import '../models/azkar_model.dart';
import '../models/hadith_model.dart';
import '../services/app_haptics.dart';
import '../services/hadith_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/dua_card_generator.dart';

/// Premier Hadith Explorer & Reading Hub
class HadithScreen extends StatefulWidget {
  final String? initialChapter;

  const HadithScreen({Key? key, this.initialChapter}) : super(key: key);

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  late Future<List<HadithItem>> _hadithsFuture;
  String _selectedChapter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final Set<int> _expandedEnglishIds = {};
  bool _heroEnglishExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.languageCode;
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

            // Filter hadiths by chapter and search query
            final filteredHadiths = allHadiths.where((h) {
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
                                            fontSize: 18,
                                            color: AppColors.cream)
                                        : AppTheme.englishTitle(
                                            fontSize: 18,
                                            color: AppColors.cream),
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
                                            fontSize: 11,
                                            color: AppColors.mutedText)
                                        : AppTheme.englishText(
                                            fontSize: 11,
                                            color: AppColors.mutedText),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isSearching = !_isSearching;
                                  if (!_isSearching) {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  }
                                });
                              },
                              icon: Icon(
                                _isSearching
                                    ? Icons.close_rounded
                                    : Icons.search_rounded,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),

                        // Animated Search Field
                        if (_isSearching) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.panelColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      AppColors.gold.withValues(alpha: 0.4)),
                            ),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: TextStyle(
                                  color: AppColors.cream, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: isKurdish
                                    ? 'گەڕان لە فەرموودەکان، تەوەر یان دەق...'
                                    : (isArabic
                                        ? 'ابحث في نصوص الأحاديث أو الأبواب...'
                                        : 'Search hadiths, topics, or keywords...'),
                                hintStyle: TextStyle(
                                    color: AppColors.faintText, fontSize: 12),
                                border: InputBorder.none,
                                icon: Icon(Icons.search_rounded,
                                    color: AppColors.gold, size: 20),
                              ),
                              onChanged: (val) {
                                setState(() => _searchQuery = val);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Hadith of the Day Spotlight Card (Only when not searching)
                if (!_isSearching &&
                    dailyHadith != null &&
                    _selectedChapter == 'all')
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      child: _buildSpotlightHadithCard(
                          dailyHadith, lang, isKurdish, isArabic),
                    ),
                  ),

                // Chapters Horizontal Filter Chips
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: isKurdish
                              ? 'هەمووی (${allHadiths.length})'
                              : (isArabic
                                  ? 'الكل (${allHadiths.length})'
                                  : 'All (${allHadiths.length})'),
                          isSelected: _selectedChapter == 'all',
                          onTap: () {
                            AppHaptics.lightImpact();
                            setState(() => _selectedChapter = 'all');
                          },
                          isKurdish: isKurdish,
                          isArabic: isArabic,
                        ),
                        const SizedBox(width: 8),
                        ...chaptersMap.entries.map((entry) {
                          final isSelected = _selectedChapter == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterChip(
                              label: '${entry.key} (${entry.value})',
                              isSelected: isSelected,
                              onTap: () {
                                AppHaptics.lightImpact();
                                setState(() => _selectedChapter = entry.key);
                              },
                              isKurdish: isKurdish,
                              isArabic: isArabic,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Results Count Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isKurdish
                              ? '${filteredHadiths.length} فەرموودە دۆزرایەوە'
                              : (isArabic
                                  ? '${filteredHadiths.length} حديث متاح'
                                  : '${filteredHadiths.length} Hadiths found'),
                          style: isKurdish
                              ? AppTheme.kurdishText(
                                  fontSize: 12,
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.bold)
                              : AppTheme.englishText(
                                  fontSize: 12,
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.bold),
                        ),
                        if (_selectedChapter != 'all')
                          GestureDetector(
                            onTap: () => setState(() => _selectedChapter = 'all'),
                            child: Text(
                              isKurdish ? 'پاککردنەوەی فلتەر' : 'Clear filter',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.gold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // Hadiths List
                if (filteredHadiths.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 60, horizontal: 30),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48, color: AppColors.faintText),
                            const SizedBox(height: 12),
                            Text(
                              isKurdish
                                  ? 'هیچ فەرموودەیەک نەدۆزرایەوە بەم ناوە'
                                  : 'No hadiths found matching your query',
                              style: isKurdish
                                  ? AppTheme.kurdishText(
                                      fontSize: 14, color: AppColors.mutedText)
                                  : AppTheme.englishText(
                                      fontSize: 14, color: AppColors.mutedText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final hadith = filteredHadiths[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildHadithCard(
                                hadith, lang, isKurdish, isArabic),
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isKurdish,
    required bool isArabic,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.panelColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.panelBorderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: isKurdish
              ? AppTheme.kurdishText(
                  fontSize: 11,
                  color: isSelected ? AppColors.darkBg : AppColors.mutedText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )
              : (isArabic
                  ? AppTheme.arabicText(
                      fontSize: 11,
                      color: isSelected ? AppColors.darkBg : AppColors.mutedText,
                    )
                  : AppTheme.englishText(
                      fontSize: 11,
                      color: isSelected ? AppColors.darkBg : AppColors.mutedText,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
        ),
      ),
    );
  }

  Widget _buildSpotlightHadithCard(
    HadithItem hadith,
    String lang,
    bool isKurdish,
    bool isArabic,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.18),
            AppColors.panelColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spotlight Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: AppColors.gold, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isKurdish
                            ? 'فەرموودەی ئەمڕۆ'
                            : (isArabic ? 'حديث اليوم المختار' : 'Hadith of the Day'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: isKurdish
                            ? AppTheme.kurdishText(
                                fontSize: 12,
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold)
                            : AppTheme.englishText(
                                fontSize: 12,
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    hadith.getChapter(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isKurdish
                        ? AppTheme.kurdishText(fontSize: 10, color: AppColors.gold)
                        : AppTheme.englishText(fontSize: 10, color: AppColors.gold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Narrator
          Text(
            hadith.narratorAr,
            style: AppTheme.arabicText(
              fontSize: 12,
              color: AppColors.gold.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),

          // Arabic Matn
          Text(
            '«${hadith.textAr}»',
            style: AppTheme.arabicTitle(
              fontSize: 16,
              color: AppColors.cream,
            ).copyWith(height: 1.6),
          ),
          const SizedBox(height: 10),

          // Dual Meaning: Kurdish (first) + Expandable English
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: isKurdish ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '📜 مانای فەرموودە (کوردی)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.kurdishText(
                      fontSize: 10,
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hadith.textKu,
                textAlign: TextAlign.right,
                style: AppTheme.kurdishText(
                  fontSize: 13,
                  color: AppColors.cream.withValues(alpha: 0.95),
                ).copyWith(height: 1.55),
              ),
              if (hadith.textEn.isNotEmpty) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    AppHaptics.selectionClick();
                    setState(() => _heroEnglishExpanded = !_heroEnglishExpanded);
                  },
                  child: Align(
                    alignment: isKurdish ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          Flexible(
                            child: Text(
                              _heroEnglishExpanded
                                  ? (isKurdish ? 'شاردنەوەی ئینگلیزی' : 'Hide English')
                                  : (isKurdish ? 'مانای ئینگلیزی ▼' : 'English Translation ▼'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      hadith.textEn,
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

          // Footer
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  '📖 ${hadith.source}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.arabicText(
                    fontSize: 10,
                    color: AppColors.faintText,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionIconButton(
                    icon: Icons.copy_rounded,
                    label: isKurdish ? 'کۆپی' : 'Copy',
                    onTap: () => _copyHadith(hadith, isKurdish),
                  ),
                  const SizedBox(width: 8),
                  _buildActionIconButton(
                    icon: Icons.share_rounded,
                    label: isKurdish ? 'کارت' : 'Card',
                    isPrimary: true,
                    onTap: () => _showHadithCardSheet(hadith),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(
    HadithItem hadith,
    String lang,
    bool isKurdish,
    bool isArabic,
  ) {
    final isSahih = hadith.grade.contains('صحيح');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.panelBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Tags Row (Chapter, Hadith ID, Grade)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chapter tag
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkBgAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.panelBorderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_outline_rounded,
                          size: 12, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          hadith.getChapter(lang),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Grade badge & Hadith #
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSahih
                          ? const Color(0xFF059669).withValues(alpha: 0.16)
                          : AppColors.gold.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSahih
                            ? const Color(0xFF059669).withValues(alpha: 0.4)
                            : AppColors.gold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      hadith.grade,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSahih
                            ? const Color(0xFF34D399)
                            : AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#${hadith.id}',
                    style: AppTheme.englishText(
                      fontSize: 12,
                      color: AppColors.faintText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Narrator
          Text(
            hadith.narratorAr,
            style: AppTheme.arabicText(
              fontSize: 12,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 8),

          // Arabic Matn
          Text(
            '«${hadith.textAr}»',
            style: AppTheme.arabicTitle(
              fontSize: 16,
              color: AppColors.cream,
            ).copyWith(height: 1.65),
          ),
          const SizedBox(height: 12),

          // Decorative Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.panelBorderColor.withValues(alpha: 0.6),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.star_rounded,
                    size: 14, color: AppColors.gold.withValues(alpha: 0.5)),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.panelBorderColor.withValues(alpha: 0.6),
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Dual Meaning Section: Kurdish (first) + Expandable English
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: isKurdish ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    '📜 مانای فەرموودە (کوردی)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.kurdishText(
                      fontSize: 10,
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hadith.textKu,
                textAlign: TextAlign.right,
                style: AppTheme.kurdishText(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ).copyWith(height: 1.6),
              ),

              // English Translation Toggle
              if (hadith.textEn.isNotEmpty) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    AppHaptics.selectionClick();
                    setState(() {
                      if (_expandedEnglishIds.contains(hadith.id)) {
                        _expandedEnglishIds.remove(hadith.id);
                      } else {
                        _expandedEnglishIds.add(hadith.id);
                      }
                    });
                  },
                  child: Align(
                    alignment: isKurdish ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _expandedEnglishIds.contains(hadith.id)
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                            : AppColors.darkBg.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _expandedEnglishIds.contains(hadith.id)
                              ? const Color(0xFF60A5FA).withValues(alpha: 0.4)
                              : AppColors.panelBorderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _expandedEnglishIds.contains(hadith.id)
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 15,
                            color: const Color(0xFF93C5FD),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _expandedEnglishIds.contains(hadith.id)
                                  ? (isKurdish
                                      ? 'شاردنەوەی ئینگلیزی'
                                      : 'Hide English')
                                  : (isKurdish
                                      ? 'مانای ئینگلیزی (English)'
                                      : 'Show English Translation'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_expandedEnglishIds.contains(hadith.id)) ...[
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
                        Align(
                          alignment: isKurdish ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '🌐 English Translation',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hadith.textEn,
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
          const SizedBox(height: 14),

          // Footer (Source & Action Buttons)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  '📖 ${hadith.source}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.arabicText(
                    fontSize: 11,
                    color: AppColors.faintText,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionIconButton(
                    icon: Icons.copy_rounded,
                    label: isKurdish ? 'کۆپی' : 'Copy',
                    onTap: () => _copyHadith(hadith, isKurdish, lang),
                  ),
                  const SizedBox(width: 8),
                  _buildActionIconButton(
                    icon: Icons.share_rounded,
                    label: isKurdish ? 'کارت' : 'Card',
                    isPrimary: true,
                    onTap: () => _showHadithCardSheet(hadith),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Action icon button helper matching Quran Duas styling
  Widget _buildActionIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
              size: 14,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isPrimary ? AppColors.gold : AppColors.cream,
                  fontSize: 11,
                  fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        content: Text(
          isKurdish
              ? 'فەرموودەکە کۆپیکرا بۆ کلیپبۆرد ✨'
              : 'Hadith copied to clipboard ✨',
        ),
        backgroundColor: AppColors.gold,
        behavior: SnackBarBehavior.floating,
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
}
