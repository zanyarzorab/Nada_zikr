import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/zikr_session.dart';
import '../models/zikr_text_item.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ZikrSession> _sessions = [];

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
    _loadHistory();
  }

  void _loadHistory() async {
    final sessions = await StorageService.readSessions();
    setState(() => _sessions = sessions);
  }

  String _itemTitle(String id, Locale locale) {
    return _titles.firstWhere((item) => item.id == id, orElse: () => _titles.first).title(locale);
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(local.translate('history'))),
      body: _sessions.isEmpty
          ? Center(child: Text(local.translate('noHistory')))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.blueAccent),
                    title: Text(_itemTitle(session.itemId, locale)),
                    subtitle: Text(session.timestamp.toLocal().toString()),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 4),
                        Text('${session.count}', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
