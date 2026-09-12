import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AppShareService {
  AppShareService._();

  /// Safely shares text on both Android and iOS (including iPad popover requirement)
  static Future<void> share(
    BuildContext? context,
    String text, {
    String? subject,
  }) async {
    Rect? origin;
    if (context != null && context.mounted) {
      try {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final position = box.localToGlobal(Offset.zero);
          origin = position & box.size;
        }
      } catch (_) {}
    }

    // Safe fallback origin for iPadOS popovers
    if (origin == null && context != null && context.mounted) {
      final size = MediaQuery.maybeSizeOf(context);
      if (size != null) {
        origin = Rect.fromLTWH(0, 0, size.width, size.height / 2);
      }
    }

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: origin,
      ),
    );
  }
}
