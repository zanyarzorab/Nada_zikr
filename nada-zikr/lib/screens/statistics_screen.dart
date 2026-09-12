import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/azkar_model.dart';
import '../models/weekly_activity_model.dart';
import '../services/app_haptics.dart';
import '../services/app_share_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<_DetailedStats> _statsFuture;
  String _selectedAchievementCategory = 'all';
  int? _selectedHeatmapIndex;
  String _weeklyViewMode = 'chart'; // 'chart' or 'table'
  int? _selectedWeeklyDayIndex;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadFullStats();
  }

  Future<void> _onRefresh() async {
    AppHaptics.selectionClick();
    final lang = AppLocalizations.of(context)?.locale.languageCode ?? 'ku';
    setState(() {
      _statsFuture = _loadFullStats(lang);
    });
    await _statsFuture;
  }

  Future<_DetailedStats> _loadFullStats([String? currentLang]) async {
    final stats = await StorageService.getStatistics();
    final profile = await StorageService.getUserProfile();
    final allZikrCounts = await StorageService.readAllZikr();
    final favoriteCards = await StorageService.readFavoriteMoodCards();
    final isKurdishOrArabic = currentLang != 'en';
    final weeklyReport = await StorageService.getWeeklyActivityReport(
      startOnSaturday: isKurdishOrArabic,
    );

    int totalDhikrCount = 0;
    for (final count in allZikrCounts.values) {
      totalDhikrCount += count;
    }

    final now = DateTime.now();
    final isDoneToday = profile.lastSessionDate.year == now.year &&
        profile.lastSessionDate.month == now.month &&
        profile.lastSessionDate.day == now.day;

    return _DetailedStats(
      appStats: stats,
      profile: profile,
      totalDhikrCount: totalDhikrCount,
      savedFavoritesCount: favoriteCards.length,
      weeklyCounts: weeklyReport.days.map((d) => d.totalCount).toList(),
      weeklyReport: weeklyReport,
      isDoneToday: isDoneToday,
    );
  }

  String _tr(String lang, {required String ku, required String ar, required String en}) {
    if (lang == 'ku') return ku;
    if (lang == 'ar') return ar;
    return en;
  }

  void _shareSpiritualProgress(_DetailedStats data, String lang) {
    final isKurdish = lang == 'ku';
    final isArabic = lang == 'ar';
    final rank = _getSpiritualRank(data.totalDhikrCount, data.appStats.totalSessions, lang);
    final userName = data.profile != null && data.profile!.name.trim().isNotEmpty
        ? '${data.profile!.name} • '
        : '';

    final text = isKurdish
        ? '📿 ئامارە ڕۆحییەکانم لە بەرنامەی (نەدا - Nada):\n\n'
            '✨ ناوی شایستە: $userName${rank.title}\n'
            '🎖️ پلە: ${rank.tierBadge}\n'
            '📌 مەرج: ${rank.requirementText}\n'
            '🔥 بەردەوامی: ${data.appStats.currentStreak} ڕۆژ\n'
            '📿 کۆی یادەکان: ${data.totalDhikrCount} جار\n'
            '🏆 باشترین تۆمار: ${data.appStats.bestStreak} ڕۆژ\n\n'
            'یاوەری ڕۆحی بۆ یاد و دوعاکانی ڕۆژانە 🌟'
        : isArabic
            ? '📿 إحصائياتي الإيمانية في تطبيق (نَدَى - Nada):\n\n'
                '✨ اللقب الإيماني: $userName${rank.title}\n'
                '🎖️ الرتبة: ${rank.tierBadge}\n'
                '📌 المتطلب: ${rank.requirementText}\n'
                '🔥 السلسلة الحالية: ${data.appStats.currentStreak} أيام\n'
                '📿 إجمالي الأذكار: ${data.totalDhikrCount} ذكر\n'
                '🏆 أفضل مواظبة: ${data.appStats.bestStreak} أيام\n\n'
                'رفيقك الإيماني للأذكار والدعاء 🌟'
            : '📿 My Spiritual Progress on Nada App:\n\n'
                '✨ Spiritual Title: $userName${rank.title}\n'
                '🎖️ Tier: ${rank.tierBadge}\n'
                '📌 Requirement: ${rank.requirementText}\n'
                '🔥 Current Streak: ${data.appStats.currentStreak} Days\n'
                '📿 Total Dhikrs: ${data.totalDhikrCount}\n'
                '🏆 Best Streak: ${data.appStats.bestStreak} Days\n\n'
                'Daily Dhikr & Quran Companion 🌟';

    AppShareService.share(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.languageCode;
    final isKurdish = lang == 'ku';
    final isArabic = lang == 'ar';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _tr(lang, ku: 'ئامارە ڕۆحییەکان', ar: 'الإحصائيات الإيمانية', en: 'Statistics'),
          style: isKurdish
              ? AppTheme.kurdishTitle(fontSize: 20, color: AppColors.gold)
              : AppTheme.englishTitle(fontSize: 20, color: AppColors.gold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final data = await _statsFuture;
              _shareSpiritualProgress(data, lang);
            },
            icon: Icon(Icons.share_rounded, color: AppColors.gold, size: 20),
            tooltip: _tr(lang, ku: 'بارکردنی دەستکەوت', ar: 'مشاركة الإنجازات', en: 'Share Progress'),
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkBg, AppColors.darkBgAlt, AppColors.panelColor],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_DetailedStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );
              }

              final data = snapshot.data!;
              final stats = data.appStats;
              final currentStreak = stats.currentStreak;
              final bestStreak = stats.bestStreak;
              final totalSessions = stats.totalSessions;
              final totalDhikr = data.totalDhikrCount;

              final rankInfo = _getSpiritualRank(totalDhikr, totalSessions, lang);

              return RefreshIndicator(
                color: AppColors.gold,
                backgroundColor: AppColors.darkPanel,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Goal / Streak Alert Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: data.isDoneToday
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : Colors.amber.shade900.withValues(alpha: 0.25),
                        border: Border.all(
                          color: data.isDoneToday ? AppColors.gold : Colors.amber.shade700,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            data.isDoneToday
                                ? Icons.check_circle_rounded
                                : Icons.local_fire_department_rounded,
                            size: 24,
                            color: data.isDoneToday
                                ? AppColors.gold
                                : Colors.amber.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.isDoneToday
                                      ? _tr(lang, ku: 'ئامانجی ئەمڕۆ تەواو کرا!', ar: 'تم إنجاز هدف اليوم!', en: 'Today\'s Goal Achieved!')
                                      : _tr(
                                          lang,
                                          ku: 'زنجیرەی $currentStreak ڕۆژەت بپارێزە!',
                                          ar: 'حافظ على سلسلة $currentStreak أيام!',
                                          en: 'Keep your $currentStreak-day streak alive!',
                                        ),
                                  style: isKurdish
                                      ? AppTheme.kurdishTitle(fontSize: 14, color: AppColors.cream)
                                      : AppTheme.englishText(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  data.isDoneToday
                                      ? _tr(lang, ku: 'پاداشتی دەستکەوتی ئەمڕۆت تۆمار کرا', ar: 'تم تسجيل أجر إنجازك اليوم', en: 'Your daily progress has been recorded')
                                      : _tr(lang, ku: 'ئەمڕۆ زیکرەکانت تەواو بکە تا زنجیرەکەت نەکەوێت', ar: 'أكمل أذكار اليوم لإبقاء المواظبة مستمرة', en: 'Complete dhikr today to maintain streak'),
                                  style: AppTheme.englishText(fontSize: 11, color: AppColors.faintText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Spiritual Rank Header Card (With Real Connectivity to User Name & Level Progress)
                    GestureDetector(
                      onTap: () => _showRankRoadmapSheet(context, data, lang, isKurdish),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              rankInfo.accentColor.withValues(alpha: 0.24),
                              AppColors.panelColor,
                              AppColors.darkBgAlt,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: rankInfo.accentColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: rankInfo.accentColor.withValues(alpha: 0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Avatar Icon + User Name & Honorific Title + Tier Badge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 62,
                                  height: 62,
                                  decoration: BoxDecoration(
                                    color: rankInfo.accentColor.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: rankInfo.accentColor, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: rankInfo.accentColor.withValues(alpha: 0.3),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(rankInfo.iconData, size: 30, color: rankInfo.accentColor),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: rankInfo.accentColor.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: rankInfo.accentColor.withValues(alpha: 0.45)),
                                            ),
                                            child: Text(
                                              rankInfo.tierBadge,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: rankInfo.accentColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          // Requirement Tag
                                          Flexible(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: rankInfo.accentColor.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: rankInfo.accentColor.withValues(alpha: 0.3)),
                                              ),
                                              child: Text(
                                                '📌 ${rankInfo.requirementText}',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: rankInfo.accentColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${(rankInfo.progressPercent * 100).toInt()}%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: rankInfo.accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // User Name + Spiritual Title with Real Connectivity
                                      Text(
                                        data.profile != null && data.profile!.name.trim().isNotEmpty
                                            ? '${data.profile!.name} • ${rankInfo.title}'
                                            : rankInfo.title,
                                        style: isKurdish
                                            ? AppTheme.kurdishTitle(fontSize: 17, color: AppColors.cream)
                                            : AppTheme.englishTitle(fontSize: 17, color: AppColors.cream),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        rankInfo.subtitle,
                                        style: isKurdish
                                            ? AppTheme.kurdishText(fontSize: 11, color: AppColors.mutedText)
                                            : AppTheme.englishText(fontSize: 11, color: AppColors.mutedText),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Real Connectivity: Progress Bar to Next Rank
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: rankInfo.progressPercent,
                                minHeight: 8,
                                backgroundColor: AppColors.darkBg.withValues(alpha: 0.7),
                                valueColor: AlwaysStoppedAnimation<Color>(rankInfo.accentColor),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Milestone Countdown Text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${data.totalDhikrCount} / ${rankInfo.targetProgress} ${_tr(lang, ku: 'یاد', ar: 'ذكر', en: 'dhikr')}',
                                  style: AppTheme.englishText(fontSize: 11, color: AppColors.mutedText),
                                ),
                                if (!rankInfo.isMaxLevel && rankInfo.nextRankTitle != null)
                                  Flexible(
                                    child: Text(
                                      isKurdish
                                          ? '${rankInfo.remainingToNext} یادت ماوە بۆ «${rankInfo.nextRankTitle}»'
                                          : (isArabic
                                              ? 'باقي ${rankInfo.remainingToNext} ذكر لبلوغ «${rankInfo.nextRankTitle}»'
                                              : '${rankInfo.remainingToNext} dhikrs to «${rankInfo.nextRankTitle}»'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: rankInfo.accentColor,
                                      ),
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                else
                                  Text(
                                    _tr(lang, ku: 'لوتکەی پلەی یاد بەدەستهێنرا 👑', ar: 'بلغت أعلى المراتب 👑', en: 'Pinnacle achieved 👑'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: rankInfo.accentColor,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Interactive Rank Roadmap Trigger
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                              decoration: BoxDecoration(
                                color: rankInfo.accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: rankInfo.accentColor.withValues(alpha: 0.35)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.workspace_premium_rounded, size: 16, color: rankInfo.accentColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    _tr(lang,
                                        ku: 'بینینی هەموو ٨ ئاستەکە و مەرجەکانیان',
                                        ar: 'عرض جميع الرتب الـ 8 وشروط بلوغها',
                                        en: 'View all 8 ranks & how to unlock them'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: rankInfo.accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    isKurdish ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                                    size: 16,
                                    color: rankInfo.accentColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Primary 4 Stat Counters Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          _tr(lang, ku: 'کۆی زیکرەکان', ar: 'إجمالي الأذكار', en: 'Total Dhikrs'),
                          '$totalDhikr',
                          _tr(lang, ku: 'دەنک زیکر', ar: 'ذكر', en: 'recitations'),
                          Icons.touch_app_rounded,
                          isKurdish,
                        ),
                        _buildStatCard(
                          _tr(lang, ku: 'بەردەوامیی ئێستا', ar: 'المواظبة الحالية', en: 'Current Streak'),
                          '$currentStreak',
                          _tr(lang, ku: 'ڕۆژی بەردەوام', ar: 'أيام متتالية', en: 'consecutive days'),
                          Icons.local_fire_department_rounded,
                          isKurdish,
                        ),
                        _buildStatCard(
                          _tr(lang, ku: 'باشترین بەردەوامی', ar: 'أفضل مواظبة', en: 'Best Streak'),
                          '$bestStreak',
                          _tr(lang, ku: 'تۆماری پێشوو', ar: 'رقم قياسي', en: 'days record'),
                          Icons.emoji_events_rounded,
                          isKurdish,
                        ),
                        _buildStatCard(
                          _tr(lang, ku: 'کۆی دانیشتنەکان', ar: 'الجلسات المكتملة', en: 'Completed Sessions'),
                          '$totalSessions',
                          _tr(lang, ku: 'تەواوکاری', ar: 'جلسة مكتملة', en: 'sessions done'),
                          Icons.task_alt_rounded,
                          isKurdish,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Interactive Weekly Activity (Dual-Mode: Visual Chart & Detailed Table)
                    _buildWeeklyActivitySection(data, lang, isKurdish),

                    const SizedBox(height: 24),

                    // 12-Week Consistency Matrix Map (Perfect 12-Week x 7-Day Architecture)
                    _build12WeekConsistencyMap(stats, lang, isKurdish),

                    const SizedBox(height: 24),

                    // Spiritual Milestones & Achievements Section
                    _buildAchievementsSection(data, lang, isKurdish),
                  ],
                ),
              ),
            );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyActivitySection(
    _DetailedStats data,
    String lang,
    bool isKurdish,
  ) {
    final report = data.weeklyReport;
    final todayIndex = report.days.indexWhere((d) => d.isToday);
    final selectedDayIndex = (_selectedWeeklyDayIndex != null &&
            _selectedWeeklyDayIndex! >= 0 &&
            _selectedWeeklyDayIndex! < report.days.length)
        ? _selectedWeeklyDayIndex!
        : (todayIndex != -1 ? todayIndex : 0);
    final selectedDay = report.days[selectedDayIndex];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        border: Border.all(color: AppColors.panelBorderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title, Subtitle, and View Mode Segmented Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.leaderboard_rounded,
                            size: 18, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Text(
                          _tr(lang,
                              ku: 'چالاکیی هەفتانە',
                              ar: 'النشاط الأسبوعي',
                              en: 'Weekly Activity'),
                          style: isKurdish
                              ? AppTheme.kurdishTitle(
                                  fontSize: 15, color: AppColors.gold)
                              : AppTheme.englishText(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _tr(lang,
                          ku: 'شیکاریی ئەم هەفتەیە بەپێی ڕۆژەکان',
                          ar: 'تحليل هذا الأسبوع بحسب الأيام',
                          en: 'Current week daily breakdown'),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.faintText,
                      ),
                    ),
                  ],
                ),
              ),

              // Segmented Switcher Pill (Chart vs Table)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.darkBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWeeklyModeButton(
                      mode: 'chart',
                      icon: Icons.bar_chart_rounded,
                      label: _tr(lang, ku: 'چارت', ar: 'رسم', en: 'Chart'),
                      isSelected: _weeklyViewMode == 'chart',
                    ),
                    _buildWeeklyModeButton(
                      mode: 'table',
                      icon: Icons.table_chart_rounded,
                      label: _tr(lang, ku: 'خشتە', ar: 'جدول', en: 'Table'),
                      isSelected: _weeklyViewMode == 'table',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4-Pill Weekly Summary Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkBg.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeeklySummaryPill(
                  label: _tr(lang, ku: 'کۆی هەفتە', ar: 'المجموع', en: 'Total'),
                  value: '${report.totalCount}',
                  icon: Icons.touch_app_rounded,
                ),
                _buildWeeklySummaryPill(
                  label: _tr(lang, ku: 'تێکڕا', ar: 'المعدل', en: 'Average'),
                  value: report.dailyAverage.toStringAsFixed(0),
                  icon: Icons.trending_up_rounded,
                ),
                _buildWeeklySummaryPill(
                  label: _tr(lang, ku: 'لووتکە', ar: 'الأعلى', en: 'Peak'),
                  value: '${report.maxDayCount}',
                  icon: Icons.emoji_events_rounded,
                ),
                _buildWeeklySummaryPill(
                  label: _tr(lang, ku: 'مواظبە', ar: 'المواظبة', en: 'Rate'),
                  value: '${report.consistencyPercent}%',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Conditional View: Animated Switcher between Chart and Table
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _weeklyViewMode == 'chart'
                ? _buildWeeklyChartView(
                    report, selectedDayIndex, selectedDay, lang, isKurdish)
                : _buildWeeklyTableView(
                    report, selectedDayIndex, lang, isKurdish),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyModeButton({
    required String mode,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        AppHaptics.selectionClick();
        setState(() {
          _weeklyViewMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.darkBg : AppColors.faintText,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.darkBg : AppColors.faintText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryPill({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.gold),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.faintText,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChartView(
    WeeklyActivityReport report,
    int selectedIndex,
    DailyActivitySummary selectedDay,
    String lang,
    bool isKurdish,
  ) {
    final maxVal = report.maxDayCount > 0 ? report.maxDayCount : 1;

    return Column(
      key: const ValueKey('weekly_chart_view'),
      children: [
        SizedBox(
          height: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final day = report.days[i];
              final isToday = day.isToday;
              final isSelected = selectedIndex == i;
              final count = day.totalCount;
              final barHeight = count > 0
                  ? ((count / maxVal) * 85).clamp(24.0, 90.0)
                  : 12.0;

              return GestureDetector(
                onTap: () {
                  AppHaptics.selectionClick();
                  setState(() {
                    _selectedWeeklyDayIndex = i;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Exact count badge above active bars
                      if (count > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.mutedText,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 15),

                      // Bar container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: barHeight,
                        width: 18,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.gold
                              : (isToday
                                  ? AppColors.gold.withValues(alpha: 0.8)
                                  : (count > 0
                                      ? AppColors.gold.withValues(alpha: 0.35)
                                      : AppColors.darkBgAlt)),
                          borderRadius: BorderRadius.circular(6),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 1.5)
                              : (isToday
                                  ? Border.all(color: AppColors.gold, width: 1)
                                  : null),
                          boxShadow: (isSelected || isToday)
                              ? [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.4),
                                    blurRadius: isSelected ? 8 : 4,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Day of week short label
                      Text(
                        day.getDayShort(lang),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? AppColors.gold : AppColors.faintText),
                        ),
                      ),
                      // Date label (e.g. 29/8)
                      Text(
                        '${day.date.day}/${day.date.month}',
                        style: TextStyle(
                          fontSize: 8,
                          color: isSelected ? AppColors.gold : AppColors.veryFaintText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),

        // Interactive Day Inspection Card
        _buildDayInspectionCard(selectedDay, lang, isKurdish),
      ],
    );
  }

  Widget _buildWeeklyTableView(
    WeeklyActivityReport report,
    int selectedIndex,
    String lang,
    bool isKurdish,
  ) {
    final maxVal = report.maxDayCount > 0 ? report.maxDayCount : 1;

    return Column(
      key: const ValueKey('weekly_table_view'),
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.darkBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  _tr(lang, ku: 'ڕۆژ / بەروار', ar: 'اليوم / التاريخ', en: 'Day / Date'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  _tr(lang, ku: 'ژمارەی یاد', ar: 'عدد الأذكار', en: 'Dhikr Count'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _tr(lang, ku: 'دانیشتن', ar: 'الجلسات', en: 'Sessions'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  _tr(lang, ku: 'دۆخ', ar: 'الحالة', en: 'Status'),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // 7 Day Rows
        ...List.generate(7, (i) {
          final day = report.days[i];
          final isSelected = selectedIndex == i;
          final ratio = (day.totalCount / maxVal).clamp(0.0, 1.0);

          return GestureDetector(
            onTap: () {
              AppHaptics.selectionClick();
              setState(() {
                _selectedWeeklyDayIndex = i;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold.withValues(alpha: 0.12)
                    : (day.isToday
                        ? AppColors.gold.withValues(alpha: 0.06)
                        : AppColors.darkBg.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.gold
                      : (day.isToday
                          ? AppColors.gold.withValues(alpha: 0.4)
                          : Colors.transparent),
                  width: isSelected ? 1.2 : 0.8,
                ),
              ),
              child: Row(
                children: [
                  // Day & Date Column
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              day.getDayName(lang),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: day.isToday || isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: day.isToday
                                    ? AppColors.gold
                                    : AppColors.cream,
                              ),
                            ),
                            if (day.isToday) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${day.date.day}/${day.date.month}',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.faintText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dhikr Count & Progress Bar Column
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${day.totalCount} ${_tr(lang, ku: 'یاد', ar: 'ذكر', en: 'dhikr')}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: day.totalCount > 0
                                  ? AppColors.cream
                                  : AppColors.veryFaintText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 4,
                              backgroundColor: AppColors.darkBg,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                day.isToday
                                    ? AppColors.gold
                                    : AppColors.gold.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sessions Column
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        '${day.sessionsCount}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: day.sessionsCount > 0
                              ? AppColors.cream
                              : AppColors.veryFaintText,
                        ),
                      ),
                    ),
                  ),

                  // Status Badge Column
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _buildDayStatusBadge(day, lang),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 8),

        // Selected Day Inspection Card in Table view
        _buildDayInspectionCard(report.days[selectedIndex], lang, isKurdish),
      ],
    );
  }

  Widget _buildDayStatusBadge(DailyActivitySummary day, String lang) {
    final bool isCompleted = day.totalCount >= 100;
    final bool isActive = day.totalCount > 0;
    final bool isToday = day.isToday;
    final bool isFuture = day.isFuture;

    final Color badgeColor;
    final String label;
    final IconData icon;

    if (isCompleted) {
      badgeColor = const Color(0xFF10B981); // Emerald
      label = _tr(lang, ku: 'تەواو', ar: 'مكتمل', en: 'Done');
      icon = Icons.check_circle_rounded;
    } else if (isActive) {
      badgeColor = AppColors.gold;
      label = _tr(lang, ku: 'چالاک', ar: 'نشط', en: 'Active');
      icon = Icons.bolt_rounded;
    } else if (isToday) {
      badgeColor = Colors.lightBlueAccent;
      label = _tr(lang, ku: 'ئەمڕۆ', ar: 'اليوم', en: 'Today');
      icon = Icons.hourglass_top_rounded;
    } else if (isFuture) {
      badgeColor = AppColors.faintText;
      label = _tr(lang, ku: 'داهاتوو', ar: 'قادم', en: 'Upcoming');
      icon = Icons.schedule_rounded;
    } else {
      badgeColor = AppColors.veryFaintText;
      label = _tr(lang, ku: 'پشوو', ar: 'راحة', en: 'Rest');
      icon = Icons.remove_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: badgeColor.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayInspectionCard(
    DailyActivitySummary day,
    String lang,
    bool isKurdish,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 13, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text(
                    '${day.getDayName(lang)} (${day.date.day}/${day.date.month}/${day.date.year})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                  if (day.isToday) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _tr(lang, ku: 'ئەمڕۆ', ar: 'اليوم', en: 'Today'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBg,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '${day.totalCount} ${_tr(lang, ku: 'یاد', ar: 'ذكر', en: 'dhikr')}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (day.totalCount > 0) ...[
            Text(
              '${_tr(lang, ku: 'دانیشتنەکان', ar: 'الجلسات', en: 'Completed sessions')}: ${day.sessionsCount}',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.faintText,
              ),
            ),
            if (day.topZikrs.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: day.topZikrs.map((zikrTitle) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      zikrTitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.cream,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ] else ...[
            Text(
              day.isFuture
                  ? _tr(lang,
                      ku: 'ئەم ڕۆژە هێشتا نەهاتووە ⏳',
                      ar: 'هذا اليوم لم يأتِ بعد ⏳',
                      en: 'This day has not arrived yet ⏳')
                  : _tr(lang,
                      ku: 'هیچ زیکرێک لەم ڕۆژەدا تۆمار نەکراوە ✨',
                      ar: 'لا توجد أذكار مسجلة في هذا اليوم ✨',
                      en: 'No dhikrs recorded on this day ✨'),
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: AppColors.faintText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getHeatmapTooltip(DateTime date, int level, String lang) {
    final now = DateTime.now();
    final isToday = now.difference(date).inDays == 0 && now.day == date.day;
    final dateStr = '${date.day}/${date.month}';

    String levelStr;
    if (level == 0) {
      levelStr = _tr(lang, ku: 'هیچ یادێک تۆمار نەکراوە', ar: 'لا توجد أذكار مسجلة', en: 'No dhikr recorded');
    } else if (level == 1) {
      levelStr = _tr(lang, ku: '١ - ٤ یاد ✨', ar: '١ - ٤ أذكار ✨', en: '1 - 4 dhikrs ✨');
    } else if (level == 2) {
      levelStr = _tr(lang, ku: '٥ - ١٩ یاد 🌟', ar: '٥ - ١٩ ذكر 🌟', en: '5 - 19 dhikrs 🌟');
    } else if (level == 3) {
      levelStr = _tr(lang, ku: '٢٠ - ٤٩ یاد 💫', ar: '٢٠ - ٤٩ ذكر 💫', en: '20 - 49 dhikrs 💫');
    } else {
      levelStr = _tr(lang, ku: '٥٠+ یادی تەواو 👑', ar: '٥٠+ ذكر مبارك 👑', en: '50+ dhikrs 👑');
    }

    if (isToday) {
      return _tr(lang,
          ku: 'ئەمڕۆ ($dateStr): $levelStr',
          ar: 'اليوم ($dateStr): $levelStr',
          en: 'Today ($dateStr): $levelStr');
    }
    return '$dateStr: $levelStr';
  }

  Widget _build12WeekConsistencyMap(AppStatistics stats, String lang, bool isKurdish) {
    final isArabic = lang == 'ar';
    final heatmapData = stats.heatmapData;
    final activeDays = heatmapData.where((v) => v > 0).length;
    final activePercent = (activeDays / 84 * 100).toInt();

    final selectedIndex = _selectedHeatmapIndex ?? 83;
    final daysAgo = 83 - selectedIndex;
    final selectedDate = DateTime.now().subtract(Duration(days: daysAgo));
    final selectedLevel = (selectedIndex < heatmapData.length ? heatmapData[selectedIndex] : 0).clamp(0, 4);

    final colors = [
      AppColors.darkBgAlt,
      AppColors.gold.withValues(alpha: 0.25),
      AppColors.gold.withValues(alpha: 0.50),
      AppColors.gold.withValues(alpha: 0.75),
      AppColors.gold,
    ];

    // Day labels for the 7 rows: Saturday through Friday
    final dayLabels = isKurdish
        ? ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'هـ']
        : (isArabic
            ? ['س', 'أ', 'إ', 'ث', 'ع', 'خ', 'ج']
            : ['S', 'S', 'M', 'T', 'W', 'T', 'F']);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        border: Border.all(color: AppColors.panelBorderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + Active Days Badge
          Row(
            children: [
              Icon(Icons.calendar_view_week_rounded, size: 20, color: AppColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _tr(lang,
                      ku: 'نەخشەی بەردەوامیی ١٢ هەفتە',
                      ar: 'خريطة المواظبة (١٢ أسبوعًا)',
                      en: '12-Week Consistency Map'),
                  style: isKurdish
                      ? AppTheme.kurdishTitle(fontSize: 14, color: AppColors.gold)
                      : AppTheme.englishText(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$activeDays/84 ${_tr(lang, ku: 'ڕۆژ', ar: 'يوم', en: 'days')} ($activePercent%)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 12-Week Columns x 7-Day Rows with Day Labels
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of week labels (alternating to remain tidy)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (d) {
                    final showLabel = d % 2 == 0;
                    return Container(
                      height: 16,
                      margin: const EdgeInsets.only(bottom: 4),
                      alignment: Alignment.center,
                      child: Text(
                        showLabel ? dayLabels[d] : '',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.faintText,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(width: 6),

              // 12 Columns (Each column is 1 full 7-day week)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(12, (w) {
                    return Column(
                      children: List.generate(7, (d) {
                        final index = w * 7 + d;
                        final level = (index < heatmapData.length ? heatmapData[index] : 0).clamp(0, 4);
                        final isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedHeatmapIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: colors[level],
                              borderRadius: BorderRadius.circular(4),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 1.5)
                                  : (level > 0 ? Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 0.5) : null),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.gold.withValues(alpha: 0.5),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Selected Day Interactive Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.darkBgAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app_rounded, size: 13, color: AppColors.gold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _getHeatmapTooltip(selectedDate, selectedLevel, lang),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.cream,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Timeline Footer with Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tr(lang, ku: '١٢ هەفتە پێشتر', ar: 'قبل 12 أسبوعًا', en: '12 weeks ago'),
                style: AppTheme.englishText(fontSize: 10, color: AppColors.veryFaintText),
              ),
              // Legend
              Row(
                children: [
                  Text(
                    _tr(lang, ku: 'کەمتر', ar: 'أقل', en: 'Less'),
                    style: AppTheme.englishText(fontSize: 9, color: AppColors.veryFaintText),
                  ),
                  const SizedBox(width: 4),
                  for (final c in colors)
                    Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Text(
                    _tr(lang, ku: 'زۆرتر', ar: 'أكثر', en: 'More'),
                    style: AppTheme.englishText(fontSize: 9, color: AppColors.veryFaintText),
                  ),
                ],
              ),
              Text(
                _tr(lang, ku: 'ئەمڕۆ', ar: 'اليوم', en: 'Today'),
                style: AppTheme.englishText(fontSize: 10, color: AppColors.veryFaintText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, bool isKurdish) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        border: Border.all(color: AppColors.panelBorderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 22, color: AppColors.gold),
              Text(
                value,
                style: AppTheme.englishTitle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isKurdish
                    ? AppTheme.kurdishText(fontSize: 12, color: AppColors.cream, fontWeight: FontWeight.bold)
                    : AppTheme.englishText(fontSize: 12, color: AppColors.cream, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: AppTheme.englishText(fontSize: 10, color: AppColors.faintText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(_DetailedStats data, String lang, bool isKurdish) {
    final isArabic = lang == 'ar';
    final allAchievements = _getAchievementsList(data, lang);
    final unlockedCount = allAchievements.where((a) => a.isUnlocked).length;
    final totalCount = allAchievements.length;
    final overallProgress = totalCount > 0 ? (unlockedCount / totalCount) : 0.0;

    final filteredAchievements = _selectedAchievementCategory == 'all'
        ? allAchievements
        : allAchievements.where((a) => a.category == _selectedAchievementCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(lang, ku: 'دەستکەوتە ڕۆحییەکان', ar: 'الإنجازات الإيمانية', en: 'Spiritual Milestones'),
              style: isKurdish
                  ? AppTheme.kurdishTitle(fontSize: 16, color: AppColors.gold)
                  : (isArabic
                      ? AppTheme.arabicTitle(fontSize: 16, color: AppColors.gold)
                      : AppTheme.englishTitle(fontSize: 16, color: AppColors.gold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Text(
                '$unlockedCount / $totalCount',
                style: AppTheme.englishText(
                  fontSize: 12,
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Overall Progress Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.panelColor,
            border: Border.all(color: AppColors.panelBorderColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, size: 22, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tr(
                        lang,
                        ku: '$unlockedCount لە $totalCount نیشانەی ڕۆحی بەدەستهاتووە',
                        ar: 'تم إنجاز $unlockedCount من أصل $totalCount إنجازات إيمانية',
                        en: '$unlockedCount of $totalCount spiritual milestones unlocked',
                      ),
                      style: isKurdish
                          ? AppTheme.kurdishText(
                              fontSize: 12,
                              color: AppColors.cream,
                              fontWeight: FontWeight.w600,
                            )
                          : (isArabic
                              ? AppTheme.arabicText(
                                  fontSize: 12,
                                  color: AppColors.cream,
                                )
                              : AppTheme.englishText(
                                  fontSize: 12,
                                  color: AppColors.cream,
                                  fontWeight: FontWeight.w600,
                                )),
                    ),
                  ),
                  Text(
                    '${(overallProgress * 100).toInt()}%',
                    style: AppTheme.englishText(
                      fontSize: 12,
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: overallProgress,
                  minHeight: 6,
                  backgroundColor: AppColors.darkBgAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('all', _tr(lang, ku: 'هەمووی', ar: 'الكل', en: 'All'), lang, isKurdish),
              const SizedBox(width: 8),
              _buildCategoryChip('journey', _tr(lang, ku: '🌱 سەرەتا', ar: '🌱 البداية', en: '🌱 Journey'), lang, isKurdish),
              const SizedBox(width: 8),
              _buildCategoryChip('streak', _tr(lang, ku: '🔥 بەردەوامی', ar: '🔥 المواظبة', en: '🔥 Streak'), lang, isKurdish),
              const SizedBox(width: 8),
              _buildCategoryChip('dhikr', _tr(lang, ku: '📿 تەسبیحات', ar: '📿 الأذكار', en: '📿 Tasbih'), lang, isKurdish),
              const SizedBox(width: 8),
              _buildCategoryChip('quran', _tr(lang, ku: '📖 قورئان', ar: '📖 القرآن', en: '📖 Quran'), lang, isKurdish),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Interactive Achievement Cards Horizontal Carousel
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filteredAchievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              return _buildInteractiveAchievementCard(filteredAchievements[i], lang, isKurdish);
            },
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCategoryChip(String catId, String label, String lang, bool isKurdish) {
    final isSelected = _selectedAchievementCategory == catId;
    final isArabic = lang == 'ar';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAchievementCategory = catId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.panelColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.panelBorderColor,
          ),
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
        ),
      ),
    );
  }

  List<_SpiritualAchievement> _getAchievementsList(_DetailedStats data, String lang) {
    final totalSessions = data.appStats.totalSessions;
    final currentStreak = data.appStats.currentStreak;
    final totalDhikr = data.totalDhikrCount;
    final savedCards = data.savedFavoritesCount;

    return [
      // 1. Journey: First Step
      _SpiritualAchievement(
        id: 'first_step',
        category: 'journey',
        categoryKu: 'گەشتی سەرەتا',
        categoryAr: 'بداية الرحلة',
        categoryEn: 'Journey',
        titleKu: 'سەرەتای نوور',
        titleAr: 'فجر البداية',
        titleEn: 'Dawn of Light',
        descKu: 'تەواوکردنی یەکەمین دانیشتنی زیکر و پاڕانەوە لە ئەپەکەدا',
        descAr: 'إكمال أول جلسة ذكر واستغفار في التطبيق',
        descEn: 'Complete your first dhikr session in Nada',
        hadithKu: '«خۆشەویستترین کردەوە لای خوا ئەوەیە کە بەردەوام بێت هەرچەندە کەمیش بێت.»',
        hadithAr: '«أحب الأعمال إلى الله أدومها وإن قل»',
        hadithEn: '“The most beloved of deeds to Allah are those that are consistent, even if small.”',
        icon: Icons.eco_rounded,
        targetValue: 1,
        currentValue: totalSessions,
        unitKu: 'دانیشتن',
        unitAr: 'جلسة',
        unitEn: 'Session',
      ),

      // 2. Journey: Daily Companion
      _SpiritualAchievement(
        id: 'daily_companion',
        category: 'journey',
        categoryKu: 'گەشتی سەرەتا',
        categoryAr: 'بداية الرحلة',
        categoryEn: 'Journey',
        titleKu: 'هاوڕێی ڕۆژانە',
        titleAr: 'الرفيق اليومي',
        titleEn: 'Daily Companion',
        descKu: 'ئەنجامدانی 5 دانیشتنی پڕ بەرەکەتی زیکر و نزا',
        descAr: 'إتمام 5 جلسات ذكر ودعاء لله تعالى',
        descEn: 'Complete 5 mindful sessions of dhikr and supplication',
        hadithKu: '«پەروەردگارت لە بەیانیان و ئێواراندا بە دڵسۆزییەوە یاد بکە.»',
        hadithAr: '«وَاذْكُر رَّبَّكَ فِي نَفْسِكَ تَضَرُّعًا وَخِيفَةً»',
        hadithEn: '“And remember your Lord within yourself in humility and awe.”',
        icon: Icons.auto_stories_rounded,
        targetValue: 5,
        currentValue: totalSessions,
        unitKu: 'دانیشتن',
        unitAr: 'جلسات',
        unitEn: 'Sessions',
      ),

      // 3. Journey: 25 Sessions
      _SpiritualAchievement(
        id: 'sessions_25',
        category: 'journey',
        categoryKu: 'گەشتی سەرەتا',
        categoryAr: 'بداية الرحلة',
        categoryEn: 'Journey',
        titleKu: 'کۆڕی دڵئارامی',
        titleAr: 'مجلس السكينة',
        titleEn: '25 Mindful Sessions',
        descKu: 'ئەنجامدانی 25 دانیشتنی تەواوی زیکر و پاڕانەوە',
        descAr: 'إتمام 25 جلسة ذكر مباركة عامرة بالسكينة',
        descEn: 'Complete 25 heartfelt dhikr sessions',
        hadithKu: '«هیچ کۆمەڵێک دانانیشن یادی خودا بکەن ئیللا فریشتەکان دەوریان دەدەن و ئارامییان بەسەردا دەبارێت.»',
        hadithAr: '«مَا اجْتَمَعَ قَوْمٌ يَذْكُرُونَ اللَّهَ إِلَّا حَفَّتْهُمُ الْمَلَائِكَةُ وَغَشِيَتْهُمُ الرَّحْمَةُ»',
        hadithEn: '“No people sit remembering Allah without the angels surrounding them and mercy covering them.”',
        icon: Icons.spa_rounded,
        targetValue: 25,
        currentValue: totalSessions,
        unitKu: 'دانیشتن',
        unitAr: 'جلسة',
        unitEn: 'Sessions',
      ),

      // 4. Journey: 50 Sessions
      _SpiritualAchievement(
        id: 'sessions_50',
        category: 'journey',
        categoryKu: 'گەشتی سەرەتا',
        categoryAr: 'بداية الرحلة',
        categoryEn: 'Journey',
        titleKu: 'پەیمانی نەبڕاوە',
        titleAr: 'العهد المبارك',
        titleEn: '50 Devotional Circles',
        descKu: 'تەواوکردنی 50 دانیشتنی خاشعانە لە یادی پەروەردگاردا',
        descAr: 'إتمام 50 جلسة خاشعة في رحاب ذكر المولى عز وجل',
        descEn: 'Achieve 50 consistent sessions in remembrance of Allah',
        hadithKu: '«یادی من بکەن تا یادتان بکەم، و سوپاسگوزارم بن و سوپاسناپێزان مەبن.»',
        hadithAr: '«فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ»',
        hadithEn: '“Remember Me; I will remember you. And be grateful to Me and do not deny Me.”',
        icon: Icons.military_tech_rounded,
        targetValue: 50,
        currentValue: totalSessions,
        unitKu: 'دانیشتن',
        unitAr: 'جلسة',
        unitEn: 'Sessions',
      ),

      // 5. Journey: 100 Sessions
      _SpiritualAchievement(
        id: 'sessions_100',
        category: 'journey',
        categoryKu: 'گەشتی سەرەتا',
        categoryAr: 'بداية الرحلة',
        categoryEn: 'Journey',
        titleKu: 'مێوانداری فریشتەکان',
        titleAr: 'مرافقة الملائكة',
        titleEn: '100 Circles of Grace',
        descKu: 'تۆمارکردنی 100 دانیشتنی پڕ لە نوور و تەسبیحات',
        descAr: 'بلوغ 100 جلسة ذكر وتسبيح ودعاء مسجلة بالكامل',
        descEn: 'Record 100 spiritual and prayer sessions',
        hadithKu: '«خوا دەفەرموێت: من لەگەڵ بەندەکەمم مادام یادم بکات و لێوەکانی بە یادم بجوڵێنێت.»',
        hadithAr: '«أَنَا مَعَ عَبْدِي مَا ذَكَرَنِي وَتَحَرَّكَتْ بِي شَفَتَاهُ»',
        hadithEn: '“I am with My servant when he remembers Me and his lips move with My mention.”',
        icon: Icons.workspace_premium_rounded,
        targetValue: 100,
        currentValue: totalSessions,
        unitKu: 'دانیشتن',
        unitAr: 'جلسة',
        unitEn: 'Sessions',
      ),

      // 6. Streak: 3 Days
      _SpiritualAchievement(
        id: 'flame_3',
        category: 'streak',
        categoryKu: 'بەردەوامی',
        categoryAr: 'المواظبة',
        categoryEn: 'Streak',
        titleKu: 'پریشکی بەردەوامی',
        titleAr: 'شعلة الاستمرار',
        titleEn: 'Spark of Consistency',
        descKu: 'پاراستنی زنجیرەی زیکری ڕۆژانە بۆ 3 ڕۆژی بەردەوام',
        descAr: 'المواظبة على الأذكار لمدة 3 أيام متتالية دون انقطاع',
        descEn: 'Maintain a 3-day unbroken streak of daily dhikr',
        hadithKu: '«سەرکەوتن لە بەردەوامی دایە لەسەر چاکە و یادکردنەوە.»',
        hadithAr: '«سددوا وقاربوا، واعلموا أن خير أعمالكم أدومها»',
        hadithEn: '“Follow the right course, be steadfast, and know consistency is virtue.”',
        icon: Icons.whatshot_rounded,
        targetValue: 3,
        currentValue: currentStreak,
        unitKu: 'ڕۆژ',
        unitAr: 'أيام',
        unitEn: 'Days',
      ),

      // 7. Streak: 7 Days
      _SpiritualAchievement(
        id: 'flame_7',
        category: 'streak',
        categoryKu: 'بەردەوامی',
        categoryAr: 'المواظبة',
        categoryEn: 'Streak',
        titleKu: 'شەوقی حەوت ڕۆژ',
        titleAr: 'سلسلة الأسبوع الذهبية',
        titleEn: '7-Day Golden Flame',
        descKu: 'هەفتەیەکی تەواو (7 ڕۆژ) بێ پچڕان لە یادی پەروەردگاردا',
        descAr: 'أسبوع كامل من الذكر والمواظبة اليومية المستمرة',
        descEn: 'Complete a full 7-day continuous streak of remembrance',
        hadithKu: '«وێنەی ئەوەی یادی پەروەردگاری دەکات و ئەوەی یاد ناکات، وەک زیندوو و مردوو وایە.»',
        hadithAr: '«مَثَلُ الَّذِي يَذْكُرُ رَبَّهُ وَالَّذِي لا يَذْكُرُ رَبَّهُ مَثَلُ الْحَيِّ وَالْمَيِّتِ»',
        hadithEn: '“The comparison between one who remembers their Lord and one who does not is like the living and the dead.”',
        icon: Icons.local_fire_department_rounded,
        targetValue: 7,
        currentValue: currentStreak,
        unitKu: 'ڕۆژ',
        unitAr: 'أيام',
        unitEn: 'Days',
      ),

      // 8. Streak: 14 Days
      _SpiritualAchievement(
        id: 'flame_14',
        category: 'streak',
        categoryKu: 'بەردەوامی',
        categoryAr: 'المواظبة',
        categoryEn: 'Streak',
        titleKu: 'شەوی چواردەی بەردەوامی',
        titleAr: 'بدر الأسبوعين',
        titleEn: '14-Day Full Moon Streak',
        descKu: 'دوو هەفتەی تەواو (14 ڕۆژ) بەردەوامیی بێ پچڕان لەسەر زیکر',
        descAr: 'المواظبة لمدة 14 يوماً متتالياً من النور والأذكار',
        descEn: 'Achieve a 14-day continuous streak of remembrance',
        hadithKu: '«خوای گەورە حەز دەکات کاتێک بەندە کارێک دەکات پوخت و بەردەوام بێت.»',
        hadithAr: '«إِنَّ اللَّهَ يُحِبُّ إِذَا عَمِلَ أَحَدُكُمْ عَمَلًا أَنْ يُتْقِنَهُ»',
        hadithEn: '“Indeed Allah loves that when one does a deed, they do it with consistency and care.”',
        icon: Icons.brightness_medium_rounded,
        targetValue: 14,
        currentValue: currentStreak,
        unitKu: 'ڕۆژ',
        unitAr: 'يوماً',
        unitEn: 'Days',
      ),

      // 9. Streak: 30 Days
      _SpiritualAchievement(
        id: 'month_steadfast',
        category: 'streak',
        categoryKu: 'بەردەوامی',
        categoryAr: 'المواظبة',
        categoryEn: 'Streak',
        titleKu: 'سەروەری 30 ڕۆژ',
        titleAr: 'ثبات الشهر المبارك',
        titleEn: 'Steadfast Month',
        descKu: 'مانگێکی تەواو (30 ڕۆژ) پڕ لە سەقامگیری و ڕۆشنایی دڵ',
        descAr: 'المواظبة المستمرة لمدة شهر كامل (30 يوماً) في رحاب الطاعة',
        descEn: '30 consecutive days of devotion, dhikr, and consistency',
        hadithKu: '«ئیماندار لەسەر چاکە و گوێڕایەڵی خودا سەقامگیر و پتەوە.»',
        hadithAr: '«إِنَّ أَحَبَّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ»',
        hadithEn: '“Indeed, the most beloved of deeds to Allah are those sustained consistently.”',
        icon: Icons.verified_rounded,
        targetValue: 30,
        currentValue: currentStreak,
        unitKu: 'ڕۆژ',
        unitAr: 'يوماً',
        unitEn: 'Days',
      ),

      // 10. Streak: 60 Days
      _SpiritualAchievement(
        id: 'flame_60',
        category: 'streak',
        categoryKu: 'بەردەوامی',
        categoryAr: 'المواظبة',
        categoryEn: 'Streak',
        titleKu: 'سەروەری بەردەوامی',
        titleAr: 'سلسلة الستين يوماً',
        titleEn: '60 Days of Steadfast Light',
        descKu: 'دوو مانگی تەواو (60 ڕۆژ) بەردەوامی لەسەر یادی خوای گەورە',
        descAr: 'شهران كاملان (60 يوماً) من الالتزام الإيماني المستمر',
        descEn: '60 unbroken days of steadfast remembrance',
        hadithKu: '«بڵێ باوەڕم بە خوا هێنا و دواتر لەسەری بەردەوام و چەسپاو بە.»',
        hadithAr: '«قُلْ: آمَنْتُ بِاللَّهِ، ثُمَّ اسْتَقِمْ»',
        hadithEn: '“Say: I believe in Allah, and then remain steadfast upon the right path.”',
        icon: Icons.local_fire_department_rounded,
        targetValue: 60,
        currentValue: currentStreak,
        unitKu: 'ڕۆژ',
        unitAr: 'يوماً',
        unitEn: 'Days',
      ),

      // 11. Streak: 100 Days
      _SpiritualAchievement(
        id: 'flame_100',
        category: 'streak',
        categoryKu: 'بەردەوامی',
        categoryAr: 'المواظبة',
        categoryEn: 'Streak',
        titleKu: 'تاجی سەد ڕۆژەی بەردەوامی',
        titleAr: 'تاج المئة يوم',
        titleEn: 'Centennial of Devotion',
        descKu: '100 ڕۆژی بەردەوامی و نەپچڕاو لەسەر زیکر و نزاکانی ڕۆژانە',
        descAr: '100 يوم متواصل من الذكر والاستغفار والمواظبة الخالصة',
        descEn: '100 unbroken days of daily remembrance and prayer',
        hadithKu: '«خۆشەویستترین کردەوە لای خوا ئەوەیە کە بەردەوام بێت هەرچەند کەمیش بێت.»',
        hadithAr: '«أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ»',
        hadithEn: '“The deeds most beloved to Allah are those most consistent, even if modest.”',
        icon: Icons.diamond_rounded,
        targetValue: 100,
        currentValue: currentStreak,
        unitKu: 'ڕۆژ',
        unitAr: 'يوماً',
        unitEn: 'Days',
      ),

      // 12. Tasbih: 100
      _SpiritualAchievement(
        id: 'tasbih_100',
        category: 'dhikr',
        categoryKu: 'تەسبیحات',
        categoryAr: 'الأذكار',
        categoryEn: 'Tasbih',
        titleKu: '100 تەسبیحات',
        titleAr: '100 تسبيحة',
        titleEn: 'Centurion of Praise',
        descKu: 'تەواوکردنی 100 زیکر و تەسبیحی پیرۆز بۆ خودا',
        descAr: 'إكمال 100 ذكر وتسبيح خالص لوجه الله تعالى',
        descEn: 'Record 100 total sacred dhikrs and tasbihs',
        hadithKu: '«دوو وشە لەسەر زمان سووک و لەسەر تەرازوو قورسن: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ.»',
        hadithAr: '«كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ»',
        hadithEn: '“Two words are light on the tongue, heavy in the scale: SubhanAllah wa bihamdihi, SubhanAllahil-Azim.”',
        icon: Icons.toll_rounded,
        targetValue: 100,
        currentValue: totalDhikr,
        unitKu: 'زیکر',
        unitAr: 'ذكر',
        unitEn: 'Count',
      ),

      // 13. Tasbih: 300
      _SpiritualAchievement(
        id: 'tasbih_300',
        category: 'dhikr',
        categoryKu: 'تەسبیحات',
        categoryAr: 'الأذكار',
        categoryEn: 'Tasbih',
        titleKu: '300 تەسبیحی پیرۆز',
        titleAr: '300 تسبيحة مباركة',
        titleEn: '300 Sacred Tasbihs',
        descKu: 'تەواوکردنی 300 زیکر و تەسبیحی خودا لە تەرازووی چاکەکانت',
        descAr: 'إكمال 300 ذكر وتسبيح في ميزان حسناتك',
        descEn: 'Reach 300 praises of Allah in your daily tasbih',
        hadithKu: '«سُبْحَانَ اللَّهِ عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ.»',
        hadithAr: '«سُبْحَانَ اللَّهِ عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ»',
        hadithEn: '“Glory be to Allah according to the number of His creation and the weight of His Throne.”',
        icon: Icons.flare_rounded,
        targetValue: 300,
        currentValue: totalDhikr,
        unitKu: 'زیکر',
        unitAr: 'ذكر',
        unitEn: 'Count',
      ),

      // 14. Tasbih: 1,000
      _SpiritualAchievement(
        id: 'tasbih_1000',
        category: 'dhikr',
        categoryKu: 'تەسبیحات',
        categoryAr: 'الأذكار',
        categoryEn: 'Tasbih',
        titleKu: '1,000 گەوهەری چاکە',
        titleAr: '1,000 حسنة مباركة',
        titleEn: '1,000 Jewels of Reward',
        descKu: 'تۆمارکردنی 1,000 زیکری پاک لە تەرازووی چاکەکانت',
        descAr: 'بلوغ 1,000 تسبيحة وذكر مسجل في التطبيق',
        descEn: 'Accumulate 1,000 dhikr repetitions on your counter',
        hadithKu: '«ئایا ناتوانن ڕۆژانە هەزار چاکە بەدەستبهێنن؟ 100 جار تەسبیح بکەن، هەزار چاکەتان بۆ دەنوسرێت.»',
        hadithAr: '«أَيَعْجِزُ أَحَدُكُمْ أَنْ يَكْسِبَ كُلَّ يَوْمٍ أَلْفَ حَسَنَةٍ؟ يُسَبِّحُ مِائَةَ تَسْبِيحَةٍ، فَيُكْتَبُ لَهُ أَلْفُ حَسَنَةٍ»',
        hadithEn: '“Can any one of you not earn 1,000 good deeds daily? Glorify Allah 100 times, and 1,000 rewards are written.”',
        icon: Icons.diamond_rounded,
        targetValue: 1000,
        currentValue: totalDhikr,
        unitKu: 'زیکر',
        unitAr: 'ذكر',
        unitEn: 'Count',
      ),

      // 15. Tasbih: 5,000
      _SpiritualAchievement(
        id: 'tasbih_5000',
        category: 'dhikr',
        categoryKu: 'تەسبیحات',
        categoryAr: 'الأذكار',
        categoryEn: 'Tasbih',
        titleKu: 'خەزێنەی بەهەشت',
        titleAr: 'كنز من كنوز الجنة',
        titleEn: '5,000 Heavenly Treasures',
        descKu: 'گەیشتن بە 5,000 یادی خودای بەخشندە و دلۆڤان',
        descAr: 'الوصول إلى 5,000 ذكر وتسبيح خالصاً لوجه الله',
        descEn: 'Reach 5,000 total dhikr praises in your lifetime journal',
        hadithKu: '«لا حَوْلَ وَلا قُوَّةَ إِلا بِاللَّهِ، خەزێنەیەکە لە خەزێنەکانی بەهەشت.»',
        hadithAr: '«لا حَوْلَ وَلا قُوَّةَ إِلَّا بِاللَّهِ كَنْزٌ مِنْ كُنُوزِ الْجَنَّةِ»',
        hadithEn: '“La hawla wa la quwwata illa billah is a treasure from the treasures of Paradise.”',
        icon: Icons.stars_rounded,
        targetValue: 5000,
        currentValue: totalDhikr,
        unitKu: 'زیکر',
        unitAr: 'ذكر',
        unitEn: 'Count',
      ),

      // 16. Tasbih: 10,000
      _SpiritualAchievement(
        id: 'tasbih_10000',
        category: 'dhikr',
        categoryKu: 'تەسبیحات',
        categoryAr: 'الأذكار',
        categoryEn: 'Tasbih',
        titleKu: 'خاوەنی دە هەزار چاکە',
        titleAr: 'صاحب العشرة آلاف',
        titleEn: '10,000 Divine Praises',
        descKu: 'گەیشتن بە 10,000 زیکری پڕ لە نوور و پاداشت لە گەشتە ڕۆحییەکەتدا',
        descAr: 'بلوغ 10,000 تسبيحة وذكر خالص مسجل في صحيفتك المباركة',
        descEn: 'Surpass 10,000 total sacred dhikrs in your lifetime journey',
        hadithKu: '«ئایا هەواڵتان پێ بدەم بە باشترین و پاکترین کردەوەتان لای پەروەردگارتان؟ یادی خوای گەورەیە.»',
        hadithAr: '«أَلَا أُنَبِّئُكُمْ بِخَيْرِ أَعْمَالِكُمْ، وَأَزْكَاهَا عِنْدَ مَلِيكِكُمْ؟ ذِكْرُ اللَّهِ تَعَالَى»',
        hadithEn: '“Shall I not inform you of the best and purest of your deeds before your Lord? The remembrance of Allah.”',
        icon: Icons.auto_awesome_rounded,
        targetValue: 10000,
        currentValue: totalDhikr,
        unitKu: 'زیکر',
        unitAr: 'ذكر',
        unitEn: 'Count',
      ),

      // 17. Tasbih: 25,000
      _SpiritualAchievement(
        id: 'tasbih_25000',
        category: 'dhikr',
        categoryKu: 'تەسبیحات',
        categoryAr: 'الأذكار',
        categoryEn: 'Tasbih',
        titleKu: 'یاقووتی زیکر',
        titleAr: 'ياقوت الذاكرين',
        titleEn: 'Ruby of the Praisers',
        descKu: 'تۆمارکردنی 25,000 زیکر و سوپاسگوزاریی بەردەوام بۆ پەروەردگار',
        descAr: 'الارتقاء إلى 25,000 ذكر مسجل بلسان رطب بذكر الله',
        descEn: 'Attain 25,000 recorded praises and supplications',
        hadithKu: '«پێشبڕکێکەران پێشکەوتن! وتیان: کێن ئەی پێغەمبەری خوا؟ فەرمووی: ئەو ژن و پیاوانەی کە زۆر یادی خوا دەکەن.»',
        hadithAr: '«سَبَقَ الْمُفَرِّدُونَ، قَالُوا: وَمَا الْمُفَرِّدُونَ يَا رَسُولَ اللَّهِ؟ قَالَ: الذَّاكِرُونَ اللَّهَ كَثِيرًا وَالذَّاكِرَاتُ»',
        hadithEn: '“The foremost have outpaced the rest! They asked: Who are they? He said: The men and women who remember Allah abundantly.”',
        icon: Icons.workspace_premium_rounded,
        targetValue: 25000,
        currentValue: totalDhikr,
        unitKu: 'زیکر',
        unitAr: 'ذكر',
        unitEn: 'Count',
      ),

      // 18. Quran: Solace Bookmark
      _SpiritualAchievement(
        id: 'quran_solace',
        category: 'quran',
        categoryKu: 'قورئان و دەروون',
        categoryAr: 'القرآن والسكينة',
        categoryEn: 'Quran & Solace',
        titleKu: 'دڵنەوایی قورئان',
        titleAr: 'شفاء وراحة القلوب',
        titleEn: 'Solace of Quran',
        descKu: 'پاشەکەوتکردنی کارتی ئارامیی دڵ لە بەشی هەستەکان و قورئان',
        descAr: 'حفظ بطاقة تأمل قرآنية من قسم خواطر وسكينة القرآن',
        descEn: 'Bookmark your favorite Quran mood reflection card',
        hadithKu: '«قورئان شیفایە بۆ ئەوەی لە سینە و دڵەکاندایە.»',
        hadithAr: '«وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ»',
        hadithEn: '“And We send down of the Quran that which is healing and mercy for the believers.”',
        icon: Icons.bookmarks_rounded,
        targetValue: 1,
        currentValue: savedCards,
        unitKu: 'کارت',
        unitAr: 'بطاقة',
        unitEn: 'Card',
      ),

      // 19. Quran: 3 Bookmarks
      _SpiritualAchievement(
        id: 'quran_favorites_3',
        category: 'quran',
        categoryKu: 'قورئان و دەروون',
        categoryAr: 'القرآن والسكينة',
        categoryEn: 'Quran & Solace',
        titleKu: 'کۆکەرەوەی ئایەتەکان',
        titleAr: 'جامع الآيات المباركة',
        titleEn: 'Collector of Verses',
        descKu: 'پاشەکەوتکردنی 3 کارتی ئارامی و هیدایەتی قورئانی بۆ کاتە پێویستەکان',
        descAr: 'حفظ 3 بطاقات قرآنية ملهمة ومطمئنة للقلب',
        descEn: 'Save 3 inspiring Quran guidance cards in your favorites',
        hadithKu: '«ئەوەی بە شارەزایی قورئان دەخوێنێت لەگەڵ فریشتە بەڕێز و چاکەکاردایە.»',
        hadithAr: '«الَّذِي يَقْرَأُ القُرْآنَ وَهُوَ مَاهِرٌ بِهِ مَعَ السَّفَرَةِ الكِرَامِ البَرَرَةِ»',
        hadithEn: '“The one who recites the Quran skillfully is with the noble and honorable angels.”',
        icon: Icons.collections_bookmark_rounded,
        targetValue: 3,
        currentValue: savedCards,
        unitKu: 'کارت',
        unitAr: 'بطاقات',
        unitEn: 'Cards',
      ),

      // 20. Quran: 10 Bookmarks
      _SpiritualAchievement(
        id: 'quran_favorites_10',
        category: 'quran',
        categoryKu: 'قورئان و دەروون',
        categoryAr: 'القرآن والسكينة',
        categoryEn: 'Quran & Solace',
        titleKu: 'باخچەی قورئان',
        titleAr: 'بستان الهدى والسكينة',
        titleEn: 'Garden of Guidance',
        descKu: 'کۆکردنەوەی 10 ئایەتی دڵنەوایی بۆ بەهێزکردنی باوەڕ و ڕووناککردنەوەی ناخ',
        descAr: 'جمع 10 بطاقات قرآنية مباركة لتثبيت الإيمان وإنارة القلب',
        descEn: 'Collect 10 Quranic wisdom cards for spiritual clarity',
        hadithKu: '«بەڕاستی ئەم قورئانە ڕێنموونی دەکات بۆ ئەو ڕێگایەی کە لە هەمووی ڕاست و پتەوترە.»',
        hadithAr: '«إِنَّ هَذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ وَيُبَشِّرُ الْمُؤْمِنِينَ»',
        hadithEn: '“Indeed, this Quran guides to that which is most upright and gives good tidings to believers.”',
        icon: Icons.menu_book_rounded,
        targetValue: 10,
        currentValue: savedCards,
        unitKu: 'کارت',
        unitAr: 'بطاقات',
        unitEn: 'Cards',
      ),
    ];
  }

  void _showRankRoadmapSheet(BuildContext context, _DetailedStats data, String lang, bool isKurdish) {
    final currentRank = _getSpiritualRank(data.totalDhikrCount, data.appStats.totalSessions, lang);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.darkPanel,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
              // Top drag bar
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Title and Description
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tr(lang,
                              ku: 'ڕێبەری پلە ڕۆحییەکان',
                              ar: 'دليل الرتب الإيمانية',
                              en: 'Spiritual Ranks Roadmap'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: isKurdish
                              ? AppTheme.kurdishTitle(fontSize: 18, color: AppColors.cream)
                              : AppTheme.englishText(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tr(lang,
                              ku: 'ناوی شایستە و چۆنیەتی بەدەستهێنانی هەر ئاستێک',
                              ar: 'الألقاب المباركة وشروط بلوغ كل رتبة',
                              en: 'Honorific titles and requirements for each tier'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.englishText(fontSize: 12, color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: AppColors.gold.withValues(alpha: 0.2)),
              const SizedBox(height: 8),

              // Ladder list of all 8 ranks
              Expanded(
                child: ListView.builder(
                  itemCount: _rankDefinitions.length,
                  itemBuilder: (context, index) {
                    final rankDef = _rankDefinitions[index];
                    final isUnlocked = (data.totalDhikrCount >= rankDef.reqDhikr || data.appStats.totalSessions >= rankDef.reqSessions);
                    final isCurrent = currentRank.level == rankDef.level;
                    final isFuture = rankDef.level > currentRank.level;
                    final remainingDhikr = (rankDef.reqDhikr - data.totalDhikrCount).clamp(0, rankDef.reqDhikr);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? rankDef.accentColor.withValues(alpha: 0.18)
                            : (isUnlocked
                                ? AppColors.panelColor
                                : AppColors.darkBgAlt.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCurrent
                              ? rankDef.accentColor
                              : (isUnlocked
                                  ? rankDef.accentColor.withValues(alpha: 0.4)
                                  : AppColors.panelBorderColor.withValues(alpha: 0.5)),
                          width: isCurrent ? 2.0 : 1.0,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: rankDef.accentColor.withValues(alpha: 0.2),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Level emblem
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUnlocked
                                  ? rankDef.accentColor.withValues(alpha: 0.2)
                                  : AppColors.panelColor,
                              border: Border.all(
                                color: isUnlocked
                                    ? rankDef.accentColor
                                    : AppColors.faintText.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                rankDef.iconData,
                                size: 24,
                                color: isUnlocked ? rankDef.accentColor : AppColors.faintText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Text & Requirements
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rankDef.getTitle(lang),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked ? rankDef.accentColor : AppColors.faintText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? rankDef.accentColor.withValues(alpha: 0.25)
                                            : (isUnlocked
                                                ? AppColors.gold.withValues(alpha: 0.15)
                                                : AppColors.panelColor),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isCurrent
                                              ? rankDef.accentColor
                                              : (isUnlocked
                                                  ? AppColors.gold.withValues(alpha: 0.3)
                                                  : AppColors.faintText.withValues(alpha: 0.2)),
                                        ),
                                      ),
                                      child: Text(
                                        isCurrent
                                            ? _tr(lang, ku: 'ئاستی ئێستات 🌟', ar: 'رتبتك الحالية 🌟', en: 'Current 🌟')
                                            : (isUnlocked
                                                ? _tr(lang, ku: 'بەدەستهاتووە ✅', ar: 'تم بلوغها ✅', en: 'Unlocked ✅')
                                                : _tr(lang, ku: 'داخراوە 🔒', ar: 'مغلقة 🔒', en: 'Locked 🔒')),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isCurrent
                                              ? rankDef.accentColor
                                              : (isUnlocked ? AppColors.gold : AppColors.faintText),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  rankDef.getSubtitle(lang),
                                  style: AppTheme.englishText(
                                    fontSize: 11,
                                    color: isUnlocked ? AppColors.cream.withValues(alpha: 0.9) : AppColors.mutedText,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Explicit Requirement Box
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isUnlocked
                                        ? rankDef.accentColor.withValues(alpha: 0.1)
                                        : AppColors.darkBgAlt,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isUnlocked
                                          ? rankDef.accentColor.withValues(alpha: 0.25)
                                          : AppColors.panelBorderColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_outlined,
                                        size: 13,
                                        color: isUnlocked ? rankDef.accentColor : AppColors.faintText,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${_tr(lang, ku: 'مەرج: ', ar: 'المتطلب: ', en: 'Req: ')}${rankDef.getRequirement(lang)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isUnlocked ? rankDef.accentColor : AppColors.faintText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (isFuture) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _tr(lang,
                                        ku: 'هێشتا $remainingDhikr یادت ماوە بۆ ئەم پلەیە',
                                        ar: 'متبقي $remainingDhikr ذكر لبلوغ هذه الرتبة',
                                        en: '$remainingDhikr dhikrs remaining for this rank'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.faintText,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.darkBg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  _tr(lang, ku: 'داخستن', ar: 'إغلاق', en: 'Close'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkBg),
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  void _showAchievementDetails(
    BuildContext context,
    _SpiritualAchievement item,
    String lang,
    bool isKurdish,
  ) {
    final isArabic = lang == 'ar';
    final title = item.getTitle(lang);
    final category = item.getCategory(lang);
    final desc = item.getDesc(lang);
    final hadith = item.getHadith(lang);
    final unit = item.getUnit(lang);
    final isUnlocked = item.isUnlocked;
    final progressPercent = (item.progress * 100).toInt();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          decoration: BoxDecoration(
            color: AppColors.panelColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Top Handle
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),

                // Large Glowing Emblem
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? AppColors.gold.withValues(alpha: 0.16)
                        : AppColors.darkBgAlt,
                    border: Border.all(
                      color: isUnlocked ? AppColors.gold : AppColors.panelBorderColor,
                      width: 2,
                    ),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      size: 38,
                      color: isUnlocked ? AppColors.gold : AppColors.faintText,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    category,
                    style: isKurdish
                        ? AppTheme.kurdishText(
                            fontSize: 11,
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          )
                        : (isArabic
                            ? AppTheme.arabicText(
                                fontSize: 11,
                                color: AppColors.gold,
                              )
                            : AppTheme.englishText(
                                fontSize: 11,
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              )),
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  title,
                  style: isKurdish
                      ? AppTheme.kurdishTitle(fontSize: 20, color: AppColors.cream)
                      : (isArabic
                          ? AppTheme.arabicTitle(fontSize: 20, color: AppColors.cream)
                          : AppTheme.englishTitle(fontSize: 20, color: AppColors.cream)),
                ),
                const SizedBox(height: 6),

                // Meaningful Description
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: isKurdish
                      ? AppTheme.kurdishText(fontSize: 13, color: AppColors.mutedText)
                      : (isArabic
                          ? AppTheme.arabicText(fontSize: 13, color: AppColors.mutedText)
                          : AppTheme.englishText(fontSize: 13, color: AppColors.mutedText)),
                ),
                const SizedBox(height: 18),

                // Progress Bar Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkBgAlt,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.panelBorderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              isUnlocked
                                  ? _tr(lang, ku: '🌟 بەدەستهاتوو', ar: '🌟 تم الإنجاز بنجاح', en: '🌟 Achieved!')
                                  : _tr(lang, ku: '⏳ لە کاردایە', ar: '⏳ قيد التقدم', en: '⏳ In Progress'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: isKurdish
                                  ? AppTheme.kurdishText(
                                      fontSize: 12,
                                      color: isUnlocked ? AppColors.gold : AppColors.cream,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : AppTheme.englishText(
                                      fontSize: 12,
                                      color: isUnlocked ? AppColors.gold : AppColors.cream,
                                      fontWeight: FontWeight.bold,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${item.currentValue} / ${item.targetValue} $unit ($progressPercent%)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: AppTheme.englishText(
                                fontSize: 12,
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: item.progress,
                          minHeight: 8,
                          backgroundColor: AppColors.panelColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUnlocked ? AppColors.gold : AppColors.gold.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Hadith / Spiritual Quote
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote_rounded, color: AppColors.gold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hadith,
                          style: isKurdish
                              ? AppTheme.kurdishText(
                                  fontSize: 12,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w600,
                                ).copyWith(height: 1.5)
                              : (isArabic
                                  ? AppTheme.arabicText(
                                      fontSize: 12,
                                      color: AppColors.gold,
                                    ).copyWith(height: 1.5)
                                  : AppTheme.englishText(
                                      fontSize: 12,
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                    ).copyWith(height: 1.5)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Actions: Share or Close
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final shareText = isKurdish
                              ? '🏆 دەستکەوتی ڕۆحی لە ئەپی (نەدا):\n\n'
                                  '✨ «$title» ($category)\n'
                                  '📜 $desc\n'
                                  '📖 $hadith\n\n'
                                  'یاوەری ڕۆحی بۆ زیکر و دوعاکانی ڕۆژانە 🌟'
                              : isArabic
                                  ? '🏆 إنجاز إيماني في تطبيق (نَدَى):\n\n'
                                      '✨ «$title» ($category)\n'
                                      '📜 $desc\n'
                                      '📖 $hadith\n\n'
                                      'رفيقك الإيماني للأذكار والقرآن 🌟'
                                  : '🏆 Spiritual Milestone on Nada App:\n\n'
                                      '✨ “$title” ($category)\n'
                                      '📜 $desc\n'
                                      '📖 $hadith\n\n'
                                      'Daily Dhikr & Quran Companion 🌟';
                          AppShareService.share(context, shareText);
                        },
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _tr(lang, ku: 'مشارکەکردن', ar: 'مشاركة الإنجاز', en: 'Share Milestone'),
                            style: isKurdish
                                ? AppTheme.kurdishText(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.bold)
                                : AppTheme.englishText(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.bold),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.darkBg,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _tr(lang, ku: 'داخستن', ar: 'إغلاق', en: 'Close'),
                            style: isKurdish
                                ? AppTheme.kurdishText(fontSize: 13, color: AppColors.darkBg, fontWeight: FontWeight.bold)
                                : AppTheme.englishText(fontSize: 13, color: AppColors.darkBg, fontWeight: FontWeight.bold),
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
      );
      },
    );
  }

  Widget _buildInteractiveAchievementCard(
    _SpiritualAchievement item,
    String lang,
    bool isKurdish,
  ) {
    final isArabic = lang == 'ar';
    final title = item.getTitle(lang);
    final unit = item.getUnit(lang);
    final isUnlocked = item.isUnlocked;

    return GestureDetector(
      onTap: () => _showAchievementDetails(context, item, lang, isKurdish),
      child: Container(
        width: 138,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppColors.gold.withValues(alpha: 0.12)
              : AppColors.panelColor,
          border: Border.all(
            color: isUnlocked ? AppColors.gold : AppColors.panelBorderColor,
            width: isUnlocked ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top icon + status dot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  item.icon,
                  size: 26,
                  color: isUnlocked ? AppColors.gold : AppColors.faintText,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.gold
                        : AppColors.panelBorderColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isUnlocked
                        ? _tr(lang, ku: 'کراوە', ar: 'مكتمل', en: 'Done')
                        : '${(item.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? AppColors.darkBg : AppColors.cream,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: isKurdish
                  ? AppTheme.kurdishText(
                      fontSize: 12,
                      color: isUnlocked ? AppColors.cream : AppColors.faintText,
                      fontWeight: FontWeight.bold,
                    )
                  : (isArabic
                      ? AppTheme.arabicText(
                          fontSize: 12,
                          color: isUnlocked ? AppColors.cream : AppColors.faintText,
                        )
                      : AppTheme.englishText(
                          fontSize: 12,
                          color: isUnlocked ? AppColors.cream : AppColors.faintText,
                          fontWeight: FontWeight.bold,
                        )),
            ),
            const SizedBox(height: 4),

            // Requirement / Progress text
            Text(
              '${item.currentValue}/${item.targetValue} $unit',
              style: AppTheme.englishText(
                fontSize: 10,
                color: isUnlocked ? AppColors.gold : AppColors.veryFaintText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            // Mini progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 4,
                backgroundColor: AppColors.darkBgAlt,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isUnlocked ? AppColors.gold : AppColors.gold.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<_RankDefinition> _rankDefinitions = [
    _RankDefinition(
      level: 1,
      titleKu: 'ڕێبواری ڕووناکی',
      titleAr: 'طالب النور',
      titleEn: 'Seeker of Divine Light',
      subtitleKu: 'دەستپێکی پیرۆزی گەشتی دڵ لە یادی خوادا',
      subtitleAr: 'بداية المسير المبارك في رحاب ذكر الرحمن',
      subtitleEn: 'The blessed start of your spiritual remembrance journey',
      reqDhikr: 0,
      reqSessions: 0,
      iconData: Icons.spa_rounded,
      accentColor: Color(0xFFD4AF37),
    ),
    _RankDefinition(
      level: 2,
      titleKu: 'پێشڕەوی چاکە',
      titleAr: 'الساعي بالخير',
      titleEn: 'Walker of Goodness',
      subtitleKu: 'هەنگاوی چەسپاو لەسەر ڕێگای گوێڕایەڵی و خێر',
      subtitleAr: 'خطوات ثابتة ومباركة في دروب الطاعة والخير',
      subtitleEn: 'Steadfast steps in righteous devotion and remembrance',
      reqDhikr: 100,
      reqSessions: 3,
      iconData: Icons.eco_rounded,
      accentColor: Color(0xFF34D399),
    ),
    _RankDefinition(
      level: 3,
      titleKu: 'هۆگری نزا و یاد',
      titleAr: 'المواظب الأوّاب',
      titleEn: 'Mindful Devotee',
      subtitleKu: 'بەردەوامی لە پاڕانەوە، نزا و گەڕانەوە بۆ لای خودا',
      subtitleAr: 'مواظبة خاشعة ورجوع دائم إلى الله بالدعاء',
      subtitleEn: 'Humble persistence in tasbih and heartfelt prayer',
      reqDhikr: 300,
      reqSessions: 7,
      iconData: Icons.volunteer_activism_rounded,
      accentColor: Color(0xFF8B5CF6),
    ),
    _RankDefinition(
      level: 4,
      titleKu: 'یادکەری دڵئارام',
      titleAr: 'الذاكر المطمئن',
      titleEn: 'Serene Remembrancer',
      subtitleKu: '«بە یادی خودا دڵەکان ئارام دەبن» — دڵێکی پڕ لە هێمنی',
      subtitleAr: 'ألا بذكر الله تطمئن القلوب — قلب مفعم بالطمأنينة',
      subtitleEn: 'A tranquil heart illuminated by remembrance',
      reqDhikr: 700,
      reqSessions: 15,
      iconData: Icons.auto_awesome_rounded,
      accentColor: Color(0xFF06B6D4),
    ),
    _RankDefinition(
      level: 5,
      titleKu: 'شەیدای ستایش',
      titleAr: 'المسبِّح الأوّاه',
      titleEn: 'Devout Glorifier',
      subtitleKu: 'زمانێک کە هەمیشە بە یادی خودا تەڕ و ڕازاوەیە',
      subtitleAr: 'لسان رطب بذكر الله وتسبيحه في كل حين',
      subtitleEn: 'A tongue perpetually moist with praises of Allah',
      reqDhikr: 1500,
      reqSessions: 25,
      iconData: Icons.stars_rounded,
      accentColor: Color(0xFF10B981),
    ),
    _RankDefinition(
      level: 6,
      titleKu: 'پارێزەری پەیمان',
      titleAr: 'حافظ العهد',
      titleEn: 'Guardian of the Covenant',
      subtitleKu: 'پابەندبوونێکی بێوچان لەسەر یادەکانی بەیانیان و ئێواران',
      subtitleAr: 'ثبات راسخ على أذكار الصباح والمساء والفرائض',
      subtitleEn: 'Unwavering commitment to daily morning and evening adhkar',
      reqDhikr: 3000,
      reqSessions: 40,
      iconData: Icons.military_tech_rounded,
      accentColor: Color(0xFFEAB308),
    ),
    _RankDefinition(
      level: 7,
      titleKu: 'پێشەنگی باوەڕی چەسپاو',
      titleAr: 'رائد الاستقامة',
      titleEn: 'Vanguard of Steadfastness',
      subtitleKu: 'خاوەن هیممەتێکی بەرز و تەرازوویەکی پڕ لە چاکە',
      subtitleAr: 'همة عالية وثبات عظيم في ميزان الحسنات',
      subtitleEn: 'High devotion and steadfastness in good deeds',
      reqDhikr: 6000,
      reqSessions: 70,
      iconData: Icons.workspace_premium_rounded,
      accentColor: Color(0xFFF59E0B),
    ),
    _RankDefinition(
      level: 8,
      titleKu: 'سەروەری یادی خودا',
      titleAr: 'خادم الأذكار المبارك',
      titleEn: 'Master of Divine Remembrance',
      subtitleKu: 'لوتکەی سەقامگیری، ئارامی دڵ و نزیکی لە پەروەردگار',
      subtitleAr: 'أعلى مراتب الأنس والمواظبة على ذكر الرحمن',
      subtitleEn: 'The highest pinnacle of divine peace and remembrance',
      reqDhikr: 10000,
      reqSessions: 100,
      iconData: Icons.diamond_rounded,
      accentColor: Color(0xFFFFD700),
    ),
  ];

  _RankInfo _getSpiritualRank(int totalDhikr, int sessions, String lang) {
    int activeIndex = 0;
    if (totalDhikr >= 10000 || sessions >= 100) {
      activeIndex = 7;
    } else if (totalDhikr >= 6000 || sessions >= 70) {
      activeIndex = 6;
    } else if (totalDhikr >= 3000 || sessions >= 40) {
      activeIndex = 5;
    } else if (totalDhikr >= 1500 || sessions >= 25) {
      activeIndex = 4;
    } else if (totalDhikr >= 700 || sessions >= 15) {
      activeIndex = 3;
    } else if (totalDhikr >= 300 || sessions >= 7) {
      activeIndex = 2;
    } else if (totalDhikr >= 100 || sessions >= 3) {
      activeIndex = 1;
    } else {
      activeIndex = 0;
    }

    final def = _rankDefinitions[activeIndex];
    final isMax = activeIndex == _rankDefinitions.length - 1;
    final nextDef = isMax ? null : _rankDefinitions[activeIndex + 1];

    final target = nextDef?.reqDhikr ?? 10000;
    final prev = def.reqDhikr;
    final remaining = isMax ? 0 : (target - totalDhikr).clamp(0, target);
    final progress = isMax
        ? 1.0
        : ((totalDhikr - prev) / (target - prev > 0 ? target - prev : 1)).clamp(0.0, 1.0);

    return _RankInfo(
      level: def.level,
      title: def.getTitle(lang),
      subtitle: def.getSubtitle(lang),
      tierBadge: _tr(lang,
          ku: 'ئاستی ${def.level} لە ٨',
          ar: 'المستوى ${def.level} من ٨',
          en: 'Level ${def.level} of 8'),
      requirementText: def.getRequirement(lang),
      iconData: def.iconData,
      accentColor: def.accentColor,
      currentProgress: totalDhikr,
      targetProgress: target,
      nextRankTitle: nextDef?.getTitle(lang),
      nextRankReq: nextDef?.getRequirement(lang),
      remainingToNext: remaining,
      progressPercent: progress,
      isMaxLevel: isMax,
    );
  }
}

class _DetailedStats {
  final AppStatistics appStats;
  final UserProfile? profile;
  final int totalDhikrCount;
  final int savedFavoritesCount;
  final List<int> weeklyCounts;
  final WeeklyActivityReport weeklyReport;
  final bool isDoneToday;

  _DetailedStats({
    required this.appStats,
    required this.profile,
    required this.totalDhikrCount,
    required this.savedFavoritesCount,
    required this.weeklyCounts,
    required this.weeklyReport,
    required this.isDoneToday,
  });
}

class _RankDefinition {
  final int level;
  final String titleKu;
  final String titleAr;
  final String titleEn;
  final String subtitleKu;
  final String subtitleAr;
  final String subtitleEn;
  final int reqDhikr;
  final int reqSessions;
  final IconData iconData;
  final Color accentColor;

  const _RankDefinition({
    required this.level,
    required this.titleKu,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleKu,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.reqDhikr,
    required this.reqSessions,
    required this.iconData,
    required this.accentColor,
  });

  String getTitle(String lang) {
    if (lang == 'ku') return titleKu;
    if (lang == 'ar') return titleAr;
    return titleEn;
  }

  String getSubtitle(String lang) {
    if (lang == 'ku') return subtitleKu;
    if (lang == 'ar') return subtitleAr;
    return subtitleEn;
  }

  String getRequirement(String lang) {
    if (level == 1) {
      if (lang == 'ku') return 'سەرەتای گەشت (٠ یاد)';
      if (lang == 'ar') return '0 ذكر (بداية المسير)';
      return '0 dhikrs (Journey start)';
    }
    if (lang == 'ku') return '$reqDhikr یاد یان $reqSessions دانیشتن';
    if (lang == 'ar') return '$reqDhikr ذكر أو $reqSessions جلسة';
    return '$reqDhikr dhikrs or $reqSessions sessions';
  }
}

class _RankInfo {
  final int level;
  final String title;
  final String subtitle;
  final String tierBadge;
  final String requirementText;
  final IconData iconData;
  final Color accentColor;
  final int currentProgress;
  final int targetProgress;
  final String? nextRankTitle;
  final String? nextRankReq;
  final int remainingToNext;
  final double progressPercent;
  final bool isMaxLevel;

  _RankInfo({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.tierBadge,
    required this.requirementText,
    required this.iconData,
    required this.accentColor,
    required this.currentProgress,
    required this.targetProgress,
    this.nextRankTitle,
    this.nextRankReq,
    required this.remainingToNext,
    required this.progressPercent,
    required this.isMaxLevel,
  });
}

class _SpiritualAchievement {
  final String id;
  final String category;
  final String categoryKu;
  final String categoryAr;
  final String categoryEn;
  final String titleKu;
  final String titleAr;
  final String titleEn;
  final String descKu;
  final String descAr;
  final String descEn;
  final String hadithKu;
  final String hadithAr;
  final String hadithEn;
  final IconData icon;
  final int targetValue;
  final int currentValue;
  final String unitKu;
  final String unitAr;
  final String unitEn;

  const _SpiritualAchievement({
    required this.id,
    required this.category,
    required this.categoryKu,
    required this.categoryAr,
    required this.categoryEn,
    required this.titleKu,
    required this.titleAr,
    required this.titleEn,
    required this.descKu,
    required this.descAr,
    required this.descEn,
    required this.hadithKu,
    required this.hadithAr,
    required this.hadithEn,
    required this.icon,
    required this.targetValue,
    required this.currentValue,
    required this.unitKu,
    required this.unitAr,
    required this.unitEn,
  });

  bool get isUnlocked => currentValue >= targetValue;
  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  String getTitle(String lang) {
    if (lang == 'ku') return titleKu;
    if (lang == 'ar') return titleAr;
    return titleEn;
  }

  String getCategory(String lang) {
    if (lang == 'ku') return categoryKu;
    if (lang == 'ar') return categoryAr;
    return categoryEn;
  }

  String getDesc(String lang) {
    if (lang == 'ku') return descKu;
    if (lang == 'ar') return descAr;
    return descEn;
  }

  String getHadith(String lang) {
    if (lang == 'ku') return hadithKu;
    if (lang == 'ar') return hadithAr;
    return hadithEn;
  }

  String getUnit(String lang) {
    if (lang == 'ku') return unitKu;
    if (lang == 'ar') return unitAr;
    return unitEn;
  }
}
