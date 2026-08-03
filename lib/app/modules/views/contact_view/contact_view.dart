import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/config/env.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'CONTACT',
          style: AppTextStyles.labelSmUpper,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.surfaceVariant,
          ),
        ),
      ),
      body: ListView(
        children: [
          _ContactTile(
            label: 'WEBSITE',
            value: Uri.parse(Env.developerWebsiteUrl).host,
            icon: PhosphorIconsRegular.globeHemisphereWest,
            onTap: () => _launchUrl(
              context,
              Uri.parse(Env.developerWebsiteUrl),
            ),
          ),
          Container(
            height: 1,
            color: AppColors.surfaceVariant,
          ),
          _ContactTile(
            label: 'EMAIL',
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
          title: 'Opened',
          message:
              uri.scheme == 'mailto' ? 'Email app opened' : 'Website opened',
          type: AppSnackbarType.success,
        );
      } else if (context.mounted) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: 'Unavailable',
          message: 'Could not open ${uri.toString()}',
          type: AppSnackbarType.error,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: 'Unavailable',
          message: 'Could not open ${uri.toString()}',
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
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: AppTextStyles.labelSmUpper.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        value,
        style: AppTextStyles.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing:
          const Icon(PhosphorIconsRegular.caretRight, color: AppColors.outline),
      onTap: onTap,
    );
  }
}
