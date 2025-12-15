import 'category_apis.dart';

class SearchPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  SearchPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory SearchPagination.fromJson(Map<String, dynamic> json) {
    return SearchPagination(
      page: (json['page'] ?? 1) is int
          ? json['page']
          : int.tryParse('${json['page']}') ?? 1,
      limit: (json['limit'] ?? 20) is int
          ? json['limit']
          : int.tryParse('${json['limit']}') ?? 20,
      total: (json['total'] ?? 0) is int
          ? json['total']
          : int.tryParse('${json['total']}') ?? 0,
      totalPages: (json['totalPages'] ?? 1) is int
          ? json['totalPages']
          : int.tryParse('${json['totalPages']}') ?? 1,
      hasMore: (json['hasMore'] ?? false) == true,
    );
  }
}

class SearchResponse {
  final bool success;
  final String? query;
  final Map<String, dynamic>? filters;
  final SearchPagination pagination;
  final List<ApiItem> data;
  final String? message;

  SearchResponse({
    required this.success,
    required this.pagination,
    required this.data,
    this.query,
    this.filters,
    this.message,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final List<ApiItem> items = <ApiItem>[];
    final rawData = json['data'];
    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          items.add(ApiItem(
            name: item['name'] ?? '',
            description: item['description'] ?? '',
            auth: item['auth'] ?? 'None',
            https: (item['https'] is bool)
                ? ((item['https'] as bool) ? 'true' : 'false')
                : (item['https']?.toString() ?? 'false'),
            cors: item['cors']?.toString() ?? 'Unknown',
            link: item['link'] ?? '',
            category: item['category'] ?? '',
            apiType: item['apiType'] ?? item['type'] ?? 'REST',
            pricing: item['pricing'] ?? 'Unknown',
            rateLimit: item['rateLimit'] ?? 'Unknown',
            documentation: item['documentation'] ?? '',
            isAlive: (item['isAlive'] is bool)
                ? (item['isAlive'] as bool)
                : (item['isAlive']?.toString().toLowerCase() == 'true'),
            responseTime: (item['responseTime'] is int)
                ? item['responseTime']
                : int.tryParse('${item['responseTime'] ?? 0}') ?? 0,
            statusCode: (item['statusCode'] is int)
                ? item['statusCode']
                : int.tryParse('${item['statusCode'] ?? ''}'),
            lastChecked: item['lastChecked'] ?? '',
          ));
        }
      }
    }

    return SearchResponse(
      success: json['success'] == true,
      query: json['query']?.toString(),
      filters: json['filters'] is Map<String, dynamic>
          ? (json['filters'] as Map<String, dynamic>)
          : null,
      pagination: SearchPagination.fromJson(
        (json['pagination'] as Map<String, dynamic>? ?? {}),
      ),
      data: items,
      message: json['message']?.toString(),
    );
  }
}
