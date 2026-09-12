import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/zikr_text_item.dart';
import '../services/storage_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _totalCount = 0;
  Map<String, int> _counts = {};

  static const _titles = [
    ZikrTextItem(id: 'default', titleEn: 'Default Dhikr', titleKu: 'زیکری بنەڕەت', titleAr: 'الذكر الرئيسي', target: 33),
    ZikrTextItem(id: 'subha', titleEn: 'Morning & Evening', titleKu: 'بەیانی و ئیوارە', titleAr: 'أذكار الصباح والمساء', target: 33),
    ZikrTextItem(id: 'travel', titleEn: 'Travel', titleKu: 'سفر', titleAr: 'أذكار السفر', target: 33),
    ZikrTextItem(id: 'health', titleEn: 'Health & Recovery', titleKu: 'توندوتیژی و چارەسەر', titleAr: 'أذكار المرض', target: 33),
    ZikrTextItem(id: 'protection', titleEn: 'Protection', titleKu: 'پاراستن', titleAr: 'أذكار الحماية', target: 33),
    ZikrTextItem(id: 'personal', titleEn: 'Personal', titleKu: 'شەخسی', titleAr: 'حياة شخصية', target: 33),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    final counts = await StorageService.readAllZikr();
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    setState(() {
      _counts = counts;
      _totalCount = total;
    });
  }

  String _itemTitle(String id, Locale locale) {
    return _titles.firstWhere((item) => item.id == id, orElse: () => _titles.first).title(locale);
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(local.translate('stats'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(local.translate('totalCount'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('$_totalCount', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: _counts.isEmpty
                  ? Center(child: Text(local.translate('noStats')))
                  : ListView(
                      children: _counts.entries.map((entry) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            leading: const Icon(Icons.bar_chart, color: Colors.deepPurple),
                            title: Text(_itemTitle(entry.key, locale)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(entry.value.toString(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(local.translate('counts'), style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
