import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:public_apis_desktop_client/app/data/models/api.dart'
    as api_model;
import 'package:public_apis_desktop_client/app/services/metadata/metadata_service.dart';
import 'package:public_apis_desktop_client/app/services/share/share_plus/share_plus.dart';
import 'package:public_apis_desktop_client/app/utils/snackbar_helper.dart';

class ApiPingResult {
  final bool isOnline;
  final int? statusCode;
  final String? statusMessage;
  final int durationMs;
  final String? errorMessage;
  final Map<String, String>? headers;
  final DateTime timestamp;

  ApiPingResult({
    required this.isOnline,
    this.statusCode,
    this.statusMessage,
    required this.durationMs,
    this.errorMessage,
    this.headers,
    required this.timestamp,
  });
}

class ApiDetailController extends GetxController {
  late final api_model.Api api;
  final MetadataService _metadataService = MetadataService();
  static const String _appShareLink =
      'https://play.google.com/store/apps/details?id=com.gwhyyy.publicApis';
  static const String _appShareName = 'Public APIs Mobile';

  final Rx<ApiPingResult?> pingResult = Rx<ApiPingResult?>(null);
  final RxBool isPinging = false.obs;
  final Rx<ApiMetadata?> metadata = Rx<ApiMetadata?>(null);
  final RxBool isLoadingMetadata = false.obs;

  double get reliabilityScore => api.alive == true ? 0.9 : 0.65;
  double get securityScore =>
      (api.https ? 0.6 : 0.3) + (api.auth.isNotEmpty ? 0.25 : 0.05);
  double get opennessScore =>
      (api.cors ? 0.55 : 0.25) + (api.https ? 0.1 : 0.0);

  @override
  void onInit() {
    super.onInit();
    api = Get.arguments as api_model.Api;
    _fetchMetadata();
    pingApi();
  }

  Future<void> _fetchMetadata() async {
    isLoadingMetadata.value = true;
    try {
      final result = await _metadataService.fetchMetadata(api.link);
      metadata.value = result;
    } catch (e) {
      // Silently fail
    } finally {
      isLoadingMetadata.value = false;
    }
  }

  Future<void> pingApi() async {
    isPinging.value = true;
    final startTime = DateTime.now();

    try {
      final response = await http.head(
        Uri.parse(api.link),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (compatible; PublicAPIs/1.0; +https://api-client.app)'
        },
      ).timeout(const Duration(seconds: 10));

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      pingResult.value = ApiPingResult(
        isOnline: response.statusCode >= 200 && response.statusCode < 500,
        statusCode: response.statusCode,
        statusMessage: _getStatusMessage(response.statusCode),
        durationMs: duration,
        headers: response.headers,
        timestamp: endTime,
      );
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      pingResult.value = ApiPingResult(
        isOnline: false,
        durationMs: duration,
        errorMessage: e.toString(),
        timestamp: endTime,
      );
    } finally {
      isPinging.value = false;
    }
  }

  Future<void> shareApi({
    String? note,
    bool includeAppAttribution = true,
  }) async {
    final buffer = StringBuffer()
      ..writeln(api.name)
      ..writeln(api.description)
      ..writeln('Link: ${api.link}');

    if (note != null && note.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Note: ${note.trim()}');
    }

    if (includeAppAttribution) {
      buffer
        ..writeln()
        ..writeln('Shared via $_appShareName')
        ..writeln(_appShareLink);
    }

    try {
      await ShareService.instance.shareText(buffer.toString());
    } catch (_) {
      AppSnackbar.show(
        title: 'Share failed',
        message: 'Unable to share this API right now. Please try again.',
        isError: true,
      );
    }
  }

  String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 301:
        return 'Moved Permanently';
      case 302:
        return 'Found';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 429:
        return 'Too Many Requests';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      default:
        return 'Status $statusCode';
    }
  }
}
