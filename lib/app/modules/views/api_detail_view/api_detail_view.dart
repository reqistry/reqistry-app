import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/api_detail_controller/api_detail_controller.dart';
import 'package:public_apis_desktop_client/app/utils/snackbar_helper.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ApiDetailView extends GetView<ApiDetailController> {
  const ApiDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final api = controller.api;

    return Scaffold(
      appBar: AppBar(
        title: Text(api.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _showShareSheet(context),
            tooltip: 'Share API',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => launchUrlString(api.link),
            tooltip: 'Open in browser',
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              final domain = buildMainDomainUrl(api.link);
              if (domain != null) {
                launchUrlString(domain);
              } else {
                AppSnackbar.show(
                  title: 'Invalid link',
                  message: 'Could not extract main domain.',
                  isError: true,
                );
              }
            },
            tooltip: 'Open main domain',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner from metadata
            Obx(() {
              final banner = controller.metadata.value?.banner;
              if (banner != null) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onTertiaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          banner,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // API Status Card
            Obx(() {
              final ping = controller.pingResult.value;
              final isPinging = controller.isPinging.value;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'API Status',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (isPinging)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: controller.pingApi,
                              tooltip: 'Refresh status',
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (ping != null) ...[
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color:
                                    ping.isOnline ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (ping.isOnline
                                            ? Colors.green
                                            : Colors.red)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              ping.isOnline ? 'Online' : 'Offline',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    ping.isOnline ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        _StatusRow(
                          icon: Icons.timer_outlined,
                          label: 'Response Time',
                          value: '${ping.durationMs}ms',
                          valueColor: ping.durationMs < 500
                              ? Colors.green
                              : ping.durationMs < 1000
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                        if (ping.statusCode != null) ...[
                          const SizedBox(height: 8),
                          _StatusRow(
                            icon: Icons.code,
                            label: 'Status Code',
                            value: '${ping.statusCode}',
                            valueColor: (ping.statusCode! >= 200 &&
                                    ping.statusCode! < 300)
                                ? Colors.green
                                : (ping.statusCode! >= 300 &&
                                        ping.statusCode! < 400)
                                    ? Colors.blue
                                    : Colors.red,
                          ),
                        ],
                        if (ping.statusMessage != null) ...[
                          const SizedBox(height: 8),
                          _StatusRow(
                            icon: Icons.message_outlined,
                            label: 'Status',
                            value: ping.statusMessage!,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _StatusRow(
                          icon: Icons.access_time,
                          label: 'Checked',
                          value:
                              '${ping.timestamp.hour}:${ping.timestamp.minute.toString().padLeft(2, '0')}',
                        ),
                        if (ping.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: theme.colorScheme.onErrorContainer,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Error: ${ping.errorMessage}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        Center(
                          child: Text(
                            'Checking API status...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // API Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      api.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      api.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.link,
                      label: 'Endpoint',
                      value: api.link,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: api.link));
                        AppSnackbar.show(
                          title: 'Copied',
                          message: 'API link copied to clipboard',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: api.categoryId,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (api.https)
                          _FeatureChip(
                            icon: Icons.lock,
                            label: 'HTTPS',
                            color: Colors.green,
                          )
                        else
                          _FeatureChip(
                            icon: Icons.lock_open,
                            label: 'HTTP',
                            color: Colors.red,
                          ),
                        if (api.auth.isNotEmpty)
                          _FeatureChip(
                            icon: Icons.key,
                            label: 'Auth: ${api.auth}',
                            color: Colors.blue,
                          ),
                        if (api.cors)
                          _FeatureChip(
                            icon: Icons.public,
                            label: 'CORS',
                            color: Colors.purple,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metrics
            _MetricCard(
              title: 'Reliability',
              value: controller.reliabilityScore,
              color: theme.colorScheme.primary,
              subtitle: api.alive == true
                  ? 'Alive reported by source'
                  : 'Unknown uptime, estimated score',
            ),
            const SizedBox(height: 12),
            _MetricCard(
              title: 'Security',
              value: controller.securityScore.clamp(0.0, 1.0),
              color: theme.colorScheme.secondary,
              subtitle: api.https
                  ? 'HTTPS enabled with ${api.auth.isNotEmpty ? 'auth' : 'open access'}'
                  : 'Non-HTTPS endpoint',
            ),
            const SizedBox(height: 12),
            _MetricCard(
              title: 'Openness',
              value: controller.opennessScore.clamp(0.0, 1.0),
              color: theme.colorScheme.tertiary,
              subtitle: api.cors ? 'CORS supported' : 'CORS not reported',
            ),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    final noteController = TextEditingController();
    bool includeAppAttribution = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(
            bottom: media.viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.share_outlined),
                      const SizedBox(width: 8),
                      Text(
                        'Share this API',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Optional note',
                      hintText: 'Add context for your team...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include app attribution'),
                    subtitle:
                        const Text('Add app name and link to the share text'),
                    value: includeAppAttribution,
                    onChanged: (value) {
                      setState(() {
                        includeAppAttribution = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        controller.shareApi(
                          note: noteController.text.trim().isEmpty
                              ? null
                              : noteController.text.trim(),
                          includeAppAttribution: includeAppAttribution,
                        );
                        Get.back();
                      },
                      icon: const Icon(Icons.ios_share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final double value;
  final String subtitle;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('${(value * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

String? buildMainDomainUrl(String link) {
  final trimmed = link.trim();
  Uri? parsed = Uri.tryParse(trimmed);

  if (parsed == null) return null;

  if (parsed.scheme.isEmpty) {
    parsed = Uri.tryParse('https://$trimmed');
  }

  final host = parsed?.host ?? '';
  if (host.isEmpty) return null;

  final scheme =
      (parsed?.scheme.isNotEmpty ?? false) ? parsed!.scheme : 'https';
  final port = (parsed?.hasPort ?? false) ? ':${parsed!.port}' : '';
  return '$scheme://$host$port';
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.copy,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
