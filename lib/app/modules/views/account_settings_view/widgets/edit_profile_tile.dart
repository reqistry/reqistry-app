import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class EditProfileTile extends StatefulWidget {
  final String userName;
  final ValueChanged<String> onSave;

  const EditProfileTile({
    super.key,
    required this.userName,
    required this.onSave,
  });

  @override
  State<EditProfileTile> createState() => _EditProfileTileState();
}

class _EditProfileTileState extends State<EditProfileTile> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.zero,
        border: Border.fromBorderSide(BorderSide(color: c.outline)),
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISPLAY NAME',
            style: AppTextStyles.labelSmUpper.copyWith(
              color: c.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.chipGap),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
          const SizedBox(height: AppSpacing.s12),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () {
                  final name = _nameController.text.trim();
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (name.isNotEmpty) widget.onSave(name);
                },
                icon: const Icon(PhosphorIconsRegular.check, size: 18),
                label: const Text('SAVE'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(112, 42),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s10,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
