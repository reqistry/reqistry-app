import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Regression: ads appear only on approved surfaces. Banner slots live on
// browse/tab roots (category list, explore, intelligence, saved) plus the
// change feed page; home and settings stay ad-free. Native cards only in
// API result lists (search, category, saved, latest/recommended
// collections); change feed event tiles and home previews stay organic.
const _bannerAllowlist = {
  'lib/app/modules/views/category_apis_view/category_apis_view.dart',
  'lib/app/modules/views/discover_view.dart',
  'lib/app/modules/views/intelligence_view/intelligence_view.dart',
  'lib/app/modules/views/favorites_view/favorites_view.dart',
  'lib/app/modules/views/change_feed_view/change_feed_view.dart',
  'lib/shared/widgets/ads/ad_banner_slot.dart',
};

const _nativeAllowlist = {
  'lib/app/modules/views/search_screen/widgets/search_results_list.dart',
  'lib/app/modules/views/category_apis_view/category_apis_view.dart',
  'lib/app/modules/views/favorites_view/favorites_view.dart',
  'lib/app/modules/views/api_collection_view/api_collection_view.dart',
  'lib/shared/widgets/ads/catalog_native_ad_card.dart',
};

List<String> _dartFiles(Directory dir) => dir
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'))
    .map((file) => file.path)
    .toList();

void main() {
  test('banner slot only on approved surfaces', () {
    for (final path in _dartFiles(Directory('lib'))) {
      final source = File(path).readAsStringSync();
      if (!source.contains('AdBannerSlot(')) continue;
      final relative =
          path.substring(path.indexOf('lib/')).replaceAll('\\', '/');
      expect(_bannerAllowlist, contains(relative),
          reason: 'AdBannerSlot used outside allowlist: $relative');
    }
  });

  test('native cards only in approved result lists', () {
    for (final path in _dartFiles(Directory('lib'))) {
      final source = File(path).readAsStringSync();
      if (!source.contains('CatalogNativeAdCard(')) continue;
      final relative =
          path.substring(path.indexOf('lib/')).replaceAll('\\', '/');
      expect(_nativeAllowlist, contains(relative),
          reason: 'CatalogNativeAdCard used outside allowlist: $relative');
    }
  });
}
