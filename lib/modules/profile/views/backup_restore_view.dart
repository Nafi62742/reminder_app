import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class BackupRestoreView extends GetView<ProfileController> {
  const BackupRestoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Informative Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Offline & Private',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your reminders and daily routines never touch the cloud. Exporting creates a secure backup file that you can save or move to another device.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Export Section
          const _SectionHeader(
            title: 'Export / Backup',
            subtitle: 'Save a snapshot of your reminders, routines, and stats',
            icon: Icons.upload_rounded,
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.download_rounded, color: colorScheme.primary),
                  ),
                  title: const Text(
                    'Export to File',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Save remindly_backup.json to phone storage'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: controller.exportBackupToFile,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.copy_all_rounded, color: colorScheme.primary),
                  ),
                  title: const Text(
                    'Export to Clipboard',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Copy backup JSON text to paste anywhere'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: controller.copyBackupToClipboard,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Import Section
          const _SectionHeader(
            title: 'Import / Restore',
            subtitle: 'Restore your saved data from a backup',
            icon: Icons.download_rounded,
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withValues(alpha: 0.12),
                    child: const Icon(Icons.upload_file_rounded, color: Colors.teal),
                  ),
                  title: const Text(
                    'Import from File',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Select a saved remindly_backup.json file'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: controller.importBackupFromFile,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withValues(alpha: 0.12),
                    child: const Icon(Icons.paste_rounded, color: Colors.teal),
                  ),
                  title: const Text(
                    'Import from Clipboard',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Restore from previously copied backup text'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: controller.restoreBackupFromClipboard,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
