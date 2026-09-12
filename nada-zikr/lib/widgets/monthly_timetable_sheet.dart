import 'package:flutter/material.dart';
import '../services/offline_prayer_calculator.dart';
import '../services/prayer_repository.dart';
import 'app_theme.dart';

/// Full Monthly Timetable Sheet.
class MonthlyTimetableSheet extends StatefulWidget {
  final DateTime initialDate;

  const MonthlyTimetableSheet({Key? key, required this.initialDate}) : super(key: key);

  static Future<void> show(BuildContext context, {required DateTime initialDate}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonthlyTimetableSheet(initialDate: initialDate),
    );
  }

  @override
  State<MonthlyTimetableSheet> createState() => _MonthlyTimetableSheetState();
}

class _MonthlyTimetableSheetState extends State<MonthlyTimetableSheet> {
  late DateTime _currentMonth;
  late Future<List<CalculatedPrayerTimes>> _monthFuture;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
    _loadMonth();
  }

  void _loadMonth() {
    _monthFuture = _fetchMonthTimes(_currentMonth);
  }

  Future<List<CalculatedPrayerTimes>> _fetchMonthTimes(DateTime month) async {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final list = <CalculatedPrayerTimes>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final schedule = await PrayerRepository.getPrayerScheduleForDate(date: date);
      final items = schedule['items'] as List<PrayerTimeItem>;

      DateTime findTime(String id) {
        final found = items.firstWhere((it) => it.id == id, orElse: () => items.first);
        return found.time;
      }

      list.add(CalculatedPrayerTimes(
        date: date,
        fajr: findTime('fajr'),
        sunrise: findTime('sunrise'),
        dhuhr: findTime('dhuhr'),
        asr: findTime('asr'),
        maghrib: findTime('maghrib'),
        isha: findTime('isha'),
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final monthName = '${_currentMonth.year} / ${_currentMonth.month.toString().padLeft(2, '0')}';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left_rounded, color: AppColors.gold),
                        onPressed: () => setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                          _loadMonth();
                        }),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            monthName,
                            style: AppTheme.englishTitle(fontSize: 18, color: AppColors.gold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right_rounded, color: AppColors.gold),
                        onPressed: () => setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                          _loadMonth();
                        }),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: AppColors.faintText),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 12),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.gold.withValues(alpha: 0.1),
            child: Row(
              children: [
                _headerCell('ڕۆژ', width: 35),
                Expanded(child: _headerCell('بەیانی')),
                Expanded(child: _headerCell('هەڵاتن')),
                Expanded(child: _headerCell('نیوەڕۆ')),
                Expanded(child: _headerCell('عەسر')),
                Expanded(child: _headerCell('مەغریب')),
                Expanded(child: _headerCell('عیشا')),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CalculatedPrayerTimes>>(
              future: _monthFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  );
                }
                final monthTimes = snapshot.data!;

                return ListView.separated(
                  itemCount: monthTimes.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, index) {
                    final dayTimes = monthTimes[index];
                    final isToday = dayTimes.date.year == DateTime.now().year &&
                        dayTimes.date.month == DateTime.now().month &&
                        dayTimes.date.day == DateTime.now().day;

                    return Container(
                      color: isToday ? AppColors.gold.withValues(alpha: 0.18) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 35,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                dayTimes.date.day.toString().padLeft(2, '0'),
                                style: AppTheme.englishTitle(
                                  fontSize: 13,
                                  color: isToday ? AppColors.gold : AppColors.cream,
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: _timeCell(dayTimes.fajr, isToday)),
                          Expanded(child: _timeCell(dayTimes.sunrise, isToday)),
                          Expanded(child: _timeCell(dayTimes.dhuhr, isToday)),
                          Expanded(child: _timeCell(dayTimes.asr, isToday)),
                          Expanded(child: _timeCell(dayTimes.maghrib, isToday)),
                          Expanded(child: _timeCell(dayTimes.isha, isToday)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _headerCell(String label, {double? width}) {
    final text = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTheme.kurdishText(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.bold),
      ),
    );
    if (width != null) return SizedBox(width: width, child: text);
    return text;
  }

  Widget _timeCell(DateTime dt, bool isToday) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '$hour:$minute',
        textAlign: TextAlign.center,
        style: AppTheme.englishText(
          fontSize: 11,
          color: isToday ? AppColors.gold : AppColors.cream,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
