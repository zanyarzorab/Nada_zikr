import 'dart:math' as math;

/// Qibla direction and distance calculator.
class QiblaCalculator {
  /// Makkah / Kaaba Coordinates
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;

  /// Calculates Qibla direction in degrees clockwise relative to true North (0° = North, 90° = East, 180° = South, 270° = West).
  static double calculateQiblaDirection(double latitude, double longitude) {
    final latRad = latitude * math.pi / 180.0;
    const kaabaLatRad = kaabaLatitude * math.pi / 180.0;
    final deltaLonRad = (kaabaLongitude - longitude) * math.pi / 180.0;

    final y = math.sin(deltaLonRad);
    final x = math.cos(latRad) * math.tan(kaabaLatRad) - math.sin(latRad) * math.cos(deltaLonRad);

    final qiblaRad = math.atan2(y, x);
    final qiblaDeg = qiblaRad * 180.0 / math.pi;

    return (qiblaDeg + 360.0) % 360.0;
  }

  /// Calculates distance to Kaaba in kilometers using the Haversine formula.
  static double calculateDistanceToKaabaKm(double latitude, double longitude) {
    const rEarthKm = 6371.0;
    final lat1Rad = latitude * math.pi / 180.0;
    const lat2Rad = kaabaLatitude * math.pi / 180.0;
    final deltaLatRad = (kaabaLatitude - latitude) * math.pi / 180.0;
    final deltaLonRad = (kaabaLongitude - longitude) * math.pi / 180.0;

    final a = math.sin(deltaLatRad / 2.0) * math.sin(deltaLatRad / 2.0) +
        math.cos(lat1Rad) * math.cos(lat2Rad) * math.sin(deltaLonRad / 2.0) * math.sin(deltaLonRad / 2.0);

    final c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
    return rEarthKm * c;
  }

  /// Converts bearing angle to cardinal direction text (e.g. "SSW", "NE", "S").
  static String getCardinalDirection(double degrees) {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final index = ((degrees + 11.25) % 360 / 22.5).floor();
    return directions[index % 16];
  }
}
