import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/submit_api_controller/submit_api_controller.dart';

class SubmitApiView extends GetView<SubmitApiController> {
  const SubmitApiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit a new API'),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _TipCard(),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.nameController,
                  label: 'API Name',
                  validator: _validateName,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.linkController,
                  label: 'API Link (https://...)',
                  keyboardType: TextInputType.url,
                  validator: _validateRequiredUrl,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.descriptionController,
                  label: 'Description (10+ chars)',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return 'Please enter at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.categoryController,
                  label: 'Category',
                  validator: _required,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.authController,
                  label: 'Auth (optional, e.g., API Key, OAuth)',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.pricingController,
                  label: 'Pricing (optional, e.g., Free, Freemium)',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => SwitchListTile.adaptive(
                          title: const Text('HTTPS supported'),
                          value: controller.httpsEnabled.value,
                          onChanged: (value) =>
                              controller.httpsEnabled.value = value,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _CorsSelector(controller: controller),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.documentationController,
                  label: 'Documentation URL (optional)',
                  keyboardType: TextInputType.url,
                  validator: _validateOptionalUrl,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.rateLimitController,
                  label: 'Rate limit (optional)',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.submitterNameController,
                  label: 'Your name (optional)',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.submitterEmailController,
                  label: 'Your email (optional)',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateOptionalEmail,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.notesController,
                  label: 'Notes (optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final isSubmitting = controller.isSubmitting.value;

                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isSubmitting ? null : controller.submit,
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_outlined),
                      label: Text(isSubmitting ? 'Submitting...' : 'Submit'),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateRequiredUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final parsed = Uri.tryParse(value.trim());
    final isValid = parsed != null && parsed.hasScheme && parsed.hasAuthority;
    if (!isValid ||
        !(parsed.scheme.toLowerCase() == 'https' ||
            parsed.scheme.toLowerCase() == 'http')) {
      return 'Enter a valid http(s) URL';
    }
    return null;
  }

  String? _validateOptionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = Uri.tryParse(value.trim());
    final isValid = parsed != null && parsed.hasScheme && parsed.hasAuthority;
    if (!isValid ||
        !(parsed.scheme.toLowerCase() == 'https' ||
            parsed.scheme.toLowerCase() == 'http')) {
      return 'Enter a valid http(s) URL';
    }
    return null;
  }

  String? _validateOptionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^\S+@\S+\.\S+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Please provide accurate details. Required fields: name, link, description, category.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CorsSelector extends StatelessWidget {
  final SubmitApiController controller;

  const _CorsSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    final options = ['Yes', 'No', 'Unknown'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CORS Support',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            children: options.map((value) {
              final selected = controller.corsValue.value == value;
              return ChoiceChip(
                label: Text(value),
                selected: selected,
                onSelected: (_) => controller.corsValue.value = value,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
