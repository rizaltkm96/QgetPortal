import 'package:flutter/material.dart';

/// Instagram-adjacent accent palette + dark UI base (not official brand assets).
abstract final class AppColors {
  // Gradient anchors (classic IG-style warm → pink → purple)
  static const Color instagramOrange = Color(0xFFF58529);
  static const Color instagramPink = Color(0xFFDD2A7B);
  static const Color instagramPurple = Color(0xFF8134AF);
  static const Color instagramBluePurple = Color(0xFF515BD4);

  // Dark surfaces
  static const Color canvasTop = Color(0xFF0A0A0C);
  static const Color canvasMid = Color(0xFF121218);
  static const Color canvasBottom = Color(0xFF0C0C12);
  static const Color surfaceDeep = Color(0xFF16161D);
  static const Color surfaceRaised = Color(0xFF1C1C26);

  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassFill = Color(0x1AFFFFFF);
  static const Color glassFillStrong = Color(0x26FFFFFF);

  /// Translucent panel for list rows (no blur).
  static const Color imitationGlassFill = Color(0x2EFFFFFF);
  static const Color imitationGlassBorder = Color(0x22FFFFFF);

  static const Color onCanvasPrimary = Color(0xFFF5F5F7);
  static const Color onCanvasMuted = Color(0xFFB0B0BA);
}
