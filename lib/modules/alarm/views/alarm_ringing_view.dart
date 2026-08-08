import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/alarm_ringing_controller.dart';

class AlarmRingingView extends GetView<AlarmRingingController> {
  const AlarmRingingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Deep Midnight/Gradient Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF020617), // Slate 950
                ],
              ),
            ),
          ),
          
          // 2. Glowing Accent Background Orbs
          Positioned(
            top: size.height * 0.15,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.25,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.shrink(),
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Title / Subtitle
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.alarm_on_rounded,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ALARM RINGING',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Center Clock with Pulsating Rings
                  Column(
                    children: [
                      _PulsatingRings(
                        color: colorScheme.primary,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.15),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Obx(
                            () => Text(
                              controller.currentTimeString.value.split(' ')[0], // Just HH:MM
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            controller.currentTimeString.value.split(' ').length > 1
                                ? controller.currentTimeString.value.split(' ')[1] // AM/PM
                                : '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Reminder Details Card
                  Obx(() {
                    final rem = controller.reminder.value;
                    final title = rem?.title ?? 'Reminder';
                    final description = rem?.description ?? 'Time to check your app';

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          if (rem?.description != null && rem!.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  // Snooze / Dismiss Button Actions
                  Column(
                    children: [
                      Row(
                        children: [
                          // Snooze Button
                          Expanded(
                            child: _GlowingButton(
                              label: 'SNOOZE',
                              subtitle: '5 minutes',
                              icon: Icons.snooze_rounded,
                              glowColor: Colors.amber,
                              onPressed: controller.snoozeAlarm,
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Dismiss Button
                          Expanded(
                            child: _GlowingButton(
                              label: 'DISMISS',
                              subtitle: 'Stop alarm',
                              icon: Icons.alarm_off_rounded,
                              glowColor: Colors.tealAccent[400]!,
                              onPressed: controller.dismissAlarm,
                              isPrimary: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsatingRings extends StatefulWidget {
  final Widget child;
  final Color color;

  const _PulsatingRings({
    required this.child,
    required this.color,
  });

  @override
  State<_PulsatingRings> createState() => _PulsatingRingsState();
}

class _PulsatingRingsState extends State<_PulsatingRings> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring
            Opacity(
              opacity: (1.0 - val) * 0.15,
              child: Container(
                width: 160 + (val * 120),
                height: 160 + (val * 120),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            // Inner Ring
            Opacity(
              opacity: (1.0 - val) * 0.35,
              child: Container(
                width: 160 + (val * 60),
                height: 160 + (val * 60),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color,
                    width: 3.5,
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _GlowingButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _GlowingButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  State<_GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<_GlowingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: widget.isPrimary 
              ? widget.glowColor.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: _isPressed 
                ? widget.glowColor 
                : widget.glowColor.withValues(alpha: widget.isPrimary ? 0.6 : 0.2),
            width: _isPressed ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withValues(alpha: _isPressed ? 0.3 : 0.08),
              blurRadius: _isPressed ? 24 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: widget.glowColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
