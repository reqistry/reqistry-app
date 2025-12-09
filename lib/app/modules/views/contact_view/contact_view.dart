import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:public_apis_desktop_client/app/utils/snackbar_helper.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
      ),
      body: ListView(
        children: [
          _ContactTile(
            label: 'Website',
            value: 'gwhyyy.com',
            icon: Icons.public,
            onTap: () => _launchUrl(Uri.parse('https://gwhyyy.com')),
          ),
          const Divider(height: 1),
          _ContactTile(
            label: 'Email',
            value: 'work@gwhyyy.com',
            icon: Icons.mail_outline,
            onTap: () =>
                _launchUrl(Uri(scheme: 'mailto', path: 'work@gwhyyy.com')),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(Uri uri) async {
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppSnackbar.show(
          title: 'Unavailable',
          message: 'Could not open ${uri.toString()}',
          isError: true,
        );
      }
    } catch (_) {
      AppSnackbar.show(
        title: 'Unavailable',
        message: 'Could not open ${uri.toString()}',
        isError: true,
      );
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
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
