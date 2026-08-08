import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/shared/widgets/api/api_chip.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class HttpsBadge extends StatelessWidget {
  final bool isHttps;
  const HttpsBadge({super.key, required this.isHttps});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return ApiChip(
      label: isHttps ? AppLocalizations.of(context)!.apiDetailHttps : AppLocalizations.of(context)!.apiDetailHttp,
      bg: isHttps ? c.successBg : c.dangerBg,
      fg: isHttps ? c.successText : c.dangerText,
    );
  }
}
