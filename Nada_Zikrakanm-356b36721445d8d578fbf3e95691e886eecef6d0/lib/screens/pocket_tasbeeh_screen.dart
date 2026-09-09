import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../widgets/app_theme.dart';
import '../services/app_haptics.dart';
import '../services/storage_service.dart';

class PocketTasbeehScreen extends StatefulWidget {
  const PocketTasbeehScreen({Key? key}) : super(key: key);

  @override
  State<PocketTasbeehScreen> createState() => _PocketTasbeehScreenState();
}

class _PocketTasbeehScreenState extends State<PocketTasbeehScreen> {
  int _count = 0;
  final int _target = 33;
  late bool _hapticEnabled;

  @override
  void initState() {
    super.initState();
    _hapticEnabled = StorageService.isHapticEnabled();
  }

  void _increment() {
    setState(() {
      _count++;
    });
    StorageService.incrementZikrCount(zikrKey: 'pocket_tasbeeh', count: 1);

    if (_hapticEnabled) {
      if (_count % _target == 0) {
        AppHaptics.heavyImpact();
      } else {
        AppHaptics.lightImpact();
      }
    }

    if (_count > 0 && _count % _target == 0) {
      StorageService.recordSessionCompletion(title: 'تەسبیح');
      StorageService.markDailyPathComplete('tasbeeh');
    }
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
    if (_hapticEnabled) {
      AppHaptics.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isKurdish = loc?.locale.languageCode == 'ku';

    return Scaffold(
      backgroundColor: Colors.black, // Dark OLED background for battery saving & distraction-free
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          loc?.translate('pocketMode') ?? 'تەسبیح',
          style: isKurdish ? AppTheme.kurdishTitle(fontSize: 18, color: AppColors.gold) : AppTheme.englishTitle(fontSize: 18, color: AppColors.gold),
        ),
        actions: [
          IconButton(
            icon: Icon(_hapticEnabled ? Icons.vibration : Icons.do_not_disturb_on, color: AppColors.gold),
            onPressed: () => setState(() => _hapticEnabled = !_hapticEnabled),
            tooltip: loc?.translate('haptic') ?? 'Haptic',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.cream),
            onPressed: _reset,
            tooltip: loc?.translate('reset') ?? 'Reset',
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _increment,
        child: SizedBox.expand(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${_count % _target} / $_target',
                      style: AppTheme.englishTitle(fontSize: 22, color: AppColors.gold),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$_count',
                        style: AppTheme.englishTitle(fontSize: 96, color: AppColors.cream),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      isKurdish
                          ? 'کرتە لە هەر شوێنێکی شاشەکە بکە بۆ ژماردن. دوای هەر ۳۳ کرتە لەرزینێکی گەورەتر دەکات.'
                          : 'Tap anywhere on the screen to count. A stronger vibration signals every 33 counts.',
                      textAlign: TextAlign.center,
                      style: isKurdish ? AppTheme.kurdishText(color: AppColors.mutedText, fontSize: 13) : AppTheme.englishText(color: AppColors.mutedText, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
