import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/snackbar_helper.dart';

class PrivacyController extends GetxController {
  // Privacy policy URL
  final String privacyPolicyUrl = 'https://gwhyyy.com/privacy';

  Future<String> privacyContent() async {
    await Future.delayed(const Duration(seconds: 1));
    String privacy =
        await rootBundle.loadString('assets/md_content/privacy.md');

    return privacy;
  }

  Future<void> navigateToPrivacyPage() async {
    try {
      final uri = Uri.parse(privacyPolicyUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to local markdown view if URL launch fails
        Get.toNamed("/privacy");
      }
    } catch (e) {
      AppSnackbar.show(
        title: 'Error',
        message: 'Unable to open privacy policy',
        isError: true,
      );
      // Fallback to local markdown view
      Get.toNamed("/privacy");
    }
  }
}
