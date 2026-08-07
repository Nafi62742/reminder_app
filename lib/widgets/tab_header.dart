import 'dart:ui';
import 'package:flutter/material.dart';

/// Shared rounded, glassmorphic header banner used at the top of each of the 4
/// main tabs — gives the app a consistent, premium look with a blurred background.
class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    final primaryHsl = HSLColor.fromColor(colorScheme.primary);
    final hue = primaryHsl.hue;

    Color firstColor;
    Color secondColor;

    if (isDark) {
      if (hue >= 190 && hue <= 250) {
        // Midnight Theme (Blue/Purple dark)
        firstColor = const Color(0xFF162A45);
        secondColor = colorScheme.primary;
      } else if (hue >= 80 && hue <= 140) {
        // Forest Theme (Dark mode green)
        firstColor = const Color(0xFF14331A);
        secondColor = colorScheme.primary;
      } else if (hue <= 35 || hue >= 340) {
        // Sunset Theme (Dark mode orange)
        firstColor = const Color(0xFF5D1105);
        secondColor = colorScheme.primary;
      } else {
        firstColor = colorScheme.primary;
        secondColor = primaryHsl.withLightness((primaryHsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
      }
    } else {
      if (hue >= 190 && hue <= 250) {
        // Ocean Theme (Blue light)
        firstColor = const Color(0xFF0D47A1);
        secondColor = colorScheme.primary;
      } else if (hue >= 80 && hue <= 140) {
        // Forest Theme (Green light)
        firstColor = const Color(0xFF1B5E20);
        secondColor = colorScheme.primary;
      } else if (hue <= 35 || hue >= 340) {
        // Sunset Theme (Orange/Red light)
        firstColor = const Color(0xFFBF360C);
        secondColor = colorScheme.primary;
      } else {
        firstColor = colorScheme.primary;
        secondColor = primaryHsl.withLightness((primaryHsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
      }
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                firstColor.withValues(alpha: isDark ? 0.85 : 0.92),
                secondColor.withValues(alpha: isDark ? 0.68 : 0.76),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: theme.copyWith(
                            iconButtonTheme: IconButtonThemeData(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          child: trailing!,
                        ),
                      ),
                    ],
                  ],
                ),
                if (bottom != null) ...[
                  const SizedBox(height: 16),
                  bottom!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
