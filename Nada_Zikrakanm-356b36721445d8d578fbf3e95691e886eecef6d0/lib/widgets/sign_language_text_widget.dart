import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../services/app_haptics.dart';
import 'app_theme.dart';

/// A high-performance, beautiful renderer that converts Arabic text into
/// authentic Arabic Sign Language Fingerspelling (الأبجدية الإشارية العربية).
class SignLanguageTextWidget extends StatelessWidget {
  final String text;
  final Color? color;
  final double scale;
  final bool showLetterBadge;

  const SignLanguageTextWidget({
    Key? key,
    required this.text,
    this.color,
    this.scale = 1.0,
    this.showLetterBadge = true,
  }) : super(key: key);

  /// Strips Arabic diacritics / tashkeel for clean letter mapping
  static String cleanArabicText(String input) {
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll('ٱ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final clean = cleanArabicText(text);
    if (clean.isEmpty) return const SizedBox.shrink();

    final words = clean.split(RegExp(r'\s+'));
    final effectiveColor = color ?? AppColors.cream;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWordWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;

          return Wrap(
            spacing: 12 * scale,
            runSpacing: 12 * scale,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: words.map((word) {
              return Container(
                constraints: BoxConstraints(maxWidth: maxWordWidth),
                padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 2 * scale),
                decoration: BoxDecoration(
                  color: AppColors.panelColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8 * scale),
                  border: Border.all(color: AppColors.panelBorderColor.withValues(alpha: 0.4)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: word.runes.map((rune) {
                      final char = String.fromCharCode(rune);
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.5 * scale),
                        child: SignLetterTile(
                          char: char,
                          color: effectiveColor,
                          scale: scale,
                          showBadge: showLetterBadge,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

/// Renders a single Arabic Sign Language letter hand-sign tile
class SignLetterTile extends StatelessWidget {
  final String char;
  final Color color;
  final double scale;
  final bool showBadge;

  const SignLetterTile({
    Key? key,
    required this.char,
    required this.color,
    this.scale = 1.0,
    this.showBadge = true,
  }) : super(key: key);

  void _showLetterInspector(BuildContext context) {
    AppHaptics.lightImpact();
    final isKurdish = AppLocalizations.languageCode == 'ku';

    final descriptions = {
      'ا': isKurdish ? 'پەنجەی دۆشاوومژە (Index) ڕاست بەرەو سەرەوە' : 'Index finger pointing straight up',
      'ب': isKurdish ? 'کەفی دەست ڕوو لە پێشەوە بە 4 پەنجەی پێکەوەبەستراو' : 'Open palm with four fingers upright',
      'ت': isKurdish ? 'دوو پەنجە (دۆشاوومژە و باڵابەرز) بەرەو سەرەوە' : 'Two fingers (index & middle) up',
      'ث': isKurdish ? 'سێ پەنجەی ناوەند بەرەو سەرەوە (شێوەی W)' : 'Three fingers upright (W shape)',
      'ج': isKurdish ? 'دەست بە کەوانەیی ئاسۆیی (C) بە پەنجەی گەورە لە خوارەوە' : 'Horizontal C-shape hook hand with thumb below',
      'ح': isKurdish ? 'کەوانەی ئاسۆیی کراوە' : 'Horizontal open curve hand',
      'خ': isKurdish ? 'کەوانەی ئاسۆیی بە نوقتە لە سەرەوە' : 'Horizontal hook hand with dot on top',
      'د': isKurdish ? 'پەنجەی دۆشاوومژە و گەورە بە شێوەی گۆشە (د)' : 'Index & thumb forming angle (د)',
      'ذ': isKurdish ? 'گۆشەی پیتی دال بە نوقتەی سەرەوە' : 'Angle hand with upper dot (ذ)',
      'ر': isKurdish ? 'دەست چەماوە بەرەو خوارەوە' : 'Curved fingers pointing downward',
      'ز': isKurdish ? 'دەست چەماوە بەرەو خوارەوە بە نوقتە' : 'Curved downward hand with dot',
      'س': isKurdish ? 'سێ پەنجە کراوە و جیاواز لە یەکتر' : 'Three fingers spread upright (س)',
      'ش': isKurdish ? 'سێ پەنجە کراوە بە پەنجەی گەورەی درێژکراوە' : 'Three fingers spread with extended thumb',
      'ص': isKurdish ? 'دەستی مستکراو بە پەنجەی گەورە لەسەر پەنجەکان' : 'Fist with thumb across curled fingers',
      'ض': isKurdish ? 'مست بە جومگەی بەرزکراوەی پەنجەی یەکەم' : 'Fist with raised index knuckle',
      'ط': isKurdish ? 'دەست بە ئەڵقەیی و پەنجەی دۆشاوومژە بەرەو سەرەوە' : 'Circle base with index pointing straight up',
      'ظ': isKurdish ? 'پیتی طا بە نوقتەی بەرز' : 'Taa gesture with upper dot',
      'ع': isKurdish ? 'کەوانەی چەماوەی عەین' : 'Curved Ayn hook hand',
      'غ': isKurdish ? 'کەوانەی عەین بە نوقتەی سەرەوە' : 'Curved Ayn hand with dot',
      'ف': isKurdish ? 'ئەڵقەی پەنجەی گەورە و دۆشاوومژە لەگەڵ 3 پەنجەی بەرز' : 'Index & thumb circle with 3 fingers up',
      'ق': isKurdish ? 'دوو پەنجەی چەماوە بەرەو خوارەوە' : 'Two fingers hooked downwards',
      'ك': isKurdish ? 'دەست بە شێوەی گۆشەی کراوەی L' : 'Open angled L-shape hand',
      'ل': isKurdish ? 'پەنجەی دۆشاوومژە بەرەو سەرەوە و گەورە ئاسۆیی (L)' : 'Index up with thumb horizontal (L-shape)',
      'م': isKurdish ? 'مست بە پەنجەکان چەماوە بەرەو خوارەوە' : 'Fist with fingers folded downwards',
      'ن': isKurdish ? 'کەوانەی دەست بە نوقتەی ناوەند' : 'Cup shape with center dot (ن)',
      'ه': isKurdish ? 'سەرپەنجەکانی 5 پەنجە پێکەوەبەستراو وەک قووچەک' : 'Fingertips joined in a cone',
      'ة': isKurdish ? 'سەرپەنجەکانی 5 پەنجە پێکەوەبەستراو (تای مەربوتە)' : 'Fingertips joined (Ta Marbuta)',
      'و': isKurdish ? 'دەستی خڕکراو بە کونی ناوەند' : 'Circular hand with center circle',
      'ي': isKurdish ? 'دەستی مستکراو بە تەنها پەنجەی تووتەکە (Pinky) بەرزکراوە' : 'Fist with pinky finger upright',
    };

    final desc = descriptions[char] ?? (isKurdish ? 'ئاماژەی دەستی پیت' : 'Hand gesture for letter');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkBgAlt,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.panelBorderColor),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.panelBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 110,
                  height: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.panelColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    size: const Size(80, 110),
                    painter: ArabicSignHandPainter(char: char, color: AppColors.gold),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'پیتی ($char)',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.cream,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tileWidth = 32.0 * scale;
    final tileHeight = 46.0 * scale;

    return GestureDetector(
      onTap: () => _showLetterInspector(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: tileWidth,
        height: tileHeight,
        decoration: BoxDecoration(
          color: AppColors.darkBgAlt,
          borderRadius: BorderRadius.circular(6 * scale),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hand Gesture Vector Drawing
            Positioned(
              top: 2 * scale,
              bottom: showBadge ? 12 * scale : 2 * scale,
              child: CustomPaint(
                size: Size(tileWidth - 4 * scale, tileHeight - (showBadge ? 14 * scale : 4 * scale)),
                painter: ArabicSignHandPainter(char: char, color: color),
              ),
            ),
            // Letter Indicator Badge at the bottom
            if (showBadge)
              Positioned(
                bottom: 1 * scale,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4 * scale),
                  ),
                  child: Text(
                    char,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter drawing the specific hand gesture outline for each Arabic letter
class ArabicSignHandPainter extends CustomPainter {
  final String char;
  final Color color;

  const ArabicSignHandPainter({required this.char, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Dispatch hand drawing according to the Arabic letter gesture
    switch (char) {
      case 'ا': // Index finger straight up
        _drawIndexUp(canvas, w, h, paint, fillPaint);
        break;
      case 'ب': // Four fingers upright together, thumb curled
        _drawFourFingersUp(canvas, w, h, paint, fillPaint, dots: 1);
        break;
      case 'ت': // Two fingers (index & middle) up
        _drawTwoFingersUp(canvas, w, h, paint, fillPaint, dots: 2);
        break;
      case 'ث': // Three fingers up (W shape)
        _drawThreeFingersUp(canvas, w, h, paint, fillPaint, dots: 3);
        break;
      case 'ج': // Horizontal C-hook shape pointing right
        _drawHookHand(canvas, w, h, paint, fillPaint, withDot: true, dotBelow: true);
        break;
      case 'ح': // Horizontal C-hook shape without dot
        _drawHookHand(canvas, w, h, paint, fillPaint, withDot: false);
        break;
      case 'خ': // Horizontal C-hook shape with dot on top
        _drawHookHand(canvas, w, h, paint, fillPaint, withDot: true, dotBelow: false);
        break;
      case 'د': // Index and thumb making angle / half circle
        _drawAngleD(canvas, w, h, paint, fillPaint, withDot: false);
        break;
      case 'ذ': // Angle D with dot/index raised
        _drawAngleD(canvas, w, h, paint, fillPaint, withDot: true);
        break;
      case 'ر': // Hand pointing down/curving
        _drawCurvedDown(canvas, w, h, paint, fillPaint, withDot: false);
        break;
      case 'ز': // Hand pointing down with dot
        _drawCurvedDown(canvas, w, h, paint, fillPaint, withDot: true);
        break;
      case 'س': // Three fingers spread wide
        _drawSeenHand(canvas, w, h, paint, fillPaint, withDots: false);
        break;
      case 'ش': // Three fingers spread wide with thumb / dots
        _drawSeenHand(canvas, w, h, paint, fillPaint, withDots: true);
        break;
      case 'ص': // Fist with thumb pressed across
        _drawFist(canvas, w, h, paint, fillPaint, withDot: false);
        break;
      case 'ض': // Fist with raised index knuckle
        _drawFist(canvas, w, h, paint, fillPaint, withDot: true);
        break;
      case 'ط': // Hand making 'O' with index pointing up
        _drawTaaHand(canvas, w, h, paint, fillPaint, withDot: false);
        break;
      case 'ظ': // Taa with dot
        _drawTaaHand(canvas, w, h, paint, fillPaint, withDot: true);
        break;
      case 'ع': // Curved C shape facing left
        _drawAynHand(canvas, w, h, paint, fillPaint, withDot: false);
        break;
      case 'غ': // Curved C shape with dot
        _drawAynHand(canvas, w, h, paint, fillPaint, withDot: true);
        break;
      case 'ف': // Circle with thumb & index, 3 fingers up
        _drawFaaHand(canvas, w, h, paint, fillPaint);
        break;
      case 'ق': // Two fingers curved down
        _drawQaafHand(canvas, w, h, paint, fillPaint);
        break;
      case 'ك': // L-shape / Open palm angled
        _drawKaafHand(canvas, w, h, paint, fillPaint);
        break;
      case 'ل': // L-shape with thumb extended horizontally
        _drawLaamHand(canvas, w, h, paint, fillPaint);
        break;
      case 'م': // Fist with fingers folded downwards
        _drawMeemHand(canvas, w, h, paint, fillPaint);
        break;
      case 'ن': // U-cup with single index inside
        _drawNoonHand(canvas, w, h, paint, fillPaint);
        break;
      case 'ه':
      case 'ة': // All 5 fingertips touching in a cone
        _drawHaaHand(canvas, w, h, paint, fillPaint);
        break;
      case 'و': // Circular hand / fist with hole
        _drawWaawHand(canvas, w, h, paint, fillPaint);
        break;
      case 'ي': // Pinky finger raised
        _drawYaaHand(canvas, w, h, paint, fillPaint);
        break;
      default:
        _drawDefaultHand(canvas, w, h, paint, fillPaint);
        break;
    }
  }

  // --- Hand Gesture Drawing Implementations ---

  void _drawIndexUp(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    final path = Path();
    // Palm base
    path.moveTo(w * 0.25, h * 0.9);
    path.lineTo(w * 0.75, h * 0.9);
    path.lineTo(w * 0.75, h * 0.55);
    // Curled fingers
    path.quadraticBezierTo(w * 0.75, h * 0.45, w * 0.55, h * 0.45);
    // Extended index finger
    path.lineTo(w * 0.55, h * 0.1);
    path.quadraticBezierTo(w * 0.45, h * 0.05, w * 0.35, h * 0.1);
    path.lineTo(w * 0.35, h * 0.5);
    // Thumb resting
    path.quadraticBezierTo(w * 0.2, h * 0.55, w * 0.25, h * 0.75);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawTwoFingersUp(Canvas canvas, double w, double h, Paint stroke, Paint fill, {int dots = 2}) {
    final path = Path();
    path.moveTo(w * 0.2, h * 0.9);
    path.lineTo(w * 0.8, h * 0.9);
    path.lineTo(w * 0.8, h * 0.55);
    // Middle finger
    path.lineTo(w * 0.65, h * 0.55);
    path.lineTo(w * 0.65, h * 0.1);
    path.quadraticBezierTo(w * 0.55, h * 0.05, w * 0.5, h * 0.1);
    path.lineTo(w * 0.5, h * 0.45);
    // Index finger
    path.lineTo(w * 0.45, h * 0.1);
    path.quadraticBezierTo(w * 0.35, h * 0.05, w * 0.3, h * 0.1);
    path.lineTo(w * 0.3, h * 0.55);
    path.lineTo(w * 0.2, h * 0.6);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawThreeFingersUp(Canvas canvas, double w, double h, Paint stroke, Paint fill, {int dots = 3}) {
    final path = Path();
    path.moveTo(w * 0.15, h * 0.9);
    path.lineTo(w * 0.85, h * 0.9);
    path.lineTo(w * 0.85, h * 0.55);
    // Ring finger
    path.lineTo(w * 0.72, h * 0.12);
    path.lineTo(w * 0.62, h * 0.12);
    path.lineTo(w * 0.6, h * 0.4);
    // Middle finger
    path.lineTo(w * 0.52, h * 0.08);
    path.lineTo(w * 0.42, h * 0.08);
    path.lineTo(w * 0.4, h * 0.4);
    // Index finger
    path.lineTo(w * 0.32, h * 0.12);
    path.lineTo(w * 0.22, h * 0.12);
    path.lineTo(w * 0.15, h * 0.6);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawFourFingersUp(Canvas canvas, double w, double h, Paint stroke, Paint fill, {int dots = 1}) {
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.6, h * 0.8), Radius.circular(w * 0.15)));
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Finger lines
    canvas.drawLine(Offset(w * 0.35, h * 0.12), Offset(w * 0.35, h * 0.55), stroke);
    canvas.drawLine(Offset(w * 0.5, h * 0.12), Offset(w * 0.5, h * 0.55), stroke);
    canvas.drawLine(Offset(w * 0.65, h * 0.12), Offset(w * 0.65, h * 0.55), stroke);
  }

  void _drawHookHand(Canvas canvas, double w, double h, Paint stroke, Paint fill,
      {required bool withDot, bool dotBelow = false}) {
    final path = Path();
    path.moveTo(w * 0.75, h * 0.2);
    path.quadraticBezierTo(w * 0.2, h * 0.2, w * 0.2, h * 0.5);
    path.quadraticBezierTo(w * 0.2, h * 0.8, w * 0.75, h * 0.8);
    path.lineTo(w * 0.8, h * 0.7);
    path.quadraticBezierTo(w * 0.35, h * 0.7, w * 0.35, h * 0.5);
    path.quadraticBezierTo(w * 0.35, h * 0.3, w * 0.8, h * 0.3);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    if (withDot) {
      final dotY = dotBelow ? h * 0.9 : h * 0.1;
      canvas.drawCircle(Offset(w * 0.5, dotY), 2.0, stroke);
    }
  }

  void _drawAngleD(Canvas canvas, double w, double h, Paint stroke, Paint fill, {required bool withDot}) {
    final path = Path();
    path.moveTo(w * 0.2, h * 0.85);
    path.lineTo(w * 0.6, h * 0.85);
    path.quadraticBezierTo(w * 0.75, h * 0.85, w * 0.75, h * 0.65);
    path.lineTo(w * 0.45, h * 0.2);
    path.lineTo(w * 0.3, h * 0.25);
    path.lineTo(w * 0.55, h * 0.65);
    path.lineTo(w * 0.2, h * 0.65);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    if (withDot) {
      canvas.drawCircle(Offset(w * 0.5, h * 0.1), 2.0, stroke);
    }
  }

  void _drawCurvedDown(Canvas canvas, double w, double h, Paint stroke, Paint fill, {required bool withDot}) {
    final path = Path();
    path.moveTo(w * 0.3, h * 0.15);
    path.lineTo(w * 0.6, h * 0.15);
    path.quadraticBezierTo(w * 0.6, h * 0.5, w * 0.3, h * 0.85);
    path.lineTo(w * 0.15, h * 0.75);
    path.quadraticBezierTo(w * 0.45, h * 0.5, w * 0.45, h * 0.25);
    path.lineTo(w * 0.3, h * 0.25);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    if (withDot) {
      canvas.drawCircle(Offset(w * 0.65, h * 0.1), 2.0, stroke);
    }
  }

  void _drawSeenHand(Canvas canvas, double w, double h, Paint stroke, Paint fill, {required bool withDots}) {
    final path = Path();
    path.moveTo(w * 0.2, h * 0.85);
    path.lineTo(w * 0.8, h * 0.85);
    path.lineTo(w * 0.8, h * 0.5);
    // 3 prongs
    path.lineTo(w * 0.75, h * 0.15);
    path.lineTo(w * 0.65, h * 0.15);
    path.lineTo(w * 0.6, h * 0.45);
    path.lineTo(w * 0.55, h * 0.15);
    path.lineTo(w * 0.45, h * 0.15);
    path.lineTo(w * 0.4, h * 0.45);
    path.lineTo(w * 0.35, h * 0.15);
    path.lineTo(w * 0.25, h * 0.15);
    path.lineTo(w * 0.2, h * 0.5);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawFist(Canvas canvas, double w, double h, Paint stroke, Paint fill, {required bool withDot}) {
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.25, w * 0.6, h * 0.6), Radius.circular(w * 0.15));
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, stroke);

    // Thumb across front
    canvas.drawLine(Offset(w * 0.2, h * 0.55), Offset(w * 0.7, h * 0.55), stroke);

    if (withDot) {
      canvas.drawCircle(Offset(w * 0.5, h * 0.12), 2.0, stroke);
    }
  }

  void _drawTaaHand(Canvas canvas, double w, double h, Paint stroke, Paint fill, {required bool withDot}) {
    // Circle at base
    canvas.drawCircle(Offset(w * 0.5, h * 0.65), w * 0.25, fill);
    canvas.drawCircle(Offset(w * 0.5, h * 0.65), w * 0.25, stroke);

    // Index sticking straight up from circle
    canvas.drawLine(Offset(w * 0.5, h * 0.4), Offset(w * 0.5, h * 0.1), stroke);

    if (withDot) {
      canvas.drawCircle(Offset(w * 0.75, h * 0.15), 2.0, stroke);
    }
  }

  void _drawAynHand(Canvas canvas, double w, double h, Paint stroke, Paint fill, {required bool withDot}) {
    final path = Path();
    path.moveTo(w * 0.3, h * 0.2);
    path.quadraticBezierTo(w * 0.75, h * 0.2, w * 0.75, h * 0.5);
    path.quadraticBezierTo(w * 0.75, h * 0.8, w * 0.3, h * 0.8);
    path.lineTo(w * 0.25, h * 0.7);
    path.quadraticBezierTo(w * 0.6, h * 0.7, w * 0.6, h * 0.5);
    path.quadraticBezierTo(w * 0.6, h * 0.3, w * 0.25, h * 0.3);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    if (withDot) {
      canvas.drawCircle(Offset(w * 0.5, h * 0.1), 2.0, stroke);
    }
  }

  void _drawFaaHand(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Circle pinch at right
    canvas.drawCircle(Offset(w * 0.35, h * 0.45), w * 0.15, fill);
    canvas.drawCircle(Offset(w * 0.35, h * 0.45), w * 0.15, stroke);

    // 3 fingers standing up at left
    canvas.drawLine(Offset(w * 0.55, h * 0.8), Offset(w * 0.55, h * 0.15), stroke);
    canvas.drawLine(Offset(w * 0.68, h * 0.8), Offset(w * 0.68, h * 0.2), stroke);
    canvas.drawLine(Offset(w * 0.8, h * 0.8), Offset(w * 0.8, h * 0.25), stroke);
  }

  void _drawQaafHand(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Two fingers pointing downward in hook
    final path = Path();
    path.moveTo(w * 0.3, h * 0.2);
    path.lineTo(w * 0.7, h * 0.2);
    path.lineTo(w * 0.7, h * 0.7);
    path.lineTo(w * 0.55, h * 0.85);
    path.lineTo(w * 0.45, h * 0.7);
    path.lineTo(w * 0.3, h * 0.85);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawKaafHand(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    final path = Path();
    path.moveTo(w * 0.25, h * 0.15);
    path.lineTo(w * 0.4, h * 0.15);
    path.lineTo(w * 0.4, h * 0.65);
    path.lineTo(w * 0.75, h * 0.65);
    path.lineTo(w * 0.75, h * 0.8);
    path.lineTo(w * 0.25, h * 0.8);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawLaamHand(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    final path = Path();
    // Index up, thumb horizontal right (L-shape)
    path.moveTo(w * 0.3, h * 0.1);
    path.lineTo(w * 0.45, h * 0.1);
    path.lineTo(w * 0.45, h * 0.65);
    path.lineTo(w * 0.8, h * 0.65);
    path.lineTo(w * 0.8, h * 0.8);
    path.lineTo(w * 0.3, h * 0.8);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawMeemHand(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    final path = Path();
    path.addOval(Rect.fromLTWH(w * 0.25, h * 0.25, w * 0.5, h * 0.45));
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Vertical tail pointing down
    canvas.drawLine(Offset(w * 0.5, h * 0.7), Offset(w * 0.5, h * 0.9), stroke);
  }

  void _drawNoonHand(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Cup shape
    final path = Path();
    path.moveTo(w * 0.2, h * 0.35);
    path.quadraticBezierTo(w * 0.2, h * 0.85, w * 0.5, h * 0.85);
    path.quadraticBezierTo(w * 0.8, h * 0.85, w * 0.8, h * 0.35);

    canvas.drawPath(path, stroke);
    // Dot in center
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 2.2, stroke);
  }

  void _drawHaaHand(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Teardrop / cone shape with fingertips joined
    final path = Path();
    path.moveTo(w * 0.5, h * 0.1);
    path.quadraticBezierTo(w * 0.8, h * 0.5, w * 0.65, h * 0.85);
    path.lineTo(w * 0.35, h * 0.85);
    path.quadraticBezierTo(w * 0.2, h * 0.5, w * 0.5, h * 0.1);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawWaawHand(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Circle top with curved tail
    canvas.drawCircle(Offset(w * 0.5, h * 0.35), w * 0.2, fill);
    canvas.drawCircle(Offset(w * 0.5, h * 0.35), w * 0.2, stroke);

    final path = Path();
    path.moveTo(w * 0.4, h * 0.45);
    path.quadraticBezierTo(w * 0.3, h * 0.7, w * 0.7, h * 0.85);
    canvas.drawPath(path, stroke);
  }

  void _drawYaaHand(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    // Fist with pinky finger sticking out/up
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.35, w * 0.45, h * 0.5), Radius.circular(w * 0.1));
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, stroke);

    // Pinky finger on the right side
    final pinkyPath = Path();
    pinkyPath.moveTo(w * 0.65, h * 0.5);
    pinkyPath.lineTo(w * 0.8, h * 0.15);
    pinkyPath.lineTo(w * 0.7, h * 0.15);
    pinkyPath.lineTo(w * 0.55, h * 0.45);
    canvas.drawPath(pinkyPath, stroke);
  }

  void _drawDefaultHand(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.6), Radius.circular(w * 0.15));
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, stroke);
  }

  @override
  bool shouldRepaint(covariant ArabicSignHandPainter oldDelegate) {
    return oldDelegate.char != char || oldDelegate.color != color;
  }
}
