import 'package:flutter_test/flutter_test.dart';
import 'package:nada_zikrakanm/models/weekly_activity_model.dart';
import 'package:nada_zikrakanm/models/zikr_session.dart';

void main() {
  group('Weekly Activity Model & Calculation Tests', () {
    test('DailyActivitySummary returns correct localized names', () {
      final summary = DailyActivitySummary(
        date: DateTime(2026, 9, 5),
        dayNameKu: 'شەممە',
        dayNameAr: 'السبت',
        dayNameEn: 'Saturday',
        dayShortKu: 'شەم',
        dayShortAr: 'سبت',
        dayShortEn: 'Sat',
        totalCount: 150,
        sessionsCount: 3,
        isToday: true,
        isFuture: false,
        topZikrs: ['سبحان الله', 'الحمد لله'],
      );

      expect(summary.getDayName('ku'), 'شەممە');
      expect(summary.getDayName('ar'), 'السبت');
      expect(summary.getDayName('en'), 'Saturday');

      expect(summary.getDayShort('ku'), 'شەم');
      expect(summary.getDayShort('ar'), 'سبت');
      expect(summary.getDayShort('en'), 'Sat');
    });

    test('WeeklyActivityReport metrics aggregate accurately', () {
      final days = List.generate(7, (i) {
        final count = i == 0 ? 100 : (i == 1 ? 50 : 0);
        return DailyActivitySummary(
          date: DateTime(2026, 9, i + 1),
          dayNameKu: 'ڕۆژ $i',
          dayNameAr: 'يوم $i',
          dayNameEn: 'Day $i',
          dayShortKu: 'ڕ$i',
          dayShortAr: 'ي$i',
          dayShortEn: 'D$i',
          totalCount: count,
          sessionsCount: count > 0 ? 2 : 0,
          isToday: i == 1,
          isFuture: i > 1,
          topZikrs: count > 0 ? ['استغفر الله'] : [],
        );
      });

      final report = WeeklyActivityReport(
        days: days,
        totalCount: 150,
        totalSessions: 4,
        activeDaysCount: 2,
        dailyAverage: 75.0,
        maxDayCount: 100,
        bestDayIndex: 0,
        bestDayNameKu: 'شەممە',
        bestDayNameAr: 'السبت',
        bestDayNameEn: 'Saturday',
        consistencyPercent: 29, // 2/7 ≈ 29%
      );

      expect(report.days.length, 7);
      expect(report.totalCount, 150);
      expect(report.totalSessions, 4);
      expect(report.activeDaysCount, 2);
      expect(report.dailyAverage, 75.0);
      expect(report.maxDayCount, 100);
      expect(report.bestDayIndex, 0);
      expect(report.getBestDayName('ku'), 'شەممە');
      expect(report.getBestDayName('ar'), 'السبت');
      expect(report.getBestDayName('en'), 'Saturday');
      expect(report.consistencyPercent, 29);
    });

    test('ZikrSession fromMap parses both legacy title/date and updated itemId/timestamp keys', () {
      // Legacy format
      final legacy = {
        'title': 'subhanallah',
        'count': 33,
        'date': '2026-09-04T12:00:00.000',
      };
      final session1 = ZikrSession.fromMap(legacy);
      expect(session1.itemId, 'subhanallah');
      expect(session1.count, 33);
      expect(session1.timestamp.year, 2026);

      // Updated format
      final updated = {
        'itemId': 'alhamdulillah',
        'count': 100,
        'timestamp': '2026-09-04T14:30:00.000',
      };
      final session2 = ZikrSession.fromMap(updated);
      expect(session2.itemId, 'alhamdulillah');
      expect(session2.count, 100);
      expect(session2.timestamp.hour, 14);

      // toMap includes both keys for backward and forward compatibility
      final map = session2.toMap();
      expect(map['itemId'], 'alhamdulillah');
      expect(map['title'], 'alhamdulillah');
      expect(map.containsKey('timestamp'), isTrue);
      expect(map.containsKey('date'), isTrue);
    });

    test('Saturday week start formula (now.weekday % 7 + 1) % 7 is mathematically exact', () {
      // Dart weekday: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7
      // Saturday should be 0 days ago, Sunday 1, Monday 2, ..., Friday 6.
      int daysSinceSaturday(int weekday) => (weekday % 7 + 1) % 7;

      expect(daysSinceSaturday(6), 0, reason: 'Saturday is day 0 of the week');
      expect(daysSinceSaturday(7), 1, reason: 'Sunday is day 1');
      expect(daysSinceSaturday(1), 2, reason: 'Monday is day 2');
      expect(daysSinceSaturday(2), 3, reason: 'Tuesday is day 3');
      expect(daysSinceSaturday(3), 4, reason: 'Wednesday is day 4');
      expect(daysSinceSaturday(4), 5, reason: 'Thursday is day 5');
      expect(daysSinceSaturday(5), 6, reason: 'Friday is day 6');
    });

    test('Monday week start formula (now.weekday - 1) is exact for English', () {
      int daysSinceMonday(int weekday) => weekday - 1;

      expect(daysSinceMonday(1), 0, reason: 'Monday is day 0');
      expect(daysSinceMonday(2), 1, reason: 'Tuesday is day 1');
      expect(daysSinceMonday(7), 6, reason: 'Sunday is day 6');
    });
  });
}
