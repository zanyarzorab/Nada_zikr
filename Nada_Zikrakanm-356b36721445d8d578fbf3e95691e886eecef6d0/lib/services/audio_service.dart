import 'package:flutter/services.dart';

class AudioService {
  static Future<void> playClick() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Fallback silently if haptic feedback is unavailable.
    }
  }
}
