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

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 20),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: isDark ? 0.70 : 0.78),
            border: Border(
              bottom: BorderSide(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.08)
                    : colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
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
                            style: TextStyle(
                              color: colorScheme.onSurface,
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
                                color: colorScheme.onSurfaceVariant,
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
                      Theme(
                        data: theme.copyWith(
                          iconButtonTheme: IconButtonThemeData(
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                              foregroundColor: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        child: trailing!,
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
