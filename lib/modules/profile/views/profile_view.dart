import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/theme/app_theme_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/tab_header.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Obx(() {
            final name = controller.nameController.text;
            final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
            return TabHeader(
              title: 'Profile & Progress',
              subtitle: name.isEmpty ? null : name,
              trailing: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            );
          }),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  title: 'Your Progress',
                  child: Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Today',
                            value:
                                '${controller.todayCount.value}/${controller.totalItems.value}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            label: 'This Week',
                            value: '${controller.weekCount.value}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            label: 'This Month',
                            value: '${controller.monthCount.value}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const _SectionCard(
                  title: 'Theme',
                  child: _ThemePicker(),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Your Profile',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: controller.nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.weightController,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                prefixIcon: Icon(Icons.monitor_weight_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: controller.heightController,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                                prefixIcon: Icon(Icons.height),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.saveProfile,
                        child: const Text('Save Profile'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => _SectionCard(
                    title: null,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline),
                      title: const Text(AppConstants.appName),
                      subtitle: Text('Version ${controller.appVersion.value}'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<AppThemeController>();
    return Obx(
      () => Wrap(
        spacing: 16,
        runSpacing: 12,
        children: AppTheme.themes.map((option) {
          final selected = themeController.selectedThemeId.value == option.id;
          return _ThemeSwatch(
            option: option,
            selected: selected,
            onTap: () => themeController.selectTheme(option.id),
          );
        }).toList(),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ThemeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: option.seedColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? colorScheme.primary : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: option.seedColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: selected ? const Icon(Icons.check, color: Colors.white) : null,
          ),
          const SizedBox(height: 6),
          Text(
            option.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
