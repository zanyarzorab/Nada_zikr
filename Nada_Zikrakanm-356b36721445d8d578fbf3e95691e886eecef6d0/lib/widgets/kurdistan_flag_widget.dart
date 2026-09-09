import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pixel-perfect, high-resolution vector rendering of the official Kurdistan Flag (Ala Rengîn).
/// - Top stripe: Red (#E30A17)
/// - Middle stripe: White (#FFFFFF)
/// - Bottom stripe: Green (#009639)
/// - Center: Golden Sun (#FFC72C) with 21 sharp solar rays
class KurdistanFlagWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const KurdistanFlagWidget({
    Key? key,
    this.width = 28,
    this.height = 19,
    this.borderRadius = 3.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white24, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius > 0.6 ? borderRadius - 0.6 : 0),
        child: CustomPaint(
          size: Size(width, height),
          painter: const _KurdistanFlagPainter(),
        ),
      ),
    );
  }
}

class _KurdistanFlagPainter extends CustomPainter {
  const _KurdistanFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stripeH = h / 3;

    // 1. Top Red Stripe
    final redPaint = Paint()..color = const Color(0xFFE30A17);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, stripeH), redPaint);

    // 2. Middle White Stripe
    final whitePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRect(Rect.fromLTWH(0, stripeH, w, stripeH), whitePaint);

    // 3. Bottom Green Stripe
    final greenPaint = Paint()..color = const Color(0xFF009639);
    canvas.drawRect(Rect.fromLTWH(0, stripeH * 2, w, stripeH), greenPaint);

    // 4. Golden 21-ray Sun in Center
    final center = Offset(w / 2, h / 2);
    final sunRadius = stripeH * 0.44;
    final rayOuterRadius = stripeH * 0.94;
    final rayBaseRadius = stripeH * 0.44;

    final sunPaint = Paint()
      ..color = const Color(0xFFFFC72C)
      ..style = PaintingStyle.fill;

    // 21 solar rays (representing Nawroz / 21 March)
    const rayCount = 21;
    const step = (2 * math.pi) / rayCount;
    final rayPath = Path();

    for (int i = 0; i < rayCount; i++) {
      final angle = i * step - (math.pi / 2);
      final tipX = center.dx + rayOuterRadius * math.cos(angle);
      final tipY = center.dy + rayOuterRadius * math.sin(angle);

      final leftAngle = angle - (step * 0.35);
      final leftX = center.dx + rayBaseRadius * math.cos(leftAngle);
      final leftY = center.dy + rayBaseRadius * math.sin(leftAngle);

      final rightAngle = angle + (step * 0.35);
      final rightX = center.dx + rayBaseRadius * math.cos(rightAngle);
      final rightY = center.dy + rayBaseRadius * math.sin(rightAngle);

      if (i == 0) {
        rayPath.moveTo(leftX, leftY);
      } else {
        rayPath.lineTo(leftX, leftY);
      }
      rayPath.lineTo(tipX, tipY);
      rayPath.lineTo(rightX, rightY);
    }
    rayPath.close();
    canvas.drawPath(rayPath, sunPaint);

    // Central sun disk
    canvas.drawCircle(center, sunRadius, sunPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
