import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_localizations.dart';
import '../models/azkar_model.dart';
import '../services/app_haptics.dart';
import '../services/names_of_allah_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';

class NamesOfAllahScreen extends StatefulWidget {
  const NamesOfAllahScreen({Key? key}) : super(key: key);

  @override
  State<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen> {
  late List<NameOfAllah> _allNames = [];
  late List<NameOfAllah> _filteredNames = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isGridView = true; // Default to square block grid view
  bool? _showEnglishMode;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
    _loadNames();
    _searchController.addListener(_filterNames);
  }

  Future<void> _loadViewMode() async {
    final mode = await StorageService.readSetting('names_view_mode', defaultValue: 'grid');
    if (mounted) {
      setState(() {
        _isGridView = mode == 'grid';
      });
    }
  }

  void _toggleViewMode(bool grid) {
    setState(() {
      _isGridView = grid;
    });
    StorageService.saveSetting('names_view_mode', grid ? 'grid' : 'list');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNames() async {
    final names = await NamesOfAllahService.instance.loadAllNames();
    if (mounted) {
      setState(() {
        _allNames = names;
        _filteredNames = names;
        _isLoading = false;
      });
    }
  }

  void _filterNames() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredNames = _allNames;
      } else {
        _filteredNames = _allNames.where((name) {
          return name.arabic.contains(query) ||
              name.english.toLowerCase().contains(query.toLowerCase()) ||
              name.kurdish.toLowerCase().contains(query.toLowerCase()) ||
              name.transliteration.toLowerCase().contains(query.toLowerCase()) ||
              name.id.toString().contains(query);
        }).toList();
      }
    });
  }

  void _showDetailModal(BuildContext context, int initialIndex, String lang, bool isRTL, bool showEnglish) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NameDetailModalSheet(
        names: _filteredNames,
        initialIndex: initialIndex,
        lang: lang,
        isRTL: isRTL,
        showEnglish: showEnglish,
        onToggleLanguage: () {
          setState(() {
            _showEnglishMode = !showEnglish;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    final isKurdish = lang == 'ku';
    final isRTL = lang == 'ar' || lang == 'ku';
    final bool showEnglish = _showEnglishMode ?? (lang == 'en');

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar with View Switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.panelColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.panelBorderColor),
                      ),
                      child: Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.cream),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc?.translate('namesOfAllah') ?? 'ناوی پیرۆزی خوای گەورە',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: isKurdish
                              ? AppTheme.kurdishTitle(fontSize: 18, color: AppColors.gold)
                              : AppTheme.englishTitle(fontSize: 18, color: AppColors.gold),
                        ),
                        Text(
                          'أسماء الله الحسنى - 99 Names',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.arabicText(fontSize: 12, color: AppColors.faintText),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // View Mode Toggle Segmented Pill (Grid / List)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.panelColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Square Grid View Button
                          GestureDetector(
                            onTap: () => _toggleViewMode(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isGridView ? AppColors.gold : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.grid_view_rounded,
                                    size: 16,
                                    color: _isGridView ? Colors.black : AppColors.gold,
                                  ),
                                  if (_isGridView) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      isKurdish ? 'چوارگۆشە' : 'Grid',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          // List View Button
                          GestureDetector(
                            onTap: () => _toggleViewMode(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: !_isGridView ? AppColors.gold : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.view_list_rounded,
                                    size: 16,
                                    color: !_isGridView ? Colors.black : AppColors.gold,
                                  ),
                                  if (!_isGridView) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      isKurdish ? 'لیست' : 'List',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ],
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                style: AppTheme.englishText(color: AppColors.cream),
                decoration: InputDecoration(
                  hintText: loc?.translate('search') ?? 'گەڕان لە ناواندا... / Search',
                  hintStyle: AppTheme.englishText(color: AppColors.veryFaintText, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.gold, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: AppColors.faintText, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.panelBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.panelBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.gold, width: 1.8),
                  ),
                  filled: true,
                  fillColor: AppColors.panelColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Main View Area (Grid vs List)
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                ),
              )
            else if (_filteredNames.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    loc?.translate('noResults') ?? 'هیچ ئەنجامێک نەدۆزرایەوە',
                    style: AppTheme.kurdishText(color: AppColors.cream, fontSize: 14),
                  ),
                ),
              )
            else if (_isGridView)
              // 🔳 Square Block Grid View Mode
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scale = MediaQuery.of(context).textScaler.scale(1.0);
                    final ratio = (0.88 / scale).clamp(0.72, 0.95);
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: ratio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredNames.length,
                      itemBuilder: (context, index) {
                        final name = _filteredNames[index];
                        return _NameOfAllahSquareCard(
                          name: name,
                          lang: lang,
                          isRTL: isRTL,
                          showEnglish: showEnglish,
                          onTap: () => _showDetailModal(context, index, lang, isRTL, showEnglish),
                        );
                      },
                    );
                  },
                ),
              )
            else
              // 📱 Classic List View Mode
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: _filteredNames.length,
                  itemBuilder: (context, index) {
                    final name = _filteredNames[index];
                    return _NameOfAllahListCard(
                      name: name,
                      lang: lang,
                      isRTL: isRTL,
                      showEnglish: showEnglish,
                      onToggleMeaning: () {
                        setState(() {
                          _showEnglishMode = !showEnglish;
                        });
                      },
                      onTap: () => _showDetailModal(context, index, lang, isRTL, showEnglish),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 🔳 Modern Square Block Card for Grid View
class _NameOfAllahSquareCard extends StatelessWidget {
  final NameOfAllah name;
  final String lang;
  final bool isRTL;
  final bool showEnglish;
  final VoidCallback onTap;

  const _NameOfAllahSquareCard({
    required this.name,
    required this.lang,
    required this.isRTL,
    required this.showEnglish,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meaning = showEnglish
        ? (name.english.isNotEmpty ? name.english : name.kurdish)
        : (name.kurdish.isNotEmpty ? name.kurdish : name.english);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.panelColor,
              AppColors.softSurface,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Decorative Gold Aura Corner Gradient
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Top Row: Number Badge & Detail Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            '#${name.id}',
                            style: AppTheme.englishText(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.open_in_full_rounded,
                          size: 14,
                          color: AppColors.gold.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Calligraphy Arabic Name
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        name.arabic,
                        textDirection: TextDirection.rtl,
                        style: AppTheme.arabicTitle(
                          fontSize: 22,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Transliteration
                    if (name.transliteration.isNotEmpty)
                      Text(
                        name.transliteration,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTheme.englishText(
                          color: AppColors.cream,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(),

                    // Meaning Footer Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Text(
                        meaning,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        style: lang == 'ku'
                            ? AppTheme.kurdishText(fontSize: 11, color: AppColors.cream)
                            : AppTheme.englishText(fontSize: 11, color: AppColors.cream),
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
}

/// 📱 Classic List View Card
class _NameOfAllahListCard extends StatelessWidget {
  final NameOfAllah name;
  final String lang;
  final bool isRTL;
  final bool showEnglish;
  final VoidCallback onToggleMeaning;
  final VoidCallback onTap;

  const _NameOfAllahListCard({
    required this.name,
    required this.lang,
    required this.isRTL,
    required this.showEnglish,
    required this.onToggleMeaning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.panelColor,
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    '#${name.id}',
                    style: AppTheme.englishText(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name.arabic,
                    textDirection: TextDirection.rtl,
                    style: AppTheme.arabicTitle(fontSize: 20, color: AppColors.gold),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            if (name.transliteration.isNotEmpty)
              Text(
                name.transliteration,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                style: AppTheme.englishText(
                  color: AppColors.cream,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 10),
            () {
              final hasKurdish = name.kurdish.trim().isNotEmpty;
              final hasEnglish = name.english.trim().isNotEmpty;
              final hasBoth = hasKurdish && hasEnglish;
              final bool isDisplayingEnglish = (showEnglish && hasEnglish) || !hasKurdish;
              final bool hasContent = hasKurdish || hasEnglish;
              final isKurdishLang = lang == 'ku';

              if (!hasContent) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: GestureDetector(
                              onTap: hasBoth
                                  ? () {
                                      AppHaptics.selectionClick();
                                      onToggleMeaning();
                                    }
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDisplayingEnglish
                                      ? const Color(0xFF3B82F6).withValues(alpha: 0.16)
                                      : AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDisplayingEnglish
                                        ? const Color(0xFF60A5FA).withValues(alpha: 0.45)
                                        : AppColors.gold.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isDisplayingEnglish
                                          ? Icons.language_rounded
                                          : Icons.menu_book_rounded,
                                      size: 13,
                                      color: isDisplayingEnglish
                                          ? const Color(0xFF93C5FD)
                                          : AppColors.gold,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isDisplayingEnglish
                                          ? (isKurdishLang
                                              ? 'مانای ئینگلیزی'
                                              : (lang == 'ar'
                                                  ? 'الترجمة بالإنجليزية'
                                                  : 'English Meaning'))
                                          : (isKurdishLang
                                              ? 'مانای کوردی'
                                              : (lang == 'ar'
                                                  ? 'المعنى بالكردية'
                                                  : 'Kurdish Meaning')),
                                      style: isDisplayingEnglish
                                          ? const TextStyle(
                                              fontSize: 10.5,
                                              color: Color(0xFF93C5FD),
                                              fontWeight: FontWeight.bold,
                                            )
                                          : AppTheme.kurdishText(
                                              fontSize: 10.5,
                                              color: AppColors.gold,
                                              fontWeight: FontWeight.bold,
                                            ),
                                    ),
                                    if (hasBoth) ...[
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: isDisplayingEnglish
                                              ? const Color(0xFF3B82F6).withValues(alpha: 0.25)
                                              : AppColors.gold.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.swap_horiz_rounded,
                                              size: 11,
                                              color: isDisplayingEnglish
                                                  ? const Color(0xFF93C5FD)
                                                  : AppColors.gold,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              isDisplayingEnglish
                                                  ? (isKurdishLang ? 'کوردی' : 'Kurdish')
                                                  : 'English',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: isDisplayingEnglish
                                                    ? const Color(0xFF93C5FD)
                                                    : AppColors.gold,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isDisplayingEnglish ? name.english : name.kurdish,
                      textAlign: isDisplayingEnglish ? TextAlign.left : TextAlign.right,
                      textDirection: isDisplayingEnglish ? TextDirection.ltr : TextDirection.rtl,
                      style: isDisplayingEnglish
                          ? AppTheme.englishText(
                              color: AppColors.cream.withValues(alpha: 0.95),
                              fontSize: 13,
                            ).copyWith(height: 1.5)
                          : AppTheme.kurdishText(
                              color: AppColors.cream.withValues(alpha: 0.95),
                              fontSize: 13,
                              height: 1.5,
                            ),
                    ),
                  ],
                ),
              );
            }(),
          ],
        ),
      ),
    );
  }
}

/// 📖 Full Details Modal Bottom Sheet with Swipe / Prev & Next Navigation
class _NameDetailModalSheet extends StatefulWidget {
  final List<NameOfAllah> names;
  final int initialIndex;
  final String lang;
  final bool isRTL;
  final bool showEnglish;
  final VoidCallback? onToggleLanguage;

  const _NameDetailModalSheet({
    Key? key,
    required this.names,
    required this.initialIndex,
    required this.lang,
    required this.isRTL,
    required this.showEnglish,
    this.onToggleLanguage,
  }) : super(key: key);

  @override
  State<_NameDetailModalSheet> createState() => _NameDetailModalSheetState();
}

class _NameDetailModalSheetState extends State<_NameDetailModalSheet> {
  late int _currentIndex;
  bool? _showEnglishMode;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _showEnglishMode = widget.showEnglish;
  }

  void _nextName() {
    if (_currentIndex < widget.names.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _previousName() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _copyToClipboard(NameOfAllah item) {
    final textToCopy = '${item.arabic} (${item.transliteration})\nکوردی: ${item.kurdish}\nEnglish: ${item.english}';
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('کۆپی کرا! • Copied to Clipboard'),
        backgroundColor: AppColors.gold,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.names[_currentIndex];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Header Row with Navigation Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentIndex > 0 ? _previousName : null,
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: _currentIndex > 0
                          ? AppColors.gold
                          : AppColors.veryFaintText,
                      size: 20,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.names.length}',
                      style: AppTheme.englishTitle(
                          fontSize: 13, color: AppColors.gold),
                    ),
                  ),
                  IconButton(
                    onPressed: _currentIndex < widget.names.length - 1
                        ? _nextName
                        : null,
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _currentIndex < widget.names.length - 1
                          ? AppColors.gold
                          : AppColors.veryFaintText,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Big Glowing Calligraphy Frame
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gold.withValues(alpha: 0.15),
                      AppColors.softSurface,
                      AppColors.panelColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      item.arabic,
                      textDirection: TextDirection.rtl,
                      style: AppTheme.arabicTitle(fontSize: 36, color: AppColors.gold),
                    ),
                    if (item.transliteration.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.transliteration,
                        style: AppTheme.englishTitle(fontSize: 16, color: AppColors.cream),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Meaning Details Box with Toggle
              () {
                final hasKurdish = item.kurdish.trim().isNotEmpty;
                final hasEnglish = item.english.trim().isNotEmpty;
                final hasBoth = hasKurdish && hasEnglish;
                final bool isDisplayingEnglish = (_showEnglishMode ?? widget.showEnglish)
                    ? (hasEnglish || !hasKurdish)
                    : (!hasKurdish);
                final isKurdishLang = widget.lang == 'ku';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.panelColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.panelBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: GestureDetector(
                                onTap: hasBoth
                                    ? () {
                                        AppHaptics.selectionClick();
                                        setState(() {
                                          _showEnglishMode = !isDisplayingEnglish;
                                        });
                                        widget.onToggleLanguage?.call();
                                      }
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDisplayingEnglish
                                        ? const Color(0xFF3B82F6).withValues(alpha: 0.16)
                                        : AppColors.gold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDisplayingEnglish
                                          ? const Color(0xFF60A5FA).withValues(alpha: 0.45)
                                          : AppColors.gold.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isDisplayingEnglish
                                            ? Icons.language_rounded
                                            : Icons.menu_book_rounded,
                                        size: 14,
                                        color: isDisplayingEnglish
                                            ? const Color(0xFF93C5FD)
                                            : AppColors.gold,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isDisplayingEnglish
                                            ? (isKurdishLang
                                                ? 'مانای ئینگلیزی'
                                                : (widget.lang == 'ar'
                                                    ? 'الترجمة بالإنجليزية'
                                                    : 'English Meaning'))
                                            : (isKurdishLang
                                                ? 'مانای کوردی'
                                                : (widget.lang == 'ar'
                                                    ? 'المعنى بالكردية'
                                                    : 'Kurdish Meaning')),
                                        style: isDisplayingEnglish
                                            ? const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF93C5FD),
                                                fontWeight: FontWeight.bold,
                                              )
                                            : AppTheme.kurdishText(
                                                fontSize: 11,
                                                color: AppColors.gold,
                                                fontWeight: FontWeight.bold,
                                              ),
                                      ),
                                      if (hasBoth) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: isDisplayingEnglish
                                                ? const Color(0xFF3B82F6).withValues(alpha: 0.25)
                                                : AppColors.gold.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.swap_horiz_rounded,
                                                size: 12,
                                                color: isDisplayingEnglish
                                                    ? const Color(0xFF93C5FD)
                                                    : AppColors.gold,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                isDisplayingEnglish
                                                    ? (isKurdishLang ? 'کوردی' : 'Kurdish')
                                                    : 'English',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  color: isDisplayingEnglish
                                                      ? const Color(0xFF93C5FD)
                                                      : AppColors.gold,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isDisplayingEnglish ? item.english : item.kurdish,
                        textAlign: isDisplayingEnglish ? TextAlign.left : TextAlign.right,
                        textDirection: isDisplayingEnglish ? TextDirection.ltr : TextDirection.rtl,
                        style: isDisplayingEnglish
                            ? AppTheme.englishText(
                                color: AppColors.cream,
                                fontSize: 15,
                              ).copyWith(height: 1.6)
                            : AppTheme.kurdishText(
                                color: AppColors.cream,
                                fontSize: 15,
                                height: 1.6,
                              ),
                      ),
                    ],
                  ),
                );
              }(),

              const SizedBox(height: 20),

              // Action Buttons (Copy / Close)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                        foregroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
                        ),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('کۆپیکردن • Copy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.panelColor,
                        foregroundColor: AppColors.cream,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.panelBorderColor),
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('داخستن • Close', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
