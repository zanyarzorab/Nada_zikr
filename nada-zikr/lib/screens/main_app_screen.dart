import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../widgets/app_theme.dart';
import 'home_screen.dart';
import 'prayer_times_screen.dart';
import 'tasbeeh_screen.dart';
import 'quran_screen.dart';
import 'settings_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({Key? key}) : super(key: key);

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  void _onSelectTab(int index) {
    if (mounted) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onSelectTab: _onSelectTab),
      const PrayerTimesScreen(),
      const TasbeehScreen(),
      const QuranScreen(),
      const SettingsScreen(),
    ];
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';

    final List<_NavItemData> items = [
      const _NavItemData(
        labelKey: 'home',
        inactiveIcon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      const _NavItemData(
        labelKey: 'prayerTimes',
        inactiveIcon: Icons.mosque_outlined,
        activeIcon: Icons.mosque_rounded,
      ),
      const _NavItemData(
        labelKey: 'tasbeeh',
        inactiveIcon: Icons.filter_vintage_outlined,
        activeIcon: Icons.filter_vintage,
      ),
      const _NavItemData(
        labelKey: 'quran',
        inactiveIcon: Icons.auto_stories_outlined,
        activeIcon: Icons.auto_stories_rounded,
      ),
      const _NavItemData(
        labelKey: 'settings',
        inactiveIcon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
      ),
    ];

    String resolveLabel(String key) {
      final translated = loc?.translate(key);
      if (translated != null && translated.trim().isNotEmpty) return translated;

      switch (key) {
        case 'home':
          return 'Home';
        case 'azkar':
          return 'Zikr & Duas';
        case 'prayerTimes':
          return 'Prayer Times';
        case 'tasbeeh':
          return 'Tasbeeh';
        case 'quran':
          return 'Quran';
        case 'settings':
          return 'Settings';
        default:
          return key[0].toUpperCase() + key.substring(1);
      }
    }

    final isDark = AppThemeController.instance.palette.isDark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: _InstagramFbNavBar(
        selectedIndex: _selectedIndex,
        items: items,
        onTap: (index) => setState(() => _selectedIndex = index),
        resolveLabel: resolveLabel,
        isDark: isDark,
        languageCode: lang,
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.labelKey,
    required this.inactiveIcon,
    required this.activeIcon,
  });

  final String labelKey;
  final IconData inactiveIcon;
  final IconData activeIcon;
}

class _InstagramFbNavBar extends StatelessWidget {
  const _InstagramFbNavBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    required this.resolveLabel,
    required this.isDark,
    required this.languageCode,
  });

  final int selectedIndex;
  final List<_NavItemData> items;
  final ValueChanged<int> onTap;
  final String Function(String) resolveLabel;
  final bool isDark;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarBgColor = isDark
        ? AppColors.darkBg.withValues(alpha: 0.92)
        : AppColors.panelColor.withValues(alpha: 0.94);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: navBarBgColor,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.panelBorderColor.withValues(alpha: 0.45)
                    : Colors.black.withValues(alpha: 0.08),
                width: 0.6,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: SizedBox(
              height: 60,
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isActive = selectedIndex == index;
                  final label = resolveLabel(item.labelKey);

                  return Expanded(
                    child: _NavBarTabButton(
                      isActive: isActive,
                      activeIcon: item.activeIcon,
                      inactiveIcon: item.inactiveIcon,
                      label: label,
                      languageCode: languageCode,
                      onTap: () => onTap(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarTabButton extends StatefulWidget {
  const _NavBarTabButton({
    Key? key,
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.languageCode,
    required this.onTap,
  }) : super(key: key);

  final bool isActive;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final String languageCode;
  final VoidCallback onTap;

  @override
  State<_NavBarTabButton> createState() => _NavBarTabButtonState();
}

class _NavBarTabButtonState extends State<_NavBarTabButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.82)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.82, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_animController);
  }

  @override
  void didUpdateWidget(covariant _NavBarTabButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animController.forward(from: 0.0);
    widget.onTap();
  }

  TextStyle _resolveTextStyle(Color color) {
    final fontWeight = widget.isActive ? FontWeight.w700 : FontWeight.w500;
    if (widget.languageCode == 'ku') {
      return AppTheme.kurdishText(
        color: color,
        fontSize: 10.5,
        fontWeight: fontWeight,
      ).copyWith(height: 1.2);
    } else if (widget.languageCode == 'ar') {
      return AppTheme.arabicText(
        color: color,
        fontSize: 10.5,
      ).copyWith(height: 1.2, fontWeight: fontWeight);
    }
    return AppTheme.englishText(
      color: color,
      fontSize: 10.5,
      fontWeight: fontWeight,
    ).copyWith(height: 1.2);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.gold;
    final inactiveColor = AppColors.veryFaintText.withValues(alpha: 0.72);
    final currentColor = widget.isActive ? activeColor : inactiveColor;

    return Tooltip(
      message: widget.label,
      waitDuration: const Duration(milliseconds: 600),
      child: Semantics(
        label: widget.label,
        selected: widget.isActive,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Outline ⇄ Filled Icon
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: child,
                        ),
                        child: Icon(
                          widget.isActive ? widget.activeIcon : widget.inactiveIcon,
                          key: ValueKey<bool>(widget.isActive),
                          size: 22,
                          color: currentColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Localized Title Text underneath
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: _resolveTextStyle(currentColor),
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
