import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/category_apis.dart';
import '../../../services/fetch_api/remote_service.dart';
import '../../../services/local_db/hive/locals_box.dart';
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
    List<String>? pricing,
    List<String>? auth,
    List<String>? apiType,
    List<String>? category,
    this.cors,
    this.https,
    this.alive,
    this.maxResponseTime,
    this.sortBy = 'name',
    this.sortOrder = 'asc',
  })  : pricing = List<String>.from(pricing ?? const []),
        auth = List<String>.from(auth ?? const []),
        apiType = List<String>.from(apiType ?? const []),
        category = List<String>.from(category ?? const []);

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
  final List<ApiItem> apis;
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
  final RxList<ApiItem> searchResults = <ApiItem>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalResults = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxBool hasMore = false.obs;
  final RxnString activeQuickFilter = RxnString();
  final RxString searchToken = ''.obs;

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

  bool get canSearch {
    final q = searchTextController.text.trim();
    final f = filters.value;
    return q.isNotEmpty ||
        f.pricing.isNotEmpty ||
        f.auth.isNotEmpty ||
        f.apiType.isNotEmpty ||
        f.category.isNotEmpty ||
        f.cors != null ||
        f.https != null ||
        f.alive != null ||
        f.maxResponseTime != null;
  }

  Future<void> saveToken(String token) async {
    try {
      await LocalsDB.instance.putWithKey('searchToken', token);
      searchToken.value = token;
      AppSnackbar.show(title: 'Saved', message: 'Search token saved');
    } catch (e) {
      AppSnackbar.show(
        title: 'Save Error',
        message: 'Could not save token',
        isError: true,
      );
    }
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
      final categories = await response.toCategories();
      availableCategories.value = categories.map((c) => c.name).toList();
    } catch (e) {
      // Silently fail
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> performSearch({bool reset = true}) async {
    // Prevent empty searches: require query text or any filter
    if (!canSearch) {
      return;
    }
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
        q: requestParams['q'] as String?,
        pricing: (requestParams['pricing'] as List<String>?),
        auth: (requestParams['auth'] as List<String>?),
        apiType: (requestParams['apiType'] as List<String>?),
        category: (requestParams['category'] as List<String>?),
        cors: requestParams['cors'] as String?,
        https: requestParams['https'] as bool?,
        alive: requestParams['alive'] as bool?,
        maxResponseTime: requestParams['maxResponseTime'] as int?,
        sortBy: requestParams['sortBy'] as String? ?? 'name',
        sortOrder: requestParams['sortOrder'] as String? ?? 'asc',
        page: requestParams['page'] as int? ?? currentPage.value,
        limit: requestParams['limit'] as int? ?? limit,
      );

      if (response.success) {
        final apis = response.data;
        if (reset) {
          searchResults.value = apis;
        } else {
          searchResults.addAll(apis);
        }

        // Keep ordering consistent with current local sort
        applyLocalSort();

        totalResults.value = response.pagination.total;
        totalPages.value = response.pagination.totalPages;
        hasMore.value = response.pagination.hasMore;
      } else {
        throw Exception(response.message ?? 'Search failed');
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

  void applyLocalSort() {
    final by = filters.value.sortBy;
    final order = filters.value.sortOrder;

    final list = List<ApiItem>.from(searchResults);
    int mod = order.toLowerCase() == 'desc' ? -1 : 1;

    list.sort((a, b) {
      int cmp;
      switch (by) {
        case 'category':
          cmp = a.category.toLowerCase().compareTo(b.category.toLowerCase());
          break;
        case 'responseTime':
          cmp = a.responseTime.compareTo(b.responseTime);
          break;
        case 'name':
        default:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return cmp * mod;
    });

    searchResults.value = list;
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
      'q': filters.value.query,
      'pricing': filters.value.pricing.isNotEmpty
          ? List<String>.from(filters.value.pricing)
          : null,
      'auth': filters.value.auth.isNotEmpty
          ? List<String>.from(filters.value.auth)
          : null,
      'apiType': filters.value.apiType.isNotEmpty
          ? List<String>.from(filters.value.apiType)
          : null,
      'category': filters.value.category.isNotEmpty
          ? List<String>.from(filters.value.category)
          : null,
      'cors': filters.value.cors,
      'https':
          filters.value.https == null ? null : (filters.value.https == 'true'),
      'alive':
          filters.value.alive == null ? null : (filters.value.alive == 'true'),
      'maxResponseTime': filters.value.maxResponseTime,
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
