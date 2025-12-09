import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/AllApis.dart' as legacy;
import '../../../services/fetch_api/remote_service.dart';
import '../../../utils/snackbar_helper.dart';

class SearchFilters {
  String? query;
  List<String> pricing;
  List<String> auth;
  List<String> apiType;
  List<String> category;
  String? cors;
  String? https;
  String? alive;
  int? maxResponseTime;
  String sortBy;
  String sortOrder;

  SearchFilters({
    this.query,
    this.pricing = const [],
    this.auth = const [],
    this.apiType = const [],
    this.category = const [],
    this.cors,
    this.https,
    this.alive,
    this.maxResponseTime,
    this.sortBy = 'name',
    this.sortOrder = 'asc',
  });

  bool get hasActiveFilters =>
      (query?.isNotEmpty ?? false) ||
      pricing.isNotEmpty ||
      auth.isNotEmpty ||
      apiType.isNotEmpty ||
      category.isNotEmpty ||
      cors != null ||
      https != null ||
      alive != null ||
      maxResponseTime != null;

  void reset() {
    query = null;
    pricing = [];
    auth = [];
    apiType = [];
    category = [];
    cors = null;
    https = null;
    alive = null;
    maxResponseTime = null;
    sortBy = 'name';
    sortOrder = 'asc';
  }
}

class SearchResult {
  final List<legacy.Api> apis;
  final int total;
  final int totalPages;
  final int currentPage;
  final bool hasMore;

  SearchResult({
    required this.apis,
    required this.total,
    required this.totalPages,
    required this.currentPage,
    required this.hasMore,
  });
}

class SearchApiController extends GetxController {
  final TextEditingController searchTextController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final filters = SearchFilters().obs;
  final RxList<legacy.Api> searchResults = <legacy.Api>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalResults = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxBool hasMore = false.obs;
  final RxnString activeQuickFilter = RxnString();

  // Debug request capture
  final RxString lastRequestDebug = ''.obs;

  // Available filter options
  final RxList<String> availableCategories = <String>[].obs;
  final RxBool isLoadingCategories = false.obs;

  final int limit = 20;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasMore.value) {
        loadMoreResults();
      }
    }
  }

  Future<void> _loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final response = await RemoteService.getCategories();
      final categories = response.toCategories();
      availableCategories.value = categories.map((c) => c.name).toList();
    } catch (e) {
      // Silently fail
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> performSearch({bool reset = true}) async {
    if (reset) {
      currentPage.value = 1;
      searchResults.clear();
    }

    isSearching.value = true;
    errorMessage.value = '';

    try {
      filters.value.query = searchTextController.text.isNotEmpty
          ? searchTextController.text
          : null;

      final requestParams = _buildRequestParams();
      if (kDebugMode) {
        lastRequestDebug.value =
            const JsonEncoder.withIndent('  ').convert(requestParams);
      } else {
        lastRequestDebug.value = '';
      }

      final response = await RemoteService.searchApis(
        query: requestParams['query'] as String?,
        pricing: requestParams['pricing'] as String?,
        auth: requestParams['auth'] as String?,
        apiType: requestParams['apiType'] as String?,
        category: requestParams['category'] as String?,
        cors: requestParams['cors'] as String?,
        https: requestParams['https'] as String?,
        alive: requestParams['alive'] as String?,
        maxResponseTime: requestParams['maxResponseTime'] as String?,
        sortBy: requestParams['sortBy'] as String?,
        sortOrder: requestParams['sortOrder'] as String?,
        page: requestParams['page'] as int? ?? currentPage.value,
        limit: requestParams['limit'] as int? ?? limit,
      );

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>;
        final pagination = response['pagination'] as Map<String, dynamic>;

        final apis = data.map((item) {
          return legacy.Api(
            name: item['name'] ?? '',
            description: item['description'] ?? '',
            auth: item['auth'] ?? 'no',
            https: item['https']?.toString() ?? 'false',
            cors: item['cors']?.toString() ?? 'unknown',
            link: item['link'] ?? '',
          );
        }).toList();

        if (reset) {
          searchResults.value = apis;
        } else {
          searchResults.addAll(apis);
        }

        totalResults.value = pagination['total'] ?? 0;
        totalPages.value = pagination['totalPages'] ?? 1;
        hasMore.value = pagination['hasMore'] ?? false;
      } else {
        throw Exception(response['message'] ?? 'Search failed');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      AppSnackbar.show(
        title: 'Search Error',
        message: errorMessage.value,
        isError: true,
      );
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> loadMoreResults() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    try {
      await performSearch(reset: false);
    } catch (e) {
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void toggleFilter<T>(List<T> list, T value) {
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
    filters.refresh();
  }

  void resetFilters() {
    searchTextController.clear();
    filters.value.reset();
    filters.refresh();
    searchResults.clear();
    currentPage.value = 1;
    totalResults.value = 0;
    errorMessage.value = '';
    activeQuickFilter.value = null;
    lastRequestDebug.value = '';
  }

  void quickFilter({
    String? preset,
  }) {
    resetFilters();

    switch (preset) {
      case 'free':
        filters.value.alive = 'true';
        activeQuickFilter.value = 'free';
        break;
      case 'no-auth':
        filters.value.auth = ['none'];
        filters.value.alive = 'true';
        activeQuickFilter.value = 'no-auth';
        break;
      case 'fast':
        filters.value.maxResponseTime = 500;
        filters.value.alive = 'true';
        filters.value.sortBy = 'responseTime';
        filters.value.sortOrder = 'asc';
        activeQuickFilter.value = 'fast';
        break;
      case 'secure':
        filters.value.https = 'true';
        filters.value.alive = 'true';
        activeQuickFilter.value = 'secure';
        break;
      case 'cors':
        filters.value.cors = 'yes';
        filters.value.https = 'true';
        filters.value.alive = 'true';
        activeQuickFilter.value = 'cors';
        break;
      default:
        activeQuickFilter.value = null;
    }

    filters.refresh();
  }

  Map<String, dynamic> _buildRequestParams() {
    return {
      'query': filters.value.query,
      'pricing': filters.value.pricing.isNotEmpty
          ? filters.value.pricing.join(',')
          : null,
      'auth':
          filters.value.auth.isNotEmpty ? filters.value.auth.join(',') : null,
      'apiType': filters.value.apiType.isNotEmpty
          ? filters.value.apiType.join(',')
          : null,
      'category': filters.value.category.isNotEmpty
          ? filters.value.category.join(',')
          : null,
      'cors': filters.value.cors,
      'https': filters.value.https,
      'alive': filters.value.alive,
      'maxResponseTime': filters.value.maxResponseTime?.toString(),
      'sortBy': filters.value.sortBy,
      'sortOrder': filters.value.sortOrder,
      'page': currentPage.value,
      'limit': limit,
    };
  }

  @override
  void onClose() {
    // searchTextController.dispose();
    // scrollController.dispose();
    super.onClose();
  }
}
