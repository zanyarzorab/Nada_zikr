import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'prayer_repository.dart';
import 'storage_service.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final WorldCity nearestCity;
  final String displayNameKu;
  final String displayNameAr;
  final String displayNameEn;
  final bool isGpsSuccess;
  final String? errorMessage;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.nearestCity,
    required this.displayNameKu,
    required this.displayNameAr,
    required this.displayNameEn,
    required this.isGpsSuccess,
    this.errorMessage,
  });

  String displayName(String locale) {
    if (locale == 'ku') return displayNameKu;
    if (locale == 'ar') return displayNameAr;
    return displayNameEn;
  }
}

class LocationService {
  static LocationResult? _cachedResult;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheTtl = Duration(minutes: 20);

  /// Invalidate in-memory cached location (e.g., when user manually selects another city)
  static void invalidateCache() {
    _cachedResult = null;
    _cacheTimestamp = null;
  }

  /// Request location permission at app launch
  static Future<bool> requestStartupPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      if (kDebugMode) print('Location startup permission error: $e');
      return false;
    }
  }

  /// Get current location with instant memory-cache, last-known fast-path, and safe fallbacks
  static Future<LocationResult> getCurrentLocation({
    bool forceGps = false,
  }) async {
    // 1. Fast path: return in-memory cached result if valid and not forcing a fresh GPS fix
    if (!forceGps && _cachedResult != null && _cacheTimestamp != null) {
      if (DateTime.now().difference(_cacheTimestamp!) < _cacheTtl) {
        return _cachedResult!;
      }
    }

    final cityId = StorageService.getPrayerSelectedCity();
    final defaultCity = WorldCitiesCatalog.byId(cityId);
    double lat = defaultCity.latitude;
    double lng = defaultCity.longitude;
    bool gpsSuccess = false;
    String? errMessage;

    final locationMode = StorageService.getPrayerLocationMode();

    if (locationMode == 'gps' || forceGps) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          errMessage = 'Location services are disabled on device';
        } else {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            Position? position;

            // Try instant last-known position first if not explicitly forcing a live fix
            if (!forceGps) {
              position = await Geolocator.getLastKnownPosition();
            }

            // If no last known position or explicit live fix requested, query live position with a short timeout
            if (position == null) {
              try {
                position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.medium,
                  timeLimit: const Duration(milliseconds: 2500),
                );
              } catch (_) {
                position = await Geolocator.getLastKnownPosition();
              }
            }

            if (position != null) {
              lat = position.latitude;
              lng = position.longitude;
              gpsSuccess = true;
              // Save last known GPS coordinates to storage
              await StorageService.savePrayerCustomCoordinates(lat, lng);
            }
          } else {
            errMessage = 'Location permission was denied';
          }
        }
      } catch (e) {
        errMessage = 'Error getting location: $e';
      }
    }

    // If GPS was not active or failed, check selected city or custom coordinates from StorageService
    if (!gpsSuccess) {
      final customCoords = StorageService.getPrayerCustomCoordinates();
      if (customCoords != null && customCoords.length >= 2) {
        lat = customCoords[0];
        lng = customCoords[1];
      } else {
        final cityId = StorageService.getPrayerSelectedCity();
        final selectedCity = WorldCitiesCatalog.byId(cityId);
        lat = selectedCity.latitude;
        lng = selectedCity.longitude;
      }
    }

    final nearest = findNearestCity(lat, lng);
    final isGpsMode = (locationMode == 'gps' || forceGps);
    final gpsSuffix = (gpsSuccess && isGpsMode) ? ' (GPS)' : '';

    final result = LocationResult(
      latitude: lat,
      longitude: lng,
      nearestCity: nearest,
      displayNameKu: '${nearest.nameKu}$gpsSuffix',
      displayNameAr: '${nearest.nameAr}$gpsSuffix',
      displayNameEn: '${nearest.nameEn}$gpsSuffix',
      isGpsSuccess: gpsSuccess,
      errorMessage: errMessage,
    );

    // Cache the result for subsequent calls
    _cachedResult = result;
    _cacheTimestamp = DateTime.now();

    return result;
  }

  /// Exact Haversine spherical distance calculation to locate nearest catalog city
  static WorldCity findNearestCity(double latitude, double longitude) {
    WorldCity nearest = WorldCitiesCatalog.allCities.first;
    double shortestDistanceKm = double.infinity;

    for (final city in WorldCitiesCatalog.allCities) {
      final dist = _haversineDistanceKm(latitude, longitude, city.latitude, city.longitude);
      if (dist < shortestDistanceKm) {
        shortestDistanceKm = dist;
        nearest = city;
      }
    }

    return nearest;
  }

  static double _haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Earth radius in KM
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRadians(double degree) => degree * math.pi / 180.0;
}
