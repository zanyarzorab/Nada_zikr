import 'package:flutter/material.dart';
import '../app_localizations.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final pages = [
      const HomeScreen(),
      const HistoryScreen(),
      const StatsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: local.translate('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: local.translate('history')),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: local.translate('stats')),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: local.translate('settings')),
        ],
      ),
    );
  }
}
