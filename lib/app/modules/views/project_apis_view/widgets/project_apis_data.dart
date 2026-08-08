import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/data/models/project_detail.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class ProjectApisData {
  final ProjectDetail detail;
  final ProjectMetadata metadata;

  const ProjectApisData({
    required this.detail,
    required this.metadata,
  });

  List<ApiItem> toApis({AppLocalizations? l10n}) {
    final previewByLink = {
      for (final item in metadata.preview) item.link: item,
    };
    final links = detail.apiLinks.isNotEmpty
        ? detail.apiLinks
        : detail.items.map((item) => item.link).toList();

    return links.map((link) {
      final preview = previewByLink[link];
      return ApiItem(
        id: preview?.apiId ?? '',
        name: preview?.name ?? Uri.tryParse(link)?.host ?? link,
        description: link,
        auth: l10n?.apiDetailUnknownValue ?? 'Unknown',
        https: link.toLowerCase().startsWith('https://') ? 'true' : 'false',
        cors: l10n?.apiDetailUnknownValue ?? 'Unknown',
        link: link,
        category: detail.title,
        apiType: 'REST',
        pricing: l10n?.apiDetailUnknownValue ?? 'Unknown',
        rateLimit: l10n?.apiDetailUnknownValue ?? 'Unknown',
        documentation: link,
        isAlive: preview?.isAlive ?? false,
        responseTime: 0,
        lastChecked: '',
      );
    }).toList();
  }
}
