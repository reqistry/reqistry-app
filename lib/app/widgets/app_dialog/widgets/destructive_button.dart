import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';

/// Red-outlined destructive action button, used in confirm dialogs.
class DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const DestructiveButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: c.danger,
        foregroundColor: c.onPrimary,
        side: BorderSide(color: c.danger, width: 1),
      ),
      child: Text(label),
    );
  }
}
