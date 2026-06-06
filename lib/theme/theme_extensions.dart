import 'package:flutter/material.dart';

import 'package:qget_portal/theme/app_colors.dart';

/// Gradients and glass tuning accessible via `Theme.of(context).extension<AppStyle>()`.
@immutable
class AppStyle extends ThemeExtension<AppStyle> {
  const AppStyle({
    required this.backgroundGradient,
    required this.instagramGradient,
    required this.storyRingGradient,
    required this.glassFill,
    required this.glassBorder,
    required this.glassBlurSigma,
    required this.imitationGlassFill,
    required this.imitationGlassBorder,
    required this.fabOuterRadius,
  });

  /// Full-screen subtle wash (dark, very soft color drift).
  final LinearGradient backgroundGradient;

  /// Strong brand gradient (buttons, chrome accents).
  final LinearGradient instagramGradient;

  /// Story avatar ring (full saturation stops).
  final LinearGradient storyRingGradient;

  final Color glassFill;
  final Color glassBorder;
  final double glassBlurSigma;

  final Color imitationGlassFill;
  final Color imitationGlassBorder;

  final double fabOuterRadius;

  static const AppStyle dark = AppStyle(
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.canvasTop,
        Color(0xFF14101A),
        AppColors.canvasMid,
        AppColors.canvasBottom,
      ],
      stops: [0.0, 0.35, 0.65, 1.0],
    ),
    instagramGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.instagramOrange,
        AppColors.instagramPink,
        AppColors.instagramPurple,
        AppColors.instagramBluePurple,
      ],
    ),
    storyRingGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.instagramOrange,
        AppColors.instagramPink,
        AppColors.instagramPurple,
        AppColors.instagramBluePurple,
      ],
    ),
    glassFill: AppColors.glassFill,
    glassBorder: AppColors.glassBorder,
    glassBlurSigma: 24,
    imitationGlassFill: AppColors.imitationGlassFill,
    imitationGlassBorder: AppColors.imitationGlassBorder,
    fabOuterRadius: 18,
  );

  @override
  AppStyle copyWith({
    LinearGradient? backgroundGradient,
    LinearGradient? instagramGradient,
    LinearGradient? storyRingGradient,
    Color? glassFill,
    Color? glassBorder,
    double? glassBlurSigma,
    Color? imitationGlassFill,
    Color? imitationGlassBorder,
    double? fabOuterRadius,
  }) {
    return AppStyle(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      instagramGradient: instagramGradient ?? this.instagramGradient,
      storyRingGradient: storyRingGradient ?? this.storyRingGradient,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      imitationGlassFill: imitationGlassFill ?? this.imitationGlassFill,
      imitationGlassBorder: imitationGlassBorder ?? this.imitationGlassBorder,
      fabOuterRadius: fabOuterRadius ?? this.fabOuterRadius,
    );
  }

  @override
  AppStyle lerp(ThemeExtension<AppStyle>? other, double t) {
    if (other is! AppStyle) return this;
    return AppStyle(
      backgroundGradient:
          LinearGradient.lerp(backgroundGradient, other.backgroundGradient, t) ??
              backgroundGradient,
      instagramGradient:
          LinearGradient.lerp(instagramGradient, other.instagramGradient, t) ??
              instagramGradient,
      storyRingGradient:
          LinearGradient.lerp(storyRingGradient, other.storyRingGradient, t) ??
              storyRingGradient,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassBlurSigma: glassBlurSigma + (other.glassBlurSigma - glassBlurSigma) * t,
      imitationGlassFill:
          Color.lerp(imitationGlassFill, other.imitationGlassFill, t)!,
      imitationGlassBorder:
          Color.lerp(imitationGlassBorder, other.imitationGlassBorder, t)!,
      fabOuterRadius: fabOuterRadius + (other.fabOuterRadius - fabOuterRadius) * t,
    );
  }
}

extension AppStyleX on BuildContext {
  AppStyle get appStyle =>
      Theme.of(this).extension<AppStyle>() ?? AppStyle.dark;
}
