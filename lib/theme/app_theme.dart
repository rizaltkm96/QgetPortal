import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:qget_portal/theme/app_colors.dart';
import 'package:qget_portal/theme/theme_extensions.dart';

class AppTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.instagramPink,
      onPrimary: Colors.white,
      primaryContainer: AppColors.instagramPurple.withValues(alpha: 0.35),
      onPrimaryContainer: AppColors.onCanvasPrimary,
      secondary: AppColors.instagramOrange,
      onSecondary: Colors.black,
      secondaryContainer: AppColors.instagramOrange.withValues(alpha: 0.22),
      onSecondaryContainer: AppColors.onCanvasPrimary,
      tertiary: AppColors.instagramBluePurple,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.instagramBluePurple.withValues(alpha: 0.28),
      onTertiaryContainer: AppColors.onCanvasPrimary,
      error: const Color(0xFFFF6B6B),
      onError: Colors.white,
      errorContainer: const Color(0xFF5C1A1A),
      onErrorContainer: const Color(0xFFFFD4D4),
      surface: AppColors.surfaceDeep,
      onSurface: AppColors.onCanvasPrimary,
      onSurfaceVariant: AppColors.onCanvasMuted,
      outline: AppColors.onCanvasMuted.withValues(alpha: 0.35),
      outlineVariant: AppColors.glassBorder,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: AppColors.onCanvasPrimary,
      onInverseSurface: AppColors.canvasTop,
      inversePrimary: AppColors.instagramPink,
      surfaceTint: AppColors.instagramPink.withValues(alpha: 0.12),
      surfaceContainerHighest: AppColors.surfaceRaised,
      surfaceContainerHigh: AppColors.surfaceRaised,
      surfaceContainer: AppColors.surfaceDeep,
      surfaceContainerLow: AppColors.surfaceDeep,
      surfaceContainerLowest: AppColors.canvasTop,
      surfaceBright: AppColors.surfaceRaised,
      surfaceDim: AppColors.canvasBottom,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      extensions: const [AppStyle.dark],
    );

    final inter = GoogleFonts.interTextTheme(base.textTheme);
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.glassBorder),
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      textTheme: inter,
      primaryTextTheme: GoogleFonts.interTextTheme(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onCanvasPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onCanvasPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.glassFillStrong,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.instagramPink.withValues(alpha: 0.22),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.inter(
            fontSize: 12,
            fontWeight:
                states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.onCanvasPrimary
                : AppColors.onCanvasMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.instagramPink
                : AppColors.onCanvasMuted,
            size: 24,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.imitationGlassFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.imitationGlassBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassFill,
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: outlineBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.instagramPink, width: 1.5),
        ),
        errorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: base.colorScheme.error, width: 1),
        ),
        focusedErrorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: base.colorScheme.error, width: 1.5),
        ),
        labelStyle: TextStyle(color: AppColors.onCanvasMuted),
        hintStyle: TextStyle(color: AppColors.onCanvasMuted.withValues(alpha: 0.7)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppColors.instagramPink,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.instagramBluePurple,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.instagramPink,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xCC16161D),
        modalBackgroundColor: Color(0xE616161D),
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.onCanvasMuted,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceRaised,
        contentTextStyle: GoogleFonts.inter(color: AppColors.onCanvasPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.instagramPink,
        linearTrackColor: AppColors.glassFill,
      ),
    );
  }
}
