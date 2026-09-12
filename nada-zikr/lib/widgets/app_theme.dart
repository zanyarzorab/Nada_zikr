import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

class AppPalette {
  final String key;
  final String label;
  final String labelKu;
  final String description;
  final bool isDark;
  final Color darkBg;
  final Color darkBgAlt;
  final Color panelColor;
  final Color panelBorderColor;
  final Color gold;
  final Color cream;
  final Color accent1;
  final Color accent2;
  final Color accent3;
  final Color lightText;
  final Color faintText;
  final Color veryFaintText;
  final Color mutedText;
  final Color softSurface;

  const AppPalette({
    required this.key,
    required this.label,
    required this.labelKu,
    required this.description,
    required this.isDark,
    required this.darkBg,
    required this.darkBgAlt,
    required this.panelColor,
    required this.panelBorderColor,
    required this.gold,
    required this.cream,
    required this.accent1,
    required this.accent2,
    required this.accent3,
    required this.lightText,
    required this.faintText,
    required this.veryFaintText,
    required this.mutedText,
    required this.softSurface,
  });

  String getLocalizedLabel(bool isKurdish) => isKurdish ? labelKu : label;
}

class AppPalettes {
  // 1. Nûrî Emerald & Gold (Default Kurdish Classic)
  static const AppPalette nuri = AppPalette(
    key: 'nuri',
    label: 'Nûrî Emerald',
    labelKu: 'زمردی و زێڕین',
    description: 'Deep Kurdish emerald green with polished gold highlights',
    isDark: true,
    darkBg: Color(0xFF07140E),
    darkBgAlt: Color(0xFF0E251B),
    panelColor: Color(0xFF122C21),
    panelBorderColor: Color(0x3D4DAE8C),
    gold: Color(0xFFD4AF37),
    cream: Color(0xFFF7F2E7),
    accent1: Color(0xFF4DAE8C),
    accent2: Color(0xFFE08A3C),
    accent3: Color(0xFF8B7DF8),
    lightText: Color(0xFFE5DDD0),
    faintText: Color(0xFFB5C9BC),
    veryFaintText: Color(0xFF829E8C),
    mutedText: Color(0xFF98B8A4),
    softSurface: Color(0xFF17382A),
  );

  // 2. Obsidian Gold (Luxury Midnight)
  static const AppPalette obsidian = AppPalette(
    key: 'obsidian',
    label: 'Obsidian Gold',
    labelKu: 'پۆڵای تاریک و زێڕین',
    description: 'Luxury obsidian black with 24K glowing gold highlights',
    isDark: true,
    darkBg: Color(0xFF0A0D10),
    darkBgAlt: Color(0xFF12171C),
    panelColor: Color(0xFF1B222A),
    panelBorderColor: Color(0x40FFD700),
    gold: Color(0xFFFFD700),
    cream: Color(0xFFFAF9F6),
    accent1: Color(0xFFFFC107),
    accent2: Color(0xFFFF9800),
    accent3: Color(0xFFFFAB40),
    lightText: Color(0xFFE2E4E9),
    faintText: Color(0xFFA6AFB9),
    veryFaintText: Color(0xFF75808E),
    mutedText: Color(0xFF9CA5B0),
    softSurface: Color(0xFF232C36),
  );

  // 3. Golden Dawn (Light Daylight Theme)
  static const AppPalette sunrise = AppPalette(
    key: 'sunrise',
    label: 'Golden Dawn',
    labelKu: 'ڕۆژهەڵاتی زێڕین',
    description: 'Warm amber and soft cream for a luminous daylight feel',
    isDark: false,
    darkBg: Color(0xFFF3ECE0),
    darkBgAlt: Color(0xFFE8DECA),
    panelColor: Color(0xFFFAF6EE),
    panelBorderColor: Color(0xFFD5C4A1),
    gold: Color(0xFF9A5B0B),
    cream: Color(0xFF1C140A),
    accent1: Color(0xFFC05E1A),
    accent2: Color(0xFF3E7538),
    accent3: Color(0xFF6B42BF),
    lightText: Color(0xFF2B2014),
    faintText: Color(0xFF584734),
    veryFaintText: Color(0xFF75624D),
    mutedText: Color(0xFF64513C),
    softSurface: Color(0xFFE2D6BE),
  );

  // 4. Forest Calm (Pine Green)
  static const AppPalette forest = AppPalette(
    key: 'forest',
    label: 'Forest Calm',
    labelKu: 'دارستانی هێمن',
    description: 'Fresh pine green tones and grounded earthy balance',
    isDark: true,
    darkBg: Color(0xFF081812),
    darkBgAlt: Color(0xFF102A20),
    panelColor: Color(0xFF16382C),
    panelBorderColor: Color(0x3852B788),
    gold: Color(0xFFD4AF37),
    cream: Color(0xFFF2F7EF),
    accent1: Color(0xFF52B788),
    accent2: Color(0xFFE07A5F),
    accent3: Color(0xFF74C69D),
    lightText: Color(0xFFDBE7D9),
    faintText: Color(0xFFA6C4A6),
    veryFaintText: Color(0xFF7B9B7B),
    mutedText: Color(0xFF8FA89B),
    softSurface: Color(0xFF1E4637),
  );

  // 5. Royal Violet Dusk (Velvet Violet)
  static const AppPalette dusk = AppPalette(
    key: 'dusk',
    label: 'Royal Violet Dusk',
    labelKu: 'بنەوشەیی شاهانە',
    description: 'Velvet violet and lavender for a calm, premium mood',
    isDark: true,
    darkBg: Color(0xFF120C1D),
    darkBgAlt: Color(0xFF1B122C),
    panelColor: Color(0xFF261A3E),
    panelBorderColor: Color(0x40C084FC),
    gold: Color(0xFFF6C86D),
    cream: Color(0xFFF8F3FE),
    accent1: Color(0xFFC084FC),
    accent2: Color(0xFFF472B6),
    accent3: Color(0xFF818CF8),
    lightText: Color(0xFFE7DBF8),
    faintText: Color(0xFFB9A6D3),
    veryFaintText: Color(0xFF8C76A8),
    mutedText: Color(0xFFA592C0),
    softSurface: Color(0xFF31224F),
  );

  // 6. Midnight Sapphire (Navy Blue)
  static const AppPalette ocean = AppPalette(
    key: 'ocean',
    label: 'Midnight Sapphire',
    labelKu: 'یاقوتی شین',
    description: 'Deep navy ocean blue with cyan and sapphire accents',
    isDark: true,
    darkBg: Color(0xFF07111D),
    darkBgAlt: Color(0xFF0E1F34),
    panelColor: Color(0xFF142B47),
    panelBorderColor: Color(0x4038BDF8),
    gold: Color(0xFF38BDF8),
    cream: Color(0xFFF0F7FF),
    accent1: Color(0xFF0EA5E9),
    accent2: Color(0xFF38BDF8),
    accent3: Color(0xFF818CF8),
    lightText: Color(0xFFD6E9FA),
    faintText: Color(0xFF90B9DE),
    veryFaintText: Color(0xFF6592BC),
    mutedText: Color(0xFF7FAACF),
    softSurface: Color(0xFF1B375B),
  );

  // 7. Rose Gold Burgundy (Luxury Rose)
  static const AppPalette rose = AppPalette(
    key: 'rose',
    label: 'Rose Gold Burgundy',
    labelKu: 'مەییی گوڵباخی شاهانە',
    description: 'Rich burgundy with elegant rose gold accents',
    isDark: true,
    darkBg: Color(0xFF180A12),
    darkBgAlt: Color(0xFF28101E),
    panelColor: Color(0xFF36162A),
    panelBorderColor: Color(0x40F4A261),
    gold: Color(0xFFF6A97A),
    cream: Color(0xFFFFF0F5),
    accent1: Color(0xFFFB7185),
    accent2: Color(0xFFF43F5E),
    accent3: Color(0xFFFDA4AF),
    lightText: Color(0xFFF4DAE3),
    faintText: Color(0xFFC8A0B2),
    veryFaintText: Color(0xFF9E7187),
    mutedText: Color(0xFFBA8F9F),
    softSurface: Color(0xFF451D36),
  );

  // 8. Pure OLED Black (Battery Saving 100% Dark)
  static const AppPalette oled = AppPalette(
    key: 'oled',
    label: 'Pure OLED Black',
    labelKu: 'ڕەشی ڕەقیک بۆ شەو',
    description: '100% pitch black for AMOLED battery saving with gold accent',
    isDark: true,
    darkBg: Color(0xFF000000),
    darkBgAlt: Color(0xFF0D0D0D),
    panelColor: Color(0xFF161616),
    panelBorderColor: Color(0x38FFD700),
    gold: Color(0xFFFFD700),
    cream: Color(0xFFFFFFFF),
    accent1: Color(0xFFFFC107),
    accent2: Color(0xFFFF9800),
    accent3: Color(0xFF81D4FA),
    lightText: Color(0xFFEBEBEB),
    faintText: Color(0xFFB0B0B0),
    veryFaintText: Color(0xFF7E7E7E),
    mutedText: Color(0xFFA0A0A0),
    softSurface: Color(0xFF1E1E1E),
  );

  static const List<AppPalette> values = [
    nuri,
    obsidian,
    sunrise,
    forest,
    dusk,
    ocean,
    rose,
    oled,
  ];

  static AppPalette byKey(String? key) {
    for (final palette in values) {
      if (palette.key == key) return palette;
    }
    return nuri;
  }
}

class AppThemeController extends ChangeNotifier {
  AppThemeController._();

  static final AppThemeController instance = AppThemeController._();

  AppPalette _palette = AppPalettes.nuri;

  AppPalette get palette => _palette;

  Future<void> loadStoredTheme() async {
    final stored = await StorageService.readSetting('appTheme',
        defaultValue: AppPalettes.nuri.key);
    _palette = AppPalettes.byKey(stored?.toString());
    notifyListeners();
  }

  Future<void> setPalette(String key) async {
    _palette = AppPalettes.byKey(key);
    await StorageService.saveSetting('appTheme', key);
    notifyListeners();
  }
}

class AppColors {
  static AppPalette get current => AppThemeController.instance.palette;

  static Color get gold => current.gold;
  static Color get cream => current.cream;
  static Color get darkBg => current.darkBg;
  static Color get darkPanel => current.softSurface;
  static Color get darkBgAlt => current.darkBgAlt;

  static Color get accent1 => current.accent1;
  static Color get accent2 => current.accent2;
  static Color get accent3 => current.accent3;

  static Color get morningColor => current.accent2;
  static Color get eveningColor => current.accent1;
  static Color get sleepColor => current.accent3;
  static Color get prayerColor => current.accent1;
  static Color get quranColor => current.accent2;
  static Color get generalColor => current.gold;

  static Color get fireOrange => current.accent2;
  static Color get lightGray => current.mutedText;

  static Color get panelColor => current.panelColor;
  static Color get panelBorderColor => current.panelBorderColor;
  static Color get lightText => current.lightText;
  static Color get faintText => current.faintText;
  static Color get veryFaintText => current.veryFaintText;
  static Color get mutedText => current.mutedText;
  static Color get softSurface => current.softSurface;

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color getGradientColor(Color color, {required bool darker}) {
    return Color.lerp(color, darkBg, darker ? 0.3 : 0.1) ?? color;
  }
}

class AppTheme {
  static TextStyle arabicTitle({
    Color? color,
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.bold,
    double? height,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.gold,
      height: height,
      letterSpacing: 0.2,
    );
  }

  static TextStyle arabicText({
    Color? color,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    double? height,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.gold,
      height: height,
      letterSpacing: 0.1,
    );
  }

  // Scheherazade New is the premier authentic, warm, and elegant traditional Arabic Quran typeface.
  static TextStyle quranAyahText({
    Color? color,
    double fontSize = 23,
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.9,
  }) {
    return GoogleFonts.scheherazadeNew(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.cream,
      height: height,
      letterSpacing: 0,
    );
  }

  static TextStyle englishTitle({
    Color? color,
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.cream,
      letterSpacing: -0.4,
    );
  }

  static TextStyle englishText({
    Color? color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.cream,
      letterSpacing: 0.1,
    );
  }

  static TextStyle labelText({
    Color? color,
    double fontSize = 11,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.veryFaintText,
      letterSpacing: 1.3,
    );
  }

  static TextStyle kurdishTitle({
    Color? color,
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
    double? height,
  }) {
    return GoogleFonts.notoNaskhArabic(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.cream,
      height: height ?? 1.35,
    );
  }

  static TextStyle kurdishText({
    Color? color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    double? height,
  }) {
    return GoogleFonts.notoNaskhArabic(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.cream,
      height: height ?? 1.7,
    );
  }

  static TextStyle tafsirText({
    required String tafsirId,
    Color? color,
    double fontSize = 15,
  }) {
    final sansSources = {
      'asan',
      'puxta',
      'raman',
      'zhin',
      'runahi',
      'sanahi',
      'krd'
    };
    final font = sansSources.contains(tafsirId)
        ? GoogleFonts.notoSansArabic
        : GoogleFonts.notoNaskhArabic;

    return font(
      fontSize: fontSize,
      color: color ?? AppColors.cream,
      height: 1.8,
    );
  }

  static ButtonStyle goldButton({
    double height = 56,
    double radius = 16,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.gold,
      foregroundColor: AppColors.darkBg,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: height / 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
