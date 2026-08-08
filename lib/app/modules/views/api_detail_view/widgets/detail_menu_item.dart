import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';

class DetailMenuItem extends StatelessWidget {
  const DetailMenuItem({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.s12),
        Text(label),
      ],
    );
  }
}
