import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/shared/widgets/api/api_chip.dart';

class TypeBadge extends StatelessWidget {
  final String type;
  const TypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return ApiChip(
      label: type.toUpperCase(),
      bg: c.surfaceContainerHighest,
      fg: c.onSurface,
    );
  }
}
