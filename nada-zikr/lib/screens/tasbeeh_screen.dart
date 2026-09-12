import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_localizations.dart';
import '../services/app_haptics.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({Key? key}) : super(key: key);

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  final TextEditingController _customZikrController = TextEditingController();
  final TextEditingController _customTargetController = TextEditingController();
  final List<String> _presetDhikr = [
    'سُبْحَانَ اللهِ',
    'الْحَمْدُ لِلَّهِ',
    'اللهُ أَكْبَرُ',
    'لَا إِلَهَ إِلَّا اللهُ',
    'أَسْتَغْفِرُ اللهَ',
    'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
  ];

  int _count = 0;
  int _target = 33;
  bool _isCustomTarget = false;
  String _activeDhikr = 'سُبْحَانَ اللهِ';
  bool _isCustom = false;
  final Map<String, Map<String, int>> _savedProgress = {};
  int _selectionVersion = 0;

  int get _inRound => _count % _target;
  int get _rounds => _count ~/ _target;

  double get _currentZikrFontSize {
    final len = _currentZikrText.length;
    if (len > 35) return 18;
    if (len > 22) return 21;
    return 26;
  }

  @override
  void dispose() {
    _customZikrController.dispose();
    _customTargetController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    dynamic raw = await StorageService.readSetting('tasbih_progress');
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {}
    }
    if (raw is Map) {
      for (final entry in raw.entries) {
        if (entry.value is Map) {
          final value = entry.value as Map;
          _savedProgress[entry.key.toString()] = {
            'count': int.tryParse(value['count'].toString()) ?? 0,
            'target': int.tryParse(value['target'].toString()) ?? 33,
          };
        }
      }
    }
    if (mounted) _restoreProgress(_activeDhikr, isCustom: false);
  }

  Future<void> _saveProgress() async {
    final Map<String, dynamic> serializable = {};
    _savedProgress.forEach((key, value) {
      serializable[key] = {
        'count': value['count'] ?? 0,
        'target': value['target'] ?? 33,
      };
    });
    await StorageService.saveSetting('tasbih_progress', jsonEncode(serializable));
  }

  Future<void> _rememberCurrentProgress() async {
    final zikr = _currentZikrText;
    if (zikr.isEmpty) return;
    _savedProgress[zikr] = {'count': _count, 'target': _target};
    await _saveProgress();
  }

  Future<void> _restoreProgress(String zikr, {required bool isCustom}) async {
    final version = ++_selectionVersion;
    final saved = _savedProgress[zikr];
    if (!mounted || version != _selectionVersion) return;
    setState(() {
      _count = saved?['count'] ?? 0;
      _target = saved?['target'] ?? _target;
      _isCustom = isCustom;
      _activeDhikr = zikr;
      _isCustomTarget = _target != 33 && _target != 99;
    });
  }

  String get _currentZikrText {
    final text = _customZikrController.text.trim();
    if (_isCustom && text.isNotEmpty) return text;
    return _activeDhikr;
  }

  void _handleTap() {
    final wasGoalReached = _count > 0 && _count % _target == 0;
    setState(() => _count++);
    _rememberCurrentProgress();

    final zikrKey = _currentZikrText;
    StorageService.incrementZikrCount(zikrKey: zikrKey, count: 1);

    if (_count > 0 && _count % _target == 0) {
      AppHaptics.heavyImpact();
      StorageService.recordSessionCompletion(title: zikrKey);
      StorageService.markDailyPathComplete('tasbeeh');
    } else if (!wasGoalReached) {
      AppHaptics.lightImpact();
    }
  }

  void _reset() {
    setState(() => _count = 0);
    _rememberCurrentProgress();
  }

  Future<void> _applyTarget(int value) async {
    final safeValue = value.clamp(1, 9999);
    setState(() {
      _target = safeValue;
      _isCustomTarget = safeValue != 33 && safeValue != 99;
      _count = 0;
    });
    await _rememberCurrentProgress();
  }

  Future<void> _setPresetTarget(int value) async {
    setState(() {
      _target = value;
      _isCustomTarget = false;
      _count = 0;
    });
    await _rememberCurrentProgress();
  }

  Future<void> _chooseCustomTarget() async {
    _customTargetController.text = _target.toString();
    final lang = AppLocalizations.of(context)?.locale.languageCode ?? 'ku';
    final isKurdish = lang == 'ku';
    final isArabic = lang == 'ar';

    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          child: AlertDialog(
            backgroundColor: AppColors.panelColor,
            title: Text(
              isKurdish
                  ? 'دیاریکردنی ژمارەی ئامانج'
                  : (isArabic ? 'تحديد الهدف' : 'Set Target'),
              style: isKurdish
                  ? AppTheme.kurdishTitle(color: AppColors.gold, fontSize: 18)
                  : AppTheme.englishTitle(color: AppColors.gold, fontSize: 18),
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: TextField(
                  controller: _customTargetController,
                  keyboardType: TextInputType.number,
                  style: AppTheme.englishText(color: AppColors.cream, fontSize: 16),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '100',
                    filled: true,
                    fillColor: AppColors.darkBg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  isKurdish
                      ? 'پاشگەزبوونەوە'
                      : (isArabic ? 'إلغاء' : 'Cancel'),
                  style: TextStyle(color: AppColors.mutedText),
                ),
              ),
              TextButton(
                onPressed: () {
                  final raw = _customTargetController.text.trim();
                  final parsed = int.tryParse(raw);
                  if (parsed != null && parsed > 0) {
                    Navigator.pop(context, parsed);
                  }
                },
                child: Text(
                  isKurdish
                      ? 'پەسەندکردن'
                      : (isArabic ? 'تأكيد' : 'OK'),
                  style: TextStyle(
                      color: AppColors.gold, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await _applyTarget(selected);
    }
  }

  void _selectPreset(String zikr) {
    _customZikrController.clear();
    _restoreProgress(zikr, isCustom: false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isKurdish = loc?.locale.languageCode == 'ku';
    final customTargetLabel = _isCustomTarget
        ? '$_target ×'
        : loc?.locale.languageCode == 'ar'
            ? 'مخصص · أدخل'
            : isKurdish
                ? 'تایبەت · بنووسە'
                : 'Custom · Enter';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkBg,
                AppColors.darkBgAlt,
                AppColors.softSurface,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isKurdish
                                  ? 'تەسبیحی ئەلیکترۆنی'
                                  : 'Electronic Tasbih',
                              style: isKurdish
                                  ? AppTheme.kurdishTitle(
                                      fontSize: 22, color: AppColors.gold)
                                  : AppTheme.englishTitle(
                                      fontSize: 22, color: AppColors.gold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isKurdish
                                  ? 'بۆ ژماردن لە هەر شوێنێكی شاشەکە کلیک بکە'
                                  : 'Tap anywhere on the screen to count',
                              style: AppTheme.englishText(
                                  fontSize: 12, color: AppColors.faintText),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _reset,
                        icon:
                            Icon(Icons.refresh_rounded, color: AppColors.gold),
                        tooltip: isKurdish ? 'ڕیستکردن' : 'Reset',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.panelColor,
                      border: Border.all(color: AppColors.panelBorderColor),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isKurdish ? 'زیکری ئێستا' : 'Current zikr',
                          style: AppTheme.englishText(
                              fontSize: 11, color: AppColors.faintText),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _currentZikrText,
                          textAlign: TextAlign.center,
                          style: AppTheme.kurdishText(
                            color: AppColors.gold,
                            fontSize: _currentZikrFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _customZikrController,
                    style: AppTheme.englishText(
                        color: AppColors.cream, fontSize: 14),
                    textDirection: TextDirection.rtl,
                    onChanged: (value) {
                      final trimmed = value.trim();
                      if (trimmed.isEmpty) {
                        setState(() {
                          _isCustom = false;
                          _activeDhikr = 'سُبْحَانَ اللهِ';
                        });
                        _restoreProgress(_activeDhikr, isCustom: false);
                        return;
                      }
                      _restoreProgress(trimmed, isCustom: true);
                    },
                    decoration: InputDecoration(
                      hintText: isKurdish
                          ? 'زیکری خۆت بنووسە'
                          : 'Write your own zikr',
                      hintStyle: AppTheme.englishText(
                          color: AppColors.veryFaintText, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.panelColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: AppColors.panelBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: AppColors.panelBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.6)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _presetDhikr.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = _presetDhikr[index];
                        final active = !_isCustom && _activeDhikr == item;
                        return GestureDetector(
                          onTap: () => _selectPreset(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.gold.withValues(alpha: 0.18)
                                  : AppColors.panelColor,
                              border: Border.all(
                                color: active
                                    ? AppColors.gold.withValues(alpha: 0.45)
                                    : AppColors.panelBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                item,
                                style: AppTheme.arabicText(
                                  color:
                                      active ? AppColors.gold : AppColors.cream,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [AppColors.softSurface, AppColors.darkBg],
                        ),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.25),
                            width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            blurRadius: 70,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$_count',
                                  style: AppTheme.englishTitle(
                                    color: AppColors.gold,
                                    fontSize: 72,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isKurdish ? 'ژماردن' : 'Tap to count',
                              style: AppTheme.englishText(
                                color: AppColors.veryFaintText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(11, (i) {
                      final filled = i * 3 < _inRound;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                filled ? AppColors.gold : AppColors.panelColor,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                          child: _statCard(
                              isKurdish ? 'خول' : 'Round', '$_rounds')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _statCard(
                              isKurdish ? 'ئامانج' : 'Target', '$_target',
                              highlight: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _statCard(
                              isKurdish ? 'کۆی گشتی' : 'Total', '$_count')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          key: const ValueKey('target-33'),
                          onTap: () => _setPresetTarget(33),
                          child: _targetPill(
                              isKurdish ? '33 ×' : '33x', _target == 33),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          key: const ValueKey('target-99'),
                          onTap: () => _setPresetTarget(99),
                          child: _targetPill(
                              isKurdish ? '99 ×' : '99x', _target == 99),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          key: const ValueKey('target-custom'),
                          onTap: _chooseCustomTarget,
                          child: _targetPill(customTargetLabel,
                              _target != 33 && _target != 99),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _targetPill(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? AppColors.gold.withValues(alpha: 0.18)
            : AppColors.panelColor,
        border: Border.all(
            color: active
                ? AppColors.gold.withValues(alpha: 0.45)
                : AppColors.panelBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: AppTheme.englishText(
            color: active ? AppColors.gold : AppColors.cream,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        border: Border.all(color: AppColors.panelBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTheme.englishTitle(
                color: highlight ? AppColors.gold : AppColors.cream,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTheme.englishText(
                  color: AppColors.faintText, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
