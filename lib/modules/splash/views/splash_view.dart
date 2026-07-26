import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';

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
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) Get.offAllNamed(widget.nextRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Text(
          AppConstants.appName,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
