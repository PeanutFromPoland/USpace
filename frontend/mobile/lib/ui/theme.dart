import 'package:flutter/material.dart';

import '../domain/models.dart';

ThemeData kindSpotTheme(DemoProfile profile) {
  final seed = switch (profile.theme) {
    'orange' => const Color(0xFFF5B98F),
    'pink' => const Color(0xFFF1B6CA),
    'blue' => const Color(0xFFA7CBEF),
    _ => const Color(0xFFADD8B4),
  };
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: profile.darkMode ? Brightness.dark : Brightness.light,
    contrastLevel: profile.highContrast ? 1 : 0,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.14,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: scheme.onSurface),
      bodyMedium: TextStyle(fontSize: 16, height: 1.5, color: scheme.onSurface),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}

// Compatibility for existing module tests.
ThemeData uspaceTheme(DemoProfile profile) => kindSpotTheme(profile);
