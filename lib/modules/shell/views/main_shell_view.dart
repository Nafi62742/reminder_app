import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../profile/views/profile_view.dart';
import '../../reminders/views/reminders_view.dart';
import '../../schedule/views/customize_schedule_view.dart';
import '../../schedule/views/schedule_view.dart';
import '../controllers/main_shell_controller.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Crucial for letting lists scroll behind the glassy bottom bar
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: const [
          RemindersView(),
          ScheduleView(),
          CustomizeScheduleView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Obx(
              () => NavigationBar(
                backgroundColor: colorScheme.surface.withValues(alpha: isDark ? 0.70 : 0.78),
                elevation: 0,
                selectedIndex: controller.currentIndex.value,
                onDestinationSelected: controller.changeTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.checklist_outlined),
                    selectedIcon: Icon(Icons.checklist),
                    label: 'Reminders',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.wb_sunny_outlined),
                    selectedIcon: Icon(Icons.wb_sunny),
                    label: 'Schedule',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.edit_note_outlined),
                    selectedIcon: Icon(Icons.edit_note),
                    label: 'Customize',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
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
