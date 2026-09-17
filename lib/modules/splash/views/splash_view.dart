import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';

/// Brief branded pause shown while the native launch screen hands off to
/// Flutter. Native Android launch screens can only show a static
/// image/color (no dynamic text), so this is the only way to show the app
/// name at startup — a simple placeholder until real branding exists.
class SplashView extends StatefulWidget {
  const SplashView({super.key, required this.nextRoute});

  final String nextRoute;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (Get.isRegistered<NotificationService>()) {
        final notifService = Get.find<NotificationService>();
        final reminderId = notifService.launchedReminderId;
        if (reminderId != null) {
          notifService.launchedReminderId = null;
          Get.offAllNamed(AppRoutes.main);
          Get.toNamed(AppRoutes.alarmRinging, arguments: reminderId);
          return;
        }
      }
      Get.offAllNamed(widget.nextRoute);
    });
  }

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

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              firstColor,
              secondColor,
            ],
          ),
        ),
        child: Center(
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.zero,
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.notifications_active_rounded,
                        size: 160,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your daily reminder companion',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
