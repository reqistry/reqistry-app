import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class FactRow extends StatelessWidget {
  const FactRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
