import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/config/env.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.settingsContactTitle,
          style: AppTextStyles.labelSmUpper,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: c.surfaceVariant,
          ),
        ),
      ),
      body: ListView(
        children: [
          _ContactTile(
            label: AppLocalizations.of(context)!.settingsWebsite,
            value: Uri.parse(Env.developerWebsiteUrl).host,
            icon: PhosphorIconsRegular.globeHemisphereWest,
            onTap: () => _launchUrl(
              context,
              Uri.parse(Env.developerWebsiteUrl),
            ),
          ),
          Container(
            height: 1,
            color: c.surfaceVariant,
          ),
          _ContactTile(
            label: AppLocalizations.of(context)!.settingsEmail,
            value: Env.contactEmail,
            icon: PhosphorIconsRegular.envelopeSimple,
            onTap: () => _launchUrl(
              context,
              Uri(scheme: 'mailto', path: Env.contactEmail),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, Uri uri) async {
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched && context.mounted) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: AppLocalizations.of(context)!.snackbarOpenedTitle,
          message:
              uri.scheme == 'mailto' ? AppLocalizations.of(context)!.snackbarEmailAppOpened : AppLocalizations.of(context)!.snackbarWebsiteOpened,
          type: AppSnackbarType.success,
        );
      } else if (context.mounted) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: AppLocalizations.of(context)!.snackbarUnavailableTitle,
          message: AppLocalizations.of(context)!.snackbarCouldNotOpenUrl(uri.toString()),
          type: AppSnackbarType.error,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: AppLocalizations.of(context)!.snackbarUnavailableTitle,
          message: AppLocalizations.of(context)!.snackbarCouldNotOpenUrl(uri.toString()),
          type: AppSnackbarType.error,
        );
      }
    }
  }
}

class _ContactTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _ContactTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return ListTile(
      leading: Icon(icon, color: c.primary),
      title: Text(
        label,
        style: AppTextStyles.labelSmUpper.copyWith(
          color: c.onSurface,
        ),
      ),
      subtitle: Text(
        value,
        style: AppTextStyles.bodyMd.copyWith(
          color: c.onSurfaceVariant,
        ),
      ),
      trailing:
          Icon(PhosphorIconsRegular.caretRight, color: c.outline),
      onTap: onTap,
    );
  }
}
