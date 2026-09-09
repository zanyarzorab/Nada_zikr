class DailyActivitySummary {
  final DateTime date;
  final String dayNameKu;
  final String dayNameAr;
  final String dayNameEn;
  final String dayShortKu;
  final String dayShortAr;
  final String dayShortEn;
  final int totalCount;
  final int sessionsCount;
  final bool isToday;
  final bool isFuture;
  final List<String> topZikrs;

  const DailyActivitySummary({
    required this.date,
    required this.dayNameKu,
    required this.dayNameAr,
    required this.dayNameEn,
    required this.dayShortKu,
    required this.dayShortAr,
    required this.dayShortEn,
    required this.totalCount,
    required this.sessionsCount,
    required this.isToday,
    required this.isFuture,
    required this.topZikrs,
  });

  String getDayName(String lang) {
    if (lang == 'ku') return dayNameKu;
    if (lang == 'ar') return dayNameAr;
    return dayNameEn;
  }

  String getDayShort(String lang) {
    if (lang == 'ku') return dayShortKu;
    if (lang == 'ar') return dayShortAr;
    return dayShortEn;
  }
}

class WeeklyActivityReport {
  final List<DailyActivitySummary> days;
  final int totalCount;
  final int totalSessions;
  final int activeDaysCount;
  final double dailyAverage;
  final int maxDayCount;
  final int bestDayIndex;
  final String bestDayNameKu;
  final String bestDayNameAr;
  final String bestDayNameEn;
  final int consistencyPercent;

  const WeeklyActivityReport({
    required this.days,
    required this.totalCount,
    required this.totalSessions,
    required this.activeDaysCount,
    required this.dailyAverage,
    required this.maxDayCount,
    required this.bestDayIndex,
    required this.bestDayNameKu,
    required this.bestDayNameAr,
    required this.bestDayNameEn,
    required this.consistencyPercent,
  });

  String getBestDayName(String lang) {
    if (lang == 'ku') return bestDayNameKu;
    if (lang == 'ar') return bestDayNameAr;
    return bestDayNameEn;
  }
}
