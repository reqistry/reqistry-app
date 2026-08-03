import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/modules/views/apis_view/widgets/api_card.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

enum ApiCollectionKind { latest, recommended }

class ApiCollectionView extends StatefulWidget {
  final ApiCollectionKind kind;

  const ApiCollectionView({
    super.key,
    required this.kind,
  });

  @override
  State<ApiCollectionView> createState() => _ApiCollectionViewState();
}

class _ApiCollectionViewState extends State<ApiCollectionView> {
  late Future<List<ApiItem>> _future;

  String get _title => widget.kind == ApiCollectionKind.latest
      ? 'LATEST ADDED'
      : 'RECOMMENDED FOR YOU';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ApiItem>> _load() {
    return widget.kind == ApiCollectionKind.latest
        ? RemoteService.getRecentlyAddedApis(limit: 50)
        : RemoteService.getRecommendedApiItems(limit: 50);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_title, style: AppTextStyles.headlineSm),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ApiItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppLoading(message: 'Loading $_title', scrollable: true);
            }
            if (snapshot.hasError) {
              return AppErrorState(
                title: 'Could not load APIs',
                message: snapshot.error.toString(),
                onRetry: () => setState(() => _future = _load()),
                scrollable: true,
              );
            }
            final apis = snapshot.data ?? const <ApiItem>[];
            if (apis.isEmpty) {
              return const AppEmptyState(
                title: 'No APIs',
                message: 'Pull to refresh and try again.',
                icon: PhosphorIconsRegular.bracketsCurly,
                scrollable: true,
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: apis.length,
              itemBuilder: (context, index) {
                final api = apis[index];
                return ApiCard(
                  api: api,
                  category: api.category.isNotEmpty ? api.category : _title,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
