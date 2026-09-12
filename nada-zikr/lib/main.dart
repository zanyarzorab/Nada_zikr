import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_localizations.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_app_screen.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/prayer_repository.dart';
import 'services/prayer_widget_service.dart';
import 'services/storage_service.dart';
import 'widgets/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

Future<void> _initializeApp() async {
  await Hive.initFlutter();
  await StorageService.initialize();

  // Pre-warm verified prayer timetable dataset and location cache in memory
  await PrayerRepository.preload();
  await LocationService.getCurrentLocation(forceGps: false);

  // Prompt location permission at app launch
  await LocationService.requestStartupPermission();
  await NotificationService.initialize();
  // NOTE: Battery optimization exclusion is requested AFTER the UI is visible
  // (see _MyAppState.initState post-frame callback), not here during cold startup.
  // Requesting it here would show the system dialog over a blank loading screen.

  // Load persisted language preference or default to Kurdish ('ku')
  final storedLang = await StorageService.readSetting('language', defaultValue: 'ku');
  AppLocalizations.setLanguageCode(storedLang);

  await AppThemeController.instance.loadStoredTheme();
  await NotificationService.rescheduleUpcomingPrayerAzans();
  await PrayerWidgetService.updateWidgets();
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({Key? key}) : super(key: key);

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<void> _initialization = _initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _StartupErrorScreen(error: snapshot.error),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _StartupLoadingScreen(),
          );
        }

        return const MyApp();
      },
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF07110D),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFB88C3E)),
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07110D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to start the app.\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFF6EEDC)),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppThemeController.instance.addListener(_refresh);
    AppLocalizations.languageCodeNotifier.addListener(_refreshAndRescheduleNotifications);

    // Request battery optimization exclusion AFTER the first frame is rendered,
    // so the app UI is visible before the Android system dialog appears.
    // StorageService tracks whether we've already shown this dialog to avoid
    // showing it again on every launch.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestBatteryOptOnce();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppThemeController.instance.removeListener(_refresh);
    AppLocalizations.languageCodeNotifier
        .removeListener(_refreshAndRescheduleNotifications);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only reschedule when the app comes back to the foreground.
    // Android's AlarmManager holds PendingIntents even while the app is in
    // background, so we must NOT cancel + reschedule on every pause — that
    // creates a race where cancel succeeds but reschedule fails mid-flight,
    // leaving the user with zero alarms.
    if (state == AppLifecycleState.resumed) {
      unawaited(NotificationService.rescheduleUpcomingPrayerAzans());
      unawaited(PrayerWidgetService.updateWidgets());
    }
  }

  void _refresh() => setState(() {});

  /// Shows the Android battery-optimization exemption dialog once, after the
  /// first frame renders. Uses a persisted flag so it only appears on first launch.
  void _requestBatteryOptOnce() {
    unawaited(_runBatteryOptRequest());
  }

  Future<void> _runBatteryOptRequest() async {
    try {
      // Only show on Android and only once per install
      final alreadyShown = await StorageService.readSetting(
        'battery_opt_requested',
        defaultValue: false,
      );
      if (alreadyShown == true) return;
      await StorageService.saveSetting('battery_opt_requested', true);
      await NotificationService.requestBatteryOptimizationExclusion();
    } catch (_) {}
  }

  void _refreshAndRescheduleNotifications() {
    _refresh();
    unawaited(NotificationService.rescheduleUpcomingPrayerAzans());
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeController.instance.palette;
    final isDark = palette.isDark;
    final onSurface = isDark ? AppColors.cream : AppColors.darkBg;
    final lang = AppLocalizations.languageCode;
    final isRtl = lang == 'ku' || lang == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: MaterialApp(
        title: 'نەدا: قورئان و یادی خوا',
        onGenerateTitle: (context) =>
            AppLocalizations.of(context)?.translate('appFullTitle') ??
            'نەدا: قورئان و یادی خوا',
        debugShowCheckedModeBanner: false,
        locale: Locale(lang),
        supportedLocales: const [
          Locale('ku'),
          Locale('en'),
          Locale('ar'),
        ],
        localeResolutionCallback: (locale, supported) {
          if (locale == null) return const Locale('en');
          for (final supportedLocale in supported) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          return const Locale('en');
        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          _MaterialLocalizationsDelegate(),
          _WidgetsLocalizationsDelegate(),
          _CupertinoLocalizationsDelegate(),
        ],
        theme: ThemeData(
          useMaterial3: true,
          brightness: isDark ? Brightness.dark : Brightness.light,
          scaffoldBackgroundColor: AppColors.darkBg,
          colorScheme: ColorScheme(
            brightness: isDark ? Brightness.dark : Brightness.light,
            primary: AppColors.gold,
            onPrimary: AppColors.darkBg,
            secondary: AppColors.accent1,
            onSecondary: isDark ? AppColors.cream : AppColors.darkBg,
            surface: AppColors.darkPanel,
            onSurface: onSurface,
            error: Colors.redAccent,
            onError: Colors.white,
            tertiary: AppColors.accent2,
            onTertiary: isDark ? AppColors.cream : AppColors.darkBg,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.darkBg,
            elevation: 0,
            centerTitle: true,
            foregroundColor: AppColors.cream,
          ),
          cardTheme: CardThemeData(
            color: AppColors.darkPanel,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
          ),
          dividerTheme: DividerThemeData(
            color: AppColors.panelBorderColor,
            thickness: 1,
          ),
        ),
        home: FutureBuilder<bool>(
          future: StorageService.isFirstLaunch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.data == true) {
              return const OnboardingScreen();
            }

            return const MainAppScreen();
          },
        ),
      ),
    );
  }
}

class _MaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ku', 'en', 'ar'].contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final frameworkLocale = locale.languageCode == 'ku' ? const Locale('en') : locale;
    return GlobalMaterialLocalizations.delegate.load(frameworkLocale);
  }

  @override
  bool shouldReload(_MaterialLocalizationsDelegate old) => false;
}

class _WidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _WidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ku', 'en', 'ar'].contains(locale.languageCode);

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    // Map Kurdish to Arabic so Flutter treats it as RTL
    final frameworkLocale = locale.languageCode == 'ku' ? const Locale('ar') : locale;
    return GlobalWidgetsLocalizations.delegate.load(frameworkLocale);
  }

  @override
  bool shouldReload(_WidgetsLocalizationsDelegate old) => false;
}

class _CupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ku', 'en', 'ar'].contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final frameworkLocale = locale.languageCode == 'ku' ? const Locale('en') : locale;
    return GlobalCupertinoLocalizations.delegate.load(frameworkLocale);
  }

  @override
  bool shouldReload(_CupertinoLocalizationsDelegate old) => false;
}
