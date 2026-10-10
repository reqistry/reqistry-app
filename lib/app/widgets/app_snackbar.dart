import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_shadows.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

enum AppSnackbarType { success, error, inform, info }

class AppSnackbarPayload {
  final int id;
  final String title;
  final String message;
  final AppSnackbarType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool persistent;

  const AppSnackbarPayload({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    this.actionLabel,
    this.onAction,
    this.persistent = false,
  });
}

class AppSnackbar extends StatefulWidget {
  final String title;
  final String message;
  final AppSnackbarType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool persistent;
  final VoidCallback? onDismiss;

  const AppSnackbar({
    super.key,
    required this.title,
    required this.message,
    this.type = AppSnackbarType.inform,
    required this.duration,
    this.actionLabel,
    this.onAction,
    this.persistent = false,
    this.onDismiss,
  });

  @override
  State<AppSnackbar> createState() => _AppSnackbarState();
}

class _AppSnackbarState extends State<AppSnackbar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void dismiss() {
    if (_controller.status == AnimationStatus.reverse) return;
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  Color _bgColor(AppColorScheme c) {
    switch (widget.type) {
      case AppSnackbarType.success:
        return c.successBg;
      case AppSnackbarType.error:
        return c.dangerBg;
      case AppSnackbarType.inform:
      case AppSnackbarType.info:
        return c.infoBg;
    }
  }

  Color _iconColor(AppColorScheme c) {
    switch (widget.type) {
      case AppSnackbarType.success:
        return c.success;
      case AppSnackbarType.error:
        return c.danger;
      case AppSnackbarType.inform:
      case AppSnackbarType.info:
        return c.info;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AppSnackbarType.success:
        return PhosphorIconsRegular.checkCircle;
      case AppSnackbarType.error:
        return PhosphorIconsRegular.warningCircle;
      case AppSnackbarType.inform:
      case AppSnackbarType.info:
        return PhosphorIconsRegular.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final iconColor = _iconColor(c);

    return Semantics(
      container: true,
      liveRegion: true,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
            confirmDismiss: (_) async {
              dismiss();
              return false;
            },
            child: Container(
              width: 380,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 32,
              ),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border.all(color: iconColor, width: 1),
                boxShadow: AppShadows.modal,
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          color: _bgColor(c),
                          child: Icon(_icon, color: iconColor, size: 16),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: c.onSurface,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s2),
                              Text(
                                widget.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: c.onSurfaceVariant,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        if (widget.actionLabel != null) ...[
                          TextButton(
                            onPressed: widget.onAction,
                            style: TextButton.styleFrom(
                              foregroundColor: iconColor,
                              minimumSize: const Size(48, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s8,
                              ),
                            ),
                            child: Text(
                              widget.actionLabel!,
                              style: AppTextStyles.labelSmUpper.copyWith(
                                color: iconColor,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s4),
                        ],
                        IconButton(
                          onPressed: dismiss,
                          tooltip: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                          constraints: const BoxConstraints.tightFor(
                            width: 48,
                            height: 48,
                          ),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            PhosphorIconsRegular.x,
                            size: 16,
                            color: c.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.persistent)
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        return ExcludeSemantics(
                          child: LinearProgressIndicator(
                            value: 1 - _progressController.value,
                            minHeight: 3,
                            backgroundColor: c.surfaceContainer,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(iconColor),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSnackbarManager {
  static final AppSnackbarManager _instance = AppSnackbarManager._();
  AppSnackbarManager._();
  factory AppSnackbarManager() => _instance;

  static final ValueNotifier<AppSnackbarPayload?> payload = ValueNotifier(null);
  static Timer? _dismissTimer;
  static int _nextId = 0;

  void show({
    required BuildContext context,
    required String title,
    required String message,
    AppSnackbarType type = AppSnackbarType.inform,
    Duration? duration,
    String overlayKey = 'global',
    String? actionLabel,
    VoidCallback? onAction,
    bool persistent = false,
  }) {
    _show(
      title: title,
      message: message,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      persistent: persistent,
    );
  }

  void dismiss({String overlayKey = 'global'}) {
    _dismiss();
  }

  static void showSnackbar({
    required BuildContext context,
    required String title,
    required String message,
    AppSnackbarType type = AppSnackbarType.inform,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    bool persistent = false,
  }) {
    AppSnackbarManager().show(
      context: context,
      title: title,
      message: message,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      persistent: persistent,
    );
  }

  static void showGlobal({
    required String title,
    required String message,
    AppSnackbarType type = AppSnackbarType.inform,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    bool persistent = false,
  }) {
    _show(
      title: title,
      message: message,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      persistent: persistent,
    );
  }

  static void success({required String title, required String message}) {
    showGlobal(title: title, message: message, type: AppSnackbarType.success);
  }

  static void info({required String title, required String message}) {
    inform(title: title, message: message);
  }

  static void inform({required String title, required String message}) {
    showGlobal(title: title, message: message, type: AppSnackbarType.inform);
  }

  static void error({required String title, required String message}) {
    showGlobal(title: title, message: message, type: AppSnackbarType.error);
  }

  static void dismissGlobal() {
    _dismiss();
  }

  static void _show({
    required String title,
    required String message,
    required AppSnackbarType type,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    bool persistent = false,
  }) {
    _dismissTimer?.cancel();
    final hideAfter = duration ??
        (type == AppSnackbarType.error
            ? const Duration(seconds: 5)
            : const Duration(seconds: 3));
    payload.value = AppSnackbarPayload(
      id: _nextId++,
      title: title,
      message: message,
      type: type,
      duration: persistent ? const Duration(days: 1) : hideAfter,
      actionLabel: actionLabel,
      onAction: onAction,
      persistent: persistent,
    );
    if (!persistent) {
      _dismissTimer = Timer(hideAfter, _dismiss);
    }
  }

  static void _dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    payload.value = null;
  }
}
