import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/config/env.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sending = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending) return;
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _sending = true);
    try {
      final confirmation = await RemoteService.sendContactMessage(
        name: _nameController.text,
        email: _emailController.text,
        subject: _subjectController.text,
        message: _messageController.text,
        l10n: l10n,
      );
      if (!mounted) return;
      AppSnackbarManager.showSnackbar(
        context: context,
        title: l10n.snackbarContactSentTitle,
        message: confirmation,
        type: AppSnackbarType.success,
      );
      _formKey.currentState?.reset();
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
    } catch (e) {
      if (!mounted) return;
      AppSnackbarManager.showSnackbar(
        context: context,
        title: l10n.snackbarUnavailableTitle,
        message: l10n.snackbarContactFailedMessage,
        type: AppSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.settingsContactTitle,
          style: AppTextStyles.labelSmUpper,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: c.surfaceVariant,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.all(color: c.surfaceVariant, width: 1),
            ),
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.contactFormTitle,
                    style: AppTextStyles.labelSmUpper.copyWith(
                      color: c.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    l10n.contactFormSubtitle,
                    style: AppTextStyles.bodySm.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  _Field(
                    controller: _nameController,
                    label: l10n.formYourName.toUpperCase(),
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 200,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.formFieldRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _Field(
                    controller: _emailController,
                    label: l10n.formEmail,
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 300,
                    validator: (v) =>
                        v == null || !_emailPattern.hasMatch(v.trim())
                            ? l10n.formInvalidEmail
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _Field(
                    controller: _subjectController,
                    label: l10n.formSubject,
                    maxLength: 500,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _Field(
                    controller: _messageController,
                    label: l10n.formMessage,
                    maxLines: 5,
                    minLines: 4,
                    maxLength: 10000,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.formFieldRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _sending ? null : _submit,
                      icon: _sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(PhosphorIconsRegular.paperPlaneTilt,
                              size: 18),
                      label: Text(l10n.actionSubmit),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.all(color: c.surfaceVariant, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ContactTile(
                  label: AppLocalizations.of(context)!.settingsWebsite,
                  value: Uri.parse(Env.developerWebsiteUrl).host,
                  icon: PhosphorIconsRegular.globeHemisphereWest,
                  onTap: () => _launchUrl(
                    context,
                    Uri.parse(Env.developerWebsiteUrl),
                  ),
                ),
                Divider(height: 1, color: c.surfaceVariant),
                _ContactTile(
                  label: AppLocalizations.of(context)!.settingsEmail,
                  value: Env.contactEmail,
                  icon: PhosphorIconsRegular.envelopeSimple,
                  onTap: () => _launchUrl(
                    context,
                    Uri(scheme: 'mailto', path: Env.contactEmail),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, Uri uri) async {
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched && context.mounted) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: AppLocalizations.of(context)!.snackbarOpenedTitle,
          message:
              uri.scheme == 'mailto' ? AppLocalizations.of(context)!.snackbarEmailAppOpened : AppLocalizations.of(context)!.snackbarWebsiteOpened,
          type: AppSnackbarType.success,
        );
      } else if (context.mounted) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: AppLocalizations.of(context)!.snackbarUnavailableTitle,
          message: AppLocalizations.of(context)!.snackbarCouldNotOpenUrl(uri.toString()),
          type: AppSnackbarType.error,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: AppLocalizations.of(context)!.snackbarUnavailableTitle,
          message: AppLocalizations.of(context)!.snackbarCouldNotOpenUrl(uri.toString()),
          type: AppSnackbarType.error,
        );
      }
    }
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: AppTextStyles.bodyMd,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelSmUpper,
        floatingLabelStyle: AppTextStyles.labelSmUpper,
        counterStyle: AppTextStyles.labelSmUpper.copyWith(
          color: AppColors.of(Theme.of(context).brightness).onSurfaceVariant,
          fontSize: 10,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s12,
        ),
      ),
      validator: validator,
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _ContactTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return ListTile(
      leading: ExcludeSemantics(
        child: Icon(icon, color: c.primary),
      ),
      title: Text(
        label,
        style: AppTextStyles.labelSmUpper.copyWith(
          color: c.onSurface,
        ),
      ),
      subtitle: Text(
        value,
        style: AppTextStyles.bodyMd.copyWith(
          color: c.onSurfaceVariant,
        ),
      ),
      trailing: ExcludeSemantics(
        child: Icon(PhosphorIconsRegular.caretRight, color: c.outline),
      ),
      onTap: onTap,
    );
  }
}
