import 'category_apis.dart';

class SearchPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  SearchPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;

  factory SearchPagination.fromJson(Map<String, dynamic> json) {
    return SearchPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class SearchResponse {
  final int count;
  final SearchPagination pagination;
  final List<ApiItem> data;

  SearchResponse({
    required this.count,
    required this.pagination,
    required this.data,
  });

  bool get success => true;
  String? get message => null;
  bool get hasMore => pagination.hasMore;

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final List<ApiItem> items = <ApiItem>[];
    final rawData = json['data'];
    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          items.add(ApiItem.fromJson(item));
        }
      }
    }

    return SearchResponse(
      count: json['count'] ?? items.length,
      pagination: SearchPagination.fromJson(
        json['pagination'] ??
            {
              'page': json['page'] ?? 1,
              'limit': json['limit'] ?? 20,
              'total': json['total'] ?? items.length,
              'totalPages': json['totalPages'] ?? 1,
            },
      ),
      data: items,
    );
  }
}
