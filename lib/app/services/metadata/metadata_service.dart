import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class ApiMetadata {
  final String? favicon;
  final String? description;
  final String? banner;
  final String? title;

  ApiMetadata({
    this.favicon,
    this.description,
    this.banner,
    this.title,
  });
}

class MetadataService {
  static final MetadataService _instance = MetadataService._internal();
  final Map<String, ApiMetadata> _cache = {};

  factory MetadataService() {
    return _instance;
  }

  MetadataService._internal();

  /// Fetch and cache metadata for an API URL
  Future<ApiMetadata?> fetchMetadata(String url) async {
    // Check cache first
    if (_cache.containsKey(url)) {
      return _cache[url];
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final metadata = _parseMetadata(response.body, url);
        _cache[url] = metadata;
        return metadata;
      }
    } catch (e) {
      // Silently fail and return null for metadata fetch errors
      // This is expected for many APIs that may not have accessible HTML
    }

    return null;
  }

  /// Parse metadata from HTML
  ApiMetadata _parseMetadata(String htmlContent, String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final baseUrlStr = '${uri.scheme}://${uri.host}';

    final document = html_parser.parse(htmlContent);

    final favicon = _extractFavicon(document, baseUrlStr);
    final description = _extractDescription(document);
    final banner = _extractBanner(document);
    final title = _extractTitle(document);

    return ApiMetadata(
      favicon: favicon,
      description: description,
      banner: banner,
      title: title,
    );
  }

  /// Extract favicon URL from HTML
  String? _extractFavicon(dom.Document document, String baseUrl) {
    // Try to find icon in link tags with various rel attributes
    final linkElements = document.querySelectorAll('link');

    for (var link in linkElements) {
      final rel = link.attributes['rel']?.toLowerCase() ?? '';

      // Check for icon, shortcut icon, apple-touch-icon, etc.
      if (rel.contains('icon')) {
        var faviconUrl = link.attributes['href'];
        if (faviconUrl != null && faviconUrl.isNotEmpty) {
          return _makeAbsoluteUrl(faviconUrl, baseUrl);
        }
      }
    }

    // Default favicon path
    return '$baseUrl/favicon.ico';
  }

  /// Extract meta description from HTML
  String? _extractDescription(dom.Document document) {
    // Try meta name="description"
    var meta = document.querySelector('meta[name="description"]');
    if (meta != null) {
      return meta.attributes['content']?.trim();
    }

    // Try meta property="og:description"
    meta = document.querySelector('meta[property="og:description"]');
    if (meta != null) {
      return meta.attributes['content']?.trim();
    }

    // Try meta name="twitter:description"
    meta = document.querySelector('meta[name="twitter:description"]');
    if (meta != null) {
      return meta.attributes['content']?.trim();
    }

    return null;
  }

  /// Extract banner/alert info from HTML
  String? _extractBanner(dom.Document document) {
    // Try meta tags first (custom announcements, status)
    final metaSelectors = [
      'meta[name="announcement"]',
      'meta[name="status"]',
      'meta[name="notice"]',
      'meta[property="og:site_name"]',
    ];

    for (var selector in metaSelectors) {
      final meta = document.querySelector(selector);
      if (meta != null) {
        final content = meta.attributes['content']?.trim();
        if (content != null && content.isNotEmpty) {
          return content;
        }
      }
    }

    // Look for common banner/alert elements and extract text
    final bannerSelectors = [
      '.banner',
      '.alert',
      '.notice',
      '.notification',
      '[role="banner"]',
      '[role="alert"]',
    ];

    for (var selector in bannerSelectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        final text = element.text.trim();
        if (text.isNotEmpty && text.length < 100) {
          return text;
        }
        return 'Featured';
      }
    }

    return null;
  }

  /// Extract page title from HTML
  String? _extractTitle(dom.Document document) {
    // Try title tag first
    final titleElement = document.querySelector('title');
    if (titleElement != null) {
      return titleElement.text.trim();
    }

    // Try og:title
    final ogTitle = document.querySelector('meta[property="og:title"]');
    if (ogTitle != null) {
      return ogTitle.attributes['content']?.trim();
    }

    return null;
  }

  /// Helper to make URL absolute
  String _makeAbsoluteUrl(String url, String baseUrl) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    } else if (url.startsWith('//')) {
      return 'https:$url';
    } else if (url.startsWith('/')) {
      return baseUrl + url;
    } else {
      return '$baseUrl/$url';
    }
  }

  /// Clear cache if needed
  void clearCache() {
    _cache.clear();
  }
}
