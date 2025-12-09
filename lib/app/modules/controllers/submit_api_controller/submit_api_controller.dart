import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/services/fetch_api/remote_service.dart';
import 'package:public_apis_desktop_client/app/utils/snackbar_helper.dart';

class SubmitApiController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final linkController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final authController = TextEditingController();
  final pricingController = TextEditingController();
  final documentationController = TextEditingController();
  final rateLimitController = TextEditingController();
  final submitterEmailController = TextEditingController();
  final submitterNameController = TextEditingController();
  final notesController = TextEditingController();

  final RxBool httpsEnabled = true.obs;
  final RxString corsValue = 'Yes'.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    linkController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    authController.dispose();
    pricingController.dispose();
    documentationController.dispose();
    rateLimitController.dispose();
    submitterEmailController.dispose();
    submitterNameController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isSubmitting.value = true;

    try {
      await RemoteService.submitApi(
        name: nameController.text.trim(),
        link: linkController.text.trim(),
        description: descriptionController.text.trim(),
        category: categoryController.text.trim(),
        auth: authController.text.trim().isEmpty
            ? null
            : authController.text.trim(),
        https: httpsEnabled.value,
        cors: corsValue.value,
        pricing: pricingController.text.trim().isEmpty
            ? null
            : pricingController.text.trim(),
        documentation: documentationController.text.trim().isEmpty
            ? null
            : documentationController.text.trim(),
        rateLimit: rateLimitController.text.trim().isEmpty
            ? null
            : rateLimitController.text.trim(),
        submitterEmail: submitterEmailController.text.trim().isEmpty
            ? null
            : submitterEmailController.text.trim(),
        submitterName: submitterNameController.text.trim().isEmpty
            ? null
            : submitterNameController.text.trim(),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      // Show success after returning to the previous screen so the snackbar stays visible.
      Get.back(result: true);
      AppSnackbar.show(
        title: 'Submission received',
        message: 'Thank you! Your API was submitted for review.',
      );
    } catch (e) {
      AppSnackbar.show(
        title: 'Submission failed',
        message: 'Unable to submit right now. Please try again.',
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
