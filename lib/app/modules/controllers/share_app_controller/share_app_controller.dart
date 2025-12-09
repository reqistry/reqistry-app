import 'dart:io';

import 'package:get/get.dart';

import '../../../services/share/share_plus/share_plus.dart';
import '../../../utils/snackbar_helper.dart';

class ShareAppController extends GetxController {
  final String appName = "Public APIs Mobile";
  final String shareAppText = "Check out this app: ";
  final String playStoreApp =
      "https://play.google.com/store/apps/details?id=com.gwhyyy.publicApis";
  final String appStoreApp = "https://apps.apple.com/app/id6502289191";
  final String fallbackAppLink =
      "https://play.google.com/store/apps/details?id=com.gwhyyy.publicApis";

  Future<void> shareApp() async {
    final linkToShare = _appLinkBasedOnPlatform();

    final shareText =
        '📱 $appName\n\nDiscover more than 1400+ free APIs to use with Public APIs Mobile. Browse, search, and manage APIs all in one place!\n\nDownload now:\n$linkToShare';

    try {
      await ShareService.instance.shareText(shareText);
      AppSnackbar.show(
        title: 'Share',
        message: 'App shared successfully',
      );
    } catch (e) {
      AppSnackbar.show(
        title: 'Share failed',
        message: 'Unable to share app',
        isError: true,
      );
    }
  }

  String _appLinkBasedOnPlatform() {
    if (Platform.isAndroid) {
      return playStoreApp;
    } else if (Platform.isIOS) {
      return appStoreApp.isNotEmpty ? appStoreApp : fallbackAppLink;
    } else {
      return fallbackAppLink;
    }
  }
}
