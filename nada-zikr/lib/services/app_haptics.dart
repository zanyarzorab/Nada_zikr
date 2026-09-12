import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Centralized, high-performance haptic feedback engine that honors user preferences.
class AppHaptics {
  AppHaptics._();

  /// Light tactile tick (for count increments, button taps)
  static Future<void> lightImpact() async {
    if (!StorageService.isHapticEnabled()) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium tactile pulse (for selections, switches)
  static Future<void> mediumImpact() async {
    if (!StorageService.isHapticEnabled()) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Heavy tactile pulse (for reaching targets, completed cycles)
  static Future<void> heavyImpact() async {
    if (!StorageService.isHapticEnabled()) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Sustained vibration (for resets, pocket mode target alarms)
  static Future<void> vibrate() async {
    if (!StorageService.isHapticEnabled()) return;
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  /// Gentle selection click
  static Future<void> selectionClick() async {
    if (!StorageService.isHapticEnabled()) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
