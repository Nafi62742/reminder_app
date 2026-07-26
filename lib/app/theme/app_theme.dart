import 'package:flutter/material.dart';

import '../../core/constants/theme_forest.dart';
import '../../core/constants/theme_midnight.dart';
import '../../core/constants/theme_ocean.dart';
import '../../core/constants/theme_sunset.dart';

/// One selectable theme: an identity (id/label) plus the seed color and
/// brightness that [AppTheme] turns into a full [ThemeData].
class ThemeOption {
  const ThemeOption({
    required this.id,
    required this.label,
    required this.seedColor,
    required this.brightness,
  });

  final String id;
  final String label;
  final Color seedColor;
  final Brightness brightness;

  ThemeData get data => AppTheme._build(
        ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness),
      );
}

class AppTheme {
  AppTheme._();

  static const List<ThemeOption> themes = [
    ThemeOption(
      id: OceanTheme.id,
      label: OceanTheme.label,
      seedColor: OceanTheme.seedColor,
      brightness: OceanTheme.brightness,
    ),
    ThemeOption(
      id: SunsetTheme.id,
      label: SunsetTheme.label,
      seedColor: SunsetTheme.seedColor,
      brightness: SunsetTheme.brightness,
    ),
    ThemeOption(
      id: ForestTheme.id,
      label: ForestTheme.label,
      seedColor: ForestTheme.seedColor,
      brightness: ForestTheme.brightness,
    ),
    ThemeOption(
      id: MidnightTheme.id,
      label: MidnightTheme.label,
      seedColor: MidnightTheme.seedColor,
      brightness: MidnightTheme.brightness,
    ),
  ];

  static const String defaultThemeId = OceanTheme.id;

  static ThemeOption optionFor(String id) {
    return themes.firstWhere((t) => t.id == id, orElse: () => themes.first);
  }

  static ThemeData dataFor(String id) => optionFor(id).data;

  static ThemeData _build(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surfaceContainerHigh,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        elevation: 2,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
