import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna yang diambil dari desain referensi
/// (Dribbble: "BidStitch mobile app" oleh Layo).
abstract final class AppColors {
  static const background = Color(0xFFF7F7F4);
  static const ink = Color(0xFF101010);
  static const muted = Color(0xFF6A6A66);
  static const line = Color(0xFFE6E6E1);
  static const tile = Color(0xFFEFEFEB);

  static const purple = Color(0xFFB481E8);
  static const purpleDeep = Color(0xFFA46BDF);
  static const orange = Color(0xFFF99520);
  static const orangeDeep = Color(0xFFF58305);
  static const orangeLight = Color(0xFFFFA83F);
  static const pink = Color(0xFFE072D8);
  static const pinkDeep = Color(0xFFCF5CC6);
  static const green = Color(0xFF17A34A);
  static const red = Color(0xFFE3150F);

  static const darkCard = Color(0xFF111111);
  static const darkDecor = Color(0xFF262626);
  static const darkMuted = Color(0xFFA3A3A3);
  static const segmentOn = Color(0xFFEDEDED);
  static const segmentOff = Color(0xFF3A3A3A);
}

/// Gaya teks: huruf tebal dengan jarak antarhuruf rapat seperti pada referensi.
abstract final class AppText {
  static TextStyle _style(
    double size,
    FontWeight weight, {
    Color color = AppColors.ink,
    double? height,
    double spacing = 0,
  }) {
    return GoogleFonts.hankenGrotesk(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
  }

  static TextStyle get display =>
      _style(31, FontWeight.w800, height: 1.04, spacing: -1.1);
  static TextStyle get h1 => _style(26, FontWeight.w800, spacing: -0.8);
  static TextStyle get h2 => _style(21, FontWeight.w800, spacing: -0.6);
  static TextStyle get title =>
      _style(16.5, FontWeight.w700, height: 1.25, spacing: -0.3);
  static TextStyle get body =>
      _style(14.5, FontWeight.w500, height: 1.42, color: const Color(0xFF1E1E1E));
  static TextStyle get small =>
      _style(13, FontWeight.w500, height: 1.4, color: AppColors.muted);
  static TextStyle get label => _style(13.5, FontWeight.w700, spacing: -0.1);
  static TextStyle get meta => _style(12.5, FontWeight.w700);
  static TextStyle get eyebrow =>
      _style(11.5, FontWeight.w800, spacing: 1.1);
  static TextStyle get button => _style(14.5, FontWeight.w700, spacing: -0.1);
  static TextStyle get stat =>
      _style(42, FontWeight.w800, height: 1, spacing: -1.8);
}

abstract final class AppTheme {
  /// Menerapkan font aplikasi ke semua slot TextTheme (dipakai oleh widget
  /// bawaan seperti date picker dan time picker).
  static TextTheme _withAppFont(TextTheme t) {
    TextStyle? font(TextStyle? s) =>
        s == null ? null : GoogleFonts.hankenGrotesk(textStyle: s);
    return t.copyWith(
      displayLarge: font(t.displayLarge),
      displayMedium: font(t.displayMedium),
      displaySmall: font(t.displaySmall),
      headlineLarge: font(t.headlineLarge),
      headlineMedium: font(t.headlineMedium),
      headlineSmall: font(t.headlineSmall),
      titleLarge: font(t.titleLarge),
      titleMedium: font(t.titleMedium),
      titleSmall: font(t.titleSmall),
      bodyLarge: font(t.bodyLarge),
      bodyMedium: font(t.bodyMedium),
      bodySmall: font(t.bodySmall),
      labelLarge: font(t.labelLarge),
      labelMedium: font(t.labelMedium),
      labelSmall: font(t.labelSmall),
    );
  }

  /// Mengunduh font lebih awal supaya frame pertama sudah memakai font final.
  /// Jika sedang offline aplikasi tetap berjalan memakai font bawaan.
  static Future<void> preloadFonts() async {
    try {
      await GoogleFonts.pendingFonts([
        for (final weight in const [
          FontWeight.w500,
          FontWeight.w600,
          FontWeight.w700,
          FontWeight.w800,
        ])
          GoogleFonts.hankenGrotesk(fontWeight: weight),
      ]).timeout(const Duration(seconds: 4));
    } catch (_) {
      // Abaikan: fallback ke font sistem.
    }
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.purple).copyWith(
      primary: AppColors.ink,
      onPrimary: Colors.white,
      secondary: AppColors.purple,
      onSecondary: AppColors.ink,
      surface: Colors.white,
      onSurface: AppColors.ink,
      error: AppColors.red,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: _withAppFont(base.textTheme),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.ink,
        selectionColor: AppColors.purple.withValues(alpha: 0.35),
        selectionHandleColor: AppColors.purpleDeep,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppText.small.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: AppColors.purple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        dialBackgroundColor: AppColors.tile,
        hourMinuteColor: AppColors.tile,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}
