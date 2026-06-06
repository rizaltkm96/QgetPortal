import 'package:flutter/foundation.dart';

/// Standalone member registration paths (Flutter web / GitHub Pages).
bool isStandaloneRegisterPath() {
  if (!kIsWeb) return false;

  final path = Uri.base.path.toLowerCase();
  final fragment = Uri.base.fragment.toLowerCase();
  final segments = Uri.base.pathSegments.map((s) => s.toLowerCase()).toList();

  if (segments.contains('register') || segments.contains('add-member')) {
    return true;
  }

  const markers = ['register', 'add-member'];
  for (final marker in markers) {
    if (path.endsWith('/$marker') || path.endsWith(marker)) return true;
    if (path.contains('/$marker/')) return true;
    if (fragment.contains(marker)) return true;
  }

  return false;
}
