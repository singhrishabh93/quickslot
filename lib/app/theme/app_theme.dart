import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const cream = Color(0xFFFAF6EE);
  static const paper = Color(0xFFF6F1E1);
  static const surfaceMuted = Color(0xFFE8E1CE);
  static const border = Color(0xFFD8CFB6);
  static const ink = Color(0xFF14110D);
  static const subtle = Color(0xFF6E6859);
  static const courtGreen = Color(0xFF1F5132);
  static const courtGreenDeep = Color(0xFF133022);
  static const clay = Color(0xFFB73E2A);
  static const clayWash = Color(0xFFF1DAD4);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final display = GoogleFonts.bebasNeueTextTheme();
    final body = GoogleFonts.ibmPlexSans;

    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.courtGreen,
      onPrimary: AppColors.cream,
      primaryContainer: AppColors.paper,
      onPrimaryContainer: AppColors.courtGreenDeep,
      secondary: AppColors.clay,
      onSecondary: AppColors.cream,
      secondaryContainer: AppColors.clayWash,
      onSecondaryContainer: AppColors.clay,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.surfaceMuted,
      onSurfaceVariant: AppColors.subtle,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      error: AppColors.clay,
      onError: AppColors.cream,
    );

    final textTheme = TextTheme(
      displayLarge: display.displayLarge?.copyWith(
        fontSize: 72,
        color: AppColors.ink,
        height: 0.95,
        letterSpacing: 0,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontSize: 56,
        color: AppColors.ink,
        height: 0.95,
        letterSpacing: 0,
      ),
      displaySmall: display.displaySmall?.copyWith(
        fontSize: 44,
        color: AppColors.ink,
        height: 1.0,
        letterSpacing: 0,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontSize: 36,
        color: AppColors.ink,
        letterSpacing: 0.5,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontSize: 30,
        color: AppColors.ink,
        letterSpacing: 0.5,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontSize: 24,
        color: AppColors.ink,
        letterSpacing: 0.5,
      ),
      titleLarge: display.titleLarge?.copyWith(
        fontSize: 22,
        color: AppColors.ink,
        letterSpacing: 0.6,
      ),
      titleMedium: body(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        letterSpacing: -0.1,
      ),
      titleSmall: body(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: body(
        fontSize: 16,
        color: AppColors.ink,
        height: 1.5,
      ),
      bodyMedium: body(
        fontSize: 14,
        color: AppColors.ink,
        height: 1.5,
      ),
      bodySmall: body(
        fontSize: 12,
        color: AppColors.subtle,
        height: 1.4,
      ),
      labelLarge: body(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: 1.2,
      ),
      labelMedium: body(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.subtle,
        letterSpacing: 1.6,
      ),
      labelSmall: body(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.subtle,
        letterSpacing: 2,
      ),
    );

    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      canvasColor: AppColors.cream,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: display.titleLarge?.copyWith(
          fontSize: 26,
          color: AppColors.ink,
          letterSpacing: 1.0,
        ),
        actionsIconTheme: const IconThemeData(color: AppColors.ink, size: 22),
        iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.paper,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.cream,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          textStyle: body(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.ink, width: 1),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          textStyle: body(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.subtle,
          textStyle: body(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: body(
          color: AppColors.cream,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.subtle,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        titleTextStyle: display.titleLarge?.copyWith(
          fontSize: 22,
          color: AppColors.ink,
          letterSpacing: 0.5,
        ),
        contentTextStyle: body(
          fontSize: 14,
          color: AppColors.ink,
          height: 1.5,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  /// Monospace text style for tabular data (times, prices, IDs).
  static TextStyle mono(BuildContext context, {
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      letterSpacing: letterSpacing,
    );
  }
}
