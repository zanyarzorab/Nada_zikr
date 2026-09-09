import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/azkar_model.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import 'main_app_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String _name = '';
  int _goal = 3;
  String _languageCode = 'ku';
  late PageController _pageController;

  static const _languageOptions = [
    {'code': 'ku', 'label': 'کوردی'},
    {'code': 'ar', 'label': 'العربية'},
    {'code': 'en', 'label': 'English'},
  ];

  static const _stepsByLanguage = {
    'ku': [
      {
        'title': 'بەخێربێیت',
        'subtitle': 'بەخێربێیت بۆ نەدا',
        'body': 'هاوڕێی ڕۆژانەی تۆیە بۆ زیکر، بیرکردنەوە و ئارامی دڵ.'
      },
      {
        'title': 'بسم الله',
        'subtitle': 'نیەتەکەت لە سەردانی ڕؤژانە ',
        'body':
            'ناوت و ژمارەی ئەو دانیشتنەی کە دەتەوێت هەموو ڕۆژێک ئەنجامی بدەیت بنووسە.'
      },
      {
        'title': 'ئامادەیت؟',
        'subtitle': 'ئێستا ئامادەیت',
        'body': 'گەشتەکەت بە یەکەم هەنگاوی بیرکردنەوە دەست پێ بکە.'
      },
    ],
    'ar': [
      {
        'title': 'مرحباً بك',
        'subtitle': 'مرحباً بك في نَدَى',
        'body': 'رفيقك الروحي اليومي للذكر والتأمل وطمأنينة القلب.'
      },
      {
        'title': 'بسم الله',
        'subtitle': 'حدّد نيتك',
        'body': 'أخبرنا باسمك وعدد الجلسات التي تريدها كل يوم.'
      },
      {
        'title': 'هل أنت مستعد؟',
        'subtitle': 'أنت مستعد الآن',
        'body': 'ابدأ رحلتك بالخطوة الأولى من الذكر.'
      },
    ],
    'en': [
      {
        'title': 'Welcome',
        'subtitle': 'Welcome to Nada',
        'body': 'Your daily companion for dhikr, reflection, and inner peace.'
      },
      {
        'title': 'Bismillah',
        'subtitle': 'Set Your Intention',
        'body': 'Tell us your name and how many sessions you want each day.'
      },
      {
        'title': 'Ready?',
        'subtitle': 'You Are Ready',
        'body': 'Start your journey with your first mindful moment.'
      },
    ],
  };

  List<Map<String, String>> get _steps => _stepsByLanguage[_languageCode]!
      .map((step) => Map<String, String>.from(step))
      .toList(growable: false);

  TextStyle _titleStyle({double fontSize = 36}) {
    if (_languageCode == 'ku') {
      return AppTheme.kurdishTitle(fontSize: fontSize);
    }
    if (_languageCode == 'ar') {
      return AppTheme.arabicTitle(fontSize: fontSize);
    }
    return AppTheme.englishTitle(fontSize: fontSize);
  }

  TextStyle _bodyStyle({Color? color, double fontSize = 14}) {
    if (_languageCode == 'ku') {
      return AppTheme.kurdishText(color: color, fontSize: fontSize);
    }
    if (_languageCode == 'ar') {
      return AppTheme.arabicText(color: color, fontSize: fontSize);
    }
    return AppTheme.englishText(color: color, fontSize: fontSize);
  }

  String get _continueLabel => _languageCode == 'ku'
      ? 'بەردەوامبە'
      : _languageCode == 'ar'
          ? 'متابعة'
          : 'Continue';

  String get _beginLabel => _languageCode == 'ku'
      ? 'گەشتەکەم دەست پێ بکە'
      : _languageCode == 'ar'
          ? 'ابدأ رحلتي'
          : 'Begin My Journey';

  String get _nameLabel => _languageCode == 'ku'
      ? 'ناوت'
      : _languageCode == 'ar'
          ? 'اسمك'
          : 'YOUR NAME';

  String get _dailyGoalLabel => _languageCode == 'ku'
      ? 'ئامانجی ڕۆژانە — $_goal دانیشتن'
      : _languageCode == 'ar'
          ? 'الهدف اليومي — $_goal جلسات'
          : 'DAILY GOAL — $_goal session${_goal > 1 ? 's' : ''}';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _languageCode = AppLocalizations.languageCode;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_step < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _step++);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final profile = UserProfile(
      name: _name.trim(),
      dailyGoal: _goal,
      currentStreak: 0,
      bestStreak: 0,
      totalSessions: 0,
      lastSessionDate: DateTime.now(),
    );

    await StorageService.saveUserProfile(profile);
    await StorageService.setFirstLaunchCompleted();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainAppScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBg,
              AppColors.darkBgAlt,
              const Color(0xFF163322),
            ],
          ),
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              top: MediaQuery.of(context).padding.top + 12,
              end: 20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.panelColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.panelBorderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _languageCode,
                    icon: Icon(Icons.expand_more,
                        color: AppColors.gold, size: 18),
                    dropdownColor: AppColors.darkPanel,
                    borderRadius: BorderRadius.circular(14),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    style: _bodyStyle(color: AppColors.cream, fontSize: 12),
                    onChanged: (code) async {
                      if (code == null) return;
                      AppLocalizations.setLanguageCode(code);
                      await StorageService.saveSetting('language', code);
                      if (mounted) setState(() => _languageCode = code);
                    },
                    items: _languageOptions
                        .map((option) => DropdownMenuItem<String>(
                              value: option['code'],
                              child: Text(option['label']!),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
            // Ambient stars
            ...List.generate(18, (i) {
              return Positioned(
                left: MediaQuery.of(context).size.width *
                    ((i * 17 + 5) % 95) /
                    100,
                top: MediaQuery.of(context).size.height *
                    ((i * 11 + 3) % 55) /
                    100,
                child: Container(
                  width: i % 3 == 0 ? 2 : 1.5,
                  height: i % 3 == 0 ? 2 : 1.5,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
            // Main content
            Column(
              children: [
                // App Icon
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    bottom: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/icon/nada_app_icon_squircle.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Step dots
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          width: i == _step ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == _step
                                ? AppColors.gold
                                : AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep0(),
                      _buildStep1(),
                      _buildStep2(),
                    ],
                  ),
                ),

                // CTA Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(AppColors.gold),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _step == _steps.length - 1
                              ? '$_beginLabel →'
                              : _continueLabel,
                          style: _titleStyle(fontSize: 16).copyWith(
                            color: AppColors.darkBg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.panelColor,
              border: Border.all(color: AppColors.panelBorderColor),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                      child: Icon(Icons.auto_awesome_rounded, size: 28, color: Color(0xFFC9A84C))),
                ),
                const SizedBox(height: 16),
                Text(
                  _steps[0]['title']!,
                  style: _titleStyle(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _steps[0]['subtitle']!,
                  style: _titleStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _steps[0]['body']!,
                  style: _bodyStyle(color: AppColors.faintText),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.panelColor,
              border: Border.all(color: AppColors.panelBorderColor),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  _steps[1]['title']!,
                  style: _titleStyle(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _steps[1]['subtitle']!,
                  style: _titleStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_nameLabel, style: _bodyStyle(fontSize: 11)),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => _name = value,
                  decoration: InputDecoration(
                    hintText: 'e.g. Ahmad',
                    hintStyle:
                        AppTheme.englishText(color: AppColors.veryFaintText),
                    filled: true,
                    fillColor: AppColors.panelColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.gold),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  style: _bodyStyle(color: AppColors.cream),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(_dailyGoalLabel, style: _bodyStyle(fontSize: 11)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [1, 2, 3, 5, 7].map((n) {
                    final selected = _goal == n;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ElevatedButton(
                          onPressed: () => setState(() => _goal = n),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selected
                                ? AppColors.gold
                                : AppColors.panelColor,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 44),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$n',
                              style: AppTheme.englishTitle(
                                color: selected
                                    ? AppColors.darkBg
                                    : AppColors.lightText,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.panelColor,
              border: Border.all(color: AppColors.panelBorderColor),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                      child: Icon(Icons.wb_sunny_rounded, size: 28, color: Color(0xFFC9A84C))),
                ),
                const SizedBox(height: 16),
                Text(
                  _steps[2]['title']!,
                  style: _titleStyle(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _steps[2]['subtitle']!,
                  style: _titleStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.24)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text('FIRST DHIKR OF THE DAY',
                          style: AppTheme.labelText(
                              color: AppColors.veryFaintText)),
                      const SizedBox(height: 12),
                      Text('بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ',
                          style: AppTheme.arabicTitle(fontSize: 24),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl),
                      const SizedBox(height: 12),
                      Text(
                          'In the Name of Allah, the Most Gracious, the Most Merciful',
                          style: AppTheme.englishText(
                              color: AppColors.faintText, fontSize: 12),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
