import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/app_settings_controller/app_settings_controller.dart';
import 'package:public_apis_desktop_client/app/utils/colors/colors.dart';

class AppSettingsView extends GetView<AppSettingsController> {
  const AppSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.themeColors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(label: 'Appearance'),
          Obx(
            () => _ThemeColorCard(
              colors: palette,
              selectedColor: controller.selectedColor.value,
              onColorSelected: controller.setThemeColor,
              onOpenPicker: () => _openCustomColorPicker(context),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(label: 'Data Management'),
          _ActionCard(
            icon: Icons.bookmark_remove_outlined,
            title: 'Delete all bookmarks',
            subtitle: 'Remove every saved API from your device.',
            danger: true,
            onTap: () => _confirm(context,
                title: 'Delete all bookmarks',
                message:
                    'This will remove all saved APIs from your device. This cannot be undone.',
                onConfirm: controller.deleteAllBookmarks),
          ),
          _ActionCard(
            icon: Icons.ios_share_outlined,
            title: 'Export favorites',
            subtitle:
                'Export a list of your favorite APIs (name, description, link).',
            onTap: controller.exportFavorites,
          ),
          const SizedBox(height: 20),
          _SectionHeader(label: 'Account'),
          _ActionCard(
            icon: Icons.delete_forever_outlined,
            title: 'Delete my account',
            subtitle:
                'Remove your account and any associated cloud data. You may need to reauthenticate.',
            danger: true,
            onTap: () => _confirm(context,
                title: 'Delete account',
                message:
                    'Your account will be permanently deleted. This action cannot be undone. Continue?',
                onConfirm: controller.deleteAccount),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context,
      {required String title,
      required String message,
      required Future<void> Function() onConfirm}) async {
    final result = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;

    if (result) {
      await onConfirm();
    }
  }

  Future<void> _openCustomColorPicker(BuildContext context) async {
    Color pendingColor = controller.selectedColor.value;

    final picked = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose any color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: pendingColor,
            onColorChanged: (color) => pendingColor = color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(pendingColor),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (picked != null) {
      await controller.setThemeColor(picked);
    }
  }
}

class _ThemeColorCard extends StatelessWidget {
  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onOpenPicker;

  const _ThemeColorCard({
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
    required this.onOpenPicker,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme base color',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pick a base color to instantly restyle the app.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final color in colors)
                  _ColorChip(
                    color: color,
                    isSelected: color.value == selectedColor.value,
                    onTap: () => onColorSelected(color),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.palette_outlined),
                    label: const Text('Pick any color'),
                    onPressed: onOpenPicker,
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

class _ColorChip extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorChip({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: isSelected
              ? Border.all(color: theme.colorScheme.onPrimary, width: 2)
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: theme.colorScheme.onPrimary,
                size: 22,
              )
            : null,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: danger
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: danger
                ? theme.colorScheme.onErrorContainer
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: danger ? theme.colorScheme.error : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
