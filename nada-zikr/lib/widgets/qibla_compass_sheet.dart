import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../services/location_service.dart';
import '../services/qibla_calculator.dart';
import '../services/storage_service.dart';
import 'app_theme.dart';

/// Styled 3D Kaaba Icon Widget with Golden Kiswa & Door.
class KaabaIconWidget extends StatelessWidget {
  final double size;
  final bool isGlowing;

  const KaabaIconWidget({
    Key? key,
    this.size = 38,
    this.isGlowing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: isGlowing ? const Color(0xFFFFE57F) : AppColors.gold,
          width: isGlowing ? 2.5 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isGlowing
                ? AppColors.gold.withValues(alpha: 0.95)
                : AppColors.gold.withValues(alpha: 0.6),
            blurRadius: isGlowing ? 24 : 14,
            spreadRadius: isGlowing ? 4 : 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Golden Kiswa Belt
          Positioned(
            top: size * 0.22,
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold,
                    const Color(0xFFFFF0B3),
                    AppColors.gold,
                  ],
                ),
              ),
            ),
          ),
          // Golden Door (Bab Al-Kaaba)
          Positioned(
            bottom: size * 0.14,
            right: size * 0.18,
            child: Container(
              width: size * 0.24,
              height: size * 0.38,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFFFFF8DC), width: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter for Full Compass Degree Ticks and Degree Labels (0° to 330°).
class CompassDialPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  CompassDialPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    final majorTickPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.85)
      ..strokeWidth = 2.0;

    // Draw 60 tick lines around the perimeter (every 6 degrees)
    for (int i = 0; i < 60; i++) {
      final angle = i * 6 * math.pi / 180;
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;

      final outer = Offset(
        center.dx + (radius - 4) * math.sin(angle),
        center.dy - (radius - 4) * math.cos(angle),
      );

      final inner = Offset(
        center.dx + (radius - 4 - tickLength) * math.sin(angle),
        center.dy - (radius - 4 - tickLength) * math.cos(angle),
      );

      canvas.drawLine(inner, outer, isMajor ? majorTickPaint : tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Painter for the Sleek Full-Length Narrow Needle Spanning Across the Dial.
class NarrowNeedlePainter extends CustomPainter {
  final Color goldColor;
  final bool isAligned;

  NarrowNeedlePainter({
    required this.goldColor,
    this.isAligned = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final needleRadius = size.height / 2 - 25;

    final activeColor = isAligned ? const Color(0xFFFFEA00) : goldColor;

    // Top Pointer (Golden Narrow Arrow pointing up)
    final topPath = Path()
      ..moveTo(center.dx, center.dy - needleRadius) // Top tip
      ..lineTo(center.dx + 4.5, center.dy - 12)     // Right edge
      ..lineTo(center.dx, center.dy)                // Center
      ..lineTo(center.dx - 4.5, center.dy - 12)     // Left edge
      ..close();

    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          isAligned ? const Color(0xFFFFFFE0) : const Color(0xFFFFF2A1),
          activeColor,
          activeColor.withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromLTWH(0, center.dy - needleRadius, size.width, needleRadius));

    canvas.drawPath(topPath, topPaint);

    // Bottom Pointer (Dark Slate/Silver Narrow Tail pointing down)
    final bottomPath = Path()
      ..moveTo(center.dx, center.dy + needleRadius) // Bottom tip
      ..lineTo(center.dx + 4.5, center.dy + 12)    // Right edge
      ..lineTo(center.dx, center.dy)               // Center
      ..lineTo(center.dx - 4.5, center.dy + 12)    // Left edge
      ..close();

    final bottomPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromLTWH(0, center.dy, size.width, needleRadius));

    canvas.drawPath(bottomPath, bottomPaint);

    // Golden Laser Edge Line up to tip
    final linePaint = Paint()
      ..color = isAligned ? Colors.white : const Color(0xFFFFF8DC)
      ..strokeWidth = 1.4;

    canvas.drawLine(Offset(center.dx, center.dy), Offset(center.dx, center.dy - needleRadius), linePaint);
  }

  @override
  bool shouldRepaint(covariant NarrowNeedlePainter oldDelegate) =>
      oldDelegate.isAligned != isAligned || oldDelegate.goldColor != goldColor;
}

/// Interactive Real-Time Qibla Compass Sheet with Verified Live Location & Compass Heading.
class QiblaCompassSheet extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const QiblaCompassSheet({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required double latitude,
    required double longitude,
    required String locationName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QiblaCompassSheet(
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
      ),
    );
  }

  @override
  State<QiblaCompassSheet> createState() => _QiblaCompassSheetState();
}

class _QiblaCompassSheetState extends State<QiblaCompassSheet> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late double _qiblaBearing;
  late double _distanceKm;
  late String _cardinal;

  StreamSubscription<CompassEvent>? _compassSubscription;
  double? _heading;
  double _smoothHeading = 0.0;
  bool _hasSensor = false;

  @override
  void initState() {
    super.initState();
    _qiblaBearing = QiblaCalculator.calculateQiblaDirection(widget.latitude, widget.longitude);
    _distanceKm = QiblaCalculator.calculateDistanceToKaabaKm(widget.latitude, widget.longitude);
    _cardinal = QiblaCalculator.getCardinalDirection(_qiblaBearing);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initCompassAndLocation();
  }

  Future<void> _initCompassAndLocation() async {
    final locationMode = StorageService.getPrayerLocationMode();
    // Attempt live high-accuracy GPS location resolution only if GPS mode is active
    if (locationMode == 'gps') {
      try {
        final locRes = await LocationService.getCurrentLocation(forceGps: false);
        if (mounted) {
          final liveBearing = QiblaCalculator.calculateQiblaDirection(locRes.latitude, locRes.longitude);
          final liveDistance = QiblaCalculator.calculateDistanceToKaabaKm(locRes.latitude, locRes.longitude);
          final liveCardinal = QiblaCalculator.getCardinalDirection(liveBearing);
          setState(() {
            _qiblaBearing = liveBearing;
            _distanceKm = liveDistance;
            _cardinal = liveCardinal;
          });
        }
      } catch (_) {}
    }

    // Listen to real hardware compass events
    final events = FlutterCompass.events;
    if (events == null) {
      if (mounted) setState(() => _hasSensor = false);
      return;
    }

    _compassSubscription = events.listen(
      (CompassEvent event) {
        if (!mounted) return;
        final h = event.heading;
        if (h == null) return;

        final normalized = (h + 360.0) % 360.0;

        // Smooth angle tracking to prevent 360° spin jumps
        double diff = (normalized - _smoothHeading) % 360.0;
        if (diff > 180.0) diff -= 360.0;
        if (diff < -180.0) diff += 360.0;

        setState(() {
          _heading = normalized;
          _smoothHeading += diff;
          _hasSensor = true;
        });
      },
      onError: (dynamic error) {
        if (mounted) setState(() => _hasSensor = false);
      },
    );
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  /// Angular difference between device orientation and Qibla bearing (-180 to +180)
  double get _headingOffset {
    final current = (_smoothHeading % 360.0 + 360.0) % 360.0;
    double diff = (_qiblaBearing - current) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return diff;
  }

  /// Returns true when top of device is aligned within 5° of Qibla
  bool get _isAligned => _hasSensor && _heading != null && _headingOffset.abs() <= 5.0;

  @override
  Widget build(BuildContext context) {
    final needleAngleRad = ((_qiblaBearing - _smoothHeading) * math.pi / 180.0);
    final dialAngleRad = (-_smoothHeading * math.pi / 180.0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: _isAligned
              ? const Color(0xFFFFD700)
              : AppColors.gold.withValues(alpha: 0.35),
          width: _isAligned ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isAligned
                ? AppColors.gold.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.6),
            blurRadius: 35,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: _isAligned ? AppColors.gold : AppColors.gold.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.explore_rounded,
                            color: _isAligned ? const Color(0xFFFFD700) : AppColors.gold,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'قیبلەنمای پیرۆز - Qibla Compass',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.kurdishTitle(
                                fontSize: 19,
                                color: _isAligned ? const Color(0xFFFFD700) : AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: 12, color: AppColors.faintText),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.locationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.englishText(fontSize: 12, color: AppColors.faintText),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: AppColors.faintText),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  // Status Sensor Indicator Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _hasSensor
                          ? (_isAligned
                              ? Colors.amber.withValues(alpha: 0.2)
                              : Colors.green.withValues(alpha: 0.15))
                          : Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _hasSensor
                            ? (_isAligned ? Colors.amber : Colors.green.withValues(alpha: 0.5))
                            : Colors.orange.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _hasSensor
                                ? (_isAligned ? const Color(0xFFFFD700) : Colors.greenAccent)
                                : Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _hasSensor
                                ? (_isAligned
                                    ? 'بەرەو قیبلەی پیرۆز! • Aligned with Qibla'
                                    : 'بووسڵەی ڕاستەوخۆ چالاکە • Live Compass Active')
                                : 'سێنسۆری بووسڵە نادۆزرایەوە • Sensor Unavailable',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _hasSensor
                                  ? (_isAligned ? const Color(0xFFFFD700) : Colors.greenAccent)
                                  : Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Full Compass Assembly
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 310,
                      height: 310,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Top Fixed Device Pointer Line (12 o'clock indicator)
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 4,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _isAligned ? const Color(0xFFFFD700) : AppColors.gold,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isAligned
                                        ? AppColors.gold
                                        : AppColors.gold.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Outer Pulsing Glow Ring
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final scale = 1.0 + (_pulseController.value * (_isAligned ? 0.06 : 0.03));
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 290,
                                  height: 290,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        _isAligned
                                            ? AppColors.gold.withValues(alpha: 0.35)
                                            : AppColors.gold.withValues(alpha: 0.15),
                                        Colors.transparent,
                                      ],
                                    ),
                                    border: Border.all(
                                      color: _isAligned
                                          ? const Color(0xFFFFD700)
                                          : AppColors.gold.withValues(alpha: 0.3),
                                      width: _isAligned ? 2.0 : 1.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Outer Compass Dial (Rotates to keep North accurate)
                          Transform.rotate(
                            angle: dialAngleRad,
                            child: Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0F1E16),
                                border: Border.all(
                                  color: _isAligned
                                      ? const Color(0xFFFFD700)
                                      : AppColors.gold.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                painter: CompassDialPainter(
                                  primaryColor: AppColors.gold,
                                  secondaryColor: AppColors.cream,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(top: 14, child: _cardinalLabel('N', isNorth: true)),
                                    Positioned(right: 16, child: _cardinalLabel('E')),
                                    Positioned(bottom: 14, child: _cardinalLabel('S')),
                                    Positioned(left: 16, child: _cardinalLabel('W')),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Rotating Qibla Needle & 3D Kaaba Badge Assembly
                          Transform.rotate(
                            angle: needleAngleRad,
                            child: SizedBox(
                              width: 280,
                              height: 280,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(280, 280),
                                    painter: NarrowNeedlePainter(
                                      goldColor: AppColors.gold,
                                      isAligned: _isAligned,
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    child: KaabaIconWidget(
                                      size: 38,
                                      isGlowing: _isAligned,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Center Brass Pivot Cap
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: _isAligned
                                    ? [
                                        const Color(0xFFFFFFE0),
                                        const Color(0xFFFFD700),
                                        const Color(0xFFB8860B),
                                      ]
                                    : [
                                        const Color(0xFFFFF5C0),
                                        AppColors.gold,
                                        const Color(0xFF7A581A),
                                      ],
                              ),
                              border: Border.all(color: Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF222222),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Real-Time Readout Data Cards
                  Row(
                    children: [
                      // Device Heading Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.panelColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.panelBorderColor),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.explore_outlined, color: AppColors.gold, size: 22),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'ئاڕاستەی ئامێر',
                                  style: AppTheme.kurdishText(fontSize: 11, color: AppColors.faintText),
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _heading != null
                                      ? '${_heading!.toStringAsFixed(1)}° ${QiblaCalculator.getCardinalDirection(_heading!)}'
                                      : '---°',
                                  style: AppTheme.englishTitle(fontSize: 15, color: AppColors.cream),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Qibla Target Bearing Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.panelColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isAligned ? AppColors.gold : AppColors.panelBorderColor,
                              width: _isAligned ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.navigation_rounded,
                                color: _isAligned ? const Color(0xFFFFD700) : AppColors.gold,
                                size: 22,
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'ڕووگەی قیبلە',
                                  style: AppTheme.kurdishText(fontSize: 11, color: AppColors.faintText),
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${_qiblaBearing.toStringAsFixed(1)}° $_cardinal',
                                  style: AppTheme.englishTitle(
                                    fontSize: 15,
                                    color: _isAligned ? const Color(0xFFFFD700) : AppColors.cream,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Distance Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.panelColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.panelBorderColor),
                          ),
                          child: Column(
                            children: [
                              const KaabaIconWidget(size: 20),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'دووری تا مەککە',
                                  style: AppTheme.kurdishText(fontSize: 11, color: AppColors.faintText),
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${_distanceKm.toStringAsFixed(0)} KM',
                                  style: AppTheme.englishTitle(fontSize: 15, color: AppColors.cream),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Guidance Banner Card
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isAligned
                          ? AppColors.gold.withValues(alpha: 0.25)
                          : AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _isAligned
                            ? const Color(0xFFFFD700)
                            : AppColors.gold.withValues(alpha: 0.3),
                        width: _isAligned ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isAligned ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          color: _isAligned ? const Color(0xFFFFD700) : AppColors.gold,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isAligned
                                ? 'ئامێرەکەت بە تەواوی ئاڕاستەی کەعبەی پیرۆز کراوە! دەتوانیت دەست بە نوێژ بکەیت.'
                                : 'مۆبایلەکەت بخەرە سەر ڕوویەکی تەخت و بیسوڕێنەوە تا دەرزیە زێڕینەکە و نیشاندەری سەرەوە بە تەواوی یەکدەگرنەوە.',
                            style: AppTheme.kurdishText(
                              fontSize: 12,
                              color: _isAligned ? Colors.white : AppColors.cream,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _cardinalLabel(String label, {bool isNorth = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNorth ? AppColors.gold : Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isNorth ? Colors.black : AppColors.cream,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
